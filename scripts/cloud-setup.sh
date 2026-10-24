#!/usr/bin/env bash
# Prepares a Claude Code on the web session (claude.ai/code).
# Locally this script does nothing: Herd already serves the app.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/..}"

composer install --no-interaction --prefer-dist --no-progress

if [ ! -f .env ]; then
  cp .env.example .env
  php artisan key:generate --no-interaction
fi

touch database/database.sqlite
php artisan migrate --no-interaction --force

npm ci --no-audit --no-fund
