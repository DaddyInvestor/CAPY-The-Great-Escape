#!/usr/bin/env python3
"""Check Rojo's actual mapping and run production Luau with a small Roblox mock.

This does not simulate Roblox physics, rendering, or Studio playtesting.
Requires rojo, luau, and luau-compile on PATH.
"""

import json
import re
import importlib.util
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)


run("python3", "tools/generate_installer.py", "--check")
run("python3", "tools/generate_layout_diagram.py", "--check")

with tempfile.TemporaryDirectory(prefix="capy-check-") as directory:
    temporary = Path(directory)
    place = temporary / "CAPY-M01A.rbxlx"
    sourcemap = temporary / "sourcemap.json"
    run("rojo", "build", "default.project.json", "-o", str(place))
    run("rojo", "sourcemap", "default.project.json", "--output", str(sourcemap))
    mapping = {}

    def visit(node, path=""):
        current = f"{path}.{node['name']}" if path else "game"
        mapping[current] = node
        for child in node.get("children", []):
            visit(child, current)

    visit(json.loads(sourcemap.read_text()))
    sources = {
        "game.ReplicatedStorage.Shared.GameConfig": (
            "src/ReplicatedStorage/Shared/GameConfig.luau", "ModuleScript"),
        "game.ReplicatedStorage.Shared.MissionConfig": (
            "src/ReplicatedStorage/Shared/MissionConfig.luau", "ModuleScript"),
        "game.ReplicatedStorage.Shared.WorldLayout": (
            "src/ReplicatedStorage/Shared/WorldLayout.luau", "ModuleScript"),
        "game.ServerScriptService.World.Geometry": (
            "src/ServerScriptService/World/Geometry.luau", "ModuleScript"),
        "game.ServerScriptService.World.Landscape": (
            "src/ServerScriptService/World/Landscape.luau", "ModuleScript"),
        "game.ServerScriptService.World.Landmarks": (
            "src/ServerScriptService/World/Landmarks.luau", "ModuleScript"),
        "game.ServerScriptService.World.ZooBuilder": (
            "src/ServerScriptService/World/ZooBuilder.luau", "ModuleScript"),
        "game.ReplicatedStorage.Shared.QuestConfig": (
            "src/ReplicatedStorage/Shared/QuestConfig.luau", "ModuleScript"),
        "game.ServerScriptService.World.StoryDetails": (
            "src/ServerScriptService/World/StoryDetails.luau", "ModuleScript"),
        "game.ServerScriptService.Gameplay.QuestLogic": (
            "src/ServerScriptService/Gameplay/QuestLogic.luau", "ModuleScript"),
        "game.ServerScriptService.Gameplay.QuestServer": (
            "src/ServerScriptService/Gameplay/QuestServer.luau", "ModuleScript"),
        "game.StarterPlayer.StarterPlayerScripts.CapyClient": (
            "src/StarterPlayer/StarterPlayerScripts/CapyClient.client.luau", "LocalScript"),
        "game.ServerScriptService.Bootstrap": (
            "src/ServerScriptService/Bootstrap.server.luau", "Script"),
    }
    for path, (source, class_name) in sources.items():
        node = mapping[path]
        assert node["className"] == class_name, (path, node)
        assert any((ROOT / p).resolve() == ROOT / source
                   for p in node["filePaths"]), (path, node)
    actual_sources = {str(p.relative_to(ROOT)) for p in (ROOT / "src").rglob("*.luau")}
    assert actual_sources == {source for source, _ in sources.values()}
    print("PASS: all 13 production scripts have the expected Rojo path and class", flush=True)
    installer = (ROOT / "STUDIO_ONE_PASTE.lua").read_text()
    embedded_sources = re.findall(r"\[====\[(.*?)\]====\]", installer, re.S)
    assert len(embedded_sources) == 2, "Expected saved server and client sources"
    for source in embedded_sources:
        assert not re.search(r'\brequire\s*\(|HttpGet|GetAsync|InsertService', source)
    installer_body = re.sub(r"\[====\[.*?\]====\]", '"embedded source"', installer, flags=re.S)
    assert not re.search(r'\brequire\s*\(|\bscript\.|WaitForChild|HttpGet|GetAsync|InsertService', installer_body)
    run("luau-compile", "--null", *sorted(actual_sources), "STUDIO_ONE_PASTE.lua")

    chunks = [(ROOT / "tests/roblox_mock.luau").read_text()]
    for path, (source, class_name) in sources.items():
        chunks.append(f"register({json.dumps(path)}, {json.dumps(class_name)}, function(script)\n"
                      + (ROOT / source).read_text() + "\nend)\n")
    chunks.append((ROOT / "tests/world.spec.luau").read_text())
    chunks.append("local function runInstaller()\n" + installer + "\nend\n")
    chunks.append((ROOT / "tests/installer.spec.luau").read_text())
    spec = importlib.util.spec_from_file_location("capy_bundle", ROOT / "tools/generate_installer.py")
    generator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(generator)
    chunks.append("local function startSavedServer(script)\n" + generator.bundle_runtime() + "\nend\n")
    chunks.append((ROOT / "tests/gameplay.spec.luau").read_text())
    bundle = temporary / "world.spec.luau"
    bundle.write_text("\n".join(chunks))
    run("luau", str(bundle))

run("git", "diff", "--check")
print("PASS: git diff --check")
