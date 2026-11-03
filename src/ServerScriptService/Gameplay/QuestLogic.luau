--!strict
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("QuestConfig"))
local Logic = {}

function Logic.New()
    return {Stage=1, Secret=false, Revision=0}
end

function Logic.Snapshot(state, message: string?, feedback: string?)
    local step = Config.Steps[state.Stage]
    return {Stage=state.Stage, Total=#Config.Steps, Complete=step==nil,
        Secret=state.Secret, Revision=state.Revision, Title=if step then step.Title else "Morning rescue complete!",
        Hint=if step then step.Hint else "Thank you, park helper. Explore the forest for an optional postcard.",
        TargetId=if step then step.Id else Config.Secret.Id,
        TargetPosition=if step then step.Position else Config.Secret.Position,
        Message=message or "", Feedback=feedback or "info"}
end

function Logic.Apply(state, id: string)
    if id == Config.Secret.Id then
        if state.Secret then return false, "You already collected this forest postcard." end
        state.Secret = true
        state.Revision += 1
        return true, "Forest postcard found! A little Khao Yai memory for your journal."
    end
    local step = Config.Steps[state.Stage]
    if not step then return false, "Your morning rescue is already complete. Enjoy the park!" end
    if step.Id ~= id then return false, "Next: " .. step.Title .. ". " .. step.Hint end
    state.Stage += 1
    state.Revision += 1
    return true, step.Response
end

return Logic
