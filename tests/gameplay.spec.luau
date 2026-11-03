-- State machine and real server/client code exercised in the mock; not a Studio test.
local initialChecks=checks
local logicState=questLogic.New()
local accepted=questLogic.Apply(logicState,"EXIT")
check(not accepted and logicState.Stage==1,"Skipped the quest order")
accepted=questLogic.Apply(logicState,"POSTCARD")
check(accepted and logicState.Secret and logicState.Stage==1,"Secret changed main progress")
accepted=questLogic.Apply(logicState,"POSTCARD")
check(not accepted and logicState.Revision==1,"Secret can be farmed")
for _, id in {"FEED","PUMP","RANGER","EXIT"} do
    check(questLogic.Apply(logicState,id),"Valid quest step rejected")
end
check(questLogic.Snapshot(logicState).Complete,"Completion not reflected")
check(not questLogic.Apply(logicState,"FEED"),"Completed quest restarted without consent")
check(not questLogic.Apply(questLogic.New(),"UNKNOWN"),"Unknown interaction accepted")

local world=Workspace.CapyWorld
local stop=questServer.Start(world)
check(questServer.Start(world)==stop,"Duplicate server controller started")
local signals=world.Signals
local failureOwner=Workspace.CapyWorld
local preparedOk=pcall(function() builder.Build(function() error("Injected script-source preparation failure") end) end)
check(not preparedOk and failureOwner.Parent==Workspace,"Runtime preparation error destroyed previous content")
local function player(name)
    local p=child(Players,"Player",name)
    child(p,"PlayerGui","PlayerGui")
    local character=child(Workspace,"Model",name.."Character")
    child(character,"Part","HumanoidRootPart")
    local humanoid=child(character,"Humanoid","Humanoid")
    humanoid.Health=100
    p.Character=character
    Players.PlayerAdded:Fire(p)
    return p
end
local alice,bob=player("Alice"),player("Bob")
local function read(p)
    mockClock+=1
    return signals.GetJournal.OnServerInvoke(p)
end
local function act(p,id,near)
    mockClock+=1
    if near~=false then p.Character.HumanoidRootPart.Position=world.Interactions[id].PromptAnchor.Position end
    world.Interactions[id].PromptAnchor.Interact.Triggered:Fire(p)
