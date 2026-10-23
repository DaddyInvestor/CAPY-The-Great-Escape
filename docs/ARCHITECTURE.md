# CAPY Architecture

## Technology

Roblox Studio
Luau
Rojo
GitHub

## Source Mapping

src/ReplicatedStorage/Shared
-> ReplicatedStorage.Shared

src/ServerScriptService
-> ServerScriptService

## Bootstrap

Bootstrap.server.luau executes on the server.

It requires World/ZooBuilder.luau.

ZooBuilder.Build() creates Workspace/CapyWorld.

## World Generation

The world builder is deterministic.

Calling Build() again replaces the previously
generated CapyWorld instead of duplicating it.

## Configuration

GameConfig.luau:
World dimensions, player tuning, guard tuning,
colors and appearance.

MissionConfig.luau:
Mission ID, states, planned routes,
checkpoints and rewards.

## Security Policy

Future mission completion, rewards, checkpoints
and interactions must be validated server-side.

Never trust client-provided rewards or progress.
