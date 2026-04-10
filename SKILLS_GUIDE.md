# Gig's Skills Guide

Installed skills for frontend development, design, and implementation.

## Installed Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **frontend-design-3** | Avoid AI slop, distinctive UIs | Any frontend work |
| **react-best-practices-2** | 69 React/Next.js performance rules | React/Next.js code |
| **shadcn-ui** | Component framework rules | UI components |
| **writing-plans** | Bite-sized implementation plans | Before coding |
| **brainstorming-tazio** | Ideas → designs via dialogue | New features |
| **ui-polish-pass** | Final polish (spacing, WCAG) | Pre-release |
| **animate** | Animation/micro-interactions | UI enhancement |
| **copywriting-pro** | Conversion copy | Marketing copy |

## Skill Workflows

### New Feature (from idea to code)
```
brainstorming-tazio  → Understand the problem
       ↓
writing-plans        → Create implementation plan  
       ↓
shadcn-ui           → Build UI components
       ↓
react-best-practices-2 → Optimize React code
       ↓
ui-polish-pass       → Polish the UI
       ↓
animate              → Add animations
```

### Code Review Checklist
1. Does it follow **frontend-design-3** principles?
2. Does it follow **react-best-practices-2** rules?
3. Does it follow **shadcn-ui** conventions?
4. Has **ui-polish-pass** been applied?
5. Are animations accessible (**animate** - respects prefers-reduced-motion)?

### Marketing Copy
- Use **copywriting-pro** for any user-facing text
- Benefits over features
- Clear, specific, active voice

## Key Rules

### From frontend-design-3
- Pick a bold aesthetic direction, execute with precision
- Typography: distinctive fonts over generic (avoid Arial, Inter)
- Motion: CSS-first, use Motion library for React
- One memorable thing per interface

### From react-best-practices-2
- Priority 1: Eliminate waterfalls (async operations)
- Priority 2: Bundle size optimization
- Server-side performance before client-side

### From shadcn-ui
- Use existing components first (`npx shadcn@latest search`)
- Compose, don't reinvent
- Semantic colors: `bg-primary`, `text-muted-foreground`
- Use `cn()` for conditional classes

## Skill Locations
```
~/.openclaw/workspace/skills/frontend-design-3/
~/.openclaw/workspace/skills/react-best-practices-2/
~/.openclaw/workspace/skills/shadcn-ui/
~/.openclaw/workspace/skills/writing-plans/
~/.openclaw/workspace/skills/brainstorming-tazio/
~/.openclaw/workspace/skills/ui-polish-pass/
~/.openclaw/workspace/skills/animate/
~/.openclaw/workspace/skills/copywriting-pro/
```

## Notes
- web-design-guidelines skipped (flagged suspicious by VirusTotal)
- Run `clawhub update` periodically to get latest versions
