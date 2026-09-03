#!/bin/sh
# JARVIS single-command launcher.
# Creates an isolated venv on first run and installs deps into it. A sha256
# stamp of pyproject.toml skips reinstall on later runs; PIP_CACHE_DIR (set by the
# JARVIS runner) keeps wheels so a rebuilt venv does not re-download.
set -eu

cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PYTHON_BIN=${PYTHON_BIN:-python3}
VENV_DIR=${VENV_DIR:-.venv}
STAMP_FILE="$VENV_DIR/.deps.sha256"

if [ ! -x "$VENV_DIR/bin/python" ]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

stamp="$("$VENV_DIR/bin/python" -c 'import hashlib; print(hashlib.sha256(open("pyproject.toml", "rb").read()).hexdigest())')"
if [ ! -f "$STAMP_FILE" ] || [ "$(cat "$STAMP_FILE")" != "$stamp" ]; then
  "$VENV_DIR/bin/python" -m pip install --disable-pip-version-check --quiet .
  printf '%s\n' "$stamp" > "$STAMP_FILE"
fi

exec "$VENV_DIR/bin/sherlock" --help "$@"
