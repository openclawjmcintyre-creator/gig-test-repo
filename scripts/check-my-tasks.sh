#!/bin/bash
# Check pending Plane tasks assigned to this agent
# Uses API key from agent's own workspace .env
# Usage: check-my-tasks.sh <agent_user_id> [agent_name]

AGENT_ID="${1:-}"
AGENT_NAME="${2:-$(basename "$HOME" | sed 's/workspace-//')}"

if [ -z "$AGENT_ID" ]; then
    echo "Usage: $0 <plane_user_id> [agent_name]"
    exit 1
fi

# Load credentials from this agent's workspace (same dir as script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$WORKSPACE_DIR/.env" ]; then
    source "$WORKSPACE_DIR/.env"
elif [ -f "$HOME/.env" ]; then
    source "$HOME/.env"
fi

PLANE_URL="${PLANE_URL:-https://plane.errorlab.uk}"
PLANE_PROJECT_ID="${PLANE_PROJECT_ID:-0af7fc96-beb4-4ca7-8a77-8f7d8aea6f5a}"
STATE_DONE="6c41c0f8-cb58-40c5-bdb0-4aafe588f02f"

curl -s --connect-timeout 15 --max-time 60 \
    "${PLANE_URL}/api/v1/workspaces/openclaw/projects/${PLANE_PROJECT_ID}/issues/?per_page=200" \
    -H "X-API-Key: ${PLANE_API_KEY}" | python3 -c "
import sys, json
from datetime import datetime, timezone

d = json.load(sys.stdin)
agent_id = '$AGENT_ID'
done_state = '$STATE_DONE'

state_map = {
    'bf4a92a1-2110-42e1-be6d-a976fc1a299b': 'Inbox',
    '692c042b-6059-440f-871c-4b46fa7ddf6d': 'Ready',
    '08dcca02-1080-4d6c-88ee-f7a4e5abb8bc': 'In Progress',
    '1c61024d-6a23-43f5-8d3f-f24d149100b3': 'Writing',
    'dd6247cb-676f-4285-aa34-f47813b33774': 'Review',
    '8dd7f72d-4d5a-447c-aa34-552927b2f432': 'Code',
    '6236f5b4-e648-4506-897b-7ae1e0fef53c': 'Research',
    '9bf2e4b7-0f3f-477b-a573-4e64a71d30bb': 'QA-1',
}

pending = []
for t in d.get('results', []):
    if agent_id not in t.get('assignees', []):
        continue
    if t.get('state') == done_state:
        continue
    
    updated = t.get('updated_at', '')[:10] if t.get('updated_at') else 'no-date'
    state = t.get('state', '')
    state_name = state_map.get(state, state[:8])
    
    pending.append((t.get('sequence_id', '?'), t.get('name', '?')[:50], state_name, updated))

print(f'[$AGENT_NAME] {len(pending)} pending tasks:')
for seq, name, state, updated in sorted(pending, key=lambda x: x[2]):
    print(f'  {seq}: {name} [{state}] ({updated})')
"
