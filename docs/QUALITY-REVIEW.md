# Full-game quality review — v0.11.0

## Scope and evidence
All 12 courses were inspected in Studio Edit views, with closer views for representative dressing and moving machinery. Every playable/collidable platform entry and every hazard part was inventoried by instance name, assembly, position, size, shape/mechanic and properties: **854 platform/collidable entries, 203 hazard parts (199 visible and 4 hidden fall catchers)**. The inventory also records the course signs. See [the individual instance inventory](qa/obstacle-inventory-before.json).

This is a **visual, structural and script review**. No Play session was started because the owner continues to handle gameplay testing. Neither a source build nor an Edit-view check proves beatability or player readiness.

## Completed changes
- Added 571 noncolliding, nonquerying, shadow-free details near the courses: safe-hub chevrons, framed start/finish gates, panel seams and theme-specific milestone details.
- Finished distant spires with 152 caps/bands plus 60 signal lamps; archive crowns, reactor crowns and timing signals differ by theme. All 783 new decoration parts omit collision, touch, query and shadows.
- Optional new dressing disappears in Low graphics; navigational chevrons and portal frames remain. Live FPS has not been measured.
- Limited explanatory sign visibility to avoid multiple room captions crowding the view.
- Fixed other maps’ CourseSky shells appearing as floating ceilings. This masking is limited to background shells, never shared platforms; streamed playable geometry is still restored visible.
- Converted 22 shared crumble/collapse surfaces to personal behavior while retaining each authored delay. One runner no longer removes another runner’s floor. Existing advanced personal balconies remain personal.
- Changed spherical hammer collision to a rounded distance check, avoiding lethal empty box corners around a visible ball.
- Floor hazards now check the avatar’s feet with a small vertical allowance, rather than an expanded torso box. Normal rectangular hazards retain their current bounds.
- Repositioned the three Cloudspire optional-route coins onto the safer balcony branch.

## Preservation and structural checks
The pre-change snapshot comparison confirms that original Platforms, Hazards, RouteGates and Checkpoints retain their hierarchy, count, CFrame, size, collision, touch, query, color, material and transparency in every course. The small personal-collapse attribute is intentional; obstacle layouts and dimensions were not rebuilt or rebalanced.

All 96 gates have their three ordered route nodes. All 52 checkpoints have arrival volumes. All 66 moving-follow references resolve to BaseParts. No unanchored playable surfaces/hazards, duplicate/missing orb IDs, or collision/query/shadow-enabled near-course QC decorations were found in these checks.

## Deliberate limits
- Existing narrow expert beams and compact rest pads remain owner-approved geometry; they need mobile playtesting rather than an unrequested resize.
- Shared switch bridges remain cooperative server objects. Another player can activate them; occupied bridges retain their existing protection against disappearing under a runner. Competitive isolation of switches would require a separate gameplay change.
- Some coins between close gear decks intentionally reward the jump. They are not all meant to sit above a static platform.
- Teaching mechanics recur later in combined contexts. This polish pass has not replaced the owner-approved obstacle sequences; it does not claim to eliminate every repeated mechanic.
- Live jump feasibility, latency, repeated attempts, checkpoints/respawn, shortcuts, device comfort, true difficulty ordering and FPS remain pending with the owner. No claim that every obstacle has been played is made.

## Every-section register
Each row records its structural/source review. All rows still require live gameplay feedback.

