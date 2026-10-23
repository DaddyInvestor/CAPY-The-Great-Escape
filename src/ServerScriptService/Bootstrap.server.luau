--!strict

local ZooBuilder = require(
    script.Parent.World.ZooBuilder
)

local world = ZooBuilder.Build()

print(
    "[CAPY-M01A] Zoo generated:",
    world:GetFullName()
)

print(
    "[CAPY-M01A] Static zoo prototype only."
)
