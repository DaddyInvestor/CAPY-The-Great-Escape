--!strict
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("GameConfig"))
local Layout = require(Shared:WaitForChild("WorldLayout"))
local G = require(script.Parent.Geometry)
local Landscape = require(script.Parent.Landscape)
local Landmarks = require(script.Parent.Landmarks)

local StoryDetails = require(script.Parent.StoryDetails)

local ZooBuilder = {}

local function gate(parent: Model, id: string, a: Vector3, b: Vector3, style)
    local result = G.model(parent, id)
    result:SetAttribute("FutureRoute", id)
    result:SetAttribute("Locked", true)
    result:SetAttribute("Start", a)
    result:SetAttribute("Finish", b)
    G.fence(result, "GateFrame", a, b, 12, style.DarkWood)
    local count = math.ceil((b - a).Magnitude / 2.2)
    for i = 1, count - 1 do
        G.part(result, "LockedGateBar", Vector3.new(0.8, 10, 0.8),
            CFrame.new(a:Lerp(b, i / count) + Vector3.new(0, 6, 0)), style.Wood, Enum.Material.Wood)
    end
    local center = (a + b) / 2
    G.part(result, "LockPlate", Vector3.new(2.5, 3, 2.5), CFrame.new(center + Vector3.new(0, 6, 0)),
        style.Roof, Enum.Material.Metal)
    local sign = G.sign(result, "FutureRouteSign", center + Vector3.new(0, 16, 0),
        string.gsub(id, "_", " ") .. " / FUTURE", style.DarkWood, 26)
    if a.X == b.X then sign.CFrame *= CFrame.Angles(0, math.pi / 2, 0) end
    return result
end

local function boundary(world: Model, style)
    local perimeter = G.model(world, "Perimeter")
    local function fence(name, ax, az, bx, bz)
        return G.fence(perimeter, name, Vector3.new(ax, 0, az), Vector3.new(bx, 0, bz), 12, style.Wood)
    end
    fence("NorthWest", -282, -214, -264, -214)
    fence("NorthEast", -246, -214, 282, -214)
    fence("East", 282, -214, 282, 235)
    fence("SouthEast", 222, 235, 282, 235)
    fence("SouthWest", -282, 235, 188, 235)
    fence("WestSouth", -282, 81, -282, 235)
    fence("WestNorth", -282, -214, -282, 59)
    local routes = G.model(world, "FutureEscapeRoutes")
    gate(routes, "MAIN_GATE", Vector3.new(188, 0, 235), Vector3.new(222, 0, 235), style)
    gate(routes, "MAINTENANCE_TUNNEL", Vector3.new(-282, 0, 59), Vector3.new(-282, 0, 81), style)
    gate(routes, "FENCE_ESCAPE", Vector3.new(-264, 0, -214), Vector3.new(-246, 0, -214), style)
    -- Tunnel mouth is a sealed scenic arch, with no escape interaction or terrain excavation.
    G.part(routes.MAINTENANCE_TUNNEL, "ServiceArch", Vector3.new(5, 4, 28),
        CFrame.new(-282, 14, 70), style.Stone, Enum.Material.Slate)
end

local function habitat(world: Model, style)
    local pen = G.model(world, "CapyEnclosure")
    local points = {
        Vector3.new(-267, 0, -197), Vector3.new(-240, 0, -205), Vector3.new(-139, 0, -192),
        Vector3.new(-120, 0, -162), Vector3.new(-120, 0, -138), Vector3.new(-120, 0, -112),
        Vector3.new(-120, 0, -70), Vector3.new(-150, 0, -49), Vector3.new(-240, 0, -54),
        Vector3.new(-269, 0, -89),
    }
    for i, a in points do
        if i ~= 5 then G.fence(pen, "HabitatFence" .. i, a, points[i % #points + 1], 7, style.Wood) end
    end
    local entry = G.model(pen, "OpenHabitatGate")
    entry:SetAttribute("Traversable", true)
    entry:SetAttribute("ClearWidth", 23.8)
    G.fence(entry, "NorthOpenLeaf", points[5], points[5] + Vector3.new(8, 0, 0), 7, style.DarkWood)
    G.fence(entry, "SouthOpenLeaf", points[6], points[6] + Vector3.new(8, 0, 0), 7, style.DarkWood)
    G.beam(entry, "OverheadWelcome", Vector3.new(-120, 12, -138), Vector3.new(-120, 12, -112),
        1.8, 2, style.DarkWood, Enum.Material.Wood)
    local sign = G.sign(entry, "HabitatEntrySign", Vector3.new(-119, 14, -125), "CAPY HABITAT", style.DarkWood, 24)
    sign.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
    Landscape.pond(pen, style)
    local spawn = G.part(pen, "CapySpawn", Vector3.new(8, 1, 8), CFrame.new(Layout.Spawn),
        style.Sand, Enum.Material.Sandstone, true, "SpawnLocation") :: SpawnLocation
    spawn.Enabled = true
    spawn.Neutral = true
    spawn.Duration = 0
    G.beam(pen, "SpawnTrail", Vector3.new(-218, 0.6, -115), Vector3.new(-190, 0.6, -125),
        12, 0.3, style.Sand, Enum.Material.Sandstone)
    G.beam(pen, "SpawnTrailRoadbed", Vector3.new(-218, -0.1, -115), Vector3.new(-190, -0.1, -125),
        15, 1.1, style.Stone, Enum.Material.Pebble)
end

function ZooBuilder.Build(prepare: ((Model) -> ())?): Model
    -- Refuse name collisions rather than deleting user content. M01A legacy ownership
    -- is accepted only so this reconstruction can upgrade the previously supplied world.
    local previous = {}
    for _, object in Workspace:GetChildren() do
        if object.Name == "CapyWorld" then
            local owner = object:GetAttribute("GeneratorId")
            local legacy = owner == nil and object:GetAttribute("Generated") == true
                and object:GetAttribute("Mission") == "CAPY-M01A"
            assert(owner == Layout.GeneratorId or legacy,
                "CapyWorld is not owned by CAPY. Rename or move it before installing; nothing was replaced.")
            table.insert(previous, object)
        end
    end
    -- Build detached first. A construction error leaves the existing world intact.
    local world = G.model(nil, "CapyWorld")
    world:SetAttribute("GeneratorId", Layout.GeneratorId)
    world:SetAttribute("Generated", true)
    world:SetAttribute("Mission", "CAPY-M01A")
    world:SetAttribute("Phase", Layout.Phase)
    world:SetAttribute("Width", Config.World.Width)
    world:SetAttribute("Depth", Config.World.Depth)
    local segments = Landscape.paths(world, Layout, Config.Style)
    Landscape.terrain(world, Config, Layout, segments)
    Landmarks.build(world, Layout, Config.Style)
    boundary(world, Config.Style)
    habitat(world, Config.Style)
    StoryDetails.build(world, Config.Style)
    local markers = G.model(world, "CheckpointMarkers")
    for _, checkpoint in Layout.Checkpoints do
        local marker = G.disc(markers, checkpoint.Id, checkpoint.Position.X, checkpoint.Position.Z,
            2.3, 2.3, checkpoint.Position.Y, 0.12, Color3.fromRGB(255, 199, 79), Enum.Material.Neon, false)
        marker:SetAttribute("CheckpointId", checkpoint.Id)
        marker:SetAttribute("VisualOnly", true)
    end
    if prepare then prepare(world) end
    for _, object in previous do object:Destroy() end
    world.Parent = Workspace
    return world
end

return ZooBuilder
