# Difficulty progression

The square jump pads use these sizes in X, Y, Z:

| Level | Jump pad size | Bend rotation speed |
| --- | --- | --- |
| 1: The Ascent | 10, 2, 10 | No added bend sweepers |
| 2: Ember Ruins | 8, 2, 8 | 0.65 radians/second |
| 3: Stormworks | 6-stud moving deck width | 0.90 radians/second |
| 4: Solar Collapse | 4, 2, 4 | 1.15 radians/second |

Stormworks has moving relays and lifts rather than square jump-pad chains. Its moving decks narrow to six studs while keeping their boarding length. Other moving decks use their course's width target. The exact square-pad rule applies to jump, phase and crumble pads.

Jump pad centers retain their twelve-stud longitudinal spacing. Gaps grow naturally as pads shrink, without stretching the level. Existing lateral offsets remain. Continuous refined routes use widths 10, 8, 6, 4; balance routes use 5, 4, 3, 2. Safe start/finish hubs and permanent rest sizes are retained.

Levels 2–4 gain sweepers at major changes in route direction: curved crossings, climbing terraces, wind switchbacks, orbit paths, balance bends and the finale. Centers follow nearby rounded joins. Opposite rotations and staggered phases vary the timing; bend hazards retain standard red-hazard behavior. There are 8 added sweepers in Ember, 3 in Stormworks and 15 in Solar. The existing central sweepers remain.

Pad borders resize inside their existing five-part Models. Other exposed-edge outlines are rebuilt after resizing. The one-time DifficultyProgression migration runs after obstacle organization and before outline generation; later manual edits survive startup.

Rush_v8 records separate these changed routes from the previous layout. The player profile store is unchanged, preserving coins, cosmetics and unlocks.

Edit-mode authoring and source packaging only. The user handles gameplay testing; no Play session was started. Fairness and completion times require user feedback.
