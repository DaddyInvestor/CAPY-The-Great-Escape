-- Data-model/geometry checks, not Roblox rendering, physics, or a Studio playtest.
local checks = 0
local function check(condition, message)
    assert(condition, message)
    checks += 1
end
local function near(a, b) return math.abs(a - b) < 0.001 end
local function bounds(part)
    local _, _, _, a,b,c,d,e,f,g,h,i = part.CFrame:GetComponents()
    local s = part.Size / 2
    return Vector3.new(math.abs(a)*s.X+math.abs(b)*s.Y+math.abs(c)*s.Z,
        math.abs(d)*s.X+math.abs(e)*s.Y+math.abs(f)*s.Z,
        math.abs(g)*s.X+math.abs(h)*s.Y+math.abs(i)*s.Z)
end
local function inside(point, part, pad)
    local d = point - part.Position
    local _, _, _, a,b,c,e,f,g,h,i,j = part.CFrame:GetComponents()
    local localPoint = Vector3.new(a*d.X+e*d.Y+h*d.Z, b*d.X+f*d.Y+i*d.Z, c*d.X+g*d.Y+j*d.Z)
    return math.abs(localPoint.X) < part.Size.X/2 + pad
        and math.abs(localPoint.Y) < part.Size.Y/2 + pad
        and math.abs(localPoint.Z) < part.Size.Z/2 + pad
end
local function signature(world)
    local entries = {}
    for _, p in world:GetDescendants() do
        if p:IsA("BasePart") then
            table.insert(entries, string.format("%s|%s|%.4f,%.4f,%.4f|%.4f,%.4f,%.4f|%s|%s",
                p:GetFullName(), p.ClassName, p.Position.X, p.Position.Y, p.Position.Z,
                p.Size.X, p.Size.Y, p.Size.Z, tostring(p.CanCollide), tostring(p.Material)))
        end
    end
    table.sort(entries)
    return table.concat(entries, "\n")
end

local unrelated = child(Workspace, "Model", "UserContent")
local bootstrap = resolve("game.ServerScriptService.Bootstrap")
loaders[bootstrap](bootstrap)
local world = Workspace:WaitForChild("CapyWorld")
local builder = require(resolve("game.ServerScriptService.World.ZooBuilder"))
local questServer = require(resolve("game.ServerScriptService.Gameplay.QuestServer"))
local questLogic = require(resolve("game.ServerScriptService.Gameplay.QuestLogic"))
local clientModule = resolve("game.StarterPlayer.StarterPlayerScripts.CapyClient")
local layout = require(resolve("game.ReplicatedStorage.Shared.WorldLayout"))
local geometry = require(resolve("game.ServerScriptService.World.Geometry"))
check(world:GetAttribute("Phase") == "POLISH-1", "Missing R1 phase")
local ground = world.Terrain.ParkGround
check(ground.Size.X == 600 and ground.Size.Z == 500, "Expected 600 x 500 world")
local parts, obstacles = {}, {}
for _, part in world:GetDescendants() do
    if part:IsA("BasePart") then
        table.insert(parts, part)
        local half = bounds(part)
        check(part.Anchored and part.Transparency < 1, "Invisible/unanchored geometry: " .. part:GetFullName())
        check(part.Size.X > 0 and part.Size.Y > 0 and part.Size.Z > 0, "Nonpositive size")
        check(math.abs(part.Position.X) + half.X <= 300.01
            and math.abs(part.Position.Z) + half.Z <= 250.01, "Out of bounds: " .. part:GetFullName())
        check(type(part.CanCollide) == "boolean", "Collision policy missing")
        check(part.CanQuery==part.CanCollide and part.CanTouch==false,"Decorative physics/query policy regressed")
        if part.CanCollide and part.Position.Y + half.Y > 2 then table.insert(obstacles, part) end
    end
