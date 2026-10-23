-- Executes the imported bootstrap and builder against the mock data model.
-- Assertions cover generated data; Studio must validate visuals and physics.
local checks = 0
local function check(condition, message)
    assert(condition, message)
    checks += 1
end
local function basePart(object)
    return object.ClassName == "Part" or object.ClassName == "SpawnLocation"
end
local function edge(part, axis, side)
    return part.Position[axis] + side * part.Size[axis] / 2
end
local function overlaps(a, b)
    for _, axis in {"X", "Y", "Z"} do
        if edge(a, axis, 1) <= edge(b, axis, -1)
            or edge(b, axis, 1) <= edge(a, axis, -1) then return false end
    end
    return true
end

local unrelated = child(Workspace, "Model", "UserContent")
local bootstrap = resolve("game.ServerScriptService.Bootstrap")
loaders[bootstrap](bootstrap)
local world = Workspace:WaitForChild("CapyWorld")
check(world:GetAttribute("Generated") == true, "World is not tagged as generated")
check(world:GetAttribute("Mission") == "CAPY-M01A", "Wrong mission tag")
local ground = world.Terrain.GrassGround
check(ground.Size.X == 420 and ground.Size.Z == 360, "Expected 420 x 360 ground")
check(edge(ground, "Y", 1) == 0, "Ground must support the world at Y=0")
local partCount = 0
for _, part in world:GetDescendants() do
    if basePart(part) then
        partCount += 1
        check(part.Anchored == true, part.Name .. " must be anchored")
        check(part.Size.X > 0 and part.Size.Y > 0 and part.Size.Z > 0, "Invalid dimensions")
        check(part.Transparency < 1, part.Name .. " is invisible")
        check(edge(part, "X", -1) >= -210 and edge(part, "X", 1) <= 210
            and edge(part, "Z", -1) >= -180 and edge(part, "Z", 1) <= 180,
            part.Name .. " extends outside the zoo")
        check(type(part.CanCollide) == "boolean", part.Name .. " has no explicit collision policy")
    end
end
check(partCount > 50, "Expected actual environment geometry")
local pen = world.CapyEnclosure
local spawn = pen.CapySpawn
check(spawn.ClassName == "SpawnLocation" and spawn.Neutral and spawn.Enabled,
    "Spawn must be an enabled neutral SpawnLocation")
check(spawn.CanCollide, "Spawn must support the avatar")
check(edge(spawn, "X", -1) > -179 and edge(spawn, "X", 1) < -81
    and edge(spawn, "Z", -1) > -139 and edge(spawn, "Z", 1) < -51,
    "Spawn is outside enclosure")
-- Reserve an R15-sized vertical clearance volume above the spawn.
local clearance = {Position = Vector3.new(spawn.Position.X, edge(spawn, "Y", 1) + 3.5,
    spawn.Position.Z), Size = Vector3.new(5, 7, 5)}
for _, part in world:GetDescendants() do
    if basePart(part) and part.CanCollide and part ~= spawn then
        check(not overlaps(clearance, part), "Spawn obstructed by " .. part.Name)
    end
end
for _, fence in pen:GetChildren() do
    if string.find(fence.Name, "Fence") then
        check(fence.CanCollide and fence.Size.Y == 7, "Enclosure fence must be solid and 7 studs tall")
    end
end
local smallGate = pen.LockedPenGate
check(smallGate.CanCollide and smallGate:GetAttribute("Locked"), "Pen gate must be locked and solid")
check(edge(pen.EastFenceNorth, "Z", 1) == edge(smallGate, "Z", -1)
    and edge(smallGate, "Z", 1) == edge(pen.EastFenceSouth, "Z", -1),
    "Pen gate does not fill the fence opening")
local mainGate = world.ExitMarkers.LockedMainGate
check(mainGate.CanCollide and mainGate:GetAttribute("Locked"), "Main gate must be locked and solid")
local perimeter = world.Perimeter
for _, wall in perimeter:GetChildren() do
    check(wall.CanCollide and wall.Size.Y == 18, "Perimeter must be solid and 18 studs tall")
end
check(edge(perimeter.SouthWallLeft, "X", 1) == edge(mainGate, "X", -1)
    and edge(mainGate, "X", 1) == edge(perimeter.SouthWallRight, "X", -1),
    "Main gate does not fill the perimeter opening")
check(edge(perimeter.NorthWall, "X", -1) == edge(perimeter.WestWall, "X", -1)
    and edge(perimeter.NorthWall, "X", 1) == edge(perimeter.EastWall, "X", 1)
    and edge(perimeter.WestWall, "Z", -1) == -180
    and edge(perimeter.WestWall, "Z", 1) == 180, "Perimeter is incomplete")
for _, name in {"SecurityOffice", "MaintenanceShed"} do
    local building = world[name]
    check(building.Floor.CanCollide and building.Roof.CanCollide, name .. " is not solid")
    check(edge(building.FrontWallRight, "X", -1) - edge(building.FrontWallLeft, "X", 1) == 12,
        name .. " needs a 12-stud doorway")
    local sign = building:WaitForChild(if name == "SecurityOffice" then "SecuritySign" else "ShedSign")
    check(sign.SurfaceGui.Face == Enum.NormalId.Back, name .. " sign must face the entrance (+Z)")
end
check(not world.Pond.WaterVisual.CanCollide and world.Pond.Bridge.CanCollide,
    "Visual pond water must not collide; bridge must collide")
check(not pen.CapyPool.CanCollide, "Decorative pool water must not collide")
check(pen.PenWelcome.SurfaceGui.Face == Enum.NormalId.Back, "Enclosure sign must face into the pen")
check(#world.VisitorPaths:GetChildren() == 4, "Expected four visitor paths")
for _, path in world.VisitorPaths:GetChildren() do
    check(path.CanCollide and edge(path, "Y", 1) > 0, path.Name .. " must be visible above the ground")
end
local mission = require(resolve("game.ReplicatedStorage.Shared.MissionConfig"))
check(#world.CheckpointMarkers:GetChildren() == #mission.Checkpoints, "Checkpoint count mismatch")
for _, id in mission.Checkpoints do
    local marker = world.CheckpointMarkers:WaitForChild(id)
    check(marker:GetAttribute("CheckpointId") == id and not marker.CanCollide,
        id .. " must be a nonblocking checkpoint marker")
    for _, part in world:GetDescendants() do
        if basePart(part) and part ~= marker and part.CanCollide then
            check(not overlaps(marker, part), id .. " is hidden inside " .. part.Name)
        end
    end
end
local firstCount = #world:GetDescendants()
local builder = require(resolve("game.ServerScriptService.World.ZooBuilder"))
local rebuilt = builder.Build()
check(world.Parent == nil and rebuilt ~= world, "Build must replace the previous generated world")
check(#rebuilt:GetDescendants() == firstCount, "Rebuild changed object count")
check(unrelated.Parent == Workspace, "Rebuild destroyed unrelated user content")
local count = 0
for _, object in Workspace:GetChildren() do
    if object.Name == "CapyWorld" then count += 1 end
end
check(count == 1, "Build created duplicate worlds")
print(string.format("PASS: %d headless assertions; %d generated parts; bootstrap/imports and rebuild checked", checks, partCount))
