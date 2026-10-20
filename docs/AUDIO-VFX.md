# Arcade audio and feedback

## Design

Each course has a chiptune soundtrack, with a short crossfade when the player changes courses. Music sits below gameplay cues. Start gates, checkpoints and finish fanfares briefly duck the music so the important cue is readable. Music and effects use separate local SoundGroups; the game never changes account-wide audio settings.

Coins rise slightly in pitch when collected close together. Checkpoints use an ascending four-note phrase; a clean finish uses a longer cadence and a personal-best message when appropriate. Spring pads combine a launch whoosh with a rising phrase. A skip has a descending phrase, purple burst and an explicit unranked label. Hazard/fall returns have a short failure cue; shop success and denial have different phrases. Buttons have quiet hover/click sounds and subtle scale feedback.

Jump/landing feedback follows the local Humanoid. Nearby phase warnings and crumble states produce localized visual bursts with quiet cues. Ferry/conveyor landings and nearby moving machinery have restrained movement sounds. Default running footsteps remain. Default legacy jump, landing and death Sound objects are locally muted to avoid duplicating the custom cues.

## Music and asset credits

The following music assets are distributed through Roblox's Creator Store by **APMOfficial**. Links identify the actual track, rather than a copied popular-song ID list.

| Course | Track | Asset |
| --- | --- | --- |
| The Ascent | Coin Bonus (a) | [1837768444](https://create.roblox.com/store/asset/1837768444) |
| Ember Ruins | Chiptune | [1841610162](https://create.roblox.com/store/asset/1841610162/Chiptune) |
| Stormworks | The Click Song | [1845556093](https://create.roblox.com/store/asset/1845556093) |
| Solar Collapse | Final Boss (b) | [1837768562](https://create.roblox.com/store/asset/1837768562/Final-Boss-b) |

Coin feedback uses Roblox's **CoinTransfer_01**, asset **127645268874265**, referenced by the [official 2D audio tutorial](https://create.roblox.com/docs/tutorials/use-case-tutorials/audio/add-2D-audio). Other action cues use Roblox's bundled jump, landing, get-up, volume-slider and ouch audio files. Melodic phrases are short pitched sequences of the bundled tone. Particle textures are bundled Roblox sparkle/square textures; no external visual assets are downloaded.

Track IDs and default mix levels are centralized in `src/shared/SkyfallAudioConfig.luau`. Asset names/creators were read from Roblox, and all four tracks plus the coin asset returned AssetFetchStatus.Success during Studio asset loading. This confirms asset loading in the current Studio context; it is not an auditory mix review or a published multiplayer playback result. Creator Store availability and usage permissions can change, so review the published experience's audio output before release. These cloud audio references are for the Roblox experience, not a standalone redistribution of music files.

## Controls and budgets

Open **Menu → Audio / FX**, or Audio / FX from the selector toolbar. Music and sound effects have separate percentage controls; tapping a percentage toggles mute. Reduced effects is independent of volume. Preferences last for the current session.

- Twelve reusable one-shot voices; two looping music players for crossfades.
- One local feedback folder and one local moment overlay.
- Maximum ten simultaneous bursts; three in Low/reduced mode.
- Low/reduced bursts emit at most four particles and omit expanding pulse discs.
- Full bursts normally emit 4–18 particles; a finish emits up to 36.
- Particle carriers expire after 1.6 seconds; pulse discs after 0.5 seconds.
- Nearby obstacle feedback is distance limited; machinery cues are limited to one per 0.9 seconds.
- One floor query at 5 Hz identifies ferry/conveyor contact; animation does not create permanent world emitters.
- Streaming-out parts release their feedback connections.

All visual parts are local, anchored, noncolliding and excluded from touches, queries and shadows. The client effects do not modify ranked timing, movement, checkpoint validation or server phase/crumble behavior. Server-confirmed actions trigger start/checkpoint/fail/skip/finish/shop feedback; a cosmetic effect cannot award coins or complete a course.

## Research used

- [Audio assets](https://create.roblox.com/docs/audio/assets): Creator Store sourcing and audio usage permissions.
- [Sound objects and mixing](https://create.roblox.com/docs/sound): background versus positioned audio and separate mixer groups.
- [SoundGroup](https://create.roblox.com/docs/reference/engine/classes/SoundGroup): independent music/effects volume control.
- [Dynamic effects](https://create.roblox.com/docs/sound/dynamic-effects): context for layered audio and mixing; this patch uses direct volume ducking rather than stacking processors.
- [ParticleEmitter](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter): explicit Emit bursts with disabled continuous emission.
- [Performance guidance](https://create.roblox.com/docs/performance-optimization/improve): avoid persistent overlapping transparent effects and unnecessary frame work.

The scripts compile and the source place builds. Audio assets loaded in Studio. Gameplay playback, listening balance, complete route traversal and physical-device profiling have not been performed for this update.
