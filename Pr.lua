local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local Players = game:GetService("Players")

-- Enhanced Billboard GUI with shadow and opacity improvements
local function createBillboardGui(core, color, name)
    local bill = Instance.new("BillboardGui", game.CoreGui)
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.Adornee = core
    bill.MaxDistance = 2000
    bill.StudsOffset = Vector3.new(0, 3, 0)  -- Adjust offset to prevent overlap

    local txt = Instance.new("TextLabel", bill)
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color
    txt.Size = UDim2.new(1, 0, 0, 25)
    txt.Position = UDim2.new(0.5, 0, 0.3, 0)
    txt.Text = name
    txt.TextStrokeTransparency = 0.3
    txt.TextSize = 26
    txt.Font = Enum.Font.Oswald  -- Change font to Oswald
    Instance.new("UIStroke", txt).Color = color

    local distanceLabel = Instance.new("TextLabel", bill)
    distanceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = color
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0.5, 0, 0.9, 0)
    distanceLabel.TextStrokeTransparency = 0.3
    distanceLabel.TextSize = 20
    distanceLabel.Font = Enum.Font.Oswald  -- Change font to Oswald
    Instance.new("UIStroke", distanceLabel).Color = color

    -- Create a Highlight instance
    local highlight = Instance.new("Highlight")
    highlight.Parent = core
    highlight.Adornee = core
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)  -- White outline
    highlight.OutlineTransparency = 0

    -- Update distance dynamically (without the word "Distance")
    local function updateDistance()
        if core and core:IsDescendantOf(workspace) and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = Players.LocalPlayer.Character.HumanoidRootPart.Position
            local targetPos = core:IsA("BasePart") and core.Position or core.PrimaryPart and core.PrimaryPart.Position

            if targetPos then
                local distance = math.floor((playerPos - targetPos).Magnitude)  -- Ensuring distance is an integer
                distanceLabel.Text = string.format("%d", distance)  -- Display just the distance value, no "Distance"
            end
        end
    end

    RunService.RenderStepped:Connect(updateDistance)
    return bill
end

-- Advanced Tracer that follows the target and supports better visuals
local function createTracer(target, color)
    local line = Drawing.new("Line")
    line.Color = color
    line.Thickness = 2
    line.Transparency = 0.8
    line.Visible = false

    local function updateTracer()
        if target and target:IsDescendantOf(workspace) then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To = Vector2.new(targetPos.X, targetPos.Y)
            line.Visible = true
        else
            line.Visible = false
        end
    end

    RunService.RenderStepped:Connect(updateTracer)
    return line
end

-- Function to check if the part has a specific attribute (or any attribute if no name is given)
local function hasValidAttribute(part, attributeName)
    -- If attributeName is provided, check if the attribute exists and is not nil
    if attributeName then
        return part:GetAttribute(attributeName) ~= nil
    else
        -- If no attributeName is provided, return true if the part has any attribute
        for _, attribute in pairs(part:GetAttributes()) do
            if attribute ~= nil then
                return true
            end
        end
        return false
    end
end

-- The main ESP function with enhanced features and attribute check
function esp(what, color, core, name, enableTracer, attributeName)
    enableTracer = enableTracer or false
    attributeName = attributeName or nil  -- Default to nil, meaning "check for any attribute"

    -- Create part list based on input (Instance or Table of parts)
    local parts = {}
    if typeof(what) == "Instance" then
        if what:IsA("Model") then
            for _, v in ipairs(what:GetChildren()) do
                -- Only process parts that have the valid attribute (if attributeName is specified)
                if v:IsA("BasePart") and hasValidAttribute(v, attributeName) then
                    table.insert(parts, v)
                end
            end
        elseif what:IsA("BasePart") and hasValidAttribute(what, attributeName) then
            table.insert(parts, what)
        end
    elseif typeof(what) == "table" then
    for _, v in ipairs(what) do
            -- Only process parts that have the valid attribute (if attributeName is specified)
            if v:IsA("BasePart") and hasValidAttribute(v, attributeName) then
                table.insert(parts, v)
            end
        end
    end

    local highlights = {}
    local tracers = {}

    -- Apply highlighting and optionally add tracers
    for _, part in ipairs(parts) do
        local highlight = Instance.new("Highlight")
        highlight.Adornee = part
        highlight.FillColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)  -- White outline
        highlight.OutlineTransparency = 0
        highlight.Parent = part
        table.insert(highlights, highlight)

        if enableTracer and #tracers == 0 then
            local tracer = createTracer(part, color)
            table.insert(tracers, tracer)
        end
    end

    -- Create Billboard GUI for name and distance display
    local bill
    if core and name then
        bill = createBillboardGui(core, color, name)
    end

    -- Function to clean up highlights, billboards, and tracers when they are no longer needed
    local function checkAndUpdate()
        for _, highlight in ipairs(highlights) do
            if not highlight.Adornee or not highlight:IsDescendantOf(workspace) then
                highlight:Destroy()
            end
        end

        if bill and (not bill.Adornee or not bill.Adornee:IsDescendantOf(workspace)) then
            bill:Destroy()
        end

        for _, tracer in ipairs(tracers) do
            if not tracer.Visible then
                tracer:Remove()
            end
        end
    end

    RunService.Stepped:Connect(checkAndUpdate)

    -- Return a delete function to remove all objects created by the ESP
    local ret = {}
    ret.delete = function()
        for _, highlight in ipairs(highlights) do
            highlight:Destroy()
        end

        if bill then
            bill:Destroy()
        end

        for _, tracer in ipairs(tracers) do
            tracer:Remove()
        end
    end

    return ret
