#!/usr/bin/env python3
"""Password Pusher bootstrap/API durability smoke; never reseeds after boot.

Boat-only bootstrap reads the generated code from the exact service container
whose published loopback port matches BASE_URL. Live HTTPS callers supply
PWPUSH_BOOT_CODE if first-run setup is still required. No production HTTPS or
secure-cookie setting is changed, and redirects are not followed to HTTP.
"""
import hashlib, html, http.cookiejar, json, os, re, secrets, subprocess
from pathlib import Path
import urllib.error, urllib.parse, urllib.request
BASE=os.environ['BASE_URL'].rstrip('/');PHASE=os.environ['SMOKE_PHASE']
assert PHASE in ('boot','upgrade','redeploy'),'unknown phase'
url=urllib.parse.urlsplit(BASE)
local=url.scheme=='http' and url.hostname in ('127.0.0.1','localhost','::1')
assert url.scheme=='https' or local,'HTTP only supported for worker loopback'
state_path=Path(__file__).parent/('state-'+hashlib.sha256(BASE.encode()).hexdigest()[:16]+'.json')
if state_path.exists():state=json.loads(state_path.read_text())
else:
 assert PHASE=='boot','missing boot state; refusing to recreate data'
 state={'email':os.environ.get('PWPUSH_ADMIN_EMAIL','validation-'+secrets.token_hex(5)+'@example.invalid'),
        'password':os.environ.get('PWPUSH_ADMIN_PASSWORD',secrets.token_urlsafe(28)),
        'payload':'railway-durable-'+secrets.token_hex(16)}
 state_path.write_text(json.dumps(state));state_path.chmod(0o600)
if PHASE!='boot':assert state.get('url_token'),'missing boot-created push identity'
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,req,fp,code,msg,headers,newurl):return None
cookies=http.cookiejar.CookieJar()
opener=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookies),NoRedirect())
def request(method,path,body=None,expected=(200,),json_body=False,extra=None,authenticated=True):
 headers={'Accept':'application/json' if json_body else 'text/html'}
 if extra:headers.update(extra)
 if local and authenticated and list(cookies):headers['Cookie']='; '.join(c.name+'='+c.value for c in cookies)
 data=None
 if body is not None:
  headers['Content-Type']='application/json' if json_body else 'application/x-www-form-urlencoded'
  data=json.dumps(body).encode() if json_body else urllib.parse.urlencode(body).encode()
 req=urllib.request.Request(BASE+path,data=data,headers=headers,method=method)
 active=opener if authenticated else urllib.request.build_opener(NoRedirect())
 try:r=active.open(req,timeout=90)
 except urllib.error.HTTPError as e:r=e
 with r:code=r.code;text=r.read().decode();response_headers=r.headers
 assert code in expected,f'{method} {path} unexpected status {code}'
 return code,text,response_headers

def csrf(text):
 match=re.search(r'name="authenticity_token"[^>]*value="([^"]+)"',text)
 if not match:match=re.search(r'name="csrf-token"[^>]*content="([^"]+)"',text)
 assert match,'CSRF token missing'
 return html.unescape(match.group(1))

def boot_code():
 if os.environ.get('PWPUSH_BOOT_CODE'):return os.environ['PWPUSH_BOOT_CODE']
 assert local and os.environ.get('SUPERCOMPUTER_OUTPUT_DIR'),'live bootstrap needs PWPUSH_BOOT_CODE'
 ids=subprocess.check_output(['docker','ps','-q','--filter','label=com.docker.compose.service=password-pusher'],text=True,timeout=30).split()
 owned=[]
 for cid in ids:
  ports=json.loads(subprocess.check_output(['docker','inspect','--format','{{json .NetworkSettings.Ports}}',cid],text=True,timeout=30))
  if any(str(p.get('HostPort'))==str(url.port) and p.get('HostIp')=='127.0.0.1' for values in ports.values() for p in values or []):owned.append(cid)
 assert len(owned)==1,'cannot uniquely identify validation-owned Password Pusher container'
 value=subprocess.check_output(['docker','exec',owned[0],'cat','/opt/PasswordPusher/storage/first_run_boot_code.txt'],text=True,timeout=30).strip().split('|')[0]
 assert re.fullmatch('[0-9a-f]{32}',value),'unexpected boot code format'
 return value

assert 'background:green' in request('GET','/up')[1]
status,first,_=request('GET','/first_run',expected=(200,302,303))
if status==200 and 'user_boot_code' in first:
 assert PHASE=='boot','first-run setup reappeared after persistent state should exist'
 token=csrf(first)
 request('POST','/first_run',{'authenticity_token':token,'user[boot_code]':'invalid-validation-code','user[email]':state['email'],'user[password]':state['password'],'user[password_confirmation]':state['password']},expected=(422,))
 first=request('GET','/first_run')[1]
 request('POST','/first_run',{'authenticity_token':csrf(first),'user[boot_code]':boot_code(),'user[email]':state['email'],'user[password]':state['password'],'user[password_confirmation]':state['password']},expected=(302,303))
# Login with the same boot-created administrator each phase; a lost database
# cannot pass by simply creating another user.
login=request('GET','/users/sign_in',expected=(200,302,303))
if login[0]==200:
 request('POST','/users/sign_in',{'authenticity_token':csrf(login[1]),'user[email]':state['email'],'user[password]':state['password']},expected=(302,303))
home=request('GET','/')[1];token=csrf(home)
headers={'X-CSRF-Token':token}
if not state.get('url_token'):
 assert PHASE=='boot','refusing to create replacement push'
 payload={'push':{'payload':state['payload'],'name':'Railway durability proof','expire_after_days':7,'expire_after_views':100,'deletable_by_viewer':False,'retrieval_step':False}}
 result=json.loads(request('POST','/api/v2/pushes.json',payload,expected=(201,),json_body=True,extra=headers)[1])
 assert result.get('url_token'),'create push omitted url_token'
 state['url_token']=result['url_token'];state_path.write_text(json.dumps(state));state_path.chmod(0o600)
result=json.loads(request('GET','/api/v2/pushes/'+state['url_token']+'.json',json_body=True)[1])
assert result.get('payload')==state['payload'],'same encrypted push payload did not persist'
assert result.get('expired') is False,'durable push unexpectedly expired'
request('GET','/api/v2/pushes/not-a-valid-validation-token.json',expected=(404,),json_body=True)
request('GET','/api/v2/pushes/active.json',expected=(401,),json_body=True,extra={'Authorization':'Bearer invalid-validation-token'},authenticated=False)
print(json.dumps({'ok':True,'phase':PHASE,'durable_push_payload':True,'negative_paths':True,'bootstrap_only_at_boot':True,'reachability':'worker-local-http' if local else 'public-https'}))
