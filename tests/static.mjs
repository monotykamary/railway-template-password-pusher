import { readFileSync } from "node:fs";
import assert from "node:assert/strict";

const dockerfile = readFileSync("Dockerfile", "utf8");
const railway = readFileSync("railway.toml", "utf8");
const readme = readFileSync("README.md", "utf8");
const templateReadme = readFileSync("TEMPLATE_README.md", "utf8");

assert.match(dockerfile, /pglombardo\/pwpush:2\.11\.0@sha256:[a-f0-9]{64}/);
assert.doesNotMatch(dockerfile, /:latest/);
assert.match(dockerfile, /HTTP_PORT=5100/);
assert.match(dockerfile, /PORT=3000/);
assert.match(dockerfile, /USER root/);
assert.match(dockerfile, /railway-entrypoint/);
assert.match(railway, /healthcheckPath = "\/up"/);
assert.match(railway, /healthcheckTimeout = 300/);
assert.match(readme, /\/opt\/PasswordPusher\/storage/);
assert.match(readme, /64 hexadecimal characters/);
assert.match(templateReadme, /version 2\.11\.0/i);
assert.doesNotMatch(`${dockerfile}\n${railway}\n${readme}\n${templateReadme}`, /PWPUSH_MASTER_KEY=[a-f0-9]{64}|SECRET_KEY_BASE=[A-Za-z0-9]{64,}/);

console.log("static template checks passed");
