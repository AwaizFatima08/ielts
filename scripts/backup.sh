#!/usr/bin/env bash
#
# backup.sh — three-layer backup for English Language Test Simulator
#
#   Layer 1: local copy    -> /mnt/storage/project_backups/ielts_backup/
#   Layer 2: Google Drive  -> https://drive.google.com/drive/folders/1tafV7aZYAUs3KEHcEyS7wq8rrUneUQPK
#   Layer 3: GitHub        -> https://github.com/AwaizFatima08/ielts (PUBLIC repo)
#
# Run:  bash /mnt/storage/projects/ielts/scripts/backup.sh
#
# Layer 2 skips .git/: Drive throttles thousands of tiny object files, and
# GitHub plus Layer 1 already hold the history.
#
# Layers 1 and 2 will include .secrets/ (release keystore) once it exists, because both are
# private storage. Layer 3 is public, so .secrets/ is gitignored there.
#
# SKIP_GIT=1 runs Layers 1 and 2 only.
#
# Layer 3 refuses to push if it finds untracked files, so stray files
# (editor locks, temp output) never get swept into the public repo. Commit or
# gitignore them first, then rerun.

set -uo pipefail

PROJECT_DIR="/mnt/storage/projects/ielts"
LOCAL_BACKUP_ROOT="/mnt/storage/project_backups/ielts_backup"
GDRIVE_REMOTE="gdrive"
GDRIVE_FOLDER_ID="1tafV7aZYAUs3KEHcEyS7wq8rrUneUQPK"
GIT_REMOTE_URL="https://github.com/AwaizFatima08/ielts.git"
KEEP_LOCAL_BACKUPS=10

TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
LOG_FILE="$PROJECT_DIR/scripts/backup.log"
EXCLUDES="$PROJECT_DIR/scripts/backup_exclude.txt"

log(){ echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "=== Starting English Language Test Simulator backup: $TIMESTAMP ==="
cd "$PROJECT_DIR" || { log "FATAL: $PROJECT_DIR not found"; exit 1; }

# ---- Layer 1: local ----
log "Layer 1: local backup"
mkdir -p "$LOCAL_BACKUP_ROOT"
DEST="$LOCAL_BACKUP_ROOT/ielts_$TIMESTAMP"
if rsync -a --exclude 'scripts/backup.log' --exclude-from="$EXCLUDES" "$PROJECT_DIR/" "$DEST/"; then
  log "  OK — copied to $DEST"
else
  log "  ERROR — local rsync failed"
fi
( cd "$LOCAL_BACKUP_ROOT" && ls -1dt ielts_*/ 2>/dev/null | tail -n +$((KEEP_LOCAL_BACKUPS + 1)) | while read -r old; do
    log "  pruning old local backup: $old"; rm -rf "${old:?}"; done )

# ---- Layer 2: Google Drive ----
log "Layer 2: Google Drive backup"
if ! command -v rclone >/dev/null 2>&1 || ! rclone listremotes 2>/dev/null | grep -q "^${GDRIVE_REMOTE}:"; then
  log "  SKIPPED — rclone or the '$GDRIVE_REMOTE' remote is not configured"
elif rclone copy "$PROJECT_DIR" "${GDRIVE_REMOTE}:" \
    --drive-root-folder-id "$GDRIVE_FOLDER_ID" \
    --exclude "scripts/backup.log" --exclude ".git/**" --exclude-from "$EXCLUDES" \
    --update --checksum --log-file="$LOG_FILE" --log-level INFO; then
  log "  OK — synced to Google Drive folder ($GDRIVE_FOLDER_ID)"
else
  log "  ERROR — rclone sync failed (see log)"
fi

# ---- Layer 3: GitHub ----
log "Layer 3: GitHub push"
if [ "${SKIP_GIT:-0}" = "1" ]; then
  log "  SKIPPED — SKIP_GIT=1"
  log "=== Backup finished: $TIMESTAMP ==="
  exit 0
fi
git remote get-url origin >/dev/null 2>&1 || git remote add origin "$GIT_REMOTE_URL"
UNTRACKED="$(git ls-files --others --exclude-standard)"
if [ -n "$UNTRACKED" ]; then
  log "  SKIPPED — untracked files present; commit or gitignore them first:"
  echo "$UNTRACKED" | sed 's/^/      /' | tee -a "$LOG_FILE"
elif ! git diff --quiet || ! git diff --cached --quiet; then
  log "  SKIPPED — uncommitted changes present; commit them with a descriptive message first"
else
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if git push -u origin "$BRANCH" >>"$LOG_FILE" 2>&1; then
    log "  OK — pushed $BRANCH to $GIT_REMOTE_URL"
  else
    log "  ERROR — git push failed (check gh auth / network)"
  fi
fi

log "=== Backup finished: $TIMESTAMP ==="
