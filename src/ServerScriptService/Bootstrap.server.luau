--!strict

local ZooBuilder = require(
    script.Parent.World.ZooBuilder
)

local world = ZooBuilder.Build()

print(
    "[CAPY-M01A-R1] Zoo generated:",
    world:GetFullName()
)

print(
    "[CAPY-M01A-R1] R1 master layout only; no escape gameplay or Studio validation implied."
)
