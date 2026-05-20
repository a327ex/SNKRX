#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

if command -v love >/dev/null 2>&1; then
  exec love .
elif [ -x "/Applications/love.app/Contents/MacOS/love" ]; then
  exec /Applications/love.app/Contents/MacOS/love .
elif [ -x "engine/love/love.exe" ]; then
  exec engine/love/love.exe --console .
else
  echo "LÖVE runtime not found. Install it with: brew install --cask love" >&2
  exit 1
fi
