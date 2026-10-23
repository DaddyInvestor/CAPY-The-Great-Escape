--!strict
local G = require(script.Parent.Geometry)
local Landmarks = {}

local function pavilion(parent: Model, name: string, x: number, z: number, w: number,
    d: number, style, enclosed: boolean?): Model
    local house = G.model(parent, name)
    house:SetAttribute("R2DetailReserved", true)
    G.part(house, "TimberDeck", Vector3.new(w, 0.5, d), CFrame.new(x, 0.25, z),
        style.Wood, Enum.Material.WoodPlanks)
    for _, dx in {-w / 2 + 1, w / 2 - 1} do
        for _, dz in {-d / 2 + 1, d / 2 - 1} do
            G.part(house, "TimberColumn", Vector3.new(1.8, 15, 1.8), CFrame.new(x + dx, 8, z + dz),
                style.DarkWood, Enum.Material.Wood)
            G.part(house, "ColumnFoot", Vector3.new(3, 1.5, 3), CFrame.new(x + dx, 0.75, z + dz),
                style.Stone, Enum.Material.Sandstone)
        end
    end
    if enclosed then
        G.part(house, "CreamBackWall", Vector3.new(w - 2, 11, 1), CFrame.new(x, 6, z - d / 2 + 1),
            style.Cream, Enum.Material.Plaster)
        for _, dx in {-w / 2 + 1, w / 2 - 1} do
            G.part(house, "LowSideWall", Vector3.new(1, 5, d - 2), CFrame.new(x + dx, 3, z),
                style.Cream, Enum.Material.Plaster)
            G.beam(house, "WindowLintel", Vector3.new(x + dx, 12, z - d / 2),
                Vector3.new(x + dx, 12, z + d / 2), 1.3, 1.3, style.Wood, Enum.Material.Wood)
        end
    end
    -- Two pitched gables, a broad eave, a smaller upper roof and rising end ornaments.
    for tier = 1, 2 do
        local roofW, roofD = w + 5 - (tier - 1) * 7, d + 6 - (tier - 1) * 7
        local base = 15 + (tier - 1) * 4
        G.part(house, "EaveBand", Vector3.new(roofW, 0.7, roofD), CFrame.new(x, base, z),
            style.DarkWood, Enum.Material.Wood)
        for _, side in {-1, 1} do
            G.part(house, "TerracottaGable", Vector3.new(roofW, 5, roofD / 2),
                CFrame.new(x, base + 2.5, z + side * roofD / 4)
                    * CFrame.Angles(0, if side == 1 then math.pi else 0, 0),
                style.Roof, Enum.Material.Brick, true, "WedgePart")
        end
    end
    G.beam(house, "RoofRidge", Vector3.new(x - w / 2, 24, z), Vector3.new(x + w / 2, 24, z),
        1.2, 1.2, style.Cream, Enum.Material.Wood)
    for _, side in {-1, 1} do
        G.beam(house, "RaisedGableTip", Vector3.new(x + side * w / 2, 24, z),
            Vector3.new(x + side * (w / 2 + 2), 28, z), 1, 1, style.Cream, Enum.Material.Wood)
    end
    return house
end

