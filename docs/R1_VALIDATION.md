# CAPY-M01A-R1 validation record

## Automated results

Executed in the cloud checkout on the feature branch using Rojo 7.7.1,
Luau 0.743 and Python 3.12.14:

```sh
python3 tools/generate_installer.py
python3 tools/generate_layout_diagram.py
python3 tests/check_world.py
```

| Check | Result | Evidence / limit |
|---|---|---|
| Generated installer freshness | PASS | Checked-in file exactly matches the six generation modules and source hash |
| Planning diagram freshness | PASS | SVG zone centers and route curves derive from WorldLayout |
| Rojo place build | PASS | Temporary `.rbxlx` successfully built |
| Rojo source mapping | PASS | All 8 production scripts have expected paths and Script/ModuleScript classes |
| Luau compilation | PASS | All 8 production scripts and the standalone installer compile |
| Geometry / layout | PASS | 1,962 generated BaseParts, within the 600 × 500 footprint; 8 connected zones |
| Navigation data | PASS | 219 curved-route segments; widths at least 16 studs; slope below 8%; sampled 12-stud central corridor clear |
| Spawn / fences / markers | PASS | Grounded spawn, clearance samples, aligned closed perimeter spans/gates, visible marker positions |
| Determinism / ownership | PASS | Repeated modular and installer geometry matches; one world remains; unrelated user models preserved |
| Failure safety | PASS | Refused unowned name collisions; injected construction failure preserves prior world; legacy owned world upgrades |
| Installer independence | PASS | Executed without the original source services; no runtime module, HTTP or external asset dependency |
| Whitespace | PASS | `git diff --check` |

The mocked data-model run completed 4,635,457 assertions before installer-specific
checks. This large count comes mainly from repeated corridor sampling against
geometry; it is not a count of independent tests and is not visual verification.
The checks caught a supply-crate obstruction in the maintenance approach, which
was moved into the service yard before the passing run.

## Unrun checks and known limitations

- **Roblox Studio Edit Mode installation: NOT RUN.** Actual Command Bar paste,
  visual composition and save/reopen persistence require Studio verification.
- **Roblox Studio Playtest: NOT RUN.** No rendering, engine physics, avatar
  navigation, real spawn selection or device performance has been verified.
- No Studio screenshots have been captured. R1_LAYOUT.svg is a design diagram.
- Roblox-aware type checking is not provided by the standalone Luau compiler.
- Buildings are R1 landmarks; detailed assets, finer terrain contours, lighting
  direction and approach-path polish remain review items for R2.
- Pond water is decorative over solid ground; the three perimeter escape routes
  are closed scenic reservations; checkpoints are visual only.
- No AI, puzzles, mission completion, saving, rewards or capybara controller.
- R1 requires review before proceeding to R2–R5; the full reconstruction is not
  complete. See TEST_PLAN.md and R2_ASSET_PLAN.md.

## Changed files

- README.md
- docs/ARCHITECTURE.md
- docs/MISSION_01.md
- docs/TEST_PLAN.md
- docs/R1_LAYOUT.md
- docs/R1_LAYOUT.svg
- docs/R1_VALIDATION.md
- docs/R2_ASSET_PLAN.md
- src/ReplicatedStorage/Shared/GameConfig.luau
- src/ReplicatedStorage/Shared/WorldLayout.luau
- src/ServerScriptService/Bootstrap.server.luau
- src/ServerScriptService/World/Geometry.luau
- src/ServerScriptService/World/Landscape.luau
- src/ServerScriptService/World/Landmarks.luau
- src/ServerScriptService/World/ZooBuilder.luau
- studio/InstallZoo.command.luau
- tools/generate_installer.py
- tools/generate_layout_diagram.py
- tests/check_world.py
- tests/roblox_mock.luau
- tests/world.spec.luau
- tests/installer.spec.luau
