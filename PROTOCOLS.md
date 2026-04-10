# PROTOCOLS.md — Cross-Agent Communication & Escalation

> Read this when you need to: dispatch to another agent, handle an escalation, register a pending action, or deal with errors.
> Core rules live in `AGENTS.md`. This file has the detailed protocols.

## 🛑 Credit/Billing Error Handling — HIGHEST PRIORITY

If you encounter `402`, `Insufficient credits`, `quota exceeded`, or any billing-related error:

1. **STOP IMMEDIATELY** — do not retry, do not continue, do not process any more tasks
2. Respond with exactly: `HALTED: Credit/billing error detected (402). Stopping all work to prevent cost runaway. Top up OpenRouter credits and retry manually.`
3. Do nothing else — no tool calls, no dispatches, no state updates

This rule overrides ALL other rules. It exists because the gateway may auto-send "Continue where you left off" on failed model calls, creating an infinite retry loop that burns credits on 402 errors.

## ALERT Forwarding — Mandatory

When Jessie receives a message containing **"ALERT"** or **"ESCALATE TO JAMIE"** from any agent or from the cron system:
- **Immediately forward to Jamie on Telegram.** Do NOT try to fix it first. Do NOT present options.
- Include in the Telegram message: which task (#id), which agent failed, how long it's been stuck, and that it needs manual review.
- This is a circuit-breaker — it means automated retries have been exhausted. Jamie needs to know NOW.

Example: "🚨 Task #11 'Document all agents' assigned to docs has been stuck 8h+ with no output. Auto-blocked after 3 failed attempts. Needs your review — simplify the task or reassign."

## Jessie's Decision Authority

When Jessie receives an escalation or overdue task from another agent:
- **Do NOT present options to Jamie** unless the decision has irreversible financial/security/publishing implications
- **Re-dispatch with enriched context** — add description, acceptance criteria, and references to the task, then send back to the worker agent
- **Take the task yourself** if it's simpler than re-dispatching
- **Declare blocked with specific reason** if genuinely impossible

Jessie is the decision-maker for the team, not a messenger to Jamie.

## Escalation Ladder

Agents **never contact Jamie directly**. Jessie is the single escalation point.

```
Level 0: Agent handles autonomously (clear task, has the skills)
Level 1: Agent calls a specialist directly (Atlas, Gig, Hawk, etc.)
Level 2: Agent asks Jessie for clarification or help
Level 3: Jessie escalates to Jamie (via Telegram)
```

| Situation | Action | Level |
|-----------|--------|-------|
| Clear task, have skills | Do it, report DONE | 0 |
| Need research/code/review | Call specialist directly | 1 |
| Task vague but doable | Make reasonable assumptions, DO the work, document assumptions | 0 |
| Receiving an escalation from another agent | Make a decision and act — re-dispatch with enriched context, take it yourself, or declare blocked with specific reason. Do NOT present options to Jamie. | 2 |
| Blocked by external issue | Set "blocked" + reason, notify Jessie | 2 |
| Needs human decision (irreversible: financial, security, publishing) | Set "blocked" + "needs Jamie's input", notify Jessie | 2 |
| Jessie can't resolve | Jessie messages Jamie via Telegram | 3 |

## When Stuck — Decision Tree

Every agent should follow this when receiving a task:

1. **Can I do this with my skills?** → Do it → Report DONE
2. **Need a specialist?** → Dispatch directly:
   - Research → `openclaw agent --agent atlas --message "..."`
   - Code → `openclaw agent --agent gig --message "..."`
   - Review → `openclaw agent --agent hawk --message "..."`
3. **Task unclear but doable?** → Make reasonable assumptions and DO the work. Document assumptions in your output. A completed task with noted assumptions beats an unstarted task.
4. **Blocked by something external?** → Update state + notify Jessie:
   - Set `status: "blocked"` and `reason: "[description]"` in heartbeat-state.json
   - `openclaw agent --agent main --message "BLOCKED on task #[id]: [reason]"`
5. **Needs Jamie's decision (irreversible: financial, security, publishing)?** → Same as blocked, but specify:
   - `reason: "Needs Jamie's input — [what decision is needed]"`
   - Jessie decides whether/when to escalate to Jamie

**NEVER ask "what do you want me to do?" or present options (a/b/c).** Either do the task, do the task with assumptions, or declare blocked with a specific reason.

## Cross-Agent Dispatch

**Use `openclaw agent --agent <id> --message "..."` for all cross-agent communication.** This runs a real agent turn on the target agent's main session via the Gateway.

⚠️ **`@agent:` syntax and `sessions_send` do NOT work** — they have never successfully delivered a message. Do not use them.

### Fire-and-Forget (for handoffs)

Use raw `openclaw agent` when the downstream agent acts independently and you don't need results back in your session:

- **Need review?** → `openclaw agent --agent hawk --message "[material to review]"`
- **Need a task created?** → `openclaw agent --agent triage --message "Create task — [description]"`
- **Need email/calendar checked?** → `openclaw agent --agent postie --message "[request]"`
- **Need clarification?** → `openclaw agent --agent main --message "Clarification needed: [question]"`

### Synchronous Dispatch (when you need results back)

Use `dispatch-and-wait.sh` when you need the other agent's output in your current session:

```bash
result=$(~/.openclaw/workspace/scripts/dispatch-and-wait.sh <agent> "<message>" --timeout 600)
echo "$result"  # contains the agent's full output
```

How it works:
1. Runs the target agent via `openclaw agent`
2. Captures its stdout directly (the agent's chat response)
3. Archives output to `~/.openclaw/workspace/research/req-*.md` for debugging
4. Returns output on stdout to the calling agent
5. Times out after `--timeout` seconds (default: 600s / 10min)

Use cases:
- **Need research?** → `dispatch-and-wait.sh atlas "Research [topic]" --timeout 600`
- **Need code?** → `dispatch-and-wait.sh gig "Write a script that [requirement]" --timeout 300`

If the target agent times out, fall back to doing the work yourself with your own skills.

These are real agents with persistent memory — not ephemeral subagents that die after one task.

From shell scripts, use the same CLI: `openclaw agent --agent <id> --message "..." --timeout 30`

## Cross-Agent Handoff Protocol

When routing a task to another agent, include in the message:

1. **Task** — what needs doing, one sentence
2. **Output** — where to send the result (Ghost draft / Outline / Postiz / Paperless / etc.)
3. **Urgency** — low / medium / urgent
4. **Context** — any workspace files to read first

Example:
```bash
openclaw agent --agent selfiestack --message "Write a blog post about [topic]. Draft in Ghost CMS. Medium urgency. Reference /memory/2026-03-11.md for background."
```

### Handoff Protocol (5-Part Standard)

When work passes between agents, the handoff message includes:

1. **What was done** — summary of completed work/output
2. **Where artifacts are** — exact file paths or URLs
3. **How to verify** — test commands or acceptance criteria
4. **Known issues** — anything incomplete or risky
5. **What's next** — clear next action for the receiving agent

**Bad handoff:** "Done, check the files."
**Good handoff:** "Build complete at /path/to/build. Test with `npm test`. Known issue: CSS not bundled in dev mode. Next: upload to staging."

## Task Lifecycle States

Every task follows this state machine:

```
Inbox → Assigned → In Progress → Review → Done | Failed
```

| State | Who owns it | What happens |
|-------|-------------|---------------|
| **Inbox** | Triage | New task received, awaiting assignment |
| **Assigned** | Worker agent | Task routed, agent has acknowledged |
| **In Progress** | Worker agent | Actively working on it |
| **Review** | Hawk or Jamie | QA review before completion |
| **Done** | Triage | Task complete, verified, closed |
| **Failed** | Triage/Jessie | Task failed, needs re-assign or manual review |

**Rules:**
- Orchestrator (Jessie) owns state transitions — don't rely on agents to update their own status
- Every transition gets a comment (who, what, why)
- Failed is a valid end state — capture why and move on

## Parallel Dispatch Pattern

When 2+ independent tasks can be worked on simultaneously:

1. **Identify Independent Domains** — group by problem area (different files, different subsystems)
2. **Dispatch one agent per domain** — each gets focused scope, no shared context needed
3. **Review and integrate** — check outputs don't conflict, run full test suite

**Use when:**
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without context from others
- No shared state between investigations

**Don't use when:**
- Failures are related (fix one might fix others)
- Need to understand full system state
- Agents would interfere with each other (editing same files)

**Example:**
```
Agent 1 → Fix post.hbs template issues
Agent 2 → Fix package.json validation
Agent 3 → Fix CSS for Koenig editor
```
All dispatched simultaneously, results reviewed after.

## ACK / DONE Protocol

Every agent that receives a routed task **must** follow this lifecycle:

1. **ACK** — Reply immediately: `ACK: [one-line task summary]`
2. **Work** — Perform the task
3. **DONE / BLOCKED** — Reply when finished:
   - `DONE: [one-line result summary]` — task completed successfully
   - `BLOCKED: [reason]` — can't proceed, needs help or input

**Timeout rule:** If no ACK within 10 minutes, the sender should escalate to Jessie:
```bash
openclaw agent --agent main --message "No ACK from [agent] on [task]. Please follow up."
```

This applies to all agent-to-agent routes. Heartbeat-initiated routes (from Triage/Postie) follow the same protocol — Triage tracks ACKs via `pending_actions`.

## Sender Registers pending_actions

When any agent routes a task, the **sender** (not the recipient) must add an entry to `memory/heartbeat-state.json` → `pending_actions`:

```json
{
  "agent": "atlas",
  "task": "Research self-hosting email solutions",
  "delegated_at": "2026-03-12T14:30:00Z",
  "expected_by": "2026-03-12T16:30:00Z",
  "status": "pending"
}
```

- `expected_by` defaults to `delegated_at + 2h` unless urgency dictates otherwise
- When the recipient replies `DONE:` or `BLOCKED:`, the sender updates `status` to `"done"` or `"blocked"`
- Triage checks `pending_actions` every 30m and escalates overdue items

## Error Escalation

When any agent encounters an error (skill failure, API down, unexpected state):

1. Log the error to `memory/YYYY-MM-DD.md`
2. If the error blocks a task → reply `BLOCKED: [error description]` to the sender
3. If the error is infrastructure-related (API down, service unreachable) → also alert Jessie:
   ```bash
   openclaw agent --agent main --message "ERROR — [skill] failed: [reason]. Blocking task #[id]."
   ```
4. **Never silently swallow errors** — if something broke, someone must know

## When to Route vs Spawn

- **Route to a dedicated agent** when the task matches their specialty (research → Atlas, code → Gig, review → Hawk)
- **Spawn a one-off subagent** only for trivial tasks that don't need specialist context (e.g. reformatting text, quick calculation)
- **Don't chain routes** — if Atlas needs Gig, Atlas routes directly; if it gets more complex, escalate to Jessie
- Subagent config: `maxSpawnDepth: 1`, `runTimeoutSeconds: 900` (15 min hard limit)

## Heartbeat Conventions

Default heartbeat prompt:
`Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.`

### Heartbeat vs Cron: When to Use Each

**Use heartbeat when:** Multiple checks batch together, need conversational context, timing can drift.
**Use cron when:** Exact timing matters, task needs isolation, different model/thinking level, one-shot reminders.
**Hard rule:** If you promise an update at a specific time, create a real cron/reminder job immediately. Do not rely on heartbeat.

### Heartbeat Detection Pipeline (Cron-Driven)

1. `scripts/heartbeat-cron.sh` runs every ~10 min
2. `scripts/heartbeat-detect.sh` writes `memory/heartbeat-actions.json`
3. If action needed, cron dispatches findings directly to agents:
   - Email/calendar → Postie, Plane → Triage, Infra → Jessie
4. Successfully dispatched findings marked in `notified_findings` (prevents re-dispatch)
5. `route-tasks.sh` + `completion-sync.sh` run after detection

### When to Reach Out vs Stay Quiet

**Reach out:** Important email, calendar event <2h away, something interesting found, been >8h since last message.

**Stay quiet (HEARTBEAT_OK):** Late night (23:00-08:00) unless urgent, human is busy, nothing new, checked <10 min ago.

**Proactive work without asking:** Read/organize memory, check projects, update docs, commit/push changes, review and curate MEMORY.md periodically.

### Memory Maintenance (During Heartbeats)

Periodically (every few days), use a heartbeat to:

1. Read through recent `memory/YYYY-MM-DD.md` files
2. Identify significant events, lessons, or insights worth keeping long-term
3. Update `MEMORY.md` with distilled learnings
4. Remove outdated info from MEMORY.md that's no longer relevant

### Session Reset Procedure

If an agent's session file grows too large (>200KB warning, >500KB critical — checked by `heartbeat-health.sh`):

1. **Identify the bloated session:** `find ~/.openclaw/agents/*/sessions/ -name "*.jsonl" -size +200k`
2. **Back up if needed:** `cp <session_file> <session_file>.bak.$(date +%s)`
3. **Reset the session:** Delete or truncate the session file. The agent will start a fresh session on next invocation.
4. **Verify:** Run `heartbeat-health.sh` to confirm sizes are back to normal.
5. **For research-heavy agents (Atlas):** Consider more aggressive compaction settings in `openclaw.json`.

---

## Deployment Requests

When you write code that needs to be deployed:

### If a service needs to run (not just static code):
1. Create a Plane task: "Deploy [service-name]"
2. Include in the task:
   - Service name and purpose
   - docker-compose.yml or container requirements
   - Environment variables needed
   - Port mappings
   - Any dependencies
3. Assign to **infra**
4. Infra will deploy and return the endpoint URL in task comments
5. You can then reference that URL in your integration

### Example Task Description
```
Task: Deploy notification-service
Description: Node.js service for sending email notifications
Requirements:
- Image: node:18-alpine
- Port: 3000
- Env: SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS
- Needs: Network access to mail server
Return: URL where service will be accessible
```

### Alternative: Direct Request
You can also message Infra directly:
```
Infra, please deploy notification-service with the attached docker-compose.yml
```

### Important
- You write the code, Infra handles deployment
- Don't try to deploy directly — that's Infra's job
- Always provide clear requirements so Infra knows what to deploy
