-- espLib.lua
local ESP = {}

-- Settings
ESP.Settings = {
    Enabled = true,
    Boxes = true,
    Names = true,
    Tracers = true,
    Distances = true, -- New setting to display distances
    BoxColor = Color3.new(1, 0, 0),
    BoxThickness = 2,
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 1,
    Transparency = 1,
    HighlightBox = true,
    MonitorOtherObjects = true, -- New setting to monitor other objects
    TargetName = "", -- New setting for target name
}

-- Dependencies
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local players = game:GetService("Players")

-- Store created ESP elements
local ESPObjects = {}

-- Function to create a BillboardGui
function ESP:CreateBillboardGui(object)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    -- Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = ""
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    -- Distance Label
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = ""
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextScaled = true
    distanceLabel.Parent = billboard

    billboard.Parent = object

    return billboard
end

-- Function to create a highlight for a model or part
function ESP:DrawHighlight(object)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = object
    highlight.FillColor = self.Settings.BoxColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    return highlight
end

-- Function to highlight the object
function ESP:HighlightObject(object)
    if self.Settings.HighlightBox then
        self:DrawHighlight(object)
    end
end

-- Function to update or create ESP
function ESP:UpdateESP(object)
    if not ESPObjects[object] then
        ESPObjects[object] = self:CreateBillboardGui(object)
    end

    local billboard = ESPObjects[object]
    local nameLabel = billboard:FindFirstChild("NameLabel")
    local distanceLabel = billboard:FindFirstChild("DistanceLabel")

    if self.Settings.Names then
        nameLabel.Text = object.Name
    else
        nameLabel.Text = ""
    end

    if self.Settings.Distances then
        local distance = self:CalculateDistance(object)
        distanceLabel.Text = "[" .. tostring(distance) .. "]"
    else
        distanceLabel.Text = ""
    end
end

-- Function to get workspace asset name
function ESP:GetWorkspaceAssetName(object)
    return object:FindFirstChild("workspaceAssetName") and object.workspaceAssetName.Value or nil
end

-- Function to calculate distance
function ESP:CalculateDistance(object)
    local player = players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local distance = (rootPart.Position - object.Position).Magnitude
        return math.floor(distance + 0.5) -- Round distance to nearest integer
    end
    return 0
end

-- Update ESP every frame
runService.RenderStepped:Connect(function()
    if ESP.Settings.Enabled then
        for _, object in pairs(workspace:GetDescendants()) do
            if (object:IsA("BasePart") or (ESP.Settings.MonitorOtherObjects and object:FindFirstChild("workspaceAssetName"))) 
            and (object.Name == ESP.Settings.TargetName or ESP.Settings.TargetName == "") then
                ESP:HighlightObject(object)
                ESP:UpdateESP(object)
            end
        end
    end
end)

-- Function to update ESP settings
function ESP:UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        self.Settings[key] = value
    end
end

-- Set ESP metatable
setmetatable(ESP, {
    __index = function(table, key)
        return ESP[key]
    end
})

_G.ESP = ESP
