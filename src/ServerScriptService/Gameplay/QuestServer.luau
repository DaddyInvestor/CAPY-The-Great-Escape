--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("QuestConfig"))
local Logic = require(script.Parent.QuestLogic)
local Server = {}
local activeWorld: Model? = nil
local stopActive = function() end

function Server.Start(world: Model)
    if activeWorld == world then return stopActive end
    stopActive()
    activeWorld = world
    local connections, sessions, reactions, guiCopies, characterConnections = {}, {}, {}, {}, {}
    local stopped = false
    local signals = Instance.new("Folder")
    signals.Name = "Signals"
    signals.Parent = world
    local changed = Instance.new("RemoteEvent")
    changed.Name, changed.Parent = "JournalChanged", signals
    local snapshot = Instance.new("RemoteFunction")
    snapshot.Name, snapshot.Parent = "GetJournal", signals
    local gateOpened = false
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end
    local function send(player, message, feedback)
        if not stopped and sessions[player] and player.Parent == Players then
            changed:FireClient(player, Logic.Snapshot(sessions[player].State, message, feedback))
        end
    end
    local function animate(part: BasePart?, angle: number, pivot: Vector3?)
        if not part or reactions[part] then return end
        reactions[part] = true
        local original = part.CFrame
        local rotation=CFrame.Angles(0,0,angle)
        local goal=if pivot then CFrame.new(pivot)*rotation*CFrame.new(-pivot)*original else original*rotation
        local tween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true),
            {CFrame=goal})
        local completion
        completion = tween.Completed:Connect(function()
            if completion then
                completion:Disconnect()
                local index=table.find(connections,completion)
                if index then table.remove(connections,index) end
            end
            reactions[part] = nil
            if part.Parent then part.CFrame = original end
        end)
        table.insert(connections, completion)
        tween:Play()
    end
    local function openGate()
        if gateOpened then return end
        gateOpened = true
        local gate = world.FutureEscapeRoutes.MAIN_GATE
        gate:SetAttribute("Locked", false)
        for _, part in gate:GetDescendants() do
            if part:IsA("BasePart") and (part.Name=="LockedGateBar" or part.Name=="Rail" or part.Name=="LockPlate") then
                -- Raise the portcullis; fixed posts and unrelated perimeter fences stay solid.
                part.CanCollide = false
                TweenService:Create(part,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                    {CFrame=part.CFrame*CFrame.new(0,12,0)}):Play()
            elseif part:IsA("TextLabel") then part.Text = "TRAIL OPEN / THANK YOU" end
        end
    end
    local function characterReady(player, character)
        task.spawn(function()
            local root = character:WaitForChild("HumanoidRootPart",10)
            local session = sessions[player]
            if stopped or not root or not session or player.Character ~= character then return end
            local stage = session.State.Stage
            local point = if stage>=4 then Vector3.new(205,4,178)
                elseif stage>=3 then Vector3.new(89,4,-125) else Vector3.new(-218,4,-115)
            character:PivotTo(CFrame.new(point))
        end)
    end
    local function joined(player)
        if sessions[player] then return end
        sessions[player] = {State=Logic.New(),LastAction=-math.huge,LastRead=-math.huge}
        player.RespawnLocation = world.CapyEnclosure.CapySpawn
        characterConnections[player]=player.CharacterAdded:Connect(function(character) characterReady(player,character) end)
        if player.Character then characterReady(player,player.Character) end
        local runtime = world:FindFirstChild("Runtime")
        local template = runtime and runtime:FindFirstChild("ClientTemplate")
        if template then
            task.spawn(function()
                local gui = player:WaitForChild("PlayerGui",10)
                if stopped or not gui or player.Parent~=Players then return end
                local old=gui:FindFirstChild("CapyJournal")
                if old and old:GetAttribute("GeneratorId")~="CAPY-M01A" then
                    warn("CAPY journal name collision; unrelated UI preserved")
                    return
                end
                if old then old:Destroy() end
                local copy=template:Clone()
                copy.Name="CapyJournal"
                copy.Parent=gui
                guiCopies[player]=copy
            end)
        end
    end
    snapshot.OnServerInvoke = function(player)
        local session = sessions[player]
        if stopped or not session then return nil end
        -- A read-only bounded response. Rate-limit duplicate requests without trusting client data.
        local now=os.clock()
        if now-session.LastRead<0.2 then return nil end
        session.LastRead=now
        return Logic.Snapshot(session.State)
    end
    for _, station in world.Interactions:GetChildren() do
        local anchor = station.PromptAnchor
        connect(anchor.Interact.Triggered,function(player)
            local session=sessions[player]
            if stopped or not session or player.Parent~=Players then return end
            local character=player.Character
            local root=character and character:FindFirstChild("HumanoidRootPart")
            local humanoid=character and character:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid or humanoid.Health<=0 then return end
            if (root.Position-anchor.Position).Magnitude>Config.InteractionDistance+2 then return end
            local now=os.clock()
            if now-session.LastAction<Config.Cooldown then return end
            session.LastAction=now
            local id=station.Name
            local accepted,message=Logic.Apply(session.State,id)
            if accepted then
                if id=="FEED" then
                    local mango=world.Zones.A_CapybaraHabitat.CapySculpture
                    for _, part in mango:GetChildren() do
                        if part.Name=="Head" or part.Name=="Eye" or part.Name=="Ear" then animate(part,0.15,mango.Head.Position) end
                    end
                end
                if id=="PUMP" then
                    world.StoryDetails.GardenPump.PowerLight.Color=Color3.fromRGB(123,218,139)
                    animate(world.StoryDetails.GardenPump.PumpHandle,0.3)
                end
                if id=="RANGER" then animate(world.StoryDetails.RangerMali.RightArm,-0.7) end
                if id=="EXIT" then openGate() end
            end
            send(player,message,if accepted then "success" else "hint")
        end)
    end
    connect(Players.PlayerAdded,joined)
    connect(Players.PlayerRemoving,function(player)
        sessions[player]=nil
        if characterConnections[player] then characterConnections[player]:Disconnect(); characterConnections[player]=nil end
        if guiCopies[player] then guiCopies[player]:Destroy(); guiCopies[player]=nil end
    end)
    local function stop()
        if stopped then return end
        stopped=true
        for _, connection in connections do connection:Disconnect() end
        for _, connection in characterConnections do connection:Disconnect() end
        for _, gui in guiCopies do if gui.Parent then gui:Destroy() end end
        snapshot.OnServerInvoke=nil
        if signals.Parent then signals:Destroy() end
        table.clear(sessions)
        if activeWorld==world then activeWorld=nil end
    end
    stopActive=stop
    connect(world.Destroying,stop)
    for _, player in Players:GetPlayers() do joined(player) end
    return stop
end
return Server