function Landmarks.build(world: Model, layout, style)
    local zones = G.model(world, "Zones")
    for _, definition in layout.Zones do
        local zone = G.model(zones, definition.Id .. "_" .. string.gsub(definition.Name, " ", ""))
        zone:SetAttribute("ZoneId", definition.Id)
        zone:SetAttribute("Center", definition.Center)
        zone:SetAttribute("Radius", definition.Radius)
        zone:SetAttribute("DisplayName", definition.Name)
    end
    local a = zones.A_CapybaraHabitat
    local shelter = pavilion(a, "HabitatShelter", -246, -79, 32, 24, style)
    G.sign(shelter, "HabitatSign", Vector3.new(-246, 12, -65), "CAPY SANCTUARY", style.DarkWood, 25)
    -- A recognizable sculptural anchor, explicitly not a controller or animal AI.
    local statue = G.model(a, "CapySculpture")
    statue:SetAttribute("DecorativeOnly", true)
    local brown = Color3.fromRGB(171, 125, 84)
    G.ellipsoid(statue, "Body", Vector3.new(-249, 4, -143), Vector3.new(10, 6, 6), brown, Enum.Material.SmoothPlastic)
    G.ellipsoid(statue, "Head", Vector3.new(-243, 5, -143), Vector3.new(5, 5, 5), brown, Enum.Material.SmoothPlastic)
    for _, dz in {-1.7, 1.7} do
        for _, dx in {-252, -246} do
            G.part(statue, "Leg", Vector3.new(1.5, 2.5, 1.5), CFrame.new(dx, 1.25, -143 + dz), brown, Enum.Material.SmoothPlastic)
        end
        G.ellipsoid(statue, "Ear", Vector3.new(-244, 7.3, -143 + dz), Vector3.new(1.3, 1.7, 1), brown, Enum.Material.SmoothPlastic)
        G.ellipsoid(statue, "Eye", Vector3.new(-241.3, 5.8, -143 + dz), Vector3.new(0.6, 0.6, 0.6),
            style.DarkWood, Enum.Material.SmoothPlastic, false)
    end
    local b = zones.B_AnimalWalkway
    local canopy = pavilion(b, "CanopyWalk", -59, -163, 36, 20, style)
    G.sign(canopy, "WalkwaySign", Vector3.new(-59, 12, -151), "WILDLIFE WALK", style.DarkWood, 28)
    local c = zones.C_VisitorPlaza
    G.disc(c, "PlazaPaving", 75, -125, 36, 31, 0.52, 0.8, style.Cream, Enum.Material.Sandstone)
    G.disc(c, "PlazaInlay", 75, -125, 30, 26, 0.55, 0.3, style.Sand, Enum.Material.Sandstone)
    G.disc(c, "LotusFountainBowl", 74, -150, 8, 6, 2, 1.5, style.Cream, Enum.Material.Sandstone)
    G.disc(c, "FountainWater", 74, -150, 6.7, 4.7, 2.1, 0.2, style.Water, Enum.Material.Glass, false)
    G.ellipsoid(c, "LotusBud", Vector3.new(74, 4, -150), Vector3.new(4, 6, 4), style.Flower, Enum.Material.SmoothPlastic)
    local kiosk = pavilion(c, "VisitorKioskAnchor", 107, -166, 24, 18, style)
    G.sign(kiosk, "MapSign", Vector3.new(107, 11, -155), "PARK MAP / INFO", style.DarkWood)
    local d = zones.D_ZooSecurity
    local office = pavilion(d, "SecurityOffice", 215, -166, 46, 28, style, true)
    G.sign(office, "SecuritySign", Vector3.new(215, 12, -150), "RANGER STATION", style.DarkWood, 28)
    local e = zones.E_MaintenanceYard
    local shed = pavilion(e, "MaintenanceShed", -225, 14, 38, 24, style, true)
    G.sign(shed, "MaintenanceSign", Vector3.new(-225, 12, 28), "MAINTENANCE", style.DarkWood, 26)
    G.disc(e, "ServiceApron", -211, 38, 39, 22, 0.2, 0.6, style.Stone, Enum.Material.Cobblestone)
    for i = 1, 3 do
        G.part(e, "SupplyCrate", Vector3.new(5, 5, 5), CFrame.new(-257 + i * 6, 2.5, 43),
            style.Wood, Enum.Material.WoodPlanks)
    end
    local f = zones.F_TropicalGarden
    local sala = pavilion(f, "GardenSala", 63, 48, 27, 24, style)
    G.sign(sala, "GardenSign", Vector3.new(63, 12, 62), "TROPICAL GARDEN", style.DarkWood, 24)
    -- Petal beds arranged around the sala rather than across circulation corridors.
    for i = 1, 5 do
        G.disc(f, "PetalBed", 75 + math.sin(i) * 9, 70 + i * 4, 6, 4, 0.4, 0.6,
            style.DarkWood, Enum.Material.Ground, false)
        for j = 1, 3 do
            G.ellipsoid(f, "FlowerClump", Vector3.new(73 + math.sin(i) * 9 + j * 1.5, 1, 70 + i * 4),
                Vector3.new(3, 1.5, 3), if i % 2 == 0 then style.Flower else style.Cream, Enum.Material.Grass, false)
        end
    end
    local g = zones.G_GrandZooEntrance
    for _, x in {182, 228} do
        G.part(g, "EntryStonePillar", Vector3.new(5, 19, 5), CFrame.new(x, 9.5, 214), style.Cream, Enum.Material.Sandstone)
        G.part(g, "EntryPillarCap", Vector3.new(8, 1.5, 8), CFrame.new(x, 19, 214), style.Roof, Enum.Material.Brick)
    end
    G.beam(g, "GatewayLintel", Vector3.new(180, 22, 214), Vector3.new(230, 22, 214),
        4, 4, style.DarkWood, Enum.Material.Wood)
    G.sign(g, "GrandEntrySign", Vector3.new(205, 24, 211), "CAPY WILDLIFE PARK", style.DarkWood, 42)
    local tickets = pavilion(g, "TicketKiosk", 162, 200, 18, 19, style)
    G.sign(tickets, "TicketSign", Vector3.new(162, 12, 211), "TICKETS", style.DarkWood, 17)
    local h = zones.H_ForestPerimeter
    local lookout = pavilion(h, "ForestLookout", -235, 177, 22, 22, style)
    G.sign(lookout, "ForestSign", Vector3.new(-235, 12, 190), "FOREST TRAIL", style.DarkWood)
    -- R2 placement metadata is preserved with the saved edit-mode world.
    local reservations = G.model(world, "R2Reservations")
    for _, area in layout.Reservations do
        local record = G.model(reservations, area.Id)
        record:SetAttribute("Center", area.Center)
        record:SetAttribute("Size", area.Size)
        record:SetAttribute("Phase", "R2")
    end
end

return Landmarks
