# Editing obstacle Models

Open `Workspace > SkyfallSprint > Levels > Level1` (or another course).

- `Platforms > Step_0_1_Pad` through `Step_0_6_Pad` are separate Models. Each contains exactly five parts: the original platform and four outline pieces. Coins remain in `Orbs`.
- Other platforms have individual assemblies or a named section Model for a continuous obstacle. Balance routes have rounded transitions and continuous center guides. Thin manual repair fragments on the old beam were removed.
- Repeated arch pillars, crowns, lights and beacons are grouped under `Decor > WorldIdentity > CheckpointArch_*`. Other loose details and hazards are grouped by section.
- Select a Model to move its whole assembly; expand it to adjust an individual part. Models stream atomically so the deck and outline arrive together.
- Playable surfaces and their outlines are unlocked. `CourseSky`, background scenery, route triggers, spawn reference and fall catcher are locked to prevent accidental selection. Locked objects can still be edited deliberately through Explorer.

The runtime and phase-rest builder use recursive platform lookup. Phase and crumble outlines follow their platform transparency; their outlines do not collide. The scene migration is one-time and preserves later manual edits. No Play-mode testing was performed for this revision at the user's request.
