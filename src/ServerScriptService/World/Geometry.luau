--!strict
-- Primitive construction shared by the terrain, architecture and path builders.
local G = {}

function G.model(parent: Instance?, name: string): Model
    local result = Instance.new("Model")
    result.Name = name
    result.Parent = parent
    return result
end

function G.part(parent: Instance, name: string, size: Vector3, frame: CFrame,
    color: Color3, material: Enum.Material, solid: boolean?, className: string?): BasePart
    local p = Instance.new(className or "Part") :: BasePart
    p.Name = name
    p.Size = size
    p.CFrame = frame
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.CanCollide = solid ~= false
    p.CanTouch = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

function G.disc(parent: Instance, name: string, x: number, z: number, rx: number, rz: number,
    top: number, depth: number, color: Color3, material: Enum.Material, solid: boolean?): BasePart
    local p = G.part(parent, name, Vector3.new(depth, rx * 2, rz * 2),
        CFrame.new(x, top - depth / 2, z) * CFrame.Angles(0, 0, math.pi / 2), color, material, solid)
    local shape = p :: Part
    shape.Shape = Enum.PartType.Cylinder
    return p
end

function G.ellipsoid(parent: Instance, name: string, pos: Vector3, size: Vector3,
    color: Color3, material: Enum.Material, solid: boolean?): BasePart
    local p = G.part(parent, name, size, CFrame.new(pos), color, material, solid)
    local shape = p :: Part
    shape.Shape = Enum.PartType.Ball
    return p
end

function G.beam(parent: Instance, name: string, a: Vector3, b: Vector3, width: number,
    height: number, color: Color3, material: Enum.Material, solid: boolean?): BasePart
    local direction = (b - a).Unit
    local up = if math.abs(direction.Y) > 0.99 then Vector3.new(0, 0, 1) else Vector3.new(0, 1, 0)
    return G.part(parent, name, Vector3.new(width, height, (b - a).Magnitude),
        CFrame.lookAt((a + b) / 2, b, up), color, material, solid)
end

function G.sign(parent: Instance, name: string, pos: Vector3, text: string, color: Color3,
    width: number?): BasePart
    local p = G.part(parent, name, Vector3.new(width or 20, 5, 0.7), CFrame.new(pos),
        color, Enum.Material.Wood)
    -- Both sides are readable, including from the route and inside the habitat.
    for _, face in {Enum.NormalId.Front, Enum.NormalId.Back} do
        local gui = Instance.new("SurfaceGui")
        gui.Face = face
        gui.LightInfluence = 0
        gui.PixelsPerStud = 40
        gui.Parent = p
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.TextWrapped = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
    end
    return p
end

function G.curve(a: Vector3, control: Vector3, b: Vector3, t: number): Vector3
    return a * ((1 - t) ^ 2) + control * (2 * (1 - t) * t) + b * (t ^ 2)
end

function G.distanceToSegment(p: Vector3, a: Vector3, b: Vector3): number
    local dx, dz = b.X - a.X, b.Z - a.Z
    local length = dx * dx + dz * dz
    local t = if length == 0 then 0 else math.clamp(((p.X - a.X) * dx + (p.Z - a.Z) * dz) / length, 0, 1)
    return math.sqrt((p.X - a.X - t * dx) ^ 2 + (p.Z - a.Z - t * dz) ^ 2)
end

function G.fence(parent: Instance, name: string, a: Vector3, b: Vector3, height: number,
    color: Color3): Model
    local fence = G.model(parent, name)
    fence:SetAttribute("Start", a)
    fence:SetAttribute("Finish", b)
    local count = math.ceil((b - a).Magnitude / 16)
    for i = 0, count do
        local p = a:Lerp(b, i / count)
        G.part(fence, "Post", Vector3.new(2.2, height + 0.7, 2.2),
            CFrame.new(p + Vector3.new(0, height / 2, 0)), color, Enum.Material.Wood)
        G.ellipsoid(fence, "PostCap", p + Vector3.new(0, height + 0.6, 0),
            Vector3.new(2.7, 1.5, 2.7), color, Enum.Material.Wood, false)
    end
    for _, level in {2.0, height * 0.53, height - 1} do
        G.beam(fence, "Rail", a + Vector3.new(0, level, 0), b + Vector3.new(0, level, 0),
            1.1, 1.0, color, Enum.Material.Wood)
    end
    return fence
end

return G
