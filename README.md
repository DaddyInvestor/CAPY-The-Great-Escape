# CAPY-The-Great-Escape
CAPY-The-Great-Escape

## CAPY-M01A FOUNDATION

CAPY ตัวตึง: The Great Escape

Genre: Story + Open World Adventure
Style: 3D Cartoon Thai Khao Yai
Mission: 01A — Zoo World Foundation

This is a zoo prototype, not yet the complete escape game.

### Getting started

1. Install [Rojo 7.7.1](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1)
   for your platform, put `rojo` on your `PATH`, and install its matching Roblox
   Studio plugin. Studio must run on a supported Windows or macOS machine.
2. Open a new Roblox Studio Baseplate. Delete its default `SpawnLocation` so
   players spawn at the generated `CapySpawn`; keep the Baseplate if desired.
3. From the repository root, run:

   ```sh
   rojo serve default.project.json
   ```

4. Connect the Rojo Studio plugin to the running server and sync the project.
5. Press Play, then inspect Studio Output and `Workspace/CapyWorld`.

The only running development service is `rojo serve`; restart it for each new
session. No credentials, package installation, DataStore access, or other
services are required for this static prototype.

The server creates Workspace/CapyWorld automatically.

The ground is 420 × 360 studs. Generated geometry is anchored; ground, paths,
buildings, fences, gates, and spawn collide. Pond water and checkpoint markers
are decorative and noncolliding. The pond does not implement swimming.

### Build and static checks

From the repository root:

```sh
mkdir -p build
rojo build default.project.json -o build/CAPY-M01A.rbxlx
```

Open that generated place in Studio as an alternative to live Rojo sync.
`build/` is ignored by Git.

For reproducible headless checks, also install the `luau` and `luau-compile`
binaries from [Luau 0.743](https://github.com/luau-lang/luau/releases/tag/0.743)
on your `PATH`, and install Python 3.10 or newer. Run:

```sh
python3 tests/check_world.py
```

This builds a temporary place, checks Rojo's actual source map, compiles all four
production Luau scripts, and runs the real bootstrap and world builder against
a small mocked Roblox data model. Assertions cover world size, visible part
properties, collision flags, spawn clearance, fence/gate alignment, checkpoint
placement, module references, and rebuilding without duplicates. These checks
do not provide Roblox-aware type checking, rendering, or physics verification.

### Roblox Studio test status

**NOT RUN** in the cloud environment. Follow [docs/TEST_PLAN.md](docs/TEST_PLAN.md)
in Studio before claiming a playtest PASS. Locked gates and visual checkpoints
are expected; this foundation does not implement a playable escape mission.

### Expected environment

- Capybara enclosure
- Water pond
- Visitor walkways
- Security office
- Maintenance shed
- Zoo perimeter
- Locked gates
- Spawn point
- Three checkpoint markers
- Tropical trees

### Important limitations

M01A does not yet contain:
- Four-legged capybara controller
- Guard AI
- Working escape puzzles
- Functional checkpoint saving
- Rewards or DataStore saving

The default Roblox avatar is temporary.

See docs/TEST_PLAN.md before reporting Studio PASS.
