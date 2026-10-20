# Skyfall Rush — game and setup guide

The upgrade is installed in the open Roblox Studio place. Press **Play → Start Speedrun**.

Move with **WASD**, jump with **Space**, or use Roblox's touch controls. Gold pickups are optional coins. Follow the course through every route marker to qualify for rankings.

## Latest visual upgrade: Expedition

- Illustrated course selector with themed colors, difficulty cards, course length, locked states and one primary Start button.
- Compact racing HUD. Open **Menu** during a run for shop, rankings, restart and skip. The timer continues while a panel is open.
- Redesigned gradient panels, catalog color previews, equipped states, insufficient-funds styling, and individual ranking rows with podium colors.
- The Ascent has hanging botanical islands; Ember Ruins has broken foundry arches; Stormworks has rotating storm turbines; Solar Collapse has orbital reactor rings and fragments. Checkpoints have illuminated gateway structures.
- Checkpoint split feedback compares cumulative time (including fall penalties) against your best split at that checkpoint during this client session. These coaching splits are temporary and are separate from server rankings. Skipped runs do not save coaching splits.
- A fixed overview camera introduces the selected course; starting a race restores normal avatar camera control.

The visual pass adds 1,132 noncolliding scenery parts. All new scenery is anchored, cannot collide, cannot trigger touches, and is excluded from ray queries. Only the current course's decorative rotors animate, capped at about 30 updates per second. Existing ranked route geometry and movement settings are unchanged, so the record version remains v3. Performance on low-end physical devices has not been profiled.

`ArtDirection.luau` is an idempotent **Edit-time** visual installer. To recreate the map from these sources, install the existing modules/scripts, run `BuildCourse.luau`, then run `ArtDirection.luau`. Do not run either builder during gameplay. The open Studio place already contains both passes. The previous client and decoration copies are in `ServerStorage.SkyfallBeforeVisualUpgrade`.

### Research behind this pass

