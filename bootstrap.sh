#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
case "$(uname -s)" in
  Darwin) exec bash install/macos.sh ;;
  Linux)  exec bash install/linux.sh ;;
  *) echo "unsupported OS"; exit 1 ;;
esac
