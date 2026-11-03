--!strict
local ZooBuilder = require(script.Parent.World.ZooBuilder)
local QuestServer = require(script.Parent.Gameplay.QuestServer)
local world = ZooBuilder.Build()
QuestServer.Start(world)
print("[CAPY POLISH] Park and session quest started:", world:GetFullName())
