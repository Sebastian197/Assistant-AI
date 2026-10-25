#!/usr/bin/env bash
# Prepares a Claude Code on the web session (claude.ai/code).
# Locally this script does nothing: Herd and Postgres.app already run the app.
# It runs on every session start and resume, so every step is idempotent.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/..}"

export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1

PHP_VERSION=8.5
PG_VERSION=16
APT_SOURCES=/etc/apt/ondrej-https.list
APT_KEYRING=/etc/apt/keyrings/ondrej-php.gpg
APT_READY=false

# The session image lists the Ubuntu mirrors over plain HTTP, which the
# egress proxy does not serve, so apt uses its own HTTPS sources list.
apt_options() {
  local options=(
    -o "Dir::Etc::sourcelist=${APT_SOURCES}"
    -o "Dir::Etc::sourceparts=-"
    -o "APT::Get::List-Cleanup=0"
  )

  if [ -n "${HTTPS_PROXY:-}" ]; then
    options+=(-o "Acquire::https::Proxy=${HTTPS_PROXY}")
  fi

  printf '%s\n' "${options[@]}"
}

apt_run() {
  local options
  mapfile -t options < <(apt_options)
  apt-get "${options[@]}" "$@"
}

prepare_apt() {
  if [ "$APT_READY" = true ]; then
    return
  fi

  mkdir -p "$(dirname "$APT_KEYRING")"
  gpg --batch --yes --dearmor --output "$APT_KEYRING" scripts/keys/ondrej-php.asc
  chmod 644 "$APT_KEYRING"

  cat > "$APT_SOURCES" <<EOF
deb https://archive.ubuntu.com/ubuntu noble main universe
deb https://archive.ubuntu.com/ubuntu noble-updates main universe
deb https://security.ubuntu.com/ubuntu noble-security main universe
deb [signed-by=${APT_KEYRING}] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main
EOF

  apt_run update -qq
  APT_READY=true
}

install_php() {
  if ! command -v "php${PHP_VERSION}" > /dev/null; then
    echo "==> Installing PHP ${PHP_VERSION}"
    prepare_apt
    apt_run install -y -qq --no-install-recommends \
      "php${PHP_VERSION}-cli" "php${PHP_VERSION}-common" "php${PHP_VERSION}-bcmath" \
      "php${PHP_VERSION}-curl" "php${PHP_VERSION}-gd" "php${PHP_VERSION}-igbinary" \
      "php${PHP_VERSION}-intl" "php${PHP_VERSION}-mbstring" "php${PHP_VERSION}-pgsql" \
      "php${PHP_VERSION}-readline" "php${PHP_VERSION}-redis" "php${PHP_VERSION}-sqlite3" \
      "php${PHP_VERSION}-xml" "php${PHP_VERSION}-zip"
  fi

  update-alternatives --quiet --set php "/usr/bin/php${PHP_VERSION}"
}

create_database() {
  local name="$1"

  if ! runuser -u postgres -- psql -tAc "SELECT 1 FROM pg_database WHERE datname = '${name}'" | grep -q 1; then
    runuser -u postgres -- createdb "$name"
  fi
}

install_postgres() {
  if [ ! -f "/usr/share/postgresql/${PG_VERSION}/extension/vector.control" ]; then
    echo "==> Installing pgvector"
    prepare_apt
    apt_run install -y -qq --no-install-recommends "postgresql-${PG_VERSION}-pgvector"
  fi

  if ! pg_lsclusters --no-header | grep -q "^${PG_VERSION} \+main .* online"; then
    pg_ctlcluster "$PG_VERSION" main start
  fi

  runuser -u postgres -- psql -qc "ALTER USER postgres PASSWORD 'postgres'"
  create_database assistant_ai
  create_database assistant_ai_testing
}

set_env() {
  local key="$1" value="$2"

  if grep -q "^${key}=" .env; then
    sed -i "s|^${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
}

configure_env() {
  if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate --no-interaction
  fi

  set_env DB_CONNECTION pgsql
  set_env DB_HOST 127.0.0.1
  set_env DB_PORT 5432
  set_env DB_DATABASE assistant_ai
  set_env DB_USERNAME postgres
  set_env DB_PASSWORD postgres
}

# The session NO_PROXY sends npm straight to the registry, which has no
# direct route out, so npm runs with those registries removed from it.
npm_no_proxy() {
  echo "${NO_PROXY:-}" | tr ',' '\n' | grep -v -e 'npmjs' -e 'jsr\.io' | paste -sd, -
}

install_php
install_postgres

composer install --no-interaction --prefer-dist --no-progress

configure_env
php artisan migrate --no-interaction --force

npm_proxy_exclusions="$(npm_no_proxy)"
NO_PROXY="$npm_proxy_exclusions" no_proxy="$npm_proxy_exclusions" npm ci --no-audit --no-fund
