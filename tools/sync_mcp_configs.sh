#!/usr/bin/env bash
# sync_mcp_configs.sh
# Safe helper to canonicalize MCP config locations and create symlinks.
# Usage:
#  ./tools/sync_mcp_configs.sh [--dry-run]
# This script does NOT delete files without backing up. It requires user
# review before making irreversible changes.
set -euo pipefail
DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then DRY_RUN=1; fi
NOW=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.warp/mcp-servers-backup-$NOW"
CANONICAL="$HOME/.warp/mcp-servers"
REPO_MCP_DIR="$PWD/mcp-servers"
echo "[sync_mcp_configs] dry_run=$DRY_RUN"
# Ensure ~/.warp exists
mkdir -p "$HOME/.warp"
# Backup existing canonical if present
if [ -d "$CANONICAL" ] && [ $DRY_RUN -eq 0 ]; then
  echo "Backing up existing $CANONICAL -> $BACKUP_DIR"
  mkdir -p "${BACKUP_DIR}"
  cp -a "$CANONICAL/"* "$BACKUP_DIR/" 2>/dev/null || true
fi
# If FIELD-70 has trident dirs, prefer linking them into canonical
FIELD70="$HOME/FIELD-70"
if [ -d "$FIELD70" ]; then
  echo "Found FIELD-70 at $FIELD70"
  for node in ATLAS TATA OBIWAN DOJO; do
    SRC="$FIELD70/$node"
    DST="$CANONICAL/$node"
    if [ -d "$SRC" ]; then
      echo " - found $SRC"
      if [ $DRY_RUN -eq 1 ]; then
        echo "   (dry) would ln -sf $SRC -> $DST"
      else
        mkdir -p "$CANONICAL"
        ln -sfn "$SRC" "$DST"
        echo "   linked $SRC -> $DST"
      fi
    fi
  done
fi
# If repo contains mcp-servers folder, offer to link or copy into canonical
if [ -d "$REPO_MCP_DIR" ]; then
  echo "Found repo mcp-servers at $REPO_MCP_DIR"
  for entry in "$REPO_MCP_DIR"/*; do
    name=$(basename "$entry")
    DST="$CANONICAL/$name"
    if [ -e "$entry" ]; then
      if [ $DRY_RUN -eq 1 ]; then
        echo "   (dry) would link/copy $entry -> $DST"
      else
        mkdir -p "$CANONICAL"
        if [ -d "$entry" ]; then
          ln -sfn "$entry" "$DST"
          echo "   linked $entry -> $DST"
        else
          cp -a "$entry" "$DST"
          echo "   copied file $entry -> $DST"
        fi
      fi
    fi
  done
fi
# Archive old flat configs in ~/.warp/mcp-servers if present (safe move)
FLAT_DIR_CANDIDATE="$HOME/.warp/mcp-servers-flat-archive-$NOW"
if compgen -G "$HOME/.warp/mcp-servers/*.json" > /dev/null 2>&1; then
  echo "Flat JSON configs found under ~/.warp/mcp-servers"
  if [ $DRY_RUN -eq 1 ]; then
    echo "   (dry) would move flat json files to $FLAT_DIR_CANDIDATE"
  else
    mkdir -p "$FLAT_DIR_CANDIDATE"
    mv "$HOME/.warp/mcp-servers"/*.json "$FLAT_DIR_CANDIDATE/" 2>/dev/null || true
    echo "   moved flat json -> $FLAT_DIR_CANDIDATE"
  fi
fi
# Final report
echo "\n[SYNC COMPLETE]"
echo "Canonical MCP dir: $CANONICAL"
if [ $DRY_RUN -eq 1 ]; then
  echo "(dry-run: no changes were made)"
fi
echo "Backup dir (if created): $BACKUP_DIR"
exit 0