[Roblox UI/UX guidance](https://create.roblox.com/docs/production/game-design/ui-ux-design) informed prioritizing the timer, grouping secondary actions, consistent colors, and restrained motion. [This Roblox developer discussion on obby preferences](https://www.reddit.com/r/robloxgamedev/comments/1qylwty/what_do_you_enjoy_most_about_obby_platformers_in/) includes requests for cohesive themes and varied stages; those individual comments inspired the four world identities. [Additional obby UI feedback](https://www.reddit.com/r/robloxgamedev/comments/1e280jn/how_can_i_improve_my_ui_i_am_making_an_obby/) was also reviewed. Community comments are design input, not representative player research.

### Checks for this pass

Inspected the desktop selector, shop, race HUD, skip panel and rankings, plus iPhone 17 Pro portrait selector/shop/rankings and landscape selector/race HUD/ranking row. Desktop button input confirmed Start, camera restoration, Menu expand/collapse, buying Ion Wake (125 → 50 coins), and equipping it. Skip confirmation still advanced to checkpoint 1 and produced `USED SKIP` with ranking eligibility false. Decorative rotation and split toast were checked in preview. No script errors were reported by Studio. Local client source matches the installed Studio script.

Phone input through Studio's automation helper remains unreliable; phone panels were opened through the game's existing action/event paths for layout inspection. This does not replace testing real touch input on hardware. A temporary session-only ranking fixture verified `01:05.432` in the new row layout; stopping Play removed the fixture and all preview records. No artificial record was published. No complete manual run of all 56 sections was performed in this visual pass.

Studio is left in Edit mode with device simulation off. The place is still unpublished (`PlaceId = 0`); live global storage and paid purchases have not been tested. Skip remains the explicitly labeled free prototype.

## Courses

| Course | Obstacle sections | Length | Checkpoints before finish |
|---|---:|---:|---:|
| The Ascent | 8 | 768 studs | 1 |
| Ember Ruins | 12 | 1,152 studs | 2 |
| Stormworks | 16 | 1,536 studs | 3 |
| Solar Collapse | 20 | 1,920 studs | 4 |

Each saved checkpoint follows four complete obstacle sections: **384 studs between checkpoints**. There are 56 sections and 5,376 studs of course in total.

The twelve obstacle patterns are momentum jumps, low hurdles, solid slalom walls, solid/ghost phase platforms, crumbling steps, moving ferries, narrow balance ridges, spinning sweepers, conveyors, sliding gates, rising crushers, and spring-launch gaps. Later courses combine narrower landings with faster movement and more double sweepers.

### Read the colors

- **Gold:** optional coins.
- **Cyan:** a phase platform is solid.
- **Amber:** a phase platform is about to become a ghost, or a crumbling platform is about to drop.
- **Pink:** a phase platform is currently non-collidable.
- **Red:** a hazard returns you to your checkpoint.
- **Green:** a checkpoint or spring-launch pad. Hold forward on a spring.

## Speedruns and records

The stopwatch counts up to milliseconds. Falls and hazard returns add three seconds. Coins, shop cosmetics, and other players do not improve movement speed.

Rankings include a separate top ten for each course and a full-campaign top ten. A full campaign starts at Level 1 and continues through all four courses using Next Level. Replaying a later course can set its individual record without qualifying as a full campaign.

The server owns elapsed time, route order, rewards, and record submission. It checks route gates and rejects skipped or suspicious runs. This is basic validation; further testing in a published multiplayer experience is still worthwhile before a competitive launch.

Ranked scores use integer milliseconds in versioned OrderedDataStores. Lower times rank first. Updating a record preserves the player's fastest previous result. Boards refresh about once a minute, and completed runs appear immediately in the current server's preview.

### Activate real global records and saving

This place was unpublished during implementation (`PlaceId` and `GameId` were zero). It currently uses **LOCAL PREVIEW / SESSION RECORDS**, and its wallet is session-only. The board never presents preview scores as live global records.

1. Save and publish the place to your Roblox experience.
2. Test in the published experience to verify records and wallet data across servers and rejoins.
3. To test live data from Studio, open **File → Experience Settings → Security → Enable Studio Access to API Services**. This setting is for Studio testing; published servers do not require that Studio toggle.

The installed code switches to Roblox data stores for a published experience. If a data load fails or another active server owns the profile, it uses a clearly labeled session wallet and does not overwrite existing saved data. Profile saves use a session lease, periodic autosaves, leave/close saves, and retries. Pending record writes are included in the server-close wait.

Live cross-server writes and rejoin persistence could not be verified in the unpublished place. Use a separate test experience/data-store namespace when testing against Roblox's backend.

## Skip button

The **R$ SKIP** button is a working **free prototype**. No Robux are charged and no purchase prompt is opened.

Its confirmation explains the effect. Confirming a skip:

1. Moves the player to the next checkpoint, or the finish after the final checkpoint.
2. Removes the current run's time and displays **USED SKIP**.
3. Prevents that level run from updating a personal best or global leaderboard.
4. Prevents its full-campaign attempt from entering the campaign leaderboard.
5. Leaves previous valid records intact.

Restart begins a fresh level run. A clean retry can qualify again, provided its earlier campaign levels were also clean. The skip itself grants no checkpoint or finish coin bonus.

### Connect a paid skip later

Keep `PrototypeSkipEnabled = true` while using the current free prototype. `SkipProductId = 0` is only a reserved configuration field; setting a product ID alone does not implement payment.

Before charging Robux, add a server-side developer-product receipt handler. Store receipt IDs and durable skip credits so a receipt cannot grant twice and an interrupted run cannot lose a purchased credit. Consume a credit only when a valid skip can be delivered.

The server integration point is **ServerScriptService.SkyfallGrantSkip**, a BindableFunction. Invoking it with a Player attempts the validated skip and returns success or a reason. It is not exposed as a purchasable client entitlement. Disable the free-prototype remote path when your complete receipt/credit flow is ready.

## Coins and cosmetics

Players start with 125 coins. Pickups award five coins. Reaching a checkpoint normally awards twenty coins once per run. Clean finishes award a course-scaled bonus, with an additional first-clean-clear bonus.

The shop includes four trails, Frost Aura, and Solar Halo. Buying an item equips it. Owned items can be equipped again without paying, and trails and auras can be removed independently. All cosmetics preserve the same movement settings. The server checks ownership, price, and balance.

In a published experience with working data access, the wallet, owned cosmetics, equipped items, unlocked courses, personal bests, and first-clear rewards are saved. The current unpublished preview resets these when Play ends.

## Source files

The scripts in this folder mirror the installed implementation:

| File | Studio location/type |
|---|---|
| SkyfallConfig.luau | ReplicatedStorage / ModuleScript `SkyfallConfig` |
| SkyfallRules.luau | ServerScriptService / ModuleScript `SkyfallRules` |
| SkyfallServices.luau | ServerScriptService / ModuleScript `SkyfallServices` |
| SkyfallRuntime.luau | ServerScriptService / ModuleScript `SkyfallRuntime` |
| SkyfallServer.server.luau | ServerScriptService / Script `SkyfallServer` |
| SkyfallClient.client.luau | StarterPlayer / StarterPlayerScripts / LocalScript `SkyfallClient` |
| BuildCourse.luau | Run once in Edit mode to rebuild course geometry; backs up the existing `SkyfallSprint` map into ServerStorage |

ReplicatedStorage also needs RemoteEvent **SkyfallAction** and RemoteFunction **SkyfallQuery**, which are already installed. The course lives in **Workspace.SkyfallSprint.Levels**. Earlier course versions and scripts are preserved in ServerStorage.

Change prices, rewards, movement, and course patterns in SkyfallConfig. The runtime and UI currently support four courses. When ranked routes or movement rules change, use a new record-store version so unlike courses do not share records.

## Checks completed

- Normal controls cleared the first momentum jumps and collected a coin.
- A purchased trail appeared, re-equipping did not charge again, and insufficient funds were rejected.
- Frost Aura and a twelve-part non-collidable halo equipped correctly.
- A standing avatar followed a ferry with about 0.02 studs of relative drift in the measured test.
- A spring launch reached its landing deck; conveyors pushed sideways.
- Walking into a low hurdle returned the player with a penalty; jumping cleared it.
- Phase platforms changed their collision state; crumbling platforms warned, disappeared, and restored.
- The skip confirmation worked, the timer became USED SKIP, and skipped finishes created no record or personal best.
- A skipped level tainted the full-campaign attempt after advancing to the next course.
- The record rules rejected skips and incomplete routes, retained faster scores, and rejected worse replacement scores.
- The iPhone 17 Pro simulator was inspected in landscape and portrait. The game's orientation setting is Sensor. Menus, shop, and rankings were checked visually; touch movement controls hide while menus are open. The Studio input helper did not reliably click buttons in phone emulation, so phone panel layout was opened through the same server events used by the in-world kiosks. Desktop button interactions were tested.
- No script errors appeared in the final Play checks. Studio was returned to Edit mode and the default viewport.

This was not a full human playthrough of all 56 sections. Tune Expert difficulty after playtesting. Live global persistence and paid receipts remain the publishing/setup checks described above.

## Research that shaped the changes

- [Reddit feedback on confusing/repetitive obbies](https://www.reddit.com/r/robloxgamedev/comments/1e3ucxh/not_just_another_obby/) informed clear collision colors, readable routes, and varied mechanics. This is community feedback, not a representative player survey.
- [Reddit feedback recommending speedruns and clearer danger signals](https://www.reddit.com/r/robloxgamedev/comments/1uxjxoj/spent_a_week_on_roblox_ads_for_my_difficulty/) informed the ranked stopwatch and consistent red hazards.
- [Reddit obby-building ideas](https://www.reddit.com/r/robloxgamedev/comments/mjvtf1/tips_for_making_an_obby/) helped inform moving and disappearing platforms. The game uses explicit signals rather than confusing players about which parts collide.
- [Roblox's global leaderboard tutorial](https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/create-leaderboard) informed server-owned ordered records and ascending time rankings.
- [Roblox data-store documentation](https://create.roblox.com/docs/cloud-services/data-stores) supports the publishing/API setup requirements.
- [Roblox developer-product guidance](https://create.roblox.com/docs/production/monetization/developer-products) is the reference for the future receipt integration.


## October 20, 2026: user edits and course skies

The user's hand-edited trees are preserved in `src/world/SkyfallSprint.rbxm` and the saved Studio place. `Hurdle_Bottem` is retained and made fully transparent. Other courses get matching invisible fall catchers. Server quick returns below the course remain active.

Course centers are now X = 0, 4096, 8192, 12288. The enclosures are 2200 studs wide and 1600 studs high, with generous front/back margins. They are visual-only and excluded from collisions, touches and queries. The Play-mode sky presenter hides enclosing geometry and other courses locally, applying daylight, sunset, storm and night settings per player. Normal editor camera controls are retained in the saved place.

An in-Studio preview showed the continuous sky with no neighboring course visible. The project builds successfully with the edited-world model. The earlier QA notes document previous passes; this update does not claim a complete run of all 56 sections or physical-device profiling.

The saved-world exporter retains editable geometry and shared-string references, while omitting derived model mesh/hash caches for compatibility with Rojo 7.7.1. A backup of the pre-environment user-edited place is kept locally under `.backups` and is not uploaded.


## October 20, 2026: enclosed 3D environments

Following the user's clarification, the hidden-room/flat-backdrop approach was replaced with a visible enclosing sky shell and physical scenery. The shell curves around the route and its ends, disguising square room edges. Its material is unlit on every face to prevent shaded panel seams. The active enclosure is now visible during Play.

Ascent has floating gardens and cloud volumes, Ember has cliff/ruin silhouettes and a sun, Stormworks has cloud banks and steady lightning/spires, and Solar has two planets, rings, asteroid fields and stars. Scene screenshots are in `docs/images`. The user's tree edits and invisible fall hazard remain preserved. The camera remains unrestricted by environment collision and has a 512-stud zoom limit.

Space and garden scenes were visually inspected in Studio. The Play preview reported the active world visible, camera query/collision disabled for its shell, and zoom 512. No Studio script errors appeared. The edited-world snapshot and Rojo place build were refreshed. A full 56-section run and hardware performance profiling were not part of this visual iteration.


## Permanent phase rests (v0.3.1)

Added six permanent, centered resting platforms: Ascent section 4, Ember section 7, Stormworks sections 1 and 10, and Solar sections 2 and 11. Each is centered between the two middle phase pads, measures 14 by 16 studs, and sits slightly above those pads to avoid surface flicker. No PhasePlatform, Crumble or Moving flag is attached. The route gates, checkpoints and rewards are unchanged.

The saved world and fallback startup installer both include this change. Course version/record namespace advances to Rush_v4 because the ranked route is easier. Coins, owned cosmetics, unlocks, wins and clear progress remain in the same profile store; personal bests are scoped to the current record version. Old global records are retained in their old namespace.


## Compact phase rests (v0.3.2)

All six rests now use Size (3.5, 0.5, 4), matching the requested reference. They remain centered between the middle pair of pads, with their top surface aligned just above the step tops. Guides scale to the actual platform dimensions. RestSizeVersion=2 performs the one-time resize; subsequent startup calls preserve manual Size changes. Future size edits must be made while Studio is stopped to persist in the saved place. The current record namespace is Rush_v5; the generic RecordVersion profile logic handles personal-best compatibility.


## Course visibility repair (v0.3.3)

Removed the client whole-course hiding/cache logic responsible for invisible return visits. Geometry is never masked based on CurrentLevel. The client clears stale local masking on non-coin geometry while leaving server phase/crumble transparency and authored invisible triggers untouched. Course lighting stays local; coin collection presentation is tracked per player across streaming, and reset clears that collection set. The enclosing 3D scenery, manual tree edits and compact permanent rests are preserved.

This repair does not change race geometry or invalidate existing records. A multi-client Studio session has not been run for this patch.


## Vibrant world and gate update (v0.4.0)

The four screenshot issues were addressed with aligned garden/slate layers, attached ember accents and a supported crucible, arch rock formations placed behind the opening, and passable translucent blue start gates. Lighting now uses colorful ambient fill with moderate saturation and low bloom. Labels are more compact and leaderboard faces turn toward the lobby.

All 12 project script sources compiled without Luau syntax errors during this pass. The edit world now contains 4,487 descendants (previously 4,770); playable phase pads and all six 3.5 × 0.5 × 4 permanent rests are retained. Each environment uses PersistentPerPlayer rather than always persistent for every player. The count reduction alone is not an FPS benchmark. Multi-client races, complete course traversal and physical low-end hardware profiling remain unmeasured for this update.


## Fitted Ember monuments (v0.4.1)

Replaced all six distant arch/butte/fissure groups with cohesive 20-part monuments. AncientArch positions from the current user-edited Studio scene determine the new locations. The silhouette has fitted feet/capitals, a connected terrace and tapered underside; glow strips are flush to the pillar/lintel/foundation faces, and the central ember sits in a supported brazier. Monuments face inward toward the route. No gameplay surfaces, start gates, timing or ranking namespace changed. The edit-time scene was visually inspected; the two changed builder modules compiled. No gameplay tests were run for this cosmetic update.


## HUD alignment (v0.4.2)

Replaced independent viewport-edge positioning with a shared RaceHUD container and StatusRow. Header, section instructions, Menu and Visuals align to the same bounded width; under 600 pixels, status text uses its own row. Expanded toolbar is positioned below the status group. The main menu retains its bottom toolbar and top-right visuals control inside the same width bounds. Client source compiles; no gameplay or ranking changes.


## Arcade audio and VFX (v0.5.0)

Installed four course-specific APMOfficial chiptune tracks and Roblox/bundled SFX. All five cloud audio assets returned AssetFetchStatus.Success in the current Studio context. Changed client/server/config sources compiled. Added bounded local sparkles, pulses, finish confetti, button scale feedback and short celebration labels, plus a scrollable Audio / FX panel. Low/reduced mode lowers particles and removes pulses. Server-confirmed feedback is separate from timing/currency validation. No gameplay playback or auditory balance review was run for this patch.


## Route geometry corrections (v0.6.0)

The current pass retains existing systems and scenery while revising selected route sections. Movement is 20/50, four courses contain eight sections each, and checkpoints follow two sections. Earlier automated keyboard traversal progressed into Ember; the user then stopped automated testing. That partial run is not evidence for completing all courses or for mobile readiness. No further Play-mode tests were performed after the user asked to handle testing.

Screenshot corrections: six 7.5-stud spheres replace Ascent stairs; rounded bridges use quadratic corner transitions, matching circular joins and slope-aligned contact surfaces; the forked bridge becomes a single curved crossing; overlapping spirals become non-crossing climbing terraces. Route nodes remain mandatory for ranked progression. Old decorative route structures beyond the shortened finish are removed. Runtime now resets partial route-node progress on checkpoint returns and avoids calling persistence cleanup on an already-removed player. Rush_v7 isolates the changed movement/routes.

## v0.6.1 — editable obstacle assemblies
Rounded the remaining original balance beams; replaced thin manual patch slivers. Organized each jump/phase/crumble pad as a five-part Model with separate coins, grouped other surfaces, repeated arches, hazards and loose details. Unlocked playable geometry and protected background/hidden infrastructure. Updated recursive runtime references and outline state synchronization. Saved the Studio place, exported the world and built the source project. No Play-mode test was started. See EDITING-MODELS.md.


## v0.6.2 — complete platform borders
Completed outlines around hubs, runways, ramps, rounded beams, rest platforms and moving surfaces in every course. Removed superseded HubEdge and LandingGuide fragments, clipped internal joins, and retained separate five-part pad Models. Added moving-outline transforms. Saved the full place and built source packaging without starting Play.


## v0.6.3 — leaderboard Model startup repair
Studio output identified a fatal startup error in PolishWorld: Size is not a valid member of Model Level1.Decor.LeaderboardBoard. Resolve the physical board inside its Model, reuse its crown, and find its SurfaceGui recursively. Services.UpdateWorldBoards also resolves nested UI safely so edited boards cannot terminate the refresh loop. Optional visual passes report errors without aborting core initialization; SkyfallReady is published after the runtime initializes. The previously failing polish pass completed on the actual Edit scene. Saved and built source packaging. No Play-mode test was started.


## v0.6.4 — crossing sweeper
The Ember ArchCrossingSweeper rotates continuously around its center at 1.1 radians/second (about 5.7 seconds per revolution). Its AlwaysAnimate attribute keeps it moving during gameplay even before a player selects Ember. The platform remains stationary, and existing red-hazard behavior is retained. Saved and built without entering Play mode.


## v0.7.0 — escalating difficulty
Square jump pads shrink by two studs per level: 10 / 8 / 6 / 4; Stormworks uses six-stud moving platform widths instead of square chains. Curved routes and balance decks narrow across courses. Bend sweepers added to Levels 2–4 (8 / 3 / 15), with increasing speeds, alternating directions and offset phases. Original twelve-stud jump-pad spacing is retained. Five-part pad trim and full exposed-edge outlines fit the revised surfaces. Changed ranked routes use Rush_v8; profiles remain v3. Saved and built without Play-mode testing. See DIFFICULTY.md.


## v0.7.1 — spin angle precision and restored coins
Fixed sweeper rotation precision: CFrame.Angles now receives an angle modulo one revolution rather than the enormous Unix-time-based phase. Restored three gold orbs per section, 24 per course, 96 overall. Coins are 1.2-stud balls centered 2.6 studs above actual route surfaces; moving-platform coins retain follow offsets. Curve and maze placements follow route control points and avoid sweeper centers. Edit-mode downward ray checks found a platform beneath all 96 coins. The existing user play session was stopped for editing; no new Play session was started. Source packaging built successfully.


## v0.7.2 — all-course route and checkpoint repair
Rebuilt 32 section arrival volumes and 96 sequential route checks using actual landing hubs and restored coin locations. Moving route checks now follow their platforms. Recentered all 12 checkpoints and added full-deck arrival zones. Server progression uses swept segment/box intersections to catch jumps and fast frames. Missed route checks make a run unranked rather than blocking casual section and checkpoint progress. Partial checks clear on skips, respawns and resets. Rush_v9 separates revised validation records. Physical obstacle geometry remains preserved. Saved and built without a new Play session. See ROUTE-REGISTRATION.md.