end
check(#parts < 2500, "Unexpected decorative density / part budget exceeded")
check(#world.Zones:GetChildren() == 8, "Eight zones required")
for _, part in parts do
    if part.Name == "GravelShoulder" or part.Name == "PromenadeRoadbed" or part.Name == "SpawnTrailRoadbed" then
        check(part.Position.Y - bounds(part).Y <= 0.001, "Roadbed floating above ground")
    end
end
for _, definition in layout.Zones do
    local found = false
    for _, zone in world.Zones:GetChildren() do
        if zone:GetAttribute("ZoneId") == definition.Id then
            found = true
            check((zone:GetAttribute("Center") - definition.Center).Magnitude < 0.001, "Zone moved")
            check(#zone:GetDescendants() > 10, "Missing recognizable landmark in " .. definition.Id)
        end
    end
    check(found, "Missing zone " .. definition.Id)
end
local visited = {A=true}
for _ = 1, 8 do
    for _, route in layout.Routes do
        if visited[route.From] or visited[route.To] then visited[route.From],visited[route.To]=true,true end
    end
end
for _, zone in layout.Zones do check(visited[zone.Id], "Disconnected zone " .. zone.Id) end
local walkSegments = {}
for _, part in world.VisitorPaths:GetDescendants() do
    if part.Name == "WalkSurface" then
        local a,b,width = part:GetAttribute("Start"),part:GetAttribute("Finish"),part:GetAttribute("Width")
        check(width >= 16 and part.Size.X == width, "Insufficient path width")
        local horizontal = Vector3.new(b.X-a.X,0,b.Z-a.Z)
        check(math.abs(b.Y-a.Y)/horizontal.Magnitude < 0.08, "Path gradient too steep")
        table.insert(walkSegments, {A=a,B=b,Width=width})
        local side = Vector3.new(-horizontal.Z,0,horizontal.X).Unit
        -- Sample a 12-stud central corridor, including avatar radius, every ~4 studs.
        for sample=0,math.ceil(horizontal.Magnitude/4) do
            local t=sample/math.ceil(horizontal.Magnitude/4)
            local center=a:Lerp(b,t)
            for _, offset in {-4.5,0,4.5} do
                local foot = center + side*offset
                for _, obstacle in obstacles do
                    for _, height in {2.2,4.5,6.2} do
                        local point=foot+Vector3.new(0,height,0)
                        check(not inside(point,obstacle,1.5), "Path blocked by " .. obstacle:GetFullName()
                            .. string.format(" near %.1f,%.1f",foot.X,foot.Z))
                    end
                end
            end
        end
    end
end
-- Verify each zone has a physical path junction, including the via node outside A's gate.
for _, zone in layout.Zones do
    local distance = math.huge
    for _, segment in walkSegments do
        distance=math.min(distance,geometry.distanceToSegment(zone.Center,segment.A,segment.B))
    end
    check(distance < 0.1, "No actual path reaches " .. zone.Id)
end
-- Every route endpoint must meet its zone node or a real intersecting route.
local centers = {}
for _, zone in layout.Zones do centers[zone.Id] = zone.Center end
for _, path in world.VisitorPaths:GetChildren() do
    if path.ClassName == "Model" then
        local first, last
        for _, part in path:GetChildren() do
            if part.Name == "WalkSurface" then
                first = first or part:GetAttribute("Start")
                last = part:GetAttribute("Finish")
            end
        end
        check((last-centers[path:GetAttribute("To")]).Magnitude<0.001,"Route misses destination")
        local connected=(first-centers[path:GetAttribute("From")]).Magnitude<0.001
        if not connected then
            for _, segment in walkSegments do
                if (segment.A-first).Magnitude>0.01 and (segment.B-first).Magnitude>0.01
                    and geometry.distanceToSegment(first,segment.A,segment.B)<0.1 then connected=true end
            end
        end
        check(connected,"Detached route start: " .. path.Name)
    end
end
local spawn = world.CapyEnclosure.CapySpawn
check(spawn.ClassName == "SpawnLocation" and spawn.Enabled and spawn.Neutral, "Invalid spawn")
check((spawn.Position-layout.Spawn).Magnitude < 0.001 and spawn.CanCollide, "Spawn misplaced")
check(near(spawn.Position.Y-spawn.Size.Y/2,0),"Spawn pad is not grounded")
for _, obstacle in obstacles do
    for _, dx in {-2.5,0,2.5} do for _, dz in {-2.5,0,2.5} do
        for _, height in {2.5,5,7} do
            check(not inside(spawn.Position+Vector3.new(dx,height,dz),obstacle,0.2),
                "Spawn clearance blocked by " .. obstacle:GetFullName())
        end
    end end
end
check(world.CapyEnclosure.OpenHabitatGate:GetAttribute("Traversable"), "Habitat must connect to paths")
-- At the perimeter, fence spans + gates must cover each side exactly, without gaps.
local spans = {North={},South={},East={},West={}}
for _, group in {world.Perimeter,world.FutureEscapeRoutes} do
    for _, section in group:GetChildren() do
        local a,b=section:GetAttribute("Start"),section:GetAttribute("Finish")
        if a then
            local side,low,high
            if near(a.Z,-214) and near(b.Z,-214) then side,low,high="North",a.X,b.X
            elseif near(a.Z,235) and near(b.Z,235) then side,low,high="South",a.X,b.X
            elseif near(a.X,-282) and near(b.X,-282) then side,low,high="West",a.Z,b.Z
            elseif near(a.X,282) and near(b.X,282) then side,low,high="East",a.Z,b.Z end
            check(side ~= nil, "Misaligned perimeter")
            table.insert(spans[side],{math.min(low,high),math.max(low,high)})
        end
    end
end
for side,list in spans do
    table.sort(list,function(a,b) return a[1]<b[1] end)
    check(near(list[1][1],if side=="North" or side=="South" then -282 else -214),"Missing fence start")
    for i=2,#list do check(near(list[i-1][2],list[i][1]),"Gap/overlap in " .. side) end
    check(near(list[#list][2],if side=="North" or side=="South" then 282 else 235),"Missing fence end")
end
for _, route in layout.FutureRoutes do
    local gate = world.FutureEscapeRoutes:WaitForChild(route.Id)
    check(gate:GetAttribute("Locked"), "Future escape must stay closed")
    check(near((gate:GetAttribute("Finish")-gate:GetAttribute("Start")).Magnitude,route.Width),"Gate width mismatch")
end
local mission = require(resolve("game.ReplicatedStorage.Shared.MissionConfig"))
for _, id in mission.Checkpoints do
    local marker=world.CheckpointMarkers:WaitForChild(id)
    check(not marker.CanCollide and marker:GetAttribute("VisualOnly"),"Checkpoint is not visual only")
    for _, part in parts do
        if part.CanCollide then
            check(not inside(marker.Position,part,0),id .. " hidden inside " .. part:GetFullName())
        end
    end
end
local expectedSignature=signature(world)
local rebuilt=builder.Build()
check(world.Parent==nil and signature(rebuilt)==expectedSignature,"Nondeterministic rebuild")
check(unrelated.Parent==Workspace,"Unrelated content removed")
-- Failure during construction must leave the previous published model intact.
local realNew=Instance.new
Instance.new=function(className)
    if className=="Part" then error("Injected construction failure") end
    return realNew(className)
end
local succeeded=pcall(builder.Build)
Instance.new=realNew
check(not succeeded and rebuilt.Parent==Workspace,"Failed build destroyed prior world")
print(string.format("PASS: %d assertions; %d parts; %d curved path segments; 8 connected zones",checks,#parts,#walkSegments))
