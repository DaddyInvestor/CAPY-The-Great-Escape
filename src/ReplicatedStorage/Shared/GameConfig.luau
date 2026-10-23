--!strict

local GameConfig = {

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

return GameConfig
