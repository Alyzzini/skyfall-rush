# Portfolio and résumé notes

## Project description

**Skyfall Rush — Roblox / Luau game development project**

A Roblox speedrun prototype spanning twelve themed courses and 96 obstacle sections. The project combines race progression, skip-aware leaderboard eligibility, an 18-item cosmetic catalog, persistent profile logic and a responsive player interface. Source is organized for VS Code and Roblox Studio with Rojo, with reusable world builders and a preserved, hand-edited world model.

## Suggested résumé bullets

- Developed a Roblox speedrun prototype in Luau with twelve themed courses, 96 obstacle sections and reusable movement/timing mechanics.
- Implemented server-owned race timing, sequential route checks, skip-based run disqualification, cosmetic purchase validation and DataStore-backed profile/leaderboard logic.
- Built responsive course selection, racing HUD, cosmetic shop and ranking interfaces, with procedural world generation and a Rojo workflow for VS Code.

Use these bullets to describe the project, and be ready to discuss its design decisions and future improvements. Add player counts, revenue or performance results only when they have been measured.

## Short project entry

**Skyfall Rush** | Luau, Roblox Studio, Rojo, Git

Roblox speedrun prototype with twelve themed courses, 96 obstacle sections, server-managed race progression, a cosmetic economy, responsive UI and persistent-data implementation.

Source: [Alyzzini/skyfall-rush](https://github.com/Alyzzini/skyfall-rush)

## Walkthrough for an interview

1. Show the course selector and explain how Config defines distinct course mechanics.
2. Start a run and show the compact HUD and checkpoint progression.
3. Use the free skip prototype and explain why assisted runs cannot enter rankings.
4. Buy/equip a trail and explain why balance, ownership and prices are checked on the server.
5. Explain profile leases, autosaves and the unpublished preview fallback.
6. Discuss a concrete improvement: modularizing the UI, stronger traversal validation, real receipt processing, or physical-device profiling.

## Honest status

Development prototype; source and visual assets are included. The original place is unpublished. Levels 9–12 have not had a Play-mode validation pass, and full traversal of the expansion and current route revisions remains with the owner. Live cross-server persistence, physical touch controls, multiplayer latency and low-end performance still require validation. Skip is free; paid skip purchase integration is not implemented. Repository publication is separate from publishing a playable Roblox experience. See the [quality review](QUALITY-REVIEW.md) for the recorded checks and remaining work.
