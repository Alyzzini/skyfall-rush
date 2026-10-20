# Levels 5–8 — v0.9.0

## Locked original courses
Levels 1–4 were not redesigned or rebuilt. LegacyLevelsLocked on the shipped world bypasses old authoring passes at startup. Existing four-course campaign records retain their meaning; expansion levels have individual ranked records. Existing profiles, currencies, cosmetics and prior times remain. Players who already completed Level 4 unlock Level 5.

## New courses
- **5 / Clockwork Docks:** transfer decks, piston timing, freight elevator, presses, sorting conveyor, pendulum bay, service climb, belt-and-press exit. A folded industrial route climbs to the upper dock.
- **6 / Prism Archive:** alternating book-stack galleries, switch-powered bridge, exterior balconies, sequential shutters, mirrored navigation, descending vault, conveyor bridge and shutter exit. Diamond markers show openings without revealing a straight shortcut.
- **7 / Pulse Citadel:** pulse introduction, wave sequence, laser lift, collapsing afterimages with permanent rest island, crossing machinery, pendulum stairs, pulse conveyor and paired gate exit. Green is open, amber warns, red is active.
- **8 / The Convergence:** moving transfers plus laser gate, switch plus pulse, lift plus press, timed exterior ledges, collapsing belt, signal stairs, timed descent and conveyor/pendulum/pulse finale.

All new courses use eight compact 56-stud sections. Checkpoints follow each section. WalkSpeed 20, JumpPower 50 and gravity 196.2 are unchanged. New walking decks are generally 10–12 studs wide. Bridges remain solid while occupied, and switches can be reused by other players.

## Implementation
ExpansionCourses only authors indices 5–8. ExpansionMechanics only drives those four maps. Obstacles are grouped by section with named deck assemblies and outlines. Machinery updates at 30 Hz only for occupied courses. Decorative silhouettes are deliberately sparse. The map browser discovers all eight config entries. HUD checkpoint counts follow the selected course.

## Research
- Roblox official platformer/classic obby templates: https://create.roblox.com/docs/resources/templates — moving platforms, tower course layout, checkpoints and configurable hazards.
- Creator discussion on introducing, then combining obstacles: https://devforum.roblox.com/t/the-guide-to-making-a-difficulty-chartpart-1/1135152
- Creator discussion on obby variety and progression: https://devforum.roblox.com/t/obby-level-suggestions/1031558

## Validation status
An initial Play startup check exposed a four-entry UI name table; expanded names and checkpoint display were corrected. The owner then explicitly requested no further Play testing. Full end-to-end traversal, jump feasibility under live conditions, multiplayer timing, shortcut resistance, difficulty progression and respawn behavior are **not yet certified**. The temporary test runner is excluded from the shipped project.

Owner playtest priorities: lift boarding and exit timing; Archive bridge prompt on touch controls; pulse windows under latency; checkpoint return after each section; the combined Level 8 encounters; whether Level 5 feels like the right step after Level 4. Please report course/section numbers for adjustment. Changes should remain restricted to Levels 5–8.
