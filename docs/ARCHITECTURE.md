# CAPY R1 architecture

## Runtime source mapping

`src/ReplicatedStorage/Shared` maps to `ReplicatedStorage.Shared`:

- `GameConfig`: dimensions, colors and future player/guard tuning (not AI).
- `WorldLayout`: eight centers, curved route controls and widths, spawn,
  checkpoints, future escape positions and R2 asset reservations.
- `MissionConfig`: future mission states/routes/rewards and marker IDs.

`src/ServerScriptService` maps to `ServerScriptService`:

- `Bootstrap.server.luau` requires `World.ZooBuilder` and calls `Build()`.
- `Geometry`: anchored primitives, signs, quadratic curves, fences and beams.
- `Landscape`: curved roads/roadbeds, material terraces, trees, pond and backdrop.
- `Landmarks`: zone anchors and reservation metadata.
- `ZooBuilder`: ownership, detached construction, boundaries, spawn and markers.

All scenery uses owned instances under `Workspace.CapyWorld`. Native shared
`Workspace.Terrain` is intentionally untouched. Natural contours are formed from
overlapping elliptical terraces, varied primitive silhouettes and wedge ridges.
This avoids destructive voxel terrain edits on reinstall.

## Edit-mode installer

`tools/generate_installer.py` bundles the same six generation modules in dependency
order into `studio/InstallZoo.command.luau`. It replaces the known local module
imports with local bundled references and rejects unresolved dependencies. The
result does not wait for synced modules, load remote assets, create scripts or
require Play Mode. Its source hash and `--check` mode catch stale generated files.
Bootstrap and future mission logic are deliberately excluded.

`tools/generate_layout_diagram.py` derives an SVG plan from the layout data; it is
an approximate planning diagram, not an in-engine screenshot.

## Replacement contract

`GeneratorId=CAPY-M01A` marks owned worlds. For one-time upgrade compatibility,
legacy worlds with `Generated=true`, `Mission=CAPY-M01A` and no `GeneratorId` are
also accepted. Any unowned `CapyWorld` name collision aborts without replacement.
The next world is constructed detached; an error preserves the previous visible
world. On success, only the old owned world(s) are destroyed and the new one is
parented to Workspace. No random seed, current time or user-specific state changes
placement. Generated geometry is identical across the installer and bootstrap.

## Validation boundary

The headless mock supports only the data-model and math features this builder
uses. It checks generated positions and collision flags; it is not a Roblox
physics engine. The standalone installer is executed without the original source
services. Tests cover repeated replacement, owned legacy upgrades, refused user
name collisions, and an injected construction failure preserving the old world.
Studio validation and R1 visual review remain separate prerequisites for R2.

Future interactions, progress, rewards and checkpoint saving must be validated
server-side. Never trust client-provided rewards or progress.
