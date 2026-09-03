#!/bin/sh
# Single-command launcher (JARVIS-ready fork).
# Creates .venv on first run, installs deps, then runs the tool.
# The .venv stays in the repo directory, so re-runs skip the setup.
set -e
cd "$(dirname "$0")"
[ -d .venv ] || python3 -m venv .venv
. .venv/bin/activate
pip install --quiet --no-cache-dir . .
exec sherlock --help "$@"
