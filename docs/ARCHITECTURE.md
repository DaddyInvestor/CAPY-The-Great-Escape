# CAPY POLISH-1 architecture

The existing R1 world remains modular: Shared.GameConfig/WorldLayout, World.Geometry,
Landscape, Landmarks and ZooBuilder. StoryDetails adds fixed prompt stations,
Mango's breakfast, the pump, Ranger Mali and the forest postcard. Geometry and
runtime files are owned by `CapyWorld`; shared Terrain/Lighting are untouched.

## Gameplay

- `Shared.QuestConfig`: fixed ordered objectives, positions, prompt labels and hints.
- `Gameplay.QuestLogic`: pure session-state transition/snapshot module.
- `Gameplay.QuestServer`: trusted player/character/distance/order/cooldown checks,
  snapshots, signals, per-player state, reactions, shared gate and respawns.
- `StarterPlayerScripts.CapyClient`: journal, native-prompt companion feedback,
  distance updates, eased FOV and lifecycle cleanup. Default Roblox controls remain.

Only the server mutates progression. Clients can request a bounded, rate-limited
snapshot; no advance/reward remote exists. ProximityPrompt handlers validate player
membership, living character, distance and cooldown before applying an ordered
transition. This is not a complete movement anti-cheat system. No currency/saving.

World state such as the pump light and gate is shared; quest progress is personal.
Opening the gate does not complete other players' quests. Progress lives only in
server memory and resets on rejoin/rebuild. CharacterAdded selects the next safe
spawn according to progress. Departure and world destruction clean up sessions,
character/prompt hooks, owned delivered GUIs and signals.

## One-paste and Rojo parity

`tools/generate_installer.py` bundles generation modules directly and saves a
self-contained server Script plus client ScreenGui/LocalScript template in
`CapyWorld.Runtime`. The server clones the owned client template into each
PlayerGui. Templates have ResetOnSpawn=false. No StarterGui edit is necessary.
Studio Command Bar in Edit Mode has the required permission to write Script.Source;
this operation, save/reopen and real execution still require Studio acceptance.

In Rojo, Bootstrap builds and starts the same QuestServer module; StarterPlayer
maps the same client source. The installer is outside the automatic Rojo mapping.
Saved sources are generated from production source, not separately maintained.
Source hashes cover both generation and runtime; --check rejects stale bundles.

`ZooBuilder.Build(prepare)` constructs detached geometry and optional saved runtime
before replacing old owned worlds. Ownership checks refuse unrelated name
collisions and accept the legacy M01A tags. A failed preparation preserves the
old world. The runtime and client both guard duplicate controllers; only owned
GUI names can be replaced. Rebuilds deliberately start a fresh session.

## Performance and validation

Road surfaces/shoulders overlap; round joints remain at sharper bends/endpoints.
Decorative geometry has CanCollide/CanTouch/CanQuery disabled as appropriate.
There is no server heartbeat scan. The single client heartbeat updates the journal
at 4 Hz; character-speed changes use quantized camera tween targets. NPC reactions
are event-driven with per-part overlap guards and completion cleanup.

Tests execute actual modules, the exact saved server bundle and actual client
source against a limited Roblox mock. They are not a physics/replication/rendering
engine. See POLISH_01_REVIEW.md for the three-pass comparison and remaining blockers.
