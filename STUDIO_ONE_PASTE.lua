-- CAPY ตัวตึง / Mission 01A — ONE PASTE Roblox Studio Installer
-- HOW: Roblox Studio > View > Command Bar > paste this entire file > Enter.
-- Run in Edit Mode (not Play). Save place after it generates Workspace.CapyWorld.
-- Does not need Rojo, GitHub sync or downloaded files inside Studio.
-- WARNING: Running it again REPLACES only Workspace.CapyWorld (not other models).
-- This is the static environment only: no guard AI, capybara rig or escape mission.

--!strict

local Workspace = game:GetService("Workspace")
local Config = {

    World = {
        Width = 420,
        Depth = 360,
        WallHeight = 18,
    },

    Player = {
        WalkSpeed = 12,
        SprintSpeed = 19,
        Stamina = 100,
        SprintSeconds = 4,
    },

    Guards = {
        PatrolSpeed = 9,
        ChaseSpeed = 15,
        SightDistance = 28,
        FieldOfView = 100,
    },

    Style = {
        Grass = Color3.fromRGB(126, 173, 96),
        GrassLight = Color3.fromRGB(156, 195, 119),
        Sand = Color3.fromRGB(225, 197, 143),
        Wood = Color3.fromRGB(145, 100, 65),
        Roof = Color3.fromRGB(180, 89, 59),
        Water = Color3.fromRGB(73, 178, 206),
    },

}

local ZooBuilder = {}

local function model(parent: Instance, name: string): Model
    local m = Instance.new("Model")
    m.Name = name
    m.Parent = parent
    return m
end

local function block(
    parent: Instance,
    name: string,
    size: Vector3,
    pos: Vector3,
    color: Color3,
    material: Enum.Material?,
    solid: boolean?
): Part

    local p = Instance.new("Part")

    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.CanCollide = solid ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent

    return p
end

local function board(
    parent: Instance,
    name: string,
    pos: Vector3,
    words: string,
    face: Enum.NormalId?
)
    local p = block(
        parent,
        name,
        Vector3.new(22, 8, 1),
        pos,
        Color3.fromRGB(80, 120, 68),
        Enum.Material.Wood
    )

    local gui = Instance.new("SurfaceGui")
    gui.Face = face or Enum.NormalId.Front
    gui.LightInfluence = 0
    gui.Parent = p

    local txt = Instance.new("TextLabel")
    txt.Name = "Caption"
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextScaled = true
    txt.TextWrapped = true
    txt.Font = Enum.Font.GothamBold
    txt.Text = words
    txt.Parent = gui
end

local function tree(
    parent: Instance,
    n: number,
    x: number,
    z: number
)
    local t = model(parent, "Tree" .. n)

    block(
        t,
        "Trunk",
        Vector3.new(3, 13, 3),
        Vector3.new(x, 6.5, z),
        Config.Style.Wood,
        Enum.Material.Wood
    )

    local leaf = block(
        t,
        "Canopy",
        Vector3.new(16, 16, 16),
        Vector3.new(x, 17, z),
        Color3.fromRGB(61, 139, 73),
        Enum.Material.Grass,
        false
    )

    leaf.Shape = Enum.PartType.Ball
end

local function hut(
    parent: Instance,
    name: string,
    x: number,
    z: number,
    w: number,
    d: number,
    wallColor: Color3
)
    local h = model(parent, name)

    block(
        h,
        "Floor",
        Vector3.new(w, 1, d),
        Vector3.new(x, 0.5, z),
        Color3.fromRGB(174, 143, 108),
        Enum.Material.Wood
    )

    block(
        h,
        "Roof",
        Vector3.new(w + 5, 2, d + 5),
        Vector3.new(x, 19, z),
        Config.Style.Roof,
        Enum.Material.Wood
    )

    block(
        h,
        "BackWall",
        Vector3.new(w, 17, 2),
        Vector3.new(x, 9.5, z - d / 2),
        wallColor,
        Enum.Material.Wood
    )

    block(
        h,
        "WestWall",
        Vector3.new(2, 17, d),
        Vector3.new(x - w / 2, 9.5, z),
        wallColor,
        Enum.Material.Wood
    )

    block(
        h,
        "EastWall",
        Vector3.new(2, 17, d),
        Vector3.new(x + w / 2, 9.5, z),
        wallColor,
        Enum.Material.Wood
    )

    local wingWidth = (w - 12) / 2

    block(
        h,
        "FrontWallLeft",
        Vector3.new(wingWidth, 17, 2),
        Vector3.new(x - (w + 12) / 4, 9.5, z + d / 2),
        wallColor,
        Enum.Material.Wood
    )

    block(
        h,
        "FrontWallRight",
        Vector3.new(wingWidth, 17, 2),
        Vector3.new(x + (w + 12) / 4, 9.5, z + d / 2),
        wallColor,
        Enum.Material.Wood
    )

    return h
