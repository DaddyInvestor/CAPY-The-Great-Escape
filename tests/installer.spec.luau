-- Remove the entire synced source tree. The installer must not depend on it.
game.ReplicatedStorage:Destroy()
game.ServerScriptService:Destroy()
runInstaller()
check(signature(Workspace.CapyWorld)==expectedSignature,"Installer differs from modular build")
runInstaller()
check(signature(Workspace.CapyWorld)==expectedSignature,"Installer repeat differs")
local current=Workspace.CapyWorld
current:Destroy()
runInstaller()
check(signature(Workspace.CapyWorld)==expectedSignature,"Fresh edit-mode install differs")
Workspace.CapyWorld:Destroy()
local userWorld=child(Workspace,"Model","CapyWorld")
local userPart=child(userWorld,"Part","UserPart")
local success=pcall(runInstaller)
check(not success and userWorld.Parent==Workspace and userPart.Parent==userWorld,
    "Installer replaced an unowned name collision")
local modularSuccess=pcall(builder.Build)
check(not modularSuccess and userWorld.Parent==Workspace,"Modular builder replaced user model")
userWorld.Name="PreservedUserWorld"
local legacy=child(Workspace,"Model","CapyWorld")
legacy:SetAttribute("Generated",true)
legacy:SetAttribute("Mission","CAPY-M01A")
runInstaller()
check(legacy.Parent==nil and signature(Workspace.CapyWorld)==expectedSignature,"Legacy upgrade failed")
check(userWorld.Parent==Workspace and unrelated.Parent==Workspace,"Unrelated models lost")
local count=0
for _, object in Workspace:GetChildren() do if object.Name=="CapyWorld" then count+=1 end end
check(count==1,"Duplicate generated worlds")
print("PASS: standalone installer matches modular geometry, installs without source modules, repeats deterministically, upgrades owned legacy worlds, and refuses unowned collisions")
