#!/usr/bin/env bash
set -euo pipefail

# Applies SQL in a fixed order: Tables -> Functions -> StoredProcedures -> BAU/Pending,
# in filename order within each folder. See ../../.github/skills/postgres-sql-deployment.
#
# Modes:
#   docker (default)  local `docker compose` service
#   direct            local `psql` client -> real DB (CI); PG* env vars or --connection
# BAU tracking:
#   move-to-Executed  (local, single DB) archives each applied BAU script (default)
#   --journal         records applied BAU scripts in app.bau_script_log; skips already-applied

SERVICE="postgres"; SKIP_BAU=0; DATABASE=""; DB_USER=""
MODE="docker"; CONNECTION="${DATABASE_URL:-}"; JOURNAL=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICE="$2"; shift 2 ;;
    --database) DATABASE="$2"; shift 2 ;;
    --user) DB_USER="$2"; shift 2 ;;
    --skip-bau) SKIP_BAU=1; shift ;;
    --direct) MODE="direct"; shift ;;
    --connection) CONNECTION="$2"; MODE="direct"; shift 2 ;;
    --journal) JOURNAL=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$CONNECTION" ]] && MODE="direct"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATABASE_DIR="$(dirname "$SCRIPTS_DIR")"
ENV_FILE="$DATABASE_DIR/.env"; [[ -f "$ENV_FILE" ]] && { set -a; . "$ENV_FILE"; set +a; }
DATABASE="${DATABASE:-${POSTGRES_DB:-app}}"; DB_USER="${DB_USER:-${POSTGRES_USER:-app}}"

run_psql() {
  if [[ "$MODE" == "direct" ]]; then
    if [[ -n "$CONNECTION" ]]; then psql "$CONNECTION" -v ON_ERROR_STOP=1 "$@"
    else psql -v ON_ERROR_STOP=1 "$@"; fi
  else docker compose exec -T "$SERVICE" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DATABASE" "$@"; fi
}
apply_file() { echo "  -> $(basename "$1")"; if [[ "$MODE" == "direct" ]]; then run_psql -f "$1"; else run_psql < "$1"; fi; }
apply_folder() {
  local folder="$SCRIPTS_DIR/$1"; [[ -d "$folder" ]] || return 0
  shopt -s nullglob; local files=("$folder"/*.sql); shopt -u nullglob
  [[ ${#files[@]} -gt 0 ]] || { echo "$1 : (no scripts)"; return 0; }
  IFS=$'\n' files=($(sort <<<"${files[*]}")); unset IFS
  echo "$1 :"; for f in "${files[@]}"; do apply_file "$f"; done
}
ensure_journal() { run_psql -c "CREATE SCHEMA IF NOT EXISTS app; CREATE TABLE IF NOT EXISTS app.bau_script_log (script_name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());" >/dev/null; }
bau_applied() { [[ "$(run_psql -tAc "SELECT 1 FROM app.bau_script_log WHERE script_name = '$1';")" == "1" ]]; }
bau_record()  { run_psql -c "INSERT INTO app.bau_script_log (script_name) VALUES ('$1') ON CONFLICT DO NOTHING;" >/dev/null; }

cd "$DATABASE_DIR"
apply_folder "Tables"; apply_folder "Functions"; apply_folder "StoredProcedures"
if [[ "$SKIP_BAU" -eq 0 ]]; then
  PENDING="$SCRIPTS_DIR/BAU/Pending"; EXECUTED="$SCRIPTS_DIR/BAU/Executed"
  shopt -s nullglob; bau=("$PENDING"/*.sql); shopt -u nullglob
  if [[ ${#bau[@]} -gt 0 ]]; then
    IFS=$'\n' bau=($(sort <<<"${bau[*]}")); unset IFS
    echo "BAU/Pending :"; [[ "$JOURNAL" -eq 1 ]] && ensure_journal
    for f in "${bau[@]}"; do
      name="$(basename "$f")"
      if [[ "$JOURNAL" -eq 1 ]]; then
        if bau_applied "$name"; then echo "  -- $name (already applied, skipping)"; continue; fi
        apply_file "$f"; bau_record "$name"; echo "     journaled -> app.bau_script_log"
      else
        apply_file "$f"; mkdir -p "$EXECUTED"; mv "$f" "$EXECUTED/$(date +%Y%m%d)_$name"
        echo "     moved -> BAU/Executed/$(date +%Y%m%d)_$name"
      fi
    done
  else echo "BAU/Pending : (nothing to run)"; fi
fi
echo "Done."
