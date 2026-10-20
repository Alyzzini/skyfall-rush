# Landing-aligned route registration

All 32 section arrivals are authored against their actual Hub parts. All 12 checkpoint pads are centered on those hubs. Their hidden arrival zones cover the landing deck and the space above it, so jumping across a checkpoint can register.

Every section has three sequential route volumes aligned to the restored route coins. These volumes are larger than the old corner checks, and moving-platform volumes follow their platform. Detection uses the segment between consecutive player positions against each oriented box, instead of only a point at the current frame.

Section completion and checkpoint progression are distinct from leaderboard eligibility. Arriving at a later hub can recover casual progress; skipped or missed route checks disqualify the time instead of permanently blocking the player. Checkpoint rewards only occur when the player's saved stage increases. Death restores the saved checkpoint, resets partial section checks, and clears the previous position. Skips also reset partial checks and remain unranked.

The RouteRegistration migration is one-time. It retains playable geometry, authored routes, obstacle Models, platform sizes, hazards and scenery. It replaces route volumes and checkpoint placement across every course. Rush_v9 separates the changed timing and validation rules from prior records; profiles remain unchanged.

The repair was authored in Edit mode. No new Play session was started. This is not a claim that every physical jump or multiplayer scenario has been playtested; the user handles that testing.
