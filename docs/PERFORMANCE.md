# Performance and visual design notes

## Research used

- [Roblox: Improve performance](https://create.roblox.com/docs/performance-optimization/improve) — instance density, transparency overdraw, shadow cost and reducing unnecessary work. Applied opaque cloud volumes, disabled cosmetic shadow/touch/query work, and reduced distant ring/star detail.
- [Roblox: Instance streaming](https://create.roblox.com/docs/workspace/streaming) and [Model streaming modes](https://create.roblox.com/docs/reference/engine/enums/ModelStreamingMode) — selected sky environments use PersistentPerPlayer; playable routes use normal streaming. No course geometry is hidden based on another player's progress.
- [Roblox: Streaming techniques](https://create.roblox.com/docs/workspace/streaming/techniques) — handle instances leaving and returning. Coin and rotor registries now release streamed-out instances; coin collection state is maintained separately.
- [Roblox: Post-processing effects](https://create.roblox.com/docs/environment/post-processing-effects) — modest color correction supplies vibrancy without stacking expensive effects. Low turns bloom off; no depth-of-field blur is used.
- [Roblox: Securing the client/server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary) — start gates use server-observed root positions, bounds, direction and cooldowns. A client message cannot supply a start timestamp or a finish time.
- [Roblox: MicroProfiler modes](https://create.roblox.com/docs/performance-optimization/microprofiler/modes) — use CPU/render frame times and memory measurements for later device profiling, rather than claiming an FPS increase from instance count alone.
- [Developer Forum: Feedback on game difficulty](https://devforum.roblox.com/t/feedback-on-game-dificulty/4272272) — community feedback about mechanical clarity informed the visible, labeled start gate and smaller instruction labels. This is design inspiration, not measured evidence about this game's difficulty.

## Implemented controls

The HUD's **Visuals** button cycles Auto → Low → High. Auto ignores menu time and large isolated stalls, then selects Low after three consecutive five-second racing windows slower than roughly 38 FPS. It stays Low for the session unless the player selects another mode. These are local presentation preferences, not changes to Roblox account graphics settings.

Low removes dynamic cloud cover, bloom and global shadows, pauses cosmetic rotors and lowers nearby coin bobbing to 15 Hz. It keeps the enclosing sky, route, hazards, phase colors, checkpoints, coin pickups and race rules. High retains the restrained cosmetic effects and 20 Hz nearby rotor animation. Normal coin animation is capped at 30 Hz and 160 studs; rotors stop beyond 220 studs.

The server updates motion at most 30 Hz in occupied courses. Empty courses retain their geometry without per-frame movement replication. Phase pads send property changes only on phase-state transitions. All moving hazard positions still use synchronized server time.

## Scope of evidence

The edited world decreased from **4,770 to 4,487 descendants**. The larger memory change is that each player pins only the selected environment instead of all four. Engine streaming may retain nearby/recent content according to memory conditions, so this is not a guarantee of immediate unloading or a 75% memory reduction.

Scripts compiled and the source place built. No low-end device FPS benchmark, complete 56-section traversal or multi-client race was performed for this update. Before a public launch, profile frame times and memory across all courses, compare Auto/Low/High on representative hardware, and exercise transitions, gate resets, skips and respawns with multiple clients.