end
check(alice.RespawnLocation==world.CapyEnclosure.CapySpawn,"Default spawn not overridden for park session")
check(read(alice).Stage==1 and read(bob).Stage==1,"Cross-player initial state leaked")
check(signals.GetJournal.OnServerInvoke(bob)==nil,"Journal request rate limit absent")
alice.Character.HumanoidRootPart.Position=Vector3.new(0,3,0)
act(alice,"FEED",false)
check(read(alice).Stage==1,"Distant prompt advanced quest")
act(alice,"EXIT")
check(read(alice).Stage==1 and world.FutureEscapeRoutes.MAIN_GATE:GetAttribute("Locked"),"Gate opened out of order")
alice.Character.Humanoid.Health=0
act(alice,"FEED")
check(read(alice).Stage==1,"Dead player advanced quest")
alice.Character.Humanoid.Health=100
act(alice,"FEED")
check(read(alice).Stage==2,"Feeding did not advance")
check(read(bob).Stage==1,"Other player progress changed")
-- Test both the installer-delivered UI source and native UI events.
mockClientPlayer=alice
Players.LocalPlayer=alice
loaders[clientModule](clientModule)
local gui=alice.PlayerGui.CapyJournal
local card=gui.JournalCard
check(card.Objective.Text:find("Restore the garden pump")~=nil,"Initial HUD snapshot wrong")
check(card.Size.X.Scale==0.9 and card.UISizeConstraint.MaxSize.X==400,"HUD not width constrained")
check(card.ToggleJournal.Size.X.Offset>=44,"Touch target too small")
card.ToggleJournal.Activated:Fire()
check(card.Size.Y.Offset==58,"HUD collapse failed")
card.ToggleJournal.Activated:Fire()
check(card.Size.Y.Offset==170,"HUD expand failed")
local countBefore=#gui:GetChildren()
loaders[clientModule](clientModule)
check(#gui:GetChildren()==countBefore,"Duplicate client HUD created")
act(alice,"PUMP")
check(read(alice).Stage==3 and card.Objective.Text:find("Meet Ranger Mali")~=nil,"Live journal update failed")
local previous=card.Objective.Text
signals.JournalChanged.OnClientEvent:Fire({Revision=-1})
check(card.Objective.Text==previous,"Stale journal update applied")
-- CharacterAdded uses stage checkpoints, not a client-supplied target.
alice.CharacterAdded:Fire(alice.Character)
check((alice.Character.HumanoidRootPart.Position-Vector3.new(89,4,-125)).Magnitude<0.01,"Plaza respawn checkpoint missing")
act(alice,"RANGER")
check(signals.JournalChanged._sent[alice].Stage==4,"Ranger did not issue pass")
-- Same clock tick: even a nearby next prompt must obey the server cooldown.
alice.Character.HumanoidRootPart.Position=world.Interactions.EXIT.PromptAnchor.Position
world.Interactions.EXIT.PromptAnchor.Interact.Triggered:Fire(alice)
check(world.FutureEscapeRoutes.MAIN_GATE:GetAttribute("Locked"),"Cooldown spam opened the gate")
act(alice,"EXIT")
check(read(alice).Complete,"Ordered mission did not complete")
check(not world.FutureEscapeRoutes.MAIN_GATE:GetAttribute("Locked"),"Gate remained locked")
for _, part in world.FutureEscapeRoutes.MAIN_GATE:GetDescendants() do
    if part.Name=="LockedGateBar" then check(not part.CanCollide and part.Position.Y>12,"Portcullis did not lift") end
end
act(bob,"EXIT")
check(read(bob).Stage==1,"Global gate opening bypassed personal mission order")
act(alice,"POSTCARD")
check(read(alice).Secret,"Optional discovery missing")
act(alice,"POSTCARD")
check(read(alice).Stage==5,"Repeated secret changed completion")
alice.CharacterAdded:Fire(alice.Character)
check((alice.Character.HumanoidRootPart.Position-Vector3.new(205,4,178)).Magnitude<0.01,"Entrance checkpoint missing")
alice.Character.Humanoid.Running:Fire(12)
check(Workspace.CurrentCamera.FieldOfView>70,"Movement FOV feedback missing")
RunService.Heartbeat:Fire(0.3)
local prompt=world.Interactions.FEED.PromptAnchor.Interact
Players.PlayerRemoving:Fire(bob)
bob.Parent=nil
check(bob.CharacterAdded:Count()==0,"Departed player's character listener leaked")
stop()
check(prompt.Triggered:Count()==0 and signals.Parent==nil,"Server cleanup left prompt listeners")
check(gui.Parent==nil and RunService.Heartbeat:Count()==0,"Client cleanup leaked heartbeat or UI")
check(Workspace.CurrentCamera.FieldOfView==70,"Camera FOV not restored")
-- Execute the EXACT saved server source without Rojo services, then check delivery.
world:Destroy()
runInstaller()
local installed=Workspace.CapyWorld
check(installed.Runtime.CapyServer.Source:find("QuestServer.Start",1,true)~=nil,"Saved server source missing")
check(installed.Runtime.ClientTemplate.CapyClient.Source:find("JournalCard",1,true)~=nil,"Saved client source missing")
startSavedServer(installed.Runtime.CapyServer)
check(installed.Signals~=nil,"Saved server did not start")
local fresh=player("InstallerPlayer")
check(fresh.PlayerGui.CapyJournal.CapyClient.Source==installed.Runtime.ClientTemplate.CapyClient.Source,"Installer lost client source")
mockClientPlayer=fresh
Players.LocalPlayer=fresh
loaders[clientModule](clientModule)
check(fresh.PlayerGui.CapyJournal.JournalCard.Objective.Text:find("Feed Mango")~=nil,"Installer session HUD did not initialize")
installed:Destroy()
check(RunService.Heartbeat:Count()==0,"Reinstall cleanup leaked client loop")
print(string.format("PASS: %d gameplay/UI/runtime assertions; ordered quest, two-player isolation, anti-skip/distance checks, gate, secret, respawn, HUD and cleanup",checks-initialChecks))
