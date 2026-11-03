# POLISH-1 regression and Studio acceptance

## Automated

With Python 3.10+, Rojo 7.7.1, Luau 0.743 (luau + luau-compile) on PATH:

```sh
python3 tools/generate_installer.py
python3 tools/generate_layout_diagram.py
python3 tests/check_world.py
```

This checks bundle freshness, all Rojo mappings, compilation, geometry/bounds,
12-stud sampled corridors, grounded roadbeds/spawn, fence spans, markers, ownership
and deterministic installation. Gameplay tests exercise real state/server/client
source in a mock: valid order, invalid order, distant/dead/cooldown attempts,
two-player isolation, secret duplicates, gate opening, respawn, HUD snapshots,
collapse target, stale updates, camera restoration and cleanup. Saved runtime
sources are exercised without the synced module services.

## Required Studio Edit acceptance — NOT RUN

1. Start a disposable Baseplate in Edit Mode. Add unrelated models named anything
   except CapyWorld. Copy the entire Raw STUDIO_ONE_PASTE.lua into Command Bar.
2. Confirm the world appears and Runtime contains CapyServer plus ClientTemplate.
   Reinstall twice; confirm exactly one owned world and unchanged unrelated models.
3. Save, close, reopen. Confirm scenery and saved Script/LocalScript sources remain.
4. In a disposable place, verify an unowned CapyWorld name collision is refused.
5. Inspect roofs, facades, lights, water/deck, foliage, joins and signs from eye level
   and overview. Capture real Studio screenshots only; label Edit/Play accurately.

## Required Studio Play acceptance — NOT RUN

1. Press Play with unrelated default spawns still present. Confirm the session uses
   CapySpawn, the journal appears once and Output has no errors.
2. Feed Mango; inspect facial reaction and dialogue. Repair the garden pump; check
   its light/animation. Talk to Mali; verify wave and pass. Present pass; verify
   portcullis lift, collision clearance, completion and unchanged outer fences.
3. Try out-of-order prompts and distant/rapid input; no progression skip. Verify
   optional postcard once only, before or after completion.
4. Reset/die at multiple stages; verify session progress and appropriate habitat,
   plaza or entrance respawn. Rejoin: progress resets as documented.
5. Start a two-player server: journal/progress must remain personal. After one opens
   the shared gate, another can physically explore but must complete their own steps.
6. Test mouse/keyboard, controller and touch. Use 320px-width phone and landscape
   emulation; check safe areas, text wrapping, 44px collapse hitbox, native prompt
   hold, camera effects and toast visibility alongside movement controls.
7. Test Rojo Play and standalone save/reopen separately. Rebuild via Bootstrap/world
   replacement during a session; confirm no stale prompts, duplicate HUD or signals.
8. Profile frame time/memory on target devices; compare against the baseline place.
   Source part counts are not FPS evidence. Check animation/network latency timing.

Compilation/mock checks do not grant Studio PASS. Release remains blocked until
these engine/device checks and visual review actually pass.
