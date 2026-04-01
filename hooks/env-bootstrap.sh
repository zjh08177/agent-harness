#!/bin/bash
# PreToolUse hook for Bash — warn about missing environment setup

# Check Python venv
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
  if [ -z "$VIRTUAL_ENV" ] && [ -d ".venv" ]; then
    echo "WARNING: Python venv detected but not active. Run: source .venv/bin/activate"
  fi
fi

# Check Node modules
if [ -f "package.json" ] && [ ! -d "node_modules" ]; then
  echo "WARNING: package.json found but node_modules missing. Run: npm install"
fi
