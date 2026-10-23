--!strict
local G = require(script.Parent.Geometry)
local Landscape = {}

function Landscape.paths(world: Model, layout, style)
    local paths = G.model(world, "VisitorPaths")
    local centers = {}
    local segments = {}
    for _, zone in layout.Zones do centers[zone.Id] = zone.Center end
    for index, route in layout.Routes do
        local path = G.model(paths, route.From .. "_" .. route.To)
        path:SetAttribute("From", route.From)
        path:SetAttribute("To", route.To)
        path:SetAttribute("Width", route.Width)
        local a, b = route.Via or centers[route.From], centers[route.To]
        local steps = math.ceil(((route.Control - a).Magnitude + (b - route.Control).Magnitude) / 10)
        local previous = a
        for i = 1, steps do
            local current = G.curve(a, route.Control, b, i / steps)
            local segment = G.beam(path, "WalkSurface", previous, current, route.Width, 0.3,
                style.Sand, Enum.Material.Sandstone)
            segment:SetAttribute("Start", previous)
            segment:SetAttribute("Finish", current)
            segment:SetAttribute("Width", route.Width)
            G.beam(path, "GravelShoulder", previous - Vector3.new(0, 0.7, 0),
                current - Vector3.new(0, 0.7, 0), route.Width + 3, 1.1,
                style.Stone, Enum.Material.Pebble)
            G.disc(path, "RoundJoin", current.X, current.Z, route.Width / 2, route.Width / 2,
                current.Y + 0.15, 0.3, style.Sand, Enum.Material.Sandstone)
            table.insert(segments, {A = previous, B = current, Width = route.Width, Route = index})
            previous = current
        end
        G.disc(path, "RoundStart", a.X, a.Z, route.Width / 2, route.Width / 2,
            a.Y + 0.15, 0.3, style.Sand, Enum.Material.Sandstone)
    end
    -- The entrance promenade continues from the graph node to the closed outer gate.
    local a, b = centers.G, Vector3.new(205, 0.6, 235)
    G.beam(paths, "EntrancePromenade", a, b, 24, 0.3, style.Sand, Enum.Material.Sandstone)
    G.beam(paths, "PromenadeRoadbed", a - Vector3.new(0, 0.7, 0), b - Vector3.new(0, 0.7, 0),
        27, 1.1, style.Stone, Enum.Material.Pebble)
    table.insert(segments, {A = a, B = b, Width = 24, Route = 11})
    return segments
end

function Landscape.clear(p: Vector3, radius: number, segments, reservations): boolean
    for _, segment in segments do
        if G.distanceToSegment(p, segment.A, segment.B) < segment.Width / 2 + radius + 3 then return false end
    end
    for _, area in reservations do
        if math.abs(p.X - area.Center.X) < area.Size.X / 2 + radius + 4
            and math.abs(p.Z - area.Center.Z) < area.Size.Z / 2 + radius + 4 then return false end
    end
    -- Keep habitat/spawn/pond, plaza and entrance compositions intentional.
    if p.X < -116 and p.Z < -45 then return false end
    if (p - Vector3.new(75, p.Y, -125)).Magnitude < 43 + radius then return false end
    if p.X > 140 and p.Z > 155 then return false end
    return true
end

local function tree(parent: Model, index: number, p: Vector3, kind: number, style)
    local treeModel = G.model(parent, "Tree" .. index)
    treeModel:SetAttribute("Species", ({"FanPalm", "RainTree", "Bamboo"})[kind])
    local height = 15 + (index % 5) * 2
    if kind == 1 then
        G.beam(treeModel, "PalmTrunk", p, p + Vector3.new(2, height, 0), 2.3, 2.3, style.Wood, Enum.Material.Wood)
        for leaf = 1, 7 do
            local angle = leaf * math.pi * 2 / 7
            local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
            local palm = G.ellipsoid(treeModel, "PalmFrond", p + Vector3.new(2, height, 0) + direction * 5,
                Vector3.new(4, 1.6, 15), Color3.fromRGB(54, 137, 79), Enum.Material.Grass, false)
            palm.CFrame = CFrame.lookAt(palm.Position, palm.Position + direction) * CFrame.Angles(-0.18, 0, 0)
        end
    elseif kind == 2 then
        G.beam(treeModel, "Trunk", p, p + Vector3.new(0, height, 0), 3, 3, style.DarkWood, Enum.Material.Wood)
        for crown = 1, 3 do
            local offset = Vector3.new((crown - 2) * 5, height + 1 - math.abs(crown - 2) * 2, (crown % 2) * 4)
            G.ellipsoid(treeModel, "LayeredCrown", p + offset, Vector3.new(17, 9 + crown, 13),
                Color3.fromRGB(58 + crown * 8, 128 + crown * 10, 66), Enum.Material.Grass, false)
        end
    else
        for stem = 1, 4 do
            local offset = Vector3.new((stem % 2) * 2, 0, math.floor(stem / 2) * 1.4)
            G.beam(treeModel, "BambooStem", p + offset, p + offset + Vector3.new(1, height - stem, 0),
                0.8, 0.8, Color3.fromRGB(117, 157, 64), Enum.Material.Wood)
            G.ellipsoid(treeModel, "BambooSpray", p + offset + Vector3.new(0, height - stem, 0),
                Vector3.new(8, 5, 4), Color3.fromRGB(87, 154, 73), Enum.Material.Grass, false)
        end
    end
