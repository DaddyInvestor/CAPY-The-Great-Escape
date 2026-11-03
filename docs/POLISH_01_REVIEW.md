# POLISH-1 audit and three-pass review

Base: `9dbf4e06561fab968538b92ad946f0398e2369a3` on
`feat/capy-m01a-project-foundation`. No project restart or main-branch modification.

This audit covered all tracked sources, Rojo mapping, installer generation,
landscape/architecture builders, configs, documentation and tests. The base had
no runtime mission, NPC behavior, UI, custom controller, animation state machine,
audio or saving to audit; those absences are findings, not working features to
remove. Art findings concern authored geometry/code, not a Studio visual review.

## Ranked top ten weaknesses

Scores V/P/J are editorial impact estimates for visuals / playability / enjoyment
on a 1–5 scale, not measured player research. Ranking favors turning the static
park into an understandable, interactive introduction without discarding it.

| Rank | Weakness in base | V/P/J | Implemented response / remaining boundary |
|---|---|---|---|
| 1 | No objective or completable gameplay loop | 1/5/5 | Four ordered park-helper objectives with a real gate-opening conclusion |
| 2 | One-paste installed scenery only; no saved runtime | 1/5/5 | Generated saved server Script plus client template, independent of Rojo |
| 3 | No HUD, guidance or interaction feedback | 2/5/5 | Journal, target distance, progress, dialogue, native touch/gamepad/keyboard prompts |
| 4 | Capy was a statue; no reacting NPCs | 4/4/5 | Mango feeding reaction and Ranger Mali with dialogue/wave; no roaming AI claimed |
| 5 | Pavilion architecture repeated without joinery or facade identity | 5/2/4 | Braces, headers, lattice windows, porch lights, ranger awning, maintenance lean-to |
| 6 | Empty exploration with no environmental story or secrets | 4/3/5 | Breakfast props, broken pump, story boards, forest clue/postcard, meaningful destinations |
| 7 | Pond lacked shoreline activities and visual detail | 4/2/3 | Lilies, lotus accents and a grounded viewing deck; still decorative, not swimmable |
| 8 | Redundant road tessellation and broad overlapping joins | 3/3/3 | Adaptive round joins, overlapped strips and fewer segments; no route or quest removed |
| 9 | No progression authority, respawn checkpoints or lifecycle rules | 1/5/4 | Server-owned order/distance/cooldown checks, isolated state, checkpoints and cleanup |
| 10 | No character/camera animation polish | 4/3/4 | Eased reactive NPC motion and subtle speed FOV; preserve default Animate/controller; custom capy rig deferred |

## Pass 1 — visual excellence

Added visible timber joinery, window lattices and warm local lanterns without
changing shared Lighting. Added lily/lotus details and a viewing deck to the
existing lobed pond. Retained all eight compositions and mixed tree silhouettes.
Reduced road segments from 219 to 158 and used round joints only where needed;
walking surfaces overlap and retain grounded roadbeds. Existing collision/bounds,
spawn, connectivity and installer regressions passed. The measured world count
fell from 1,962 to 1,688 parts at this pass. No screenshots or Studio appearance
comparison was available; the geometry/source change is the evidence.

## Pass 2 — gameplay excellence

Implemented *Mango's Morning Rescue*: breakfast → pump → Mali → trail pass/exit,
plus an optional forest postcard. Interactions use native prompts. The journal
shows the current objective/distance, success/hint dialogue and progress. The
shared portcullis lifts only after an eligible player's ordered completion;
other players still need their own steps. Progress is session-only. NPC reactions
are eased event-triggered tweens; no idle AI loop or downloaded animation IDs.
Server state is the sole progression authority. The first gameplay regression
run passed 61 gameplay/UI/runtime assertions; a generator whitespace failure was
then corrected in the production pass. This was not a Studio playtest.

## Pass 3 — production excellence

- Prepared saved controller sources before replacing the prior owned world.
- Added/rechecked ordered, distant, dead-player, unknown, duplicate, cooldown and
  two-player cases; secret collection cannot be farmed for extra progress.
- Added server-controlled habitat/plaza/entrance respawn positions.
- Added same-world server deduplication and a client HUD ownership/deduplication guard.
- Cleaned up prompt, player, character, UI, heartbeat and camera listeners on
  departure/stop/rebuild; restored camera FOV on owned GUI destruction.
- Bounded UI width, respected device safe insets and kept a 44-pixel collapse target;
  tested UI properties/events in the mock, not actual mobile rendering.
