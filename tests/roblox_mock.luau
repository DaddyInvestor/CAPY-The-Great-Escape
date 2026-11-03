local mockClock = 100
local os = {clock=function() return mockClock end}
local task = {spawn=function(callback) callback() end}
local TweenInfo = {new=function(...) return {...} end}
local UDim = {new=function(a,b) return {Scale=a,Offset=b} end}
local Vector2 = {new=function(x,y) return {X=x,Y=y} end}
local mockClientPlayer=nil
local function signal()
    local callbacks={}
    return {Connect=function(_,callback)
        local connection={Connected=true}
        function connection:Disconnect() self.Connected=false end
        table.insert(callbacks,{connection,callback})
        return connection
    end, Fire=function(_, ...)
        for _, entry in table.clone(callbacks) do
            if entry[1].Connected then entry[2](...) end
        end
    end, Count=function()
        local n=0
        for _, entry in callbacks do if entry[1].Connected then n+=1 end end
        return n
    end}
end
-- Minimal data model for headless checks; not an engine or physics emulator.
local vmt = {}
local Vector3 = {}
function Vector3.new(x, y, z) return setmetatable({X=x, Y=y, Z=z}, vmt) end
function vmt.__add(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function vmt.__sub(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function vmt.__unm(a) return Vector3.new(-a.X,-a.Y,-a.Z) end
function vmt.__mul(a,b)
    if type(a)=="number" then return b*a end
    return Vector3.new(a.X*b,a.Y*b,a.Z*b)
end
function vmt.__div(a,b) return a*(1/b) end
function vmt.__index(a,k)
    if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
    if k=="Unit" then return a/a.Magnitude end
    if k=="Lerp" then return function(self,b,t) return self+(b-self)*t end end
    if k=="Dot" then return function(self,b) return self.X*b.X+self.Y*b.Y+self.Z*b.Z end end
    if k=="Cross" then return function(self,b)
        return Vector3.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X)
    end end
end
local CFrame = {}
local fmt = {}
local identity = {1,0,0,0,1,0,0,0,1}
local function frame(p,r) return setmetatable({Position=p, r=r}, fmt) end
function CFrame.new(x,y,z)
    return frame(if type(x)=="table" then x else Vector3.new(x or 0,y or 0,z or 0),table.clone(identity))
end
function CFrame.Angles(x,y,z)
    local sx,cx,sy,cy,sz,cz=math.sin(x),math.cos(x),math.sin(y),math.cos(y),math.sin(z),math.cos(z)
    return frame(Vector3.new(0,0,0),{cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,
        sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy})
end
local function rotate(a,v)
    local r=a.r
    return Vector3.new(r[1]*v.X+r[2]*v.Y+r[3]*v.Z,r[4]*v.X+r[5]*v.Y+r[6]*v.Z,r[7]*v.X+r[8]*v.Y+r[9]*v.Z)
end
function fmt.__mul(a,b)
    local r={}
    for row=0,2 do for col=0,2 do
        local value=0
        for k=0,2 do value+=a.r[row*3+k+1]*b.r[k*3+col+1] end
        r[row*3+col+1]=value
    end end
    return frame(a.Position+rotate(a,b.Position),r)
end
function fmt.__index(a,k)
    if k=="GetComponents" then return function(self)
        return self.Position.X,self.Position.Y,self.Position.Z,table.unpack(self.r)
    end end
    if k=="VectorToWorldSpace" then return rotate end
end
function CFrame.lookAt(p,target)
    local forward=(target-p).Unit
    local up=Vector3.new(0,1,0)
    if math.abs(forward.Y)>0.99 then up=Vector3.new(0,0,1) end
    local right=forward:Cross(up).Unit
    up=right:Cross(forward)
    return frame(p,{right.X,up.X,-forward.X,right.Y,up.Y,-forward.Y,right.Z,up.Z,-forward.Z})
end
local Color3 = {
    fromRGB = function(r, g, b) return {R = r / 255, G = g / 255, B = b / 255} end,
    new = function(r, g, b) return {R = r, G = g, B = b} end,
}
local UDim2 = {
    fromScale = function(x,y) return {X={Scale=x,Offset=0},Y={Scale=y,Offset=0}} end,
    fromOffset = function(x,y) return {X={Scale=0,Offset=x},Y={Scale=0,Offset=y}} end,
    new = function(a,b,c,d) return {X={Scale=a,Offset=b},Y={Scale=c,Offset=d}} end,
}
local Enum = setmetatable({}, {__index = function(self, name)
    local enum = setmetatable({}, {__index = function(_, value) return name .. "." .. value end})
    rawset(self, name, enum)
    return enum
end})

local methods = {}
local mt = {
    __index = function(self, key)
        if key == "Parent" then return rawget(self, "_parent") end
        if key == "CFrame" then return rawget(self, "_frame") end
        if key == "Position" then return rawget(self, "_frame").Position end
        if methods[key] then return methods[key] end
        for _, child in self._children do
            if child.Name == key then return child end
        end
        return nil
    end,
    __newindex = function(self, key, value)
        if key == "CFrame" then rawset(self, "_frame", value); return end
        if key == "Position" then rawget(self, "_frame").Position = value; return end
        if key ~= "Parent" then rawset(self, key, value); return end
        local old = rawget(self, "_parent")
        if old then
            local index = table.find(old._children, self)
            if index then table.remove(old._children, index) end
        end
        rawset(self, "_parent", value)
        if value then table.insert(value._children, self); value.ChildAdded:Fire(self) end
    end,
}
local Instance = {new = function(className)
    local object = setmetatable({ClassName = className, Name = className,
        _children = {}, _attributes = {}, Transparency = 0, _frame = CFrame.new()}, mt)
    for _, name in {"Destroying","ChildAdded","CharacterAdded","Triggered","OnClientEvent","Running","Activated"} do
        object[name]=signal()
    end
    return object
end}
function methods:GetChildren() return table.clone(self._children) end
function methods:GetDescendants()
    local result = {}
    for _, child in self._children do
        table.insert(result, child)
        for _, descendant in child:GetDescendants() do table.insert(result, descendant) end
    end
    return result
end
function methods:FindFirstChild(name)
    for _, child in self._children do
        if child.Name == name then return child end
    end
    return nil
end
function methods:WaitForChild(name)
    return assert(self:FindFirstChild(name), "Unresolved reference: " .. self.Name .. "." .. name)
end
function methods:SetAttribute(key, value) self._attributes[key] = value end
function methods:GetAttribute(key) return self._attributes[key] end
function methods:GetFullName()
    return if self.Parent then self.Parent:GetFullName() .. "." .. self.Name else self.Name
end
function methods:Destroy()
    self.Destroying:Fire()
    for _, child in self:GetChildren() do child:Destroy() end
    self.Parent = nil
end

function methods:IsA(className)
    return self.ClassName == className or (className == "BasePart"
        and table.find({"Part", "WedgePart", "SpawnLocation"}, self.ClassName) ~= nil)
end
function methods:FindFirstChildOfClass(className)
    for _, object in self._children do if object.ClassName==className then return object end end
end
function methods:PivotTo(frame)
    local root=self:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame=frame end
end
function methods:FireClient(player,value)
    self._sent=self._sent or {}
    self._sent[player]=value
    if player==mockClientPlayer then self.OnClientEvent:Fire(value) end
end
function methods:InvokeServer() return self.OnServerInvoke(mockClientPlayer) end
local game = Instance.new("DataModel")
game.Name = "game"
local function child(parent, className, name)
    local object = Instance.new(className)
    object.Name = name
    object.Parent = parent
    return object
end
local Workspace = child(game, "Workspace", "Workspace")
child(game, "ReplicatedStorage", "ReplicatedStorage")
child(game, "ServerScriptService", "ServerScriptService")
local Players=child(game,"Players","Players")
Players.PlayerAdded,Players.PlayerRemoving=signal(),signal()
function Players:GetPlayers() return self:GetChildren() end
local TweenService=child(game,"TweenService","TweenService")
function TweenService:Create(object,info,goals)
    local tween={Completed=signal()}
    function tween:Play()
        for k,v in goals do object[k]=v end
        self.Completed:Fire()
    end
    function tween:Cancel() end
    return tween
end
local RunService=child(game,"RunService","RunService")
RunService.Heartbeat=signal()
local camera=child(Workspace,"Camera","Camera")
camera.FieldOfView=70
Workspace.CurrentCamera=camera
function methods:Clone()
    local copy=Instance.new(self.ClassName)
    for key,value in self do
        if string.sub(key,1,1)~="_" and not (type(value)=="table" and value.Connect) then copy[key]=value end
    end
    copy._attributes=table.clone(self._attributes)
    copy._frame=frame(self._frame.Position,table.clone(self._frame.r))
    for _, item in self:GetChildren() do item:Clone().Parent=copy end
    return copy
end
function game:GetService(name) return self:WaitForChild(name) end

local loaders, cache = {}, {}
local function resolve(path)
    local object = game
    for segment in string.gmatch(path, "[^.]+") do
        if segment ~= "game" then object = object:WaitForChild(segment) end
    end
    return object
end
local function register(path, className, loader)
    local parent = game
    local segments = string.split(path, ".")
    for i = 2, #segments do
        local name = segments[i]
        parent = parent:FindFirstChild(name)
            or child(parent, if i == #segments then className else "Folder", name)
    end
    loaders[parent] = loader
end
local function require(module)
    assert(module and module.ClassName == "ModuleScript", "require target is not a ModuleScript")
    if cache[module] == nil then
        cache[module] = assert(loaders[module], "Missing module loader")(module)
    end
    return cache[module]
end
