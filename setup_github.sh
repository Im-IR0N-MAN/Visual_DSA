#!/bin/bash

# --- Checks and Authentication for setup ---
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found. Please create one with your GH_TOKEN."
    exit 1
fi


GH_BIN="./.bin/gh.exe"

if [ ! -f "$GH_BIN" ]; then
    echo "Error: Local GitHub CLI not found at $GH_BIN."
    echo "Please download the zip release and place gh.exe in the .bin folder."
    exit 1
fi

if ! "$GH_BIN" auth status &> /dev/null; then
    echo "Error: Authentication failed. Please check your GH_TOKEN in the .env file."
    exit 1
fi

echo "Starting isolated GitHub Project Setup..."


# --- LABELS ---
echo "Configuring Labels..."

create_label() {
    name="$1"
    color="$2"
    desc="$3"
    
    "$GH_BIN" label edit "$name" --color "$color" --description "$desc" &>/dev/null || \
    "$GH_BIN" label create "$name" --color "$color" --description "$desc" &>/dev/null
    echo " - Processed label: $name"
}

# Delete default GitHub labels
"$GH_BIN" label delete "bug" --yes &>/dev/null
"$GH_BIN" label delete "enhancement" --yes &>/dev/null
"$GH_BIN" label delete "documentation" --yes &>/dev/null
"$GH_BIN" label delete "duplicate" --yes &>/dev/null
"$GH_BIN" label delete "good first issue" --yes &>/dev/null
"$GH_BIN" label delete "help wanted" --yes &>/dev/null
"$GH_BIN" label delete "invalid" --yes &>/dev/null
"$GH_BIN" label delete "question" --yes &>/dev/null
"$GH_BIN" label delete "wontfix" --yes &>/dev/null

# Create custom workflow labels
create_label "type: feature" "A2EEEF" "New functionality"
create_label "type: bug" "d73a4a" "Something is broken"
create_label "type: chore" "E4E669" "Maintenance, docker, config"
create_label "priority: critical" "B60205" "Must fix ASAP"
create_label "priority: high" "FF9F1C" "Needed for next release"
create_label "priority: low" "C2E0C6" "Nice to have"
create_label "status: blocked" "000000" "Waiting on other tasks"
create_label "area: frontend" "BFD4F2" "React/Next.js"
create_label "area: backend" "F4CBB2" "Django/DB"
create_label "complexity: small" "0E8A16" "Less than 2 hours work"
create_label "complexity: large" "5319E7" "More than 1 day work"


# --- MILESTONES ---
echo "Creating Milestones..."

"$GH_BIN" api repos/{owner}/{repo}/milestones -f title="v0.1: Skeleton MVP" -f description="Docker, Django Init, Auth, Hello World API" &>/dev/null
echo " - Created Milestone: v0.1: Skeleton MVP"

"$GH_BIN" api repos/{owner}/{repo}/milestones -f title="v0.2: Visualizer Core" -f description="Canvas, Nodes, Save to DB" &>/dev/null
echo " - Created Milestone: v0.2: Visualizer Core"

"$GH_BIN" api repos/{owner}/{repo}/milestones -f title="v0.3: Security & SaaS" -f description="User Accounts, 2-Device Limit, Payments" &>/dev/null
echo " - Created Milestone: v0.3: Security & SaaS"

# --- ISSUE TEMPLATES ---
echo "Creating Issue Templates..."

mkdir -p .github/ISSUE_TEMPLATE

# Feature Request Template
cat > .github/ISSUE_TEMPLATE/feature_request.md <<EOL
---
name: Feature Request
about: Suggest an idea for this project
title: "[FEAT] <Short Description>"
labels: 'type: feature'
assignees: ''
---

**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Acceptance Criteria**
- [ ] User can do X
- [ ] Database stores Y
- [ ] Test coverage added
EOL
echo " - Created: feature_request.md"

# Bug Report Template
cat > .github/ISSUE_TEMPLATE/bug_report.md <<EOL
---
name: Bug Report
about: Create a report to help us improve
title: "[BUG] <Short Description>"
labels: 'type: bug'
assignees: ''
---

**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
A clear description of what you expected to happen.
EOL
echo " - Created: bug_report.md"

echo "Setup complete. Check your GitHub repository."