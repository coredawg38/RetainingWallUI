#!/bin/bash
# Repair broken nginx site config from old .mjs sed deploys, then ensure
# .mjs is served as text/javascript (Chrome ES modules).
#
# Fixes the common failure mode where GNU sed inserted literal "\n" characters
# instead of newlines, which left a top-level `location` and hid `server {`
# mid-line so nginx reported: location directive is not allowed here …:2
#
# Usage on EC2:
#   sudo bash fix-and-ensure-mjs-mime.sh
set -euo pipefail

NGINX_CONF="${NGINX_CONF:-/etc/nginx/sites-available/retainingwall}"
MIME_TYPES="${MIME_TYPES:-/etc/nginx/mime.types}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo -n bash "$0" "$@"
fi

echo "[mjs] repairing $NGINX_CONF if needed"
echo "[mjs] diagnostics:"
ls -la "$NGINX_CONF" || true
wc -l -c "$NGINX_CONF" || true
echo "----- first 25 lines -----"
head -n 25 "$NGINX_CONF" || true
echo "----- end head -----"

python3 - "$NGINX_CONF" <<'PY'
import pathlib, re, sys, shutil, datetime

path = pathlib.Path(sys.argv[1])
if not path.exists():
    raise SystemExit(f"missing config: {path}")

text = path.read_text(encoding="utf-8", errors="replace")
original = text

# Backup before mutating
stamp = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
backup = path.with_suffix(path.suffix + f".bak-{stamp}")
shutil.copy2(path, backup)
print(f"[mjs] backup: {backup}")

# 1) Turn literal backslash-n sequences from botched sed into real newlines
if "\\n" in text:
    text = text.replace("\\n", "\n")
    print("[mjs] converted literal \\n sequences into real newlines")

# 2) Remove EVERY location ~* \.mjs$ block (we'll rely on mime.types instead)
n_loc = 0
while True:
    new_text, count = re.subn(
        r"(?ms)^[ \t]*(?:#.*\n)*[ \t]*location\s+~\*\s+\\\.mjs\$\s*\{.*?^[ \t]*\}\s*\n?",
        "",
        text,
        count=1,
    )
    if count == 0:
        # Also catch mid-line / single-line forms after bad sed
        new_text, count = re.subn(
            r"(?s)\s*location\s+~\*\s+\\\.mjs\$\s*\{.*?\}",
            "\n",
            text,
            count=1,
        )
    if count == 0:
        break
    text = new_text
    n_loc += count
if n_loc:
    print(f"[mjs] removed {n_loc} .mjs location block(s)")
else:
    print("[mjs] no .mjs location blocks found to remove")

# 3) Verify a server block exists (anywhere, not only start-of-line after repair)
if not re.search(r"(?m)^\s*server\s*\{", text) and not re.search(r"\bserver\s*\{", text):
    # Try restoring from an existing backup beside the file
    candidates = sorted(path.parent.glob(path.name + ".bak*"), reverse=True)
    candidates += sorted(path.parent.glob("retainingwall*~"), reverse=True)
    restored = False
    for cand in candidates:
        try:
            cand_text = cand.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if re.search(r"\bserver\s*\{", cand_text):
            text = cand_text
            if "\\n" in text:
                text = text.replace("\\n", "\n")
            # Strip mjs locations from restored backup too
            text = re.sub(
                r"(?ms)^[ \t]*(?:#.*\n)*[ \t]*location\s+~\*\s+\\\.mjs\$\s*\{.*?^[ \t]*\}\s*\n?",
                "",
                text,
            )
            text = re.sub(r"(?s)\s*location\s+~\*\s+\\\.mjs\$\s*\{.*?\}", "\n", text)
            print(f"[mjs] restored server config from {cand}")
            restored = True
            break
    if not restored:
        print("[mjs] ERROR: no server { block found after repair.")
        print("[mjs] File may be irrecoverably corrupted.")
        print("[mjs] Re-run deploy/ec2/setup-certbot.sh on the server, or restore nginx config from backup.")
        print("----- file preview -----")
        print(text[:1500])
        raise SystemExit(2)

if text != original:
    path.write_text(text, encoding="utf-8")
    print(f"[mjs] wrote repaired config ({len(text)} bytes)")
else:
    print("[mjs] config unchanged after repair pass")

# Final sanity
if not re.search(r"(?m)^\s*server\s*\{", text):
    raise SystemExit("[mjs] ERROR: server { still not at line start after repair")
print("[mjs] server block(s) present")
PY

echo "[mjs] ensuring mime.types maps mjs"
if grep -qE '\bmjs\b' "$MIME_TYPES"; then
  echo "[mjs] mime.types already maps mjs"
else
  if grep -qE '^[[:space:]]*text/javascript[[:space:]]+' "$MIME_TYPES"; then
    sed -i -E 's|^([[:space:]]*text/javascript[[:space:]]+[^;]*\bjs)\b|\1 mjs|' "$MIME_TYPES"
  elif grep -qE '^[[:space:]]*application/javascript[[:space:]]+' "$MIME_TYPES"; then
    sed -i -E 's|^([[:space:]]*application/javascript[[:space:]]+[^;]*\bjs)\b|\1 mjs|' "$MIME_TYPES"
  else
    sed -i '/^}/i\    text/javascript                             js mjs;' "$MIME_TYPES"
  fi
  echo "[mjs] mime.types updated with mjs"
fi

nginx -t
systemctl reload nginx
echo "[mjs] nginx OK — .mjs should be text/javascript in Chrome"
