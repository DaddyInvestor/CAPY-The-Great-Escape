-- Minimal data model for headless checks; not an engine or physics emulator.
local Vector3 = {new = function(x, y, z) return {X = x, Y = y, Z = z} end}
local Color3 = {
    fromRGB = function(r, g, b) return {R = r / 255, G = g / 255, B = b / 255} end,
    new = function(r, g, b) return {R = r, G = g, B = b} end,
}
local UDim2 = {fromScale = function(x, y) return {X = x, Y = y} end}
local Enum = setmetatable({}, {__index = function(self, name)
    local enum = setmetatable({}, {__index = function(_, value) return name .. "." .. value end})
    rawset(self, name, enum)
    return enum
end})

local methods = {}
local mt = {
    __index = function(self, key)
        if key == "Parent" then return rawget(self, "_parent") end
        if methods[key] then return methods[key] end
        for _, child in self._children do
            if child.Name == key then return child end
        end
        return nil
    end,
    __newindex = function(self, key, value)
        if key ~= "Parent" then rawset(self, key, value); return end
        local old = rawget(self, "_parent")
        if old then
            local index = table.find(old._children, self)
            if index then table.remove(old._children, index) end
        end
        rawset(self, "_parent", value)
        if value then table.insert(value._children, self) end
    end,
}
local Instance = {new = function(className)
    return setmetatable({ClassName = className, Name = className,
        _children = {}, _attributes = {}, Transparency = 0}, mt)
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
    for _, child in self:GetChildren() do child:Destroy() end
    self.Parent = nil
end

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