end

function ZooBuilder.Build(): Model

    local old = Workspace:FindFirstChild("CapyWorld")

    if old then
        old:Destroy()
    end

    local world = model(Workspace, "CapyWorld")

    world:SetAttribute("Mission", "CAPY-M01A")
    world:SetAttribute("Generated", true)

    -- ==========================================
    -- GROUND
    -- ==========================================

    local terrain = model(world, "Terrain")

    block(
        terrain,
        "GrassGround",
        Vector3.new(
            Config.World.Width,
            2,
            Config.World.Depth
        ),
        Vector3.new(0, -1, 0),
        Config.Style.Grass,
        Enum.Material.Grass
    )

    -- ==========================================
    -- ZOO PERIMETER
    -- ==========================================

    local perimeter = model(world, "Perimeter")
    local wood = Config.Style.Wood

    block(
        perimeter,
        "NorthWall",
        Vector3.new(420, 18, 3),
        Vector3.new(0, 9, -178.5),
        wood,
        Enum.Material.Wood
    )

    block(
        perimeter,
        "WestWall",
        Vector3.new(3, 18, 360),
        Vector3.new(-208.5, 9, 0),
        wood,
        Enum.Material.Wood
    )

    block(
        perimeter,
        "EastWall",
        Vector3.new(3, 18, 360),
        Vector3.new(208.5, 9, 0),
        wood,
        Enum.Material.Wood
    )

    -- Gate opening spans X = 108 to 130.

    block(
        perimeter,
        "SouthWallLeft",
        Vector3.new(318, 18, 3),
        Vector3.new(-51, 9, 178.5),
        wood,
        Enum.Material.Wood
    )

    block(
        perimeter,
        "SouthWallRight",
        Vector3.new(80, 18, 3),
        Vector3.new(170, 9, 178.5),
        wood,
        Enum.Material.Wood
    )

    -- ==========================================
    -- VISITOR PATHS
    -- ==========================================

    local paths = model(world, "VisitorPaths")

    block(
        paths,
        "CentralPath",
        Vector3.new(24, 0.3, 300),
        Vector3.new(16, 0.16, 0),
        Config.Style.Sand,
        Enum.Material.Sand
    )

    block(
        paths,
        "PenLink",
        Vector3.new(96, 0.3, 14),
        Vector3.new(-32, 0.17, -95),
        Config.Style.Sand,
        Enum.Material.Sand
    )

    block(
        paths,
        "VisitorCrossing",
        Vector3.new(210, 0.3, 20),
        Vector3.new(-2, 0.18, 35),
        Config.Style.Sand,
        Enum.Material.Sand
    )

    block(
        paths,
        "GateApproach",
        Vector3.new(120, 0.3, 20),
        Vector3.new(67, 0.18, 145),
        Config.Style.Sand,
        Enum.Material.Sand
    )

    -- ==========================================
    -- CAPYBARA ENCLOSURE
    -- ==========================================

    local pen = model(world, "CapyEnclosure")

    block(
        pen,
        "PenGrass",
        Vector3.new(100, 0.3, 90),
        Vector3.new(-130, 0.15, -95),
        Config.Style.GrassLight,
        Enum.Material.Grass
    )

    block(
        pen,
        "NorthFence",
        Vector3.new(100, 7, 2),
        Vector3.new(-130, 3.5, -140),
        wood,
        Enum.Material.Wood
    )

    block(
        pen,
        "SouthFence",
        Vector3.new(100, 7, 2),
        Vector3.new(-130, 3.5, -50),
        wood,
        Enum.Material.Wood
    )

    block(
        pen,
        "WestFence",
        Vector3.new(2, 7, 90),
        Vector3.new(-180, 3.5, -95),
        wood,
        Enum.Material.Wood
    )

    block(
        pen,
        "EastFenceNorth",
        Vector3.new(2, 7, 39),
        Vector3.new(-80, 3.5, -120.5),
        wood,
        Enum.Material.Wood
    )

    block(
        pen,
        "EastFenceSouth",
        Vector3.new(2, 7, 39),
        Vector3.new(-80, 3.5, -69.5),
        wood,
        Enum.Material.Wood
    )

    local smallGate = block(
        pen,
        "LockedPenGate",
        Vector3.new(2, 7, 12),
        Vector3.new(-80, 3.5, -95),
        Color3.fromRGB(194, 129, 64),
        Enum.Material.Wood
    )

    smallGate:SetAttribute("Locked", true)

    block(
        pen,
        "HayBale",
        Vector3.new(13, 5, 8),
        Vector3.new(-154, 2.5, -109),
        Color3.fromRGB(219, 187, 107),
        Enum.Material.Sand
    )

    local drink = block(
        pen,
        "CapyPool",
        Vector3.new(26, 0.2, 19),
        Vector3.new(-117, 0.45, -120),
        Config.Style.Water,
        Enum.Material.Glass,
        false
    )

    drink.Transparency = 0.25

    board(
        pen,
        "PenWelcome",
        Vector3.new(-131, 7, -139),
        "CAPY ZONE",
        Enum.NormalId.Back
    )

    -- ==========================================
    -- MAIN POND
    -- ==========================================

    local pond = model(world, "Pond")

    block(
        pond,
        "SandShore",
        Vector3.new(78, 0.3, 59),
        Vector3.new(105, 0.15, -100),
        Config.Style.Sand,
        Enum.Material.Sand
    )

    local water = block(
        pond,
        "WaterVisual",
        Vector3.new(70, 0.2, 51),
        Vector3.new(105, 0.37, -100),
        Config.Style.Water,
        Enum.Material.Glass,
        false
    )

    water.Transparency = 0.25

    block(
        pond,
        "Bridge",
        Vector3.new(14, 1, 65),
        Vector3.new(105, 1.1, -100),
        Color3.fromRGB(166, 119, 75),
        Enum.Material.Wood
    )

    -- ==========================================
    -- ZOO BUILDINGS
    -- ==========================================

    local office = hut(
        world,
        "SecurityOffice",
        120,
        3,
        52,
        46,
        Color3.fromRGB(245, 222, 169)
    )

    board(
        office,
        "SecuritySign",
        Vector3.new(120, 13, 27),
        "SECURITY",
        Enum.NormalId.Back
    )

    local shed = hut(
        world,
        "MaintenanceShed",
        -130,
        98,
        58,
        46,
        Color3.fromRGB(167, 140, 111)
    )

    board(
        shed,
        "ShedSign",
        Vector3.new(-130, 13, 122),
        "MAINTENANCE",
        Enum.NormalId.Back
    )

    -- ==========================================
    -- MAIN EXIT
    -- ==========================================

    local exits = model(world, "ExitMarkers")

    local mainGate = block(
        exits,
        "LockedMainGate",
        Vector3.new(22, 18, 3),
        Vector3.new(119, 9, 178.5),
        Color3.fromRGB(190, 119, 66),
        Enum.Material.Wood
    )

    mainGate:SetAttribute("Locked", true)

    board(
        exits,
        "ExitSign",
        Vector3.new(119, 22, 176),
        "EXIT - LOCKED"
    )

    local zonePreview = block(
        exits,
        "Zone02Preview",
        Vector3.new(18, 0.2, 10),
        Vector3.new(119, 0.4, 162),
        Color3.fromRGB(243, 185, 69),
        Enum.Material.Neon,
        false
    )

    zonePreview.Transparency = 0.55
    zonePreview:SetAttribute("FutureContent", true)

    -- ==========================================
    -- CHECKPOINT MARKERS
    -- ==========================================

    local markers = model(world, "CheckpointMarkers")

    local points = {
        -- Keep CP01 beside the spawn pad so its marker stays visible.
        Vector3.new(-116, 0.65, -95),
        Vector3.new(-16, 0.65, 35),
        Vector3.new(119, 0.65, 145),
    }

    for i, pos in ipairs(points) do

        local id = string.format("CP%02d", i)

        local cp = block(
            markers,
            id,
            Vector3.new(9, 0.25, 9),
            pos,
            Color3.fromRGB(255, 202, 70),
            Enum.Material.Neon,
            false
        )

        cp:SetAttribute("CheckpointId", id)

    end

    -- ==========================================
    -- PLAYER SPAWN
    -- ==========================================

    local spawn = Instance.new("SpawnLocation")

    spawn.Name = "CapySpawn"
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Size = Vector3.new(9, 1, 9)
    spawn.Position = Vector3.new(-130, 1, -95)
    spawn.Neutral = true
    spawn.Enabled = true
    spawn.Transparency = 0.2
    spawn.Parent = pen

    -- ==========================================
    -- TROPICAL TREES
    -- ==========================================

    local vegetation = model(world, "Vegetation")

    local locations = {
        {-190, -10},
        {-168, 149},
        {-19, -130},
        {184, -49},
        {179, 112},
        {-25, 141},
        {71, -147},
        {-175, 23},
        {183, 15},
        {-61, 143},
    }

    for i, coords in ipairs(locations) do
        tree(
            vegetation,
            i,
            coords[1],
            coords[2]
        )
    end

    return world
end
local builtWorld = ZooBuilder.Build()
print('[CAPY-M01A] Zoo created in Edit Mode: ' .. builtWorld:GetFullName())
print('[CAPY-M01A] Select Workspace > CapyWorld to inspect; save your place to keep it.')
