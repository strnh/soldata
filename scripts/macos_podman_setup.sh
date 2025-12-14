#!/usr/bin/env bash
set -euo pipefail

# macOS 向け: Podman + PostgreSQL を準備し、スキーマ/シードを適用する補助スクリプト
# 使い方:
#   chmod +x scripts/macos_podman_setup.sh
#   ./scripts/macos_podman_setup.sh

info(){ echo "[INFO] $*"; }
err(){ echo "[ERROR] $*" >&2; }

if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew が見つかりません。https://brew.sh/ を参照して Homebrew をインストールしてください。"
  exit 1
fi

if ! command -v podman >/dev/null 2>&1; then
  info "podman を Homebrew でインストールします..."
  brew install podman || { err "podman のインストールに失敗しました。手動でインストールしてください。"; exit 1; }
fi

info "Podman 初期化とマシンの準備を開始します。"
if ! podman machine list --format '{{.Name}}' 2>/dev/null | grep -q '^default$'; then
  info "podman machine を初期化します (default)。"
  podman machine init --cpus 2 --memory 4096 --disk-size 20000 || true
fi

info "podman machine を起動します。"
podman machine start

info "Podman デーモンが利用可能になるまで待機します..."
for i in $(seq 1 30); do
  if podman info >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

CONTAINER_NAME=soldata-postgres
IMAGE=docker.io/library/postgres:15

if podman ps --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  info "コンテナ '${CONTAINER_NAME}' は既に起動済みです。"
elif podman ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  info "既存コンテナ '${CONTAINER_NAME}' を起動します。"
  podman start "${CONTAINER_NAME}"
else
  info "Postgres コンテナを起動します (名前: ${CONTAINER_NAME})..."
  podman run -d \
    --name "${CONTAINER_NAME}" \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=soldata \
    -p 5432:5432 \
    ${IMAGE}
fi

info "Postgres が応答するまで待機します..."
for i in $(seq 1 120); do
  if podman exec "${CONTAINER_NAME}" pg_isready -U postgres >/dev/null 2>&1; then
    info "Postgres が利用可能です。"
    break
  fi
  sleep 1
done

if ! podman exec "${CONTAINER_NAME}" pg_isready -U postgres >/dev/null 2>&1; then
  err "Postgres が起動しませんでした。ログを確認してください: podman logs ${CONTAINER_NAME}"
  exit 1
fi

# スキーマ適用・シードの実行
if [ -x scripts/apply-schema.sh ]; then
  info "スキーマ適用スクリプトを実行します: scripts/apply-schema.sh"
  ./scripts/apply-schema.sh || { err "スキーマ適用に失敗しました。"; exit 1; }
else
  info "scripts/apply-schema.sh が見つかりません。手動でスキーマを適用してください。"
fi

if [ -x db/seed/seed.sh ]; then
  info "シードスクリプトを実行します: db/seed/seed.sh"
  ./db/seed/seed.sh || { err "シード実行に失敗しました。"; exit 1; }
else
  info "db/seed/seed.sh が見つかりません。必要に応じてシードを実行してください。"
fi

info "完了: PostgreSQL が起動しており、スキーマ/シード処理を試行しました。"
info "ローカル接続: host=localhost port=5432 user=postgres db=soldata password=postgres"
info "(必要なら 'chmod +x scripts/macos_podman_setup.sh' を実行してから実行してください)"

exit 0