| Level | Section | Obstacle | Review/action |
|---|---:|---|---|
| 1 / The Ascent | 1 | Jumps | Pad spacing and outline continuity reviewed; geometry retained. |
| 1 / The Ascent | 2 | Hurdles | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 1 / The Ascent | 3 | Slalom | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 1 / The Ascent | 4 | Phase | Phase periods and warning visibility reviewed; permanent rest retained. |
| 1 / The Ascent | 5 | BoulderHop | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 1 / The Ascent | 6 | Switchback | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 1 / The Ascent | 7 | Balance | Existing narrow expert balance route retained; mobile comfort still needs playtest. |
| 1 / The Ascent | 8 | Spinners | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 1 | Crumble | Per-player collapse replaces shared disappearance; original delay retained. |
| 2 / Ember Ruins | 2 | Maze | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 3 | Conveyor | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 4 | ArchCrossing | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 5 | TerraceClimb | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 6 | Spring | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 7 | Alternating | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 2 / Ember Ruins | 8 | Crusher | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 3 / Stormworks | 1 | MovingRelay | Moving references and boarding geometry reviewed; carry code present. |
| 3 / Stormworks | 2 | Ferry | Moving references reviewed; boarding and live transfer need playtest. |
| 3 / Stormworks | 3 | Elevator | Moving references reviewed; live vertical transfer needs playtest. |
| 3 / Stormworks | 4 | Alternating | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 3 / Stormworks | 5 | WindSwitchback | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 3 / Stormworks | 6 | Spinners | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 3 / Stormworks | 7 | Elevator | Moving references reviewed; live vertical transfer needs playtest. |
| 3 / Stormworks | 8 | MovingRelay | Moving references and boarding geometry reviewed; carry code present. |
| 4 / Solar Collapse | 1 | Crumble | Per-player collapse replaces shared disappearance; original delay retained. |
| 4 / Solar Collapse | 2 | Phase | Phase periods and warning visibility reviewed; permanent rest retained. |
| 4 / Solar Collapse | 3 | Orbit | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 4 / Solar Collapse | 4 | Crusher | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 4 / Solar Collapse | 5 | Ferry | Moving references reviewed; boarding and live transfer need playtest. |
| 4 / Solar Collapse | 6 | TerraceClimb | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 4 / Solar Collapse | 7 | Balance | Existing narrow expert balance route retained; mobile comfort still needs playtest. |
| 4 / Solar Collapse | 8 | Finale | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 5 / Clockwork Docks | 1 | Relay | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 5 / Clockwork Docks | 2 | Pistons | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 5 / Clockwork Docks | 3 | Lift | Dock extents and movement references reviewed; live boarding needs playtest. |
| 5 / Clockwork Docks | 4 | Press | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 5 / Clockwork Docks | 5 | Belt | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 5 / Clockwork Docks | 6 | Swing | Spherical hammer collision uses rounded distance, avoiding box corners. |
| 5 / Clockwork Docks | 7 | Stairs | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 5 / Clockwork Docks | 8 | DockRun | Spherical moving hazard collision corrected; mechanical dressing added. |
| 6 / Prism Archive | 1 | Gallery | Wall seams and clearer sign distance; existing navigation gaps retained. |
| 6 / Prism Archive | 2 | Switch | Shared cooperative bridge behavior retained; prompt range validated in source. |
| 6 / Prism Archive | 3 | Ledges | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 6 / Prism Archive | 4 | Shutters | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 6 / Prism Archive | 5 | GalleryReverse | Mirrored gallery retained; visual panel seams added. |
| 6 / Prism Archive | 6 | Descent | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 6 / Prism Archive | 7 | SwitchBelt | Shared cooperative bridge behavior retained; prompt range validated in source. |
| 6 / Prism Archive | 8 | ArchiveExit | Shutter timing source reviewed; navigation geometry retained. |
| 7 / Pulse Citadel | 1 | Pulse | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 7 / Pulse Citadel | 2 | Wave | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 7 / Pulse Citadel | 3 | LiftLaser | Dock extents, gate warnings and carry code reviewed. |
| 7 / Pulse Citadel | 4 | Collapse | Per-player collapse; permanent blue rest retained. |
| 7 / Pulse Citadel | 5 | Crossfire | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 7 / Pulse Citadel | 6 | SwingSteps | Spherical hammer collision uses rounded distance, avoiding box corners. |
| 7 / Pulse Citadel | 7 | PulseBelt | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 7 / Pulse Citadel | 8 | ClockExit | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 8 / The Convergence | 1 | RelayLaser | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 8 / The Convergence | 2 | SwitchPulse | Shared cooperative bridge behavior retained; prompt range validated in source. |
| 8 / The Convergence | 3 | LiftPress | Lift/press source reviewed; guard seams added. |
| 8 / The Convergence | 4 | LedgesPulse | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 8 / The Convergence | 5 | CollapseBelt | Personal collapse plus existing conveyor behavior; permanent rest retained. |
| 8 / The Convergence | 6 | CrossfireSteps | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 8 / The Convergence | 7 | DescentPulse | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 8 / The Convergence | 8 | FinalRun | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 9 / The Great Engine | 1 | GearTransfer | Transform carry and following references reviewed; tooth shape retained. |
| 9 / The Great Engine | 2 | PistonDecks | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 9 / The Great Engine | 3 | PressureLine | Accessible refuge bays retained; housing seams added. |
| 9 / The Great Engine | 4 | RollingDrum | Rotational carry source reviewed; live rider stability remains pending. |
| 9 / The Great Engine | 5 | WallLift | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 9 / The Great Engine | 6 | SteamUnderpass | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 9 / The Great Engine | 7 | MachineInterior | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 9 / The Great Engine | 8 | DriveShaft | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 10 / Cloudspire | 1 | ExteriorClimb | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 10 / Cloudspire | 2 | OrbitLanding | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 10 / Cloudspire | 3 | WallSteps | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 10 / Cloudspire | 4 | LiftShaft | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 10 / Cloudspire | 5 | InteriorStairs | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 10 / Cloudspire | 6 | BreakawayBalconies | Already personal breakaway behavior retained. |
| 10 / Cloudspire | 7 | SkyBridge | Three orbs moved onto the safe branch; alternate routes retained. |
| 10 / Cloudspire | 8 | CrownAscent | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 11 / Chrono Nexus | 1 | TravelingWindow | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 11 / Chrono Nexus | 2 | SignalFloor | Foot-position collision corrected for avatar height. |
| 11 / Chrono Nexus | 3 | BeatBridge | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 11 / Chrono Nexus | 4 | CrossingWindows | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 11 / Chrono Nexus | 5 | SafeZoneCircuit | Foot-position collision corrected; deterministic floor phases retained. |
| 11 / Chrono Nexus | 6 | EchoStairs | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 11 / Chrono Nexus | 7 | PhaseOrbit | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 11 / Chrono Nexus | 8 | PatternFinale | Foot-position collision corrected; window/floor combination retained. |
| 12 / Skyfall Apex | 1 | GearWindow | Gear/window combination retained; true spherical collision only applies to balls. |
| 12 / Skyfall Apex | 2 | PressureEscape | Accessible refuge bays retained; housing seams added. |
| 12 / Skyfall Apex | 3 | LiftWindows | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 12 / Skyfall Apex | 4 | BreakawayRise | Personal breakaway and steam pattern source reviewed. |
| 12 / Skyfall Apex | 5 | CoreNavigation | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 12 / Skyfall Apex | 6 | SignalOrbit | Moving references and foot-position signal collision reviewed. |
| 12 / Skyfall Apex | 7 | UnderCore | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
| 12 / Skyfall Apex | 8 | SummitCircuit | Geometry and mechanic references reviewed; existing route retained; visual markers/dressing improved where applicable. |
