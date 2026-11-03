# CAPY-The-Great-Escape

## เปิดสวนสัตว์ใน Roblox Studio แบบก๊อปโค้ดครั้งเดียว (ง่ายที่สุด)

**ไม่ต้องใช้ Rojo, ZIP หรือ Terminal**

**POLISH-1: 600 × 500 studs / 8 โซน / ภารกิจช่วย Mango — Studio Playtest: NOT RUN**

1. เปิดไฟล์ [STUDIO_ONE_PASTE.lua](STUDIO_ONE_PASTE.lua) ใน Branch นี้
2. กดปุ่ม **Copy raw file** ของ GitHub เพื่อคัดลอกโค้ดทั้งหมด
3. เปิด Roblox Studio -> สร้าง **Baseplate** ใหม่
4. เปิด **View -> Command Bar** แล้ววางโค้ดทั้งหมด กด **Enter** ตอนอยู่ในโหมด Edit
5. ตรวจว่า Explorer มี **Workspace -> CapyWorld**; กด **File -> Save to File** เก็บเป็น .rbxl
6. กด Play ดูฉากและตำแหน่งเกิด (ลบ SpawnLocation เริ่มต้นของ Baseplate หากมี เพื่อใช้ CapySpawn)

**ข้อควรทราบ:** ติดตั้งฉากใน Edit Mode แล้ว Save จากนั้นกด Play เพื่อเริ่มภารกิจให้อาหาร Mango → ซ่อมปั๊ม → คุยกับ Mali → เปิดประตู ความคืบหน้าอยู่เฉพาะรอบนี้ ยังไม่ใช่เกมหนีฉบับเต็ม และยังไม่ได้ทดสอบจริงใน Studio

---

CAPY-The-Great-Escape

## CAPY POLISH-1 — Mango's Morning Rescue

An incremental upgrade of the existing 600 × 500 park, with all eight zones,
curved circulation, habitat, pond, buildings, spawn, three markers, forest and
mountain backdrop retained. **Development build; not release-ready.**

### One-paste installation

Open [STUDIO_ONE_PASTE.lua](STUDIO_ONE_PASTE.lua) on GitHub, select **Raw**, copy
its entire contents into Roblox Studio's Command Bar in **Edit Mode**, and execute.
The park appears immediately. Save the place, then press **Play** for the quest.
No Rojo, HTTP permissions, external assets or package installation are required.
The installer also saves a server Script and client GUI/LocalScript template
inside `CapyWorld.Runtime`, so the quest works after reopening the saved place.

Only CAPY-owned `CapyWorld` models are replaced. An unowned name collision is
refused. Construction and runtime-source preparation finish before the previous
world is removed. Shared Terrain, Lighting and unrelated models are preserved.
Session players are assigned the park spawn; unrelated SpawnLocations are retained.

### What to do in Play Mode

1. Feed Mango at the habitat feeder. Use the native keyboard/gamepad/touch prompt.
2. Find the blue garden pump and hold its repair prompt.
3. Talk to Ranger Mali on the east side of the visitor plaza.
4. Present your trail pass at the grand entrance; the portcullis lifts.
5. Optional: follow the forest hint to collect a postcard for the journal.

Mango reacts to breakfast; Mali waves; the pump indicator changes. A collapsible,
width-constrained journal shows the next objective, distance, progress and dialogue.
The default Roblox avatar, controller, camera and Animate script remain in use,
with subtle eased FOV feedback. Session respawns use habitat/plaza/entrance
checkpoints according to quest progress. Rejoining or rebuilding resets progress.

The gate is shared and stays open after the first successful completion, while
completion remains validated separately per player. Other players can explore
through the open gate but cannot skip their mission steps. There is no currency,
DataStore saving, custom capybara controller or roaming guard AI. Pond water remains
decorative. The two other future escape anchors remain closed.

### Modular development and checks

Install [Rojo 7.7.1](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1),
[Luau 0.743](https://github.com/luau-lang/luau/releases/tag/0.743) (`luau` and
`luau-compile`), and Python 3.10+ on PATH. From this repository root:

```sh
rojo serve default.project.json
```

Connect the Rojo Studio plugin and press Play. Bootstrap starts the same server
quest module; StarterPlayerScripts runs the same client source. To refresh and
check the generated installer:

```sh
python3 tools/generate_installer.py
python3 tools/generate_layout_diagram.py
python3 tests/check_world.py
```

The installer has no runtime module downloads. Its saved sources are generated
from the modular gameplay and client code, not separately maintained copies.
The source hash covers world, server and client sources. Build a place with
`rojo build default.project.json -o build/CAPY-POLISH.rbxlx` after creating `build/`.

[Iteration audit, ranked weaknesses, pass reviews and before/after evidence](docs/POLISH_01_REVIEW.md)

[Studio acceptance and regression procedure](docs/TEST_PLAN.md)

[Architecture](docs/ARCHITECTURE.md) · [Original layout plan](docs/R1_LAYOUT.md)

### Validation boundary

**Actual Studio Edit Mode installation and Studio Playtest: NOT RUN.** No Studio
screenshots or FPS measurements were captured. Compilation and the mocked data-model
checks exercise real source but do not verify rendering, physics, real avatar
movement, touch input, network latency, or Studio's Script.Source installation.
Those remain release blockers; passing static checks is not visual approval.

The original R1 documents/results are historical baseline evidence. This iteration
implements a short introductory quest, not the complete escape campaign.
