--lazy write(Ai Create)
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

-- Function to create a drawing object
function ESP:CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

-- Function to create a box for a model or part
function ESP:DrawBox(object)
    local box = self:CreateDrawing("Square", {
        Color = self.Settings.BoxColor,
        Thickness = self.Settings.BoxThickness,
        Filled = false,
        Transparency = self.Settings.Transparency,
    })
    box.Visible = false
    return box
end

-- Function to create a tracer for a model or part
function ESP:DrawTracer(object)
    local tracer = self:CreateDrawing("Line", {
        Color = self.Settings.TracerColor,
        Thickness = self.Settings.TracerThickness,
        Transparency = self.Settings.Transparency,
    })
    tracer.Visible = false
    return tracer
end

-- Function to highlight the box
function ESP:HighlightBox(box)
    if self.Settings.HighlightBox then
        box.Color = Color3.fromRGB(0, 255, 0) -- Highlight color (e.g., green)
        box.Thickness = 3
    end
end

-- Function to display name
function ESP:DisplayName(object, position, text)
    local displayName = self:CreateDrawing("Text", {
        Text = text or object.Name,
        Color = Color3.new(1, 1, 1),
        Size = 16,
        Center = true,
        Outline = true,
        OutlineColor = Color3.new(0, 0, 0),
        Transparency = self.Settings.Transparency,
        Position = position,
    })
    displayName.Visible = true
    return displayName
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
                    -- Draw box
                    if ESP.Settings.Boxes then
                        local box = ESP:DrawBox(object)
                        box.Visible = true
                        box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                        box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                        ESP:HighlightBox(box)
                    end
                    
                    -- Draw tracer
                    if ESP.Settings.Tracers then
                        local tracer = ESP:DrawTracer(object)
                        tracer.Visible = true
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                    end

                    -- Display name and workspace asset name
                    if ESP.Settings.Names then
                        local namePosition = Vector2.new(pos.X, pos.Y - 20)
                        ESP:DisplayName(object, namePosition)

                        local workspaceAssetName = ESP:GetWorkspaceAssetName(object)
                        if workspaceAssetName then
                            local assetNamePosition = Vector2.new(pos.X, pos.Y - 40)
                            ESP:DisplayName({Name = workspaceAssetName}, assetNamePosition)
                        end
                    end

                    -- Display distance
                    if ESP.Settings.Distances then
                        local distance = ESP:CalculateDistance(object)
                        local distancePosition = Vector2.new(pos.X, pos.Y - 60)
                        ESP:DisplayName(object, distancePosition, tostring(distance) .. " studs")
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
