# Portfolio and résumé notes

## Project description

**Skyfall Rush — Roblox / Luau game development project**

A procedural speedrun platformer spanning four themed courses and 56 obstacle sections. The project combines race progression, skip-aware leaderboard eligibility, cosmetic purchases, persistent profile logic and a responsive player interface. Source is organized for VS Code and Roblox Studio with Rojo.

## Suggested résumé bullets

- Developed a Roblox speedrun obby in Luau with four progressively harder courses, 56 obstacle sections and 12 reusable obstacle patterns.
- Implemented server-owned race timing, sequential route checks, skip-based run disqualification, cosmetic purchase validation and DataStore-backed profile/leaderboard logic.
- Built responsive course selection, racing HUD, cosmetic shop and ranking interfaces, with procedural world generation and a Rojo workflow for VS Code.

Use these bullets to describe the project, and be ready to discuss its design decisions and future improvements. Add player counts, revenue or performance results only when they have been measured.

## Short project entry

**Skyfall Rush** | Luau, Roblox Studio, Rojo, Git

Procedural speedrun game with four themed courses, server-managed race progression, cosmetic economy, responsive UI and persistent-data implementation.

Source: https://github.com/Alyzzini/skyfall-rush

## Walkthrough for an interview

1. Show the course selector and explain how Config defines increasingly long courses.
2. Start a run and show the compact HUD and checkpoint progression.
3. Use the free skip prototype and explain why assisted runs cannot enter rankings.
4. Buy/equip a trail and explain why balance, ownership and prices are checked on the server.
5. Explain profile leases, autosaves and the unpublished preview fallback.
6. Discuss a concrete improvement: modularizing the UI, stronger traversal validation, real receipt processing, or physical-device profiling.

## Honest status

Playable prototype; source and visual assets are included. The original place is unpublished. Live cross-server persistence, real Robux purchases, exhaustive course completion and low-end device performance are not yet validated. Repository publication is separate from publishing a playable Roblox experience.