end

function Landscape.terrain(world: Model, config, layout, segments)
    local style = config.Style
    local terrain = G.model(world, "Terrain")
    G.part(terrain, "ParkGround", Vector3.new(config.World.Width, 4, config.World.Depth),
        CFrame.new(0, -2, 0), style.Grass, Enum.Material.Grass)
    -- Overlapping low elliptical terraces soften zone boundaries without touching shared Terrain.
    for i, zone in layout.Zones do
        if zone.Id ~= "A" and zone.Id ~= "C" then
            G.disc(terrain, "Meadow_" .. zone.Id, zone.Center.X, zone.Center.Z,
                zone.Radius, zone.Radius * 0.71, 0.12, 0.8,
                if i % 2 == 0 then style.GrassLight else style.Grass, Enum.Material.Grass)
        end
    end
    local vegetation = G.model(world, "Vegetation")
    local index = 0
    for row = 0, 9 do
        for column = 0, 13 do
            local x = -263 + column * 39 + math.sin(row * 13 + column * 7) * 8
            local z = -194 + row * 43 + math.cos(row * 5 + column * 9) * 7
            local p = Vector3.new(x, 0, z)
            if Landscape.clear(p, 11, segments, layout.Reservations) then
                index += 1
                tree(vegetation, index, p, 1 + index % 3, style)
                if index % 2 == 0 then
                    G.ellipsoid(terrain, "StoneCluster", p + Vector3.new(-5, 1.2, 5),
                        Vector3.new(8, 4, 5), style.Stone, Enum.Material.Slate)
                    -- Low stepped berms: 0.2-stud changes rather than sheer rectangular platforms.
                    for tier = 1, 3 do
                        G.disc(terrain, "LowBerm", x, z, 11 - tier * 1.8, 8 - tier,
                            tier * 0.2, 0.8, style.GrassLight, Enum.Material.Grass)
                    end
                end
            end
        end
    end
    -- Background silhouette stays inside the 600 x 500 authored bounds.
    local backdrop = G.model(world, "KhaoYaiBackdrop")
    for i = 1, 7 do
        local x = -249 + (i - 1) * 82
        local height = 43 + (i % 3) * 18
        G.part(backdrop, "MountainRidge", Vector3.new(76, height, 27),
            CFrame.new(x, height / 2 - 1, -235) * CFrame.Angles(0, if i % 2 == 0 then math.pi else 0, 0),
            Color3.fromRGB(90 + i * 3, 128 + i * 2, 109 + i * 3), Enum.Material.Slate, true, "WedgePart")
        for j = 1, 2 do
            tree(backdrop, i * 10 + j, Vector3.new(x - 18 + j * 11, 0, -219), 2, style)
        end
    end
end

function Landscape.pond(parent: Model, style)
    local pond = G.model(parent, "HabitatPond")
    -- Overlapping lobes produce a kidney-shaped outline with an uneven sandy shoreline.
    local lobes = {{-226, -166, 21, 16}, {-208, -172, 24, 18}, {-194, -161, 16, 14}}
    for i, lobe in lobes do
        G.disc(pond, "SandBank" .. i, lobe[1], lobe[2], lobe[3] + 4, lobe[4] + 4,
            0.22, 0.5, style.Sand, Enum.Material.Sand)
        local water = G.disc(pond, "WaterLobe" .. i, lobe[1], lobe[2], lobe[3], lobe[4],
            0.38, 0.13, style.Water, Enum.Material.SmoothPlastic, false)
        water.Transparency = 0.12
    end
    for i = 1, 8 do
        local x, z = -246 + i * 7, -187 + math.sin(i) * 3
        G.ellipsoid(pond, "ShoreRock", Vector3.new(x, 1.0, z), Vector3.new(5, 3, 4),
            style.Stone, Enum.Material.Slate)
        G.beam(pond, "Reeds", Vector3.new(x + 2, 0.3, z + 3), Vector3.new(x + 2, 4, z + 3),
            0.5, 0.5, style.GrassLight, Enum.Material.Grass, false)
    end
end

return Landscape
