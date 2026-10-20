# Advanced chapter — v0.10.0

## Scope and preservation
Only Levels 9–12 were built. Levels 1–8 were snapshotted before authoring and compared afterward for hierarchy, part geometry, visual properties and collision settings. Existing movement settings, profile store, level records, and the original four-course campaign remain. Shared selection, unlock and motion code was extended to support the new chapter. Completing Level 8 unlocks Level 9; existing saved Level 8 completions migrate accordingly.

## Review of existing content
Before authoring, all eight maps were inspected. Existing content relies heavily on stepping pads, phase platforms, straight ferries, short lifts, pulse gates (13 each in Levels 7 and 8), collapse chains, presses and pendulum bays. The advanced chapter introduces traveling openings, actual rotating rideable surfaces, a tower topology, floor timing lanes and alternate routes rather than copying those room sequences.

## Course identities
9 / The Great Engine: gear-to-gear transfer; three piston carriers; conveyor pressure line with accessible blue refuge bays; rolling drive drum; lift inside a moving window housing; steam underpass; engine interior with a blue safer branch and optional gold moving relay; gear/exhaust output shaft. Industrial amber outlines and machinery housing connect the sequence.

10 / Cloudspire: exterior climbing balconies; orbital landing; moving wall cassettes; interior lift shaft; enclosed service stairs; personal breakaway balconies; optional gold route beside the blue balcony climb; crown transfer. The tower rises from Y32 to Y160 through eight distinct sections around its central structure. Falls below the saved tower checkpoint return to that milestone.

11 / Chrono Nexus: traveling window introduction; three-lane signal floor; beat bridge with permanent blue islands; offset paired windows; denser safe-zone floor circuit; vent-timed ascending steps; orbital timing exit; combined signal-floor/window room. Hazard clocks are deterministic with green safe states and 0.85-second amber warnings. Read patterns from safe landings before committing.

12 / Skyfall Apex: gear plus window; conveyor pressure escape; lift plus moving exit; breakaway climb with vents; core navigation through alternating openings; orbital signal landing; descent under the core; final stair/steam/window circuit. Permanent milestone landings break up the mixed challenges.

Each course has eight 64-stud sections and three checkpoints, after sections 2, 4, 6. Decks generally use 10–20-stud widths. Shared movement remains WalkSpeed20, JumpPower50, gravity196.2. No double jump, duck input, purchase, or keyboard-only puzzle is required; the same movement/jump controls apply on touch. Mobile feasibility and comfort still need the owner's playtest.

## Systems
AdvancedCourses authors only indices 9–12. AdvancedMechanics moves only their machinery and clocks at 30 Hz when a player occupies that level. Rider movement supports translation and rotation. Moving coins and route markers follow platform transforms. Breakaway balconies are local to each player so another player cannot remove the floor underneath them. Optional routes share wide ordered route volumes and are intended to remain eligible for records. Decorative parts are sparse, noncolliding and locked; obstacle assemblies remain editable.

## Verification and remaining testing
Edit-mode authoring and visual inspection only. No Play session was started for this chapter, following the owner's explicit reply to leave gameplay testing to them. Source packaging and preservation checks do not certify jump feasibility, mobile completion, live motion consistency, multiplayer latency, repeated-attempt reliability, shortcut resistance, difficulty ordering or FPS. Those require actual gameplay feedback.

Playtest priorities: gear/drum rider stability; piston transfer timing; lift boarding; tower checkpoint fall returns; moving wall gap reachability; signal-floor warning windows; optional route registration; interactions in Level 12. Report course and section numbers for fixes restricted to the new chapter.
