#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1"
}

handle_error() {
    log "ERROR: $1"
    exit 1
}

if [ ! -d ".git" ]; then
    handle_error "Current directory is not a git repository"
fi

log "Checking for repository updates..."

CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null) || handle_error "Failed to get current commit"

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null) || handle_error "Failed to get current branch"

log "Current branch: $CURRENT_BRANCH"
log "Current commit: $CURRENT_COMMIT"

log "Getting changes from remote repository..."
if ! git fetch origin 2>/dev/null; then
    log "Warning: Failed to get changes from remote repository"
    exit 0
fi

REMOTE_COMMIT=$(git rev-parse "origin/$CURRENT_BRANCH" 2>/dev/null) || {
    log "Warning: Remote branch origin/$CURRENT_BRANCH not found"
    exit 0
}

log "Remote commit: $REMOTE_COMMIT"

if [ "$CURRENT_COMMIT" != "$REMOTE_COMMIT" ]; then
    log "Changes detected in repository!"
    
    log "Information about commits:"
    git log --oneline -1 "$CURRENT_COMMIT" | sed 's/^/  Current: /'
    git log --oneline -1 "$REMOTE_COMMIT" | sed 's/^/  Remote: /'
    
    log "Updating local repository..."
    if ! git pull origin "$CURRENT_BRANCH"; then
        handle_error "Failed to update repository"
    fi
    
    log "Restarting services..."
    if ! ./restart.sh; then
        handle_error "Failed to restart services"
    fi
    
    log "Update completed successfully!"
else
    log "No changes detected"
fi
