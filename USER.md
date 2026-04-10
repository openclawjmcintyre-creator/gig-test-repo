# USER.md - About Your Human

## Basics

- **Name:** Jamie
- **What to call them:** Jamie
- **Timezone:** GMT (UK, Europe/London)
- **Quiet hours:** 00:00-08:00 GMT (no non-urgent messages)

## Background

- Experienced Linux, security, and infrastructure engineer
- Runs a serious homelab: Proxmox cluster (5 nodes), TrueNAS, pfSense, 60+ proxied services
- Domain: `errorlab.uk` (wildcard cert via NPMPlus)
- Self-hosts everything possible — privacy and control are core values

## Communication Style

- **Concise.** Prefers detailed-but-short responses. No fluff.
- **Options-based decisions.** Present multiple options (labelled a/b/c) with a recommendation, wait for "go"
- **Bullet points and tables** for actionable items
- **No filler phrases.** Skip "Great question!" — just answer
- **Text over voice.** Prefers written responses

## Decision Pattern

Jamie reviews proposals before approving. Typical flow:
1. You present findings/options
2. Jamie picks (often with modifications: "b and c, ignore a")
3. You implement
4. Jamie reviews and pushes to git

## Homelab & Infrastructure

- **Cluster:** Proxmox (hild, loki, odin, thor, valhalla) — mix of LXCs and VMs
- **Storage:** TrueNAS (192.168.3.65)
- **Firewall:** pfSense (192.168.3.1)
- **DNS:** AdGuard Home (primary + secondary)
- **Monitoring:** Uptime Kuma (39 monitors, 4 groups)
- **Proxy:** NPMPlus (65 hosts, wildcard *.errorlab.uk)
- **Backups:** PBS → TrueNAS datastore

## Agent Roadmap

Current and planned use cases:
- Personal assistant (Jessie — active, 51 skills)
- Finance tracking (Actual Budget + Yahoo Finance — connected)
- Fitness/health (SparkyFitness — connected)
- Security management (pfSense/AdGuard — connected)
- Documentation & knowledge (Outline, Ghost CMS — connected)
- Research (SearxNG, Miniflux, Reddit, YouTube, Hacker News — connected)
- Email management (gog/Gmail — connected)
- Task management (Plane, Donetick — connected)
- Media management (Radarr, Sonarr, Prowlarr, Overseerr — pending config)
- Social & content (Postiz, content pipeline skills — pending config)
- Infrastructure (Proxmox read + write, TrueNAS, Cloudflare — connected/pending)
- Sub-agent architecture (planned — Phase 2)
