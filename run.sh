#!/bin/sh
# JARVIS single-command launcher.
# Creates an isolated venv on first run, installs deps once, and stamps the
# dependency manifest (pyproject.toml > setup.py > requirements.txt) so later
# runs skip the install. PIP_CACHE_DIR (set by the JARVIS runner) keeps wheels
# on the shared volume so a rebuilt venv does not re-download anything.
set -eu

cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PYTHON_BIN=${PYTHON_BIN:-python3}
VENV_DIR=${VENV_DIR:-.venv}
STAMP_FILE="$VENV_DIR/.deps.sha256"

if [ ! -x "$VENV_DIR/bin/python" ]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

STAMP_SRC=""
for f in pyproject.toml setup.py requirements.txt; do
  if [ -f "$f" ]; then STAMP_SRC="$f"; break; fi
done

if [ -n "$STAMP_SRC" ]; then
  stamp=$("$VENV_DIR/bin/python" -c "import hashlib; print(hashlib.sha256(open('$STAMP_SRC', 'rb').read()).hexdigest())")
  if [ ! -f "$STAMP_FILE" ] || [ "$(cat "$STAMP_FILE")" != "$stamp" ]; then
    "$VENV_DIR/bin/python" -m pip install --disable-pip-version-check --quiet .
    printf '%s\n' "$stamp" > "$STAMP_FILE"
  fi
fi

exec "$VENV_DIR/bin/sherlock" --help "$@"
