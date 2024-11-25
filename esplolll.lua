-- main.lua
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

-- Function to create a BillboardGui
function ESP:CreateBillboardGui(object, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = billboard

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

-- Function to display name
function ESP:DisplayName(object, text)
    self:CreateBillboardGui(object, text or object.Name)
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
                local pos, onScreen = camera:WorldToViewportPoint(object.Position)
                
                if onScreen then
                    -- Highlight object
                    ESP:HighlightObject(object)

                    -- Display name and workspace asset name
                    if ESP.Settings.Names then
                        ESP:DisplayName(object, object.Name)

                        local workspaceAssetName = ESP:GetWorkspaceAssetName(object)
                        if workspaceAssetName then
                            ESP:DisplayName(object, workspaceAssetName)
                        end
                    end

                    -- Display distance
                    if ESP.Settings.Distances then
                        local distance = ESP:CalculateDistance(object)
                        ESP:DisplayName(object, "[" .. tostring(distance) .. "]")
                    end
                end
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
