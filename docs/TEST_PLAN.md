# Mission 01A-R1 test plan

## Automated checks

With Python 3.10+, Rojo 7.7.1, Luau 0.743 (`luau` and `luau-compile`) on PATH:

```sh
python3 tools/generate_installer.py
python3 tools/generate_layout_diagram.py
python3 tests/check_world.py
```

The runner checks generated output freshness, actual Rojo mapping/classes, place
build and production/installer compilation. The real bootstrap/builder executes
inside a small mocked Roblox data model. Checks cover world bounds including
rotated parts, eight zone centers and graph connectivity, actual route junctions,
path widths/slope and a sampled 12-stud clear corridor, spawn clearance, closed
perimeter continuity, checkpoint visibility and deterministic rebuilding.

Installer checks remove the synced source services and execute the checked-in
installer in the mock: its geometry must match, repeat installation must not
duplicate worlds, unowned name collisions must be preserved, and legacy owned
worlds must upgrade. An injected build error must preserve the previous world.

This is not Roblox-aware type checking, visual verification, physics simulation,
real avatar navigation or device performance testing.

## Studio Edit Mode acceptance — NOT RUN

1. Open Studio on a supported machine, stop Play/Run, and open Command Bar.
2. Copy the entire Raw `STUDIO_ONE_PASTE.lua`, paste and execute it.
3. Confirm one `Workspace.CapyWorld` with `GeneratorId=CAPY-M01A`, `Phase=R1`.
4. Frame the world; inspect all eight zones, materials, hill/forest silhouettes,
   curved routes, pond lobes, roofs, signs and the absence of oversized empty areas.
5. Re-run the installer. Confirm exactly one owned world remains and an unrelated
   model placed outside it is unchanged. In a disposable place, verify an unowned
   model named `CapyWorld` produces a refusal instead of being deleted.
6. Save, close and reopen the place: the full world must remain visible in Edit
   Mode without Rojo, HTTP access or pressing Play.
7. Capture screenshots only from Studio and label them accurately. No screenshots
   have been captured for this cloud implementation.

## Studio Playtest — NOT RUN

1. Manually disable/remove unrelated default SpawnLocations; the installer leaves
   them intact. Press Play and verify the avatar uses the habitat spawn.
2. Inspect Studio Output for errors. Walk from spawn through the open habitat gate
   and traverse the eight-zone loop. Test slopes, joins and doorway clearances.
3. Verify the outer fence and all three future route barriers block the avatar.
4. Confirm the pond is decorative and checkpoints do not save/advance progress.
5. Check roofs, sign readability, ground support, floating/intersecting geometry,
   tree placement and collisions from eye level and overview cameras.
6. In the Rojo workflow only, use the server Command Bar to run
   `require(game.ServerScriptService.World.ZooBuilder).Build()` twice and verify
   one generated world remains. The standalone installer does not create scripts.
7. Profile frame time, instance cost and memory on intended devices. No headless
   assertion count establishes real-world performance or visual quality.

Report Edit Mode installation, Studio playtesting and automated checks separately.
Do not report Studio PASS unless it was actually performed. R2–R5 wait for R1
review; the overall reconstruction and escape mission remain incomplete.
