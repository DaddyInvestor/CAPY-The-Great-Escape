--!strict
local G = require(script.Parent.Geometry)
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Quest = require(Shared:WaitForChild("QuestConfig"))
local Details = {}

function Details.build(world: Model, style)
    local details = G.model(world, "StoryDetails")
    local stations = G.model(world, "Interactions")
    -- Stations are outside the walking corridor and have native keyboard/gamepad/touch prompts.
    for _, definition in Quest.Steps do
        local station = G.model(stations, definition.Id)
        local marker = G.part(station, "PromptAnchor", Vector3.new(0.5,0.5,0.5), CFrame.new(definition.Position),
            style.Cream, Enum.Material.SmoothPlastic, false)
        marker.Transparency = 0.85
        marker:SetAttribute("InteractionId", definition.Id)
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "Interact"
        prompt.ActionText = definition.Action
        prompt.ObjectText = definition.Object
        prompt.HoldDuration = definition.Hold
        prompt.MaxActivationDistance = Quest.InteractionDistance
        prompt.RequiresLineOfSight = false
        prompt.Parent = marker
    end
    local secret = G.model(stations, Quest.Secret.Id)
    local postcard = G.part(secret, "PromptAnchor", Vector3.new(3,2,0.4), CFrame.new(Quest.Secret.Position),
        Color3.fromRGB(255,207,102), Enum.Material.SmoothPlastic, false)
    postcard:SetAttribute("InteractionId", Quest.Secret.Id)
    G.sign(secret, "PostcardArt", Quest.Secret.Position+Vector3.new(0,0,0.3), "A SMALL PAW\nA BIG ADVENTURE", style.DarkWood, 5)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name, prompt.ActionText, prompt.ObjectText = "Interact", Quest.Secret.Action, Quest.Secret.Object
    prompt.HoldDuration, prompt.MaxActivationDistance = Quest.Secret.Hold, Quest.InteractionDistance
    prompt.RequiresLineOfSight = false
    prompt.Parent = postcard

    local feeder = G.model(details, "MangoFeeder")
    G.disc(feeder, "Bowl", -238,-133,4,3,0.8,0.7,style.Wood,Enum.Material.Wood)
    for i=1,3 do
        G.ellipsoid(feeder,"MelonSlice",Vector3.new(-241+i*1.4,1,-133),Vector3.new(1.6,0.7,1),
            Color3.fromRGB(240,151,91),Enum.Material.SmoothPlastic,false)
    end
    G.sign(feeder,"BreakfastStory",Vector3.new(-238,6,-136),"MANGO'S BREAKFAST\nGarden water: low",style.DarkWood,17)
    local pump = G.model(details,"GardenPump")
    G.disc(pump,"PumpFoot",8,-5,4,4,0.4,0.4,style.Stone,Enum.Material.Slate)
    G.part(pump,"BluePump",Vector3.new(2.5,4,2.5),CFrame.new(8,2.4,-5),style.Water,Enum.Material.Metal)
    G.beam(pump,"PumpHandle",Vector3.new(6,4.8,-5),Vector3.new(11,4.8,-5),0.7,0.7,style.DarkWood,Enum.Material.Metal)
    G.part(pump,"PowerLight",Vector3.new(0.8,0.8,0.8),CFrame.new(8,4.3,-3.5),style.Roof,Enum.Material.Neon,false)
    G.sign(pump,"RepairNote",Vector3.new(8,8,-8),"GARDEN PUMP\nPlease lend a paw",style.DarkWood,17)

    local ranger=G.model(details,"RangerMali")
    local green=Color3.fromRGB(68,112,77)
    local skin=Color3.fromRGB(205,152,111)
    G.part(ranger,"Torso",Vector3.new(2.8,3.2,1.6),CFrame.new(119,3.8,-95),green,Enum.Material.Fabric)
    for _,dx in {-0.8,0.8} do
        G.part(ranger,"Boot",Vector3.new(1,0.8,1.5),CFrame.new(119+dx,0.4,-95),style.DarkWood,Enum.Material.SmoothPlastic)
        G.part(ranger,"Leg",Vector3.new(1,2,1),CFrame.new(119+dx,1.8,-95),style.Sand,Enum.Material.Fabric)
    end
    G.ellipsoid(ranger,"Head",Vector3.new(119,6.4,-95),Vector3.new(2.5,2.5,2.2),skin,Enum.Material.SmoothPlastic)
    G.disc(ranger,"HatBrim",119,-95,2,1.6,7.6,0.3,green,Enum.Material.Fabric)
    G.disc(ranger,"HatCrown",119,-95,1.3,1.1,8.5,0.9,green,Enum.Material.Fabric)
    for _,dx in {-0.5,0.5} do
        G.ellipsoid(ranger,"Eye",Vector3.new(119+dx,6.7,-93.95),Vector3.new(0.25,0.3,0.25),style.DarkWood,Enum.Material.SmoothPlastic,false)
    end
    G.part(ranger,"Smile",Vector3.new(0.6,0.15,0.15),CFrame.new(119,6,-93.9),style.DarkWood,Enum.Material.SmoothPlastic,false)
    G.part(ranger,"LeftArm",Vector3.new(0.8,3,1),CFrame.new(117.1,3.8,-95),green,Enum.Material.Fabric)
    G.part(ranger,"RightArm",Vector3.new(0.8,3,1),CFrame.new(120.9,3.8,-95),green,Enum.Material.Fabric)
    G.sign(ranger,"NameBadge",Vector3.new(119,10.5,-95),"RANGER MALI\nSmall paws welcome",style.DarkWood,16)

    G.sign(details,"TrailGuide",Vector3.new(-230,6,-108),"MANGO'S MORNING RESCUE\nBreakfast - Pump - Mali - Gate",style.DarkWood,24)
    G.sign(details,"ForestHint",Vector3.new(-224,7,145),"Quiet paws find\nbeautiful things",style.DarkWood,17)
    -- Directional boards sit beside junctions, not in the navigable center strip.
    G.sign(details,"GardenWayfinding",Vector3.new(-12,7,20),"GARDEN PUMP\nNorth of the sala",style.DarkWood,16)
end
return Details
