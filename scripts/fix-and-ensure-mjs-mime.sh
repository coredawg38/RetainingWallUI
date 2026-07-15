#!/bin/bash
# Repair broken nginx site config from old .mjs sed deploys, then ensure
# .mjs is served as text/javascript (Chrome ES modules).
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

python3 - "$NGINX_CONF" <<'PY'
import pathlib, re, sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
original = text

# Remove .mjs location blocks that appear BEFORE the first server { }
m = re.search(r"(?m)^\s*server\s*\{", text)
if not m:
    raise SystemExit(f"no server block found in {path}")

head, tail = text[: m.start()], text[m.start() :]
head, n = re.subn(
    r"(?ms)^[ \t]*(?:#.*\n)*[ \t]*location\s+~\*\s+\\\.mjs\$\s*\{.*?^[ \t]*\}\s*\n?",
    "",
    head,
)
text = head + tail

if text != original:
    path.write_text(text, encoding="utf-8")
    print(f"[mjs] removed {n} orphaned top-level .mjs location block(s)")
else:
    print("[mjs] no orphaned top-level .mjs location blocks")
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