end

-- Load Linoria UI library and dependencies
local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)
Library.ShowCustomCursor = true -- Toggles the Linoria cursor globally (Default value = true)
Library.NotifySide = "Left" -- Changes the side of the notifications globally (Left, Right) (Default value = Left)

local Window = Library:CreateWindow({
    Title = 'Creepy Client V3',
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Left",
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Explorer = Window:AddTab('Explorer Entity'),
}

local MainGroupBox = Tabs.Main:AddLeftGroupbox('Main Controls')
local ExplorerGroupBox = Tabs.Explorer:AddLeftGroupbox('Explorer Features')

-- Add God Mode toggle
MainGroupBox:AddToggle('GodMode', {
    Text = 'God Mode',
    Default = false,
    Tooltip = 'Activate God Mode',
    Callback = function(Value)
        if Value then
            _G.GodModeLoop = true
            spawn(function()
                while _G.GodModeLoop do
                    local args = {
                        [1] = true
                    }
                    workspace:WaitForChild("Rooms"):WaitForChild("Start"):WaitForChild("Locker"):WaitForChild("Folder"):WaitForChild("Enter"):InvokeServer(unpack(args))
                    wait(1) -- Adjust the interval as needed
                end
            end)
            Library:Notify('God Mode activated!', 3)
        else
            _G.GodModeLoop = false
            Library:Notify('God Mode deactivated!', 3)
        end
    end
})

-- Add Anti Entity (Eyefestation) toggle
MainGroupBox:AddToggle('AntiEntityEyefestation', {
    Text = 'Anti Entity (Eyefestation)',
    Default = false,
    Tooltip = 'Prevent damage from Eyefestation entity',
    Callback = function(Value)
        if Value then
            _G.AntiEntityLoop = true
            spawn(function()
                while _G.AntiEntityLoop do
                    local localDamageEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):FindFirstChild("LocalDamage")
                    if localDamageEvent then
                        localDamageEvent:Destroy() -- Break the LocalDamage event
                    end
                    wait(1) -- Adjust the interval as needed
                end
            end)
            Library:Notify('Anti Entity (Eyefestation) activated!', 3)
        else
            _G.AntiEntityLoop = false
            -- Note: You may need to re-initialize LocalDamage event if disabling anti-entity
            Library:Notify('Anti Entity (Eyefestation) deactivated!', 3)
        end
    end
})

-- Add NormalDoor ESP toggle
ExplorerGroupBox:AddToggle('NormalDoorESP', {
    Text = 'NormalDoor ESP',
    Default = false,
    Tooltip = 'Highlight NormalDoors with ESP',
    Callback = function(Value)
        if Value then
            connection = RunService.Stepped:Connect(function()
                for _, door in pairs(workspace:GetDescendants()) do
                    if door.Name == "NormalDoor" and not door:FindFirstChild("Highlight") then
                        local player = Players.LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local rootPart = character:WaitForChild("HumanoidRootPart")
                        if (door.Position - rootPart.Position).Magnitude <= 1000 then
                            esp(door, Color3.new(1, 0, 0), door, "NormalDoor", true)
                        end
                    end
                end
            end)
            Library:Notify('NormalDoor ESP activated!', 3)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            -- Remove existing ESP highlights
            for _, door in pairs(workspace:GetDescendants()) do
                if door.Name == "NormalDoor" and door:FindFirstChild("Highlight") then
                    door.Highlight:Destroy()
                end
            end
            Library:Notify('NormalDoor ESP deactivated!', 3)
        end
    end
})

-- Add NormalKeyCard ESP toggle
ExplorerGroupBox:AddToggle('NormalKeyCardESP', {
    Text = 'NormalKeyCard ESP',
    Default = false,
    Tooltip = 'Highlight NormalKeyCards with ESP',
    Callback = function(Value)
        if Value then
            connection = RunService.Stepped:Connect(function()
                for _, keycard in pairs(workspace:GetDescendants()) do
                    if keycard.Name == "NormalKeyCard" and not keycard:FindFirstChild("Highlight") then
                       local player = Players.LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local rootPart = character:WaitForChild("HumanoidRootPart")
                        local proxyPart = keycard:WaitForChild("ProxyPart")
                        if (proxyPart.Position - rootPart.Position).Magnitude <= 1000 then
                            esp(keycard, Color3.new(0, 1, 0), proxyPart, "NormalKeyCard", false)
                        end
                    end
                end
            end)
            Library:Notify('NormalKeyCard ESP activated!', 3)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            -- Remove existing ESP highlights
            for _, keycard in pairs(workspace:GetDescendants()) do
                if keycard.Name == "NormalKeyCard" and keycard:FindFirstChild("Highlight") then
                    keycard.Highlight:Destroy()
                end
            end
            Library:Notify('NormalKeyCard ESP deactivated!', 3)
        end
    end
})

print("Creepy Client V3 loaded!")
