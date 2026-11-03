--!strict
-- The same source is packaged into the installer's saved LocalScript template.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
local connections={}
local stopped=false
local function connect(signal,callback)
    local connection=signal:Connect(callback)
    table.insert(connections,connection)
    return connection
end
local guiParent=player:WaitForChild("PlayerGui")
local gui=guiParent:FindFirstChild("CapyJournal")
if gui and gui:GetAttribute("GeneratorId")~="CAPY-M01A" then
    warn("CAPY journal name collision; unrelated UI preserved")
    return
end
if not gui then
    gui=Instance.new("ScreenGui")
    gui.Name="CapyJournal"
    gui:SetAttribute("GeneratorId","CAPY-M01A")
    gui.Parent=guiParent
end
-- Refuse duplicate client controllers; a saved installer template and Rojo can coexist.
if gui:GetAttribute("ClientActive") then return end
gui:SetAttribute("ClientActive",true)
gui.ResetOnSpawn=false
gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets
gui.DisplayOrder=10
local function make(className,parent,properties)
    local object=Instance.new(className)
    for key,value in properties do object[key]=value end
    object.Parent=parent
    return object
end
local function corner(parent,radius)
    make("UICorner",parent,{CornerRadius=UDim.new(0,radius)})
end
local card=make("Frame",gui,{Name="JournalCard",AnchorPoint=Vector2.new(0.5,0),
    Position=UDim2.new(0.5,0,0,16),Size=UDim2.new(0.9,0,0,170),BackgroundColor3=Color3.fromRGB(35,58,46),BorderSizePixel=0})
corner(card,14)
make("UISizeConstraint",card,{MinSize=Vector2.new(220,52),MaxSize=Vector2.new(400,170)})
make("UIStroke",card,{Color=Color3.fromRGB(228,199,139),Thickness=1.5})
local title=make("TextLabel",card,{Name="Objective",Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-72,0,44),
    BackgroundTransparency=1,Text="Mango's Morning Rescue",TextWrapped=true,TextSize=19,Font=Enum.Font.GothamBold,
    TextColor3=Color3.fromRGB(255,237,197),TextXAlignment=Enum.TextXAlignment.Left})
