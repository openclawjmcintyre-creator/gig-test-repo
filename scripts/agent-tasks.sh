#!/bin/bash
# Agent task operations - check queue, mark done, escalate
# Usage: agent-tasks.sh <command>

COMMAND="${1:-status}"

# Scripts live in main workspace, agents run in their own workspaces
MAIN_WORKSPACE="/root/.openclaw/workspace"
SCRIPT_DIR="$MAIN_WORKSPACE/scripts"

source "$MAIN_WORKSPACE/.env" 2>/dev/null

# Determine agent name from current workspace
AGENT_NAME="$(basename "$(pwd)" | sed 's/workspace-//')"
PLANE_URL="https://plane.errorlab.uk"
PLANE_PROJECT_ID="0af7fc96-beb4-4ca7-8a77-8f7d8aea6f5a"

# State IDs
STATE_WRITING="1c61024d-6a23-43f5-8d3f-f24d149100b3"
STATE_CODE="8dd7f72d-4d5a-447c-aa34-552927b2f432"
STATE_RESEARCH="6236f5b4-e648-4506-897b-7ae1e0fef53c"
STATE_REVIEW="dd6247cb-676f-4285-aa34-f47813b33774"
STATE_QA="9bf2e4b7-0f3f-477b-a573-4e64a71d30bb"
STATE_DONE="6c41c0f8-cb58-40c5-bdb0-4aafe588f02f"
STATE_BLOCKED="67692057-1701-4e2c-9c8c-08ecf0a1dbf"

# Get agent's Plane user ID from email mapping
get_agent_id() {
    case "$AGENT_NAME" in
        docs) echo "e5483788-15cc-4449-9caa-90fd953471f4" ;;
        infra) echo "608aab4b-8621-43f9-bd53-053f011bbe79" ;;
        hawk) echo "e9daa8f9-f55d-4369-a2aa-4afee76b4a98" ;;
        postie) echo "4b13ae4a-1a18-40ba-996a-d8491c5aa7df" ;;
        selfiestack|stack) echo "1ceac40c-0b74-4764-9cee-2400426e6b3b" ;;
        atlas) echo "a15d651a-889e-4cf0-a71b-08cf880b4799" ;;
        gig) echo "182efa12-b34e-4024-a0e4-452447bf4f0a" ;;
        media) echo "c6205b4f-2f35-46bf-8127-d61a80ef23cb" ;;
        personal) echo "c0510153-2198-4244-ab72-5f04dc3f23dc" ;;
        triage) echo "047706cc-511b-42ca-9ae9-6106afb7b06d" ;;
        *) echo "" ;;
    esac
}

AGENT_ID="$(get_agent_id)"

# Get my assigned tasks
my_tasks() {
    curl -s --connect-timeout 15 --max-time 60 \
        "${PLANE_URL}/api/v1/workspaces/openclaw/projects/${PLANE_PROJECT_ID}/issues/?per_page=200" \
        -H "X-API-Key: ${PLANE_API_KEY}" | python3 -c "
import sys, json
from datetime import datetime, timezone

d = json.load(sys.stdin)
agent_id = '$AGENT_ID'

state_map = {
    '$STATE_WRITING': 'Writing',
    '$STATE_CODE': 'Code',
    '$STATE_RESEARCH': 'Research',
    '$STATE_REVIEW': 'Review',
    '$STATE_QA': 'QA',
    '$STATE_BLOCKED': 'Blocked',
}

pending = []
for t in d.get('results', []):
    if t.get('state') in ['$STATE_DONE']:
        continue
    if agent_id not in t.get('assignees', []):
        continue

    state = t.get('state', '')
    state_name = state_map.get(state, state[:8])
    updated = t.get('updated_at', '')[:10] if t.get('updated_at') else '?'
    pending.append((t.get('sequence_id', '?'), t.get('name', '?')[:50], state_name, updated, t.get('id', '')))

print(f'[$AGENT_NAME] {len(pending)} pending tasks:')
for seq, name, state, updated, tid in sorted(pending, key=lambda x: x[2]):
    print(f'  OPS-{seq}: {name} [{state}] ({updated}) [id:{tid}]')
"
}

# Mark task done/next state
done_task() {
    local task_id="$1"
    local next_state="${2:-Review}"
    local comment="${3:-}"

    # Validate - must go through Review (not directly to Done)
    case "$next_state" in
        Review) target="$STATE_REVIEW" ;;
        QA) target="$STATE_QA" ;;
        Blocked) target="$STATE_BLOCKED" ;;
        Done) echo "✗ Cannot move directly to Done. Use 'Review' first, then Triage will promote."; return 1 ;;
        *) echo "Invalid state: $next_state (use: Review, QA, Blocked)"; return 1 ;;
    esac

    # Require a comment explaining what was done and where
    if [ -z "$comment" ]; then
        echo "✗ Comment required. Explain: what was done, where it was saved."
        echo "   Example: agent-tasks.sh done <id> Review 'Updated SKILL.md - added section on X. Saved to Outline.'"
        return 1
    fi

    if [ ${#comment} -lt 15 ]; then
        echo "✗ Comment too brief. Be specific: what was done, where it was saved."
        return 1
    fi

    # Update state
    response=$(curl -s --connect-timeout 15 --max-time 60 -X PATCH \
        "${PLANE_URL}/api/v1/workspaces/openclaw/projects/${PLANE_PROJECT_ID}/issues/${task_id}/" \
        -H "X-API-Key: ${PLANE_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg state "$target" '{state: $state}')")

    if echo "$response" | jq -e '.id' >/dev/null 2>&1; then
        echo "✓ Moved to $next_state"

        # Add comment with agent prefix
        curl -s --connect-timeout 15 --max-time 60 -X POST \
            "${PLANE_URL}/api/v1/workspaces/openclaw/projects/${PLANE_PROJECT_ID}/issues/${task_id}/comments/" \
            -H "X-API-Key: ${PLANE_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg c "[$AGENT_NAME] $comment" '{comment_content: $c}')" >/dev/null 2>&1
        echo "✓ Added comment"

        # If moved to Review, notify triage
        if [ "$next_state" = "Review" ]; then
            openclaw agent --agent triage --message "[$AGENT_NAME] moved task $task_id to Review. Please verify work and promote to QA." >/dev/null 2>&1
        fi
        return 0
    else
        echo "✗ Failed: $(echo "$response" | jq -r '.detail // .error // .' )"
        return 1
    fi
}

# Show help
help() {
    echo "Agent Tasks - $AGENT_NAME (ID: $AGENT_ID)"
    echo ""
    echo "Commands:"
    echo "  status              - Show my pending tasks"
    echo "  done <task_id> <state> <note>  - Move task (state required, note required)"
    echo "  block <task_id> <reason>       - Move task to Blocked"
    echo ""
    echo "States: Review, QA, Blocked"
    echo "        (Cannot move directly to Done - must go through Review)"
    echo ""
    echo "Note MUST include: what was done, where it was saved."
    echo ""
    echo "Examples:"
    echo "  agent-tasks.sh status"
    echo "  agent-tasks.sh done abc123-def456 Review 'Updated SKILL.md - added X section. Saved to Outline.'"
    echo "  agent-tasks.sh done abc123-def456 QA 'Passed all checks.'"
    echo "  agent-tasks.sh block abc123-def456 'Waiting on external API.'"
}

case "$COMMAND" in
    status|s) my_tasks ;;
    done|move) done_task "${2:-}" "${3:-}" "${4:-}" ;;
    block) done_task "${2:-}" "Blocked" "${3:-}" ;;
    help|h) help ;;
    *) help ;;
esac
