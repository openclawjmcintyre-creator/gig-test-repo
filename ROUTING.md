# ROUTING.md - Task & Output Routing

## Plane Task Routing

### States
| State | ID | Purpose |
|-------|-----|---------|
| Backlog | 474fe791-b834-4eb0-a1cf-0de49c2d03ff | Ready for work |
| Todo | cb975ea3-7f7a-49ba-bb94-69d8c562b997 | Prioritized |
| In Progress | 08dcca02-1080-4d6c-88ee-f7a4e5abb8bc | Being worked |
| Done | 6c41c0f8-cb58-40c5-bdb0-4aafe588f02f | Complete |
| Inbox | bf4a92a1-2110-42e1-be6d-a976fc1a299b | New/unprocessed |

### Agent Task Routing
| Task Type | Assigned Agent | Label |
|-----------|---------------|-------|
| Blog posts | selfiestack | `blog` |
| Documentation | docs | `docs` |
| Infrastructure | infra | `infra` |
| QA/Review | hawk | `hawk` |
| Research | atlas | `research` |
| Email/Calendar | postie | `postie` |
| Media requests | media | `media` |
| Code/Scripts | gig | `code` |
| Personal/Finance | personal | `personal` |
| Task routing | triage | `triage` |

### Helper Scripts
```bash
# Assign task to agent
./scripts/plane-assign.sh <sequence-id> <agent> [state-id]

# Example
./scripts/plane-assign.sh 106 docs "Todo"
```

## Agent User IDs (Plane)
| Agent | Email | User ID |
|-------|-------|---------|
| docs | docs@errorlab.uk | e5483788-15cc-4449-9caa-90fd953471f4 |
| infra | infra@errorlab.uk | 608aab4b-8621-43f9-bd53-053f011bbe79 |
| hawk | hawk@errorlab.uk | e9daa8f9-f55d-4369-a2aa-4afee76b4a98 |
| postie | postie@errorlab.uk | 4b13ae4a-1a18-40ba-996a-d8491c5aa7df |
| selfiestack | selfiestack@errorlab.uk | 1ceac40c-0b74-4764-9cee-2400426e6b3b |
| atlas | atlas@errorlab.uk | a15d651a-889e-4cf0-a71b-08cf880b4799 |
| gig | gig@errorlab.uk | 182efa12-b34e-4024-a0e4-452447bf4f0a |
| personal | personal@errorlab.uk | c0510153-2198-4244-ab72-5f04dc3f23dc |
| media | media@errorlab.uk | c6205b4f-2f35-46bf-8127-d61a80ef23cb |
| triage | triage@errorlab.uk | 047706cc-511b-42ca-9ae9-6106afb7b06d |

## Output Routing
| Output Type | Destination |
|-------------|-------------|
| Blog posts | Ghost CMS (selfiestack.io) |
| Docs | Outline (appropriate collection) |
| Code/Scripts | GitHub or workspace |
| Reports | Telegram to Jamie |
| Verification | Plane task comment |