local hint=make("TextLabel",card,{Position=UDim2.fromOffset(16,58),Size=UDim2.new(1,-32,0,55),BackgroundTransparency=1,
    Text="Finding your journal...",TextWrapped=true,TextSize=15,Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(239,242,228),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
local distance=make("TextLabel",card,{Position=UDim2.fromOffset(16,118),Size=UDim2.new(1,-32,0,22),BackgroundTransparency=1,
    Text="",TextSize=14,Font=Enum.Font.GothamMedium,TextColor3=Color3.fromRGB(235,207,139),TextXAlignment=Enum.TextXAlignment.Left})
local progressTrack=make("Frame",card,{Position=UDim2.new(0,16,1,-14),Size=UDim2.new(1,-32,0,5),
    BackgroundColor3=Color3.fromRGB(76,96,78),BorderSizePixel=0})
corner(progressTrack,3)
local fill=make("Frame",progressTrack,{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.fromRGB(244,200,104),BorderSizePixel=0})
corner(fill,3)
local collapse=make("TextButton",card,{Name="ToggleJournal",Position=UDim2.new(1,-52,0,4),Size=UDim2.fromOffset(44,44),
    Text="−",TextSize=24,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1})
local toast=make("TextLabel",gui,{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,196),Size=UDim2.new(0.9,0,0,110),
    BackgroundColor3=Color3.fromRGB(45,76,57),BackgroundTransparency=0.08,BorderSizePixel=0,
    Text="",TextWrapped=true,TextSize=16,Font=Enum.Font.GothamMedium,TextColor3=Color3.fromRGB(255,243,212),Visible=false})
corner(toast,12)
make("UISizeConstraint",toast,{MinSize=Vector2.new(220,80),MaxSize=Vector2.new(400,110)})
make("UIPadding",toast,{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
local expanded=true
connect(collapse.Activated,function()
    expanded=not expanded
    card.Size=UDim2.new(0.9,0,0,if expanded then 170 else 58)
    hint.Visible,distance.Visible,progressTrack.Visible=expanded,expanded,expanded
    collapse.Text=if expanded then "−" else "+"
    toast.Position=UDim2.new(0.5,0,0,if expanded then 196 else 84)
end)
local state=nil
local toastUntil=0
local function receive(value)
    if type(value)~="table" or type(value.Revision)~="number" then return end
    if state and value.Revision<state.Revision then return end
    state=value
    title.Text=if value.Complete then "Morning rescue complete!" else string.format("%d/%d  %s",value.Stage,value.Total,value.Title)
    hint.Text=value.Hint
    TweenService:Create(fill,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
        {Size=UDim2.fromScale(math.clamp((value.Stage-1)/value.Total,0,1),1)}):Play()
    if value.Message~="" then
        toast.Text=value.Message
        toast.BackgroundColor3=if value.Feedback=="success" then Color3.fromRGB(45,90,61) else Color3.fromRGB(94,75,45)
        toast.Visible=true
        toastUntil=os.clock()+7
    end
end
local worldConnection=nil
local worldDestroyed=nil
local bindVersion=0
local function bind(world)
    if world:GetAttribute("GeneratorId")~="CAPY-M01A" then return end
    bindVersion+=1
    local version=bindVersion
    if worldConnection then worldConnection:Disconnect() end
    if worldDestroyed then worldDestroyed:Disconnect() end
    state=nil
    title.Text="Mango's Morning Rescue"
    hint.Text="Getting your trail journal..."
    worldDestroyed=world.Destroying:Connect(function()
        bindVersion+=1
        state=nil
        hint.Text="The park is rebuilding. Your next trail will start shortly."
    end)
    task.spawn(function()
        local signals=world:WaitForChild("Signals",15)
        if not signals or stopped or version~=bindVersion then return end
        worldConnection=signals.JournalChanged.OnClientEvent:Connect(receive)
        -- Connect before requesting the first snapshot so no progress update is lost.
        local ok,value=pcall(function() return signals.GetJournal:InvokeServer() end)
        if version~=bindVersion then return end
        if ok and value then receive(value) else hint.Text="Talk to a park station to refresh your journal." end
    end)
end
connect(Workspace.ChildAdded,function(object) if object.Name=="CapyWorld" then bind(object) end end)
local current=Workspace:FindFirstChild("CapyWorld")
if current then bind(current) end
local accumulated=0
connect(RunService.Heartbeat,function(delta)
    accumulated+=delta
    if accumulated<0.25 then return end
    accumulated=0
    if toast.Visible and os.clock()>toastUntil then toast.Visible=false end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if state and root then
        distance.Text=if state.Complete and state.Secret then "Forest postcard found · Park helper!"
            else string.format("%d studs to %s%s",math.floor((root.Position-state.TargetPosition).Magnitude),
                state.TargetId,if state.Secret then " · Postcard found" else "")
    end
end)
-- Keep Roblox's default camera/Animate/controller. No forced cutscene or movement lock.
local runConnection=nil
local fovTween=nil
local cameraBase=nil
local camera=nil
local lastTarget=nil
local function characterAdded(character)
    if runConnection then runConnection:Disconnect() end
    task.spawn(function()
        local humanoid=character:WaitForChild("Humanoid",10)
        if not humanoid or stopped or player.Character~=character then return end
        local nextCamera=Workspace.CurrentCamera
        if camera and camera~=nextCamera and cameraBase and camera.Parent then camera.FieldOfView=cameraBase end
        if camera~=nextCamera then cameraBase=nil end
        camera=nextCamera
        lastTarget=nil
        if camera then
            cameraBase=cameraBase or camera.FieldOfView
            runConnection=humanoid.Running:Connect(function(speed)
                if stopped or Workspace.CurrentCamera~=camera then return end
                local target=cameraBase+math.floor(math.clamp(speed/4,0,4)*2)/2
                if target==lastTarget then return end
                lastTarget=target
                if fovTween then fovTween:Cancel() end
                fovTween=TweenService:Create(camera,TweenInfo.new(0.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),
                    {FieldOfView=target})
                fovTween:Play()
            end)
        end
    end)
end
connect(player.CharacterAdded,characterAdded)
if player.Character then characterAdded(player.Character) end
connect(gui.Destroying,function()
    stopped=true
    for _, connection in connections do connection:Disconnect() end
    if runConnection then runConnection:Disconnect() end
    if worldConnection then worldConnection:Disconnect() end
    if worldDestroyed then worldDestroyed:Disconnect() end
    if fovTween then fovTween:Cancel() end
    if camera and cameraBase and camera.Parent then camera.FieldOfView=cameraBase end
end)
