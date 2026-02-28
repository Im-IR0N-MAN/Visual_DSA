#!/bin/bash

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found."
    exit 1
fi

GH_BIN="./.bin/gh.exe"

if [ ! -f "$GH_BIN" ]; then
    echo "Error: Local GitHub CLI not found at $GH_BIN."
    exit 1
fi

echo "Creating issues for v0.1: Skeleton MVP..."

MILESTONE="v0.1: Skeleton MVP"

create_issue() {
    title="$1"
    body="$2"
    labels="$3"
    
    "$GH_BIN" issue create --title "$title" --body "$body" --label "$labels" --milestone "$MILESTONE" &>/dev/null
    echo " - Created issue: $title"
}

# --- ISSUE DEFINITIONS ---

# --- 1. DOCKER ---
create_issue \
    "Docker: Setup Compose and Dockerfiles" \
    "Create docker-compose.yml and custom Dockerfiles for the database, backend, and frontend for isolated local development." \
    "type: chore,priority: critical"

# --- 2. DJANGO INIT ---
create_issue \
    "Django Init: Create Project and Connect Postgres" \
    "Execute django-admin startproject inside the backend container and configure settings.py to connect to the Postgres container." \
    "type: chore,area: backend,priority: critical"

# --- 3. AUTH ---
create_issue \
    "Auth: Custom User Model" \
    "Implement an AbstractUser model using UUIDs. This must be completed before running the first database migration." \
    "type: feature,area: backend,priority: critical"

create_issue \
    "Auth: Google OAuth2 and 2-Device Limit" \
    "Configure django-allauth for Google sign-in. Write Django signals to track active sessions in Redis and block logins if active count >= 2." \
    "type: feature,area: backend,priority: high"

# --- 4. HELLO WORLD API ---
create_issue \
    "Hello World API: Protected Test Endpoint" \
    "Create a simple GET endpoint that requires a valid OAuth token. It should return user details to verify the entire stack is working." \
    "type: feature,area: backend,priority: high"

echo "Strict MVP issues created successfully."