- Removed decorative parts from physics queries; retained required solid geometry.
- Quantized FOV targets to avoid recreating tweens for tiny speed fluctuations.
- Kept the whole runtime inside the owned installed world; added Rojo client mapping.
- Kept Mango's head, ears and eyes together during its feeding reaction; added
  distinct ranger/maintenance facade silhouettes during review.

## Concrete before/after evidence

| Capability / generated data | Before | Current |
|---|---|---|
| Footprint / connected zones | 600 × 500 / 8 | Preserved |
| Generated world BaseParts | 1,962 | 1,719 (243 fewer, about 12.4%) |
| Curved road segments | 219 | 158 (about 27.9% fewer) |
| Ordered objectives | 0 | 4, plus one optional discovery |
| Interactable/reaction-driven characters | 0 | Mango and Mali |
| Interaction stations | 0 | 5 native ProximityPrompts |
| Player journal / progress feedback | None | One responsive, collapsible journal |
| Checkpoint behavior | Visual markers only | Markers retained; session progress chooses respawn location |
| One-paste saved controllers | None | Server and client sources saved inside owned world |
| Server per-frame scan loops | None | Still none; interactions are event-driven |
| Client updates | None | One throttled 4 Hz journal-distance update plus change-triggered camera tweens |

Counts were produced by running the real builders against the repository mock.
They do not measure FPS, draw calls, device memory or quality of the rendered scene.
The baseline and pass logs were captured during this iteration; the original R1
validation record is also retained. Current geometry checks execute 4,472,860
assertions, mostly repeated corridor samples, not independent test cases.

## Automated results

`python3 tests/check_world.py` with Rojo 7.7.1 / Luau 0.743 / Python 3.12.14:

- PASS: generated installer/diagram freshness, source self-containment and Rojo build.
- PASS: all 13 production mappings and compilation of those scripts plus installer.
- PASS: bounds, explicit collision/query policy, slopes, sampled 12-stud corridors,
  spawn clearance, perimeter alignment, zone endpoints/graph and visible markers.
- PASS: deterministic modular/installer worlds, legacy upgrade, unowned collision
  refusal, construction/runtime-preparation failure preserving the prior world.
- PASS: 63 gameplay/UI/runtime assertions covering ordered completion, independent
  players, distance/dead/cooldown rejection, shared gate with personal completion,
  secret idempotency, checkpoint respawn, HUD state/events, stale messages and cleanup.
- PASS: exact bundled server code executes and delivers the saved client source
  without Rojo source services; mock client initializes the delivered journal.
- PASS: whitespace checks.

The mock does not emulate Roblox rendering, physics, replication timing, prompt
hold timing, real device input, or engine permission to write Script.Source.
Standalone Luau compilation is not Roblox-aware type checking.

**Actual Studio Edit installation/save/reopen: NOT RUN.**
**Actual Studio Playtest: NOT RUN.** No fabricated screenshots or playtest claims.
This Linux executor has no Roblox Studio binary or connected Studio testing tool.

## Features preserved and boundaries

Retained branch/history, one-paste workflow, modular Rojo workflow, all zones,
habitat geometry and open visitor gate, natural pond outline, forest/mountains,
perimeter, future maintenance/fence routes, buildings, spawn and checkpoint markers.
The main gate starts closed and now opens as the introduction's intentional ending.
Default avatar controls/Animate remain. No working gameplay was removed for FPS.
Native shared Terrain/Lighting and unrelated models/UI are protected.

There is no persistent save, currency, full escape campaign, roaming guard system,
custom capy controller, authored character animation set or verified audio design.
A gate opened by one player is physically open to others, while their completion
stays locked behind their own quest state. Server rebuild/rejoin resets progress.

## Next five improvements / release blockers

1. Run Studio Edit/save/reopen and multi-client Play acceptance, including real
   prompt holds, physics, network timing, mobile safe areas and frame-time profiling.
2. Build and test a capybara rig/controller and authored movement/reaction animations.
3. Add a reviewed escape challenge beyond this introductory quest, with richer NPC
   behavior, choices and measured mission pacing; preserve server authority.
4. Perform a Studio art pass on water/terrain transitions, roof silhouettes,
   foliage composition, camera accessibility and a coherent soundscape.
5. Profile actual target devices, tune collision/rendering budgets from measurements,
   then design persistent progression with explicit failure/recovery tests.

**Not release-ready.** Automated success does not resolve the Studio acceptance
blockers or establish a premium visual standard.
