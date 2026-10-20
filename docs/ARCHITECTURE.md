# Architecture

## Flow

```mermaid
flowchart LR
    Build[Procedural builders] --> World[Four course maps]
    Entry[Server bootstrap] --> Build
    Entry --> Ready[SkyfallReady marker]
    Ready --> Client[Client HUD and presentation]
    Client -->|SkyfallAction requests| Runtime[Server race runtime]
    Runtime --> Rules[Ranking eligibility rules]
    Runtime --> Services[Profiles, purchases and records]
    Services --> Profiles[Profile DataStore]
    Services --> Records[OrderedDataStore boards]
    Client -->|SkyfallQuery| Services
```

## Boundaries

`SkyfallConfig` holds four course specifications, 12 obstacle patterns, movement settings, catalog definitions, persistence names and the free-skip feature flag.

`SkyfallServer` builds missing geometry before starting the race runtime. It creates `SkyfallReady` after world construction so the client does not enumerate a partially built map. Existing world geometry is preserved on ordinary game startup.

`SkyfallRuntime` owns player run state, checkpoint advancement, route gates, hazards, timing, penalties, skips and completion. The state progresses from Loading to Ready to Racing to Finished. Replaying resets current-run eligibility; a skip invalidates the current run and its campaign.

`SkyfallRules` provides a second eligibility guard at the record submission boundary. A run needs positive elapsed time, all required sections, eligibility and no skip. Times are stored as integer milliseconds for OrderedDataStore compatibility.

`SkyfallServices` owns the wallet, catalog prices, ownership checks, equipped cosmetics, profiles and record persistence. Published-game records retain the minimum time for each player. Local previews keep session records in memory.

`SkyfallClient` builds the interface and handles local camera, visual animations and moving-platform carry. Client attributes support presentation; server run state determines record submission. Local checkpoint split comparisons are temporary coaching information, not authoritative records.

## Persistence choices

- Sanitized profile data includes coins, unlocked courses, cosmetic ownership/equipment, best times and clear state.
- Unique session lease tokens reduce conflicting writes; leases renew with autosaves and expire after a bounded interval.
- Saves and record submissions retry transient failures. Shutdown waits a bounded interval for pending work.
- Failed profile loads do not overwrite saved data with defaults.
- Course versions separate ranked records after route changes. Change `RecordStorePrefix` when changing ranked geometry, and define a personal-best migration/reset policy before deploying altered courses.

These safeguards are implemented but require published, multi-server validation before being described as production-proven.

## Tradeoffs and next engineering work

The client is currently a single large UI script. Separating HUD, shop, rankings, course selection and camera into modules would improve maintainability. The runtime also combines race logic and hazard simulation; future mechanics would benefit from distinct controllers.

Basic movement checks cannot guarantee an exploit-free leaderboard. Server-verified traversal, suspicious-run review, better telemetry and adversarial testing are follow-up work. The local ferry carry improves movement feel but still relies on the normal Roblox character networking model.

The world uses procedural anchored parts for reproducibility. More detailed scenery should follow device profiling, streaming checks and draw-call measurements. Current client startup waits for server construction; streaming behavior across course transitions still needs broader physical-device coverage.

The skip prototype has a runtime grant hook for later receipt integration. Never replace it with a client purchase-success message; real developer products require idempotent server receipt handling.

## Sky rooms and edited-world source (v0.2.0)

The default project imports `src/world/SkyfallSprint.rbxm`, preserving manual island/tree edits. `Export-World.py` extracts that world from the saved Studio place; the baseline builders are fallback tooling rather than the source of the edited scene.

`CourseEnvironments.Apply` translates each whole course to its configured region without rebuilding obstacles, creates spacious persistent backdrop models, and keeps the fall catchers invisible. Relative obstacle spacing and the Z-based route gates are unchanged. The server retains control of fall returns and race eligibility.

`CourseSky` applies lighting and cloud settings locally for each player's current course. It hides other course instances and the enclosing backdrop from the local camera, preserving an unbroken real sky at all supported zoom distances. Visibility is reapplied to streamed instances and reset events. This is presentation only; server geometry and race validation remain authoritative.

Coin visual registration and rotor registration respond to incoming streamed instances. Decorative rotor models use atomic streaming. The zoom limit is 512 studs; the environment half-width is 1,100 studs. Broad physical-device streaming and performance coverage remain follow-up work.
