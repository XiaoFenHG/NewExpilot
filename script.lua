local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local Players = game:GetService("Players")
local connection
-- Function to create a smoother and more advanced highlight with effects
local function createHighlightBoxWithCylinders(part, color)
    if not part or not part:IsA("BasePart") then
        return nil
    end

    local highlightBox = Instance.new("Part")
    highlightBox.Size = part.Size + Vector3.new(0.2, 0.2, 0.2) -- Slightly larger than the part
    highlightBox.Transparency = 1  -- Make the box itself invisible
    highlightBox.Anchored = true
    highlightBox.CanCollide = false
    highlightBox.CFrame = part.CFrame
    highlightBox.Parent = workspace

    local function createCornerCylinder(position, size)
        local cylinder = Instance.new("Part")
        cylinder.Shape = Enum.PartType.Cylinder
        cylinder.Size = size
        cylinder.Color = color
        cylinder.Transparency = 0.5
        cylinder.Anchored = true
        cylinder.CanCollide = false
        cylinder.Material = Enum.Material.Neon
        cylinder.CFrame = position
        cylinder.Parent = highlightBox
        return cylinder
    end

    local cornerPositions = {
        CFrame.new(-highlightBox.Size.X / 2, -highlightBox.Size.Y / 2, -highlightBox.Size.Z / 2),
        CFrame.new(highlightBox.Size.X / 2, -highlightBox.Size.Y / 2, -highlightBox.Size.Z / 2),
        CFrame.new(-highlightBox.Size.X / 2, highlightBox.Size.Y / 2, -highlightBox.Size.Z / 2),
        CFrame.new(highlightBox.Size.X / 2, highlightBox.Size.Y / 2, -highlightBox.Size.Z / 2),
        CFrame.new(-highlightBox.Size.X / 2, -highlightBox.Size.Y / 2, highlightBox.Size.Z / 2),
        CFrame.new(highlightBox.Size.X / 2, -highlightBox.Size.Y / 2, highlightBox.Size.Z / 2),
        CFrame.new(-highlightBox.Size.X / 2, highlightBox.Size.Y / 2, highlightBox.Size.Z / 2),
        CFrame.new(highlightBox.Size.X / 2, highlightBox.Size.Y / 2, highlightBox.Size.Z / 2),
    }
    
    local cylinderSize = Vector3.new(0.1, highlightBox.Size.Y, 0.1)  -- Adjust cylinder size as needed

    for _, pos in pairs(cornerPositions) do
        createCornerCylinder(highlightBox.CFrame * pos, cylinderSize)
    end

    local function updatePosition()
        if part:IsDescendantOf(workspace) then
            highlightBox.CFrame = part.CFrame
        else
            highlightBox:Destroy()
        end
    end

    game:GetService("RunService").RenderStepped:Connect(updatePosition)
    return highlightBox
end

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
    txt.Font = Enum.Font.Code
    Instance.new("UIStroke", txt).Color = color

    local distanceLabel = Instance.new("TextLabel", bill)
    distanceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = color
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0.5, 0, 0.9, 0)
    distanceLabel.TextStrokeTransparency = 0.3
    distanceLabel.TextSize = 20
    distanceLabel.Font = Enum.Font.Code
    Instance.new("UIStroke", distanceLabel).Color = color

    -- Update distance dynamically (without the word "Distance")
    local function updateDistance()
        if core and core:IsDescendantOf(workspace) then
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
        local highlight = createHighlight(part, color)
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
local flags = {
        sc = false,
	sj = false,
	sd = false,
	gc =false,
	g = false,
	g2 = false,
	error = false,
	r3 = false,
	eyes = false,
	esplocker = false,
	esprush = false,
        espitems = false,
        espkeys = false,
	espdoors = false,
	espGuidance = false,
	noseek = false,
	espbooks = false,
	instapp2 = false,
	Keyaura = false,
	itemaura = false,
	draweraura = false,
	espGeneratorsAndFuses = false,
	timerLeverFlag = false
}
local esptable = {
    entity = {},
    doors = {},
    lockers = {},
    items = {},
    books = {},
    Gold = {},
    keys = {},
    loc = {},
    lol = {},
    guidances = {},
    generators = {},
    fuses = {},
    timerLevers = {}
}

local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.NotifySide = "Right" -- Changes the side of the notifications globaly (Left, Right) (Default value = Left)
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)
Library.ShowCustomCursor = true -- Toggles the Linoria cursor globaly (Default value = true)
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local entityModules = ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("EntityModules")
local remotesFolder
remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder", 5) -- Set a timeout
local fireTouch
local Window = Library:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Set Resizable to true if you want to have in-game resizable Window
	-- Set ShowCustomCursor to false if you don't want to use the Linoria cursor
	-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)

	Title = 'Expilot Hax A4',
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	NotifySide = "Left",
	TabPadding = 8,
	MenuFadeTime = 0.2
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
	-- Creates a new tab titled Main
	Main = Window:AddTab('LocalPlayer'),
	Main2 = Window:AddTab('Expliots'),
        Main3 = Window:AddTab('Expliots ESP'),
	['UI Settings'] = Window:AddTab('UI Addons'),
	Enity = Window:AddTab('Enity spawner'),
}
local RightGroup = Tabs.Main3:AddLeftGroupbox('ESP')
local LeftGroupBox = Tabs.Enity:AddLeftGroupbox('Enity')
local Group = Tabs.Main:AddLeftGroupbox('Chat Nofiction')
local textChannel = game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
-- Add Input Boxes and Buttons for custom entity parameters
Group:AddToggle('entityEvent', {
    Text = 'Entity Event',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            local entityNames = {"RushMoving", "AmbushMoving", "Snare", "A60", "A120", "A90", "Eyes", "JeffTheKiller"}
            local plr = game.Players.LocalPlayer

            local function notifyEntitySpawn(entity)
                local entityName = entity.Name:gsub("Moving", ""):lower()
                local entityMessage = entityName .. " " .. (customEntityMessage or "Spawned!")
                addAndPlaySound("ExampleSound", 4590657391)
                textChannel:SendAsync(entityMessage) -- 使用 SendAsync 发送消息
            end

            local function onChildAdded(child)
                if table.find(entityNames, child.Name) then
                    repeat task.wait() until plr:DistanceFromCharacter(child:GetPivot().Position) < 1000 or not child:IsDescendantOf(workspace)

                    if child:IsDescendantOf(workspace) then
                        notifyEntitySpawn(child)
                    end
                end
            end

            local connection = workspace.ChildAdded:Connect(onChildAdded)

            -- 处理运行状态
            while state do
                task.wait(1)
            end
            connection:Disconnect()
        end
    end
})
Group:AddToggle('No Clip', {
    Text = 'Library Code',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(val)
        local addConnect
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait() -- Ensure char is defined
        if val then
            -- Function: Decode the code from LibraryHintPaper
            local function decipherCode()
                local paper = char:FindFirstChild("LibraryHintPaper")
                local hints = plr.PlayerGui:WaitForChild("PermUI"):WaitForChild("Hints")
                local code = {"_", "_", "_", "_", "_"}
                if paper then
                    for i, v in pairs(paper:WaitForChild("UI"):GetChildren()) do
                        if v:IsA("ImageLabel") and v.Name ~= "Image" then
                            for _, img in pairs(hints:GetChildren()) do
                                if img:IsA("ImageLabel") and img.Visible and v.ImageRectOffset == img.ImageRectOffset then
                                    local num = img:FindFirstChild("TextLabel") and img.TextLabel.Text or "_"
                                    code[tonumber(v.Name)] = num 
                                end
                            end
                        end
                    end 
                end
                return code
            end
            -- Listen for LibraryHintPaper tool addition
            addConnect = char.ChildAdded:Connect(function(v)
                if v:IsA("Tool") and v.Name == "LibraryHintPaper" then
                    task.wait()
                    local code = table.concat(decipherCode())
                    -- Check for missing books
                    if code:find("_") then
                        local message = "You are still missing some books! The current code is: '" .. code .. "'"
			addAndPlaySound("ExampleSound", 4590657391)
                        textChannel:SendAsync(message) -- 使用 SendAsync 发送消息
                    else
                        if not apart then
                            apart = Instance.new("Part", game.ReplicatedStorage)
                            apart.CanCollide = false
                            apart.Anchored = true
                            apart.Position = game.Players.LocalPlayer.Character.PrimaryPart.Position
                            apart.Transparency = 1
                            -- Play sound
                            addAndPlaySound("ExampleSound", 4590657391)
                            -- Notify complete code
                            local successMessage = "The code is '" .. code .. "'."
                            textChannel:SendAsync(successMessage) -- 使用 SendAsync 发送消息
                            repeat
                                task.wait(0.1)
                            until game:GetService("ReplicatedStorage").GameData.LatestRoom.Value ~= 50
                            apart:Destroy()
                            apart = nil
                        end
                    end
                end
            end)
        else
            -- If toggled off, disconnect the event
            if addConnect then
                addConnect:Disconnect()
            end
        end
    end
})

local SoundService = game:GetService("SoundService")

-- 添加并播放声音
local function addAndPlaySound(name, soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Name = name
    sound.Parent = SoundService
    sound:Play()
end
local RightGroup1 = Tabs.Main:AddLeftGroupbox('Nofiction')
RightGroup:AddToggle('pe', {
    Text = 'Player esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.espInstances = {}
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    local espInstance = esp(player.Character, Color3.new(1, 9, 0), player.Character:FindFirstChild("HumanoidRootPart"), player.Name)
                    table.insert(_G.espInstances, espInstance)
                end
            end
        else
            if _G.espInstances then
                for _, espInstance in pairs(_G.espInstances) do
                    espInstance.delete()
                end
                _G.espInstances = nil
            end
        end
    end
})

RightGroup:AddToggle('Monitor MinesGenerator', {
    Text = 'Generator esp',
    Default = false,
    Tooltip = 'all MinesGenerator in CurrentRooms',
    Callback = function(state)
        local customSuffix = "MinesGeneratorMonitor" -- 自定义后缀
        local flagsName = "monitorMinesGenerator" .. customSuffix
        local espTableName = "minesGeneratorESPInstances" .. customSuffix

        if state then
            _G[espTableName] = {}
            _G[flagsName] = state

            local function check(v)
                if v:IsA("Model") and v.Name == "MinesGenerator" then
		    local generatorMain = v:FindFirstChild("GeneratorMain")
                    if generatorMain then
                        local h = esp(generatorMain, Color3.fromRGB(0, 255, 0), generatorMain, "Generator")
                        table.insert(esptable.minesGeneratorESP, h)
                    end
                end
            end

            local function setup(room)
                local assets = room:WaitForChild("Assets")

                if assets then
                    local subaddcon
                    subaddcon = assets.DescendantAdded:Connect(function(v)
                        check(v)
                    end)

                    for i, v in pairs(assets:GetDescendants()) do
                        check(v)
                    end

                    task.spawn(function()
                        repeat task.wait() until not _G[flagsName]
                        subaddcon:Disconnect()
                    end)
                end
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)

            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room)
            end

            table.insert(_G[espTableName], esptable)
        else
            if _G[espTableName] then
                for _, instance in pairs(_G[espTableName]) do
                    for _, v in pairs(instance.minesGeneratorESP) do
                        v.delete()
                    end
                end
                _G[espTableName] = nil
            end
        end
    end
})

RightGroup:AddToggle('pe', {
    Text = 'Item esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.itemESPInstances = {}
            flags.espitems = state

	    local function check(v)
                if v:IsA("Model") and (v:GetAttribute("Pickup") or v:GetAttribute("PropType")) then
                    task.wait(0.1)
                    
                    local part = (v:FindFirstChild("Handle") or v:FindFirstChild("Prop"))
                    local h = esp(part, Color3.fromRGB(255, 255, 255), part, v.Name)
                    table.insert(esptable.items, h)
                end
            end
            
            local function setup(room)
                local assets = room:WaitForChild("Assets")
                
                if assets then  
                    local subaddcon
                    subaddcon = assets.DescendantAdded:Connect(function(v)
                        check(v) 
                    end)
                    
                    for i, v in pairs(assets:GetDescendants()) do
                        check(v)
                    end
                    
                    task.spawn(function()
                        repeat task.wait() until not flags.espitems
                        subaddcon:Disconnect()  
                    end) 
                end 
            end
            
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:FindFirstChild("Assets") then
                    setup(room) 
                end
            end

            table.insert(_G.itemESPInstances, esptable)

        else
            if _G.itemESPInstances then
                for _, instance in pairs(_G.itemESPInstances) do
                    for _, v in pairs(instance.items) do
                        v.delete()
                    end
                end
                _G.itemESPInstances = nil
            end
        end
    end
})
RightGroup:AddToggle('pe', {
    Text = 'Key ESP',
    Default = false,
    Tooltip = 'Highlight keys',
    Callback = function(state)
        if state then
            _G.keyESPInstances = {}
            flags.espkeys = state

            local function setupKey(keyObject)
                if keyObject.Name == "KeyObtain" then
                    local h = esp(keyObject, Color3.fromRGB(173, 216, 230), keyObject, "Key") -- 高亮显示KeyObtain
                    table.insert(esptable.keys, h)

                    keyObject.AncestryChanged:Connect(function()
                        h.delete()
                    end)
                end
            end

            local function searchForKeys()
                while flags.espkeys do
                    for _, service in pairs(game:GetChildren()) do
                        for _, v in pairs(service:GetDescendants()) do
                            if v.Name == "KeyObtain" then
                                setupKey(v)
                            end
                        end
                    end
                    task.wait(1) -- 每隔一秒搜索一次
                end
            end

            -- 初始搜索一次
            for _, service in pairs(game:GetChildren()) do
                for _, v in pairs(service:GetDescendants()) do
                    if v.Name == "KeyObtain" then
                        setupKey(v)
                    end
                end
            end

            -- 开始循环搜索
            connection = task.spawn(searchForKeys)

            table.insert(_G.keyESPInstances, esptable)

        else
            if connection then
                connection:Cancel()
                connection = nil
            end
            if _G.keyESPInstances then
                for _, instance in pairs(_G.keyESPInstances) do
                    for _, v in pairs(instance.keys) do
                        v.delete()
                    end
                end
                _G.keyESPInstances = nil
            end
        end
    end
})

RightGroup:AddToggle('pe', {
    Text = 'Door esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.doorESPInstances = {}
            flags.espdoors = state
                
            local function setup(room)
                local door = room:WaitForChild("Door") -- Directly get the Door object
                
                task.wait(0.1)
                
                -- Get the RoomID attribute
                local roomID = door:GetAttribute("RoomID") or "Unknown"
                
                -- Check the Opened attribute to determine the status
                local doorStatus = door:GetAttribute("Opened") and "Opened" or "Locked"
                
                -- Set up ESP with the door status in the format "Door [RoomID] - Status"
                local h = esp(door:WaitForChild("Door"), Color3.fromRGB(90, 255, 40), door, "Door [" .. roomID .. "] - " .. doorStatus)
                table.insert(esptable.doors, h)
                
                door:WaitForChild("Door"):WaitForChild("Open").Played:Connect(function()
                    h.delete()
                end)
                
                door.AncestryChanged:Connect(function()
                    h.delete()
                end)
            end
            
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:FindFirstChild("Assets") then
                    setup(room) 
                end
            end

            table.insert(_G.doorESPInstances, esptable)

        else
            if _G.doorESPInstances then
                for _, instance in pairs(_G.doorESPInstances) do
                    for _, v in pairs(instance.doors) do
                        v.delete()
                    end
                end
                _G.doorESPInstances = nil
            end
        end
    end
})
RightGroup:AddToggle('pe', {
    Text = 'Timer Lever esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.timerLeverESPInstances = {}
            local timerLeverFlag = state
            
            local function check(v)
                if v:IsA("Model") then
                    task.wait(0.1)
                    if v.Name == "TimerLever" then
                        local h = esp(v.PrimaryPart, Color3.fromRGB(90, 255, 40), v.PrimaryPart, "Timer Lever")
                        table.insert(espTable.timerLevers, h) 
                    end
                end
            end
                
            local function setup(room)
                local assets = room:WaitForChild("Assets")
                
                if assets then
                    local subaddcon
                    subaddcon = assets.DescendantAdded:Connect(function(v)
                        check(v) 
                    end)
                    
                    for _, v in pairs(assets:GetDescendants()) do
                        check(v)
                    end
                    
                    task.spawn(function()
                        repeat task.wait() until not timerLeverFlag
                        subaddcon:Disconnect()  
                    end) 
                end 
            end
            
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room) 
            end

            table.insert(_G.timerLeverESPInstances, espTable)

        else
            if _G.timerLeverESPInstances then
                for _, instance in pairs(_G.timerLeverESPInstances) do
                    for _, v in pairs(instance.timerLevers) do
                        v.delete()
                    end
                end
                _G.timerLeverESPInstances = nil
            end
        end
    end
})
RightGroup:AddToggle('pe', {
    Text = 'Closet Locker esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.lockerESPInstances = {}
	    flags.esplocker = state
	    local function check(v)
                if v:IsA("Model") then
                    task.wait(0.1)
                    if v.Name == "Wardrobe" or v.Name == "Locker_Large" or v.Name == "Backdoor_Wardrobe" then
                        local h = esp(v.PrimaryPart, Color3.fromRGB(90, 255, 40), v.PrimaryPart, "Closet")
                        table.insert(esptable.lockers, h) 
                    elseif (v.Name == "Rooms_Locker" or v.Name == "Rooms_Locker_Fridge") then
                        local h = esp(v.PrimaryPart, Color3.fromRGB(90, 255, 40), v.PrimaryPart, "Locker")
                        table.insert(esptable.lockers, h) 
                    end
                end
            end
                
            local function setup(room)
                local assets = room:WaitForChild("Assets")
                
                if assets then
                    local subaddcon
                    subaddcon = assets.DescendantAdded:Connect(function(v)
                        check(v) 
                    end)
                    
                    for i, v in pairs(assets:GetDescendants()) do
                        check(v)
                    end
                    
                    task.spawn(function()
                        repeat task.wait() until not flags.esplocker
                        subaddcon:Disconnect()  
                    end) 
                end 
            end
            
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room) 
            end

            table.insert(_G.lockerESPInstances, esptable)

	else
            if _G.lockerESPInstances then
                for _, instance in pairs(_G.lockerESPInstances) do
                    for _, v in pairs(instance.lockers) do
                        v.delete()
                    end
                end
                _G.lockerESPInstances = nil
            end
        end
    end
})
RightGroup:AddToggle('ee', {
    Text = 'enity esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.entityESPInstances = {}
            flags.esprush = state
            local entitynames = {"RushMoving", "AmbushMoving", "Snare", "A60", "A120", "Eyes", "JeffTheKiller", "SeekMoving", "GiggleCeiling", "BackdoorRush"}
	    
            local addconnect
            addconnect = workspace.ChildAdded:Connect(function(v)
                if table.find(entitynames, v.Name) then
                    task.wait(0.1)
                    
                    local h = esp(v, Color3.fromRGB(255, 25, 25), v.PrimaryPart, v.Name:gsub("Moving", ""))
                    table.insert(esptable.entity, h)
                end
            end)

            local function setup(room)
                if room.Name == "50" or room.Name == "100" then
                    local figuresetup = room:WaitForChild("FigureSetup")
                
                    if figuresetup then
                        local fig = figuresetup:WaitForChild("FigureRagdoll")
                        task.wait(0.1)
                        
                        local h = esp(fig, Color3.fromRGB(255, 25, 25), fig.PrimaryPart, "Figure")
                        table.insert(esptable.entity, h)
                    end 
                else
                    local assets = room:WaitForChild("Assets")
                    
                    local function check(v)
                        if v:IsA("Model") and table.find(entitynames, v.Name) then
                            task.wait(0.1)
                            
                            local h = esp(v:WaitForChild("Base"), Color3.fromRGB(255, 25, 25), v.Base, "Snare")
                            table.insert(esptable.entity, h)
                        end
                    end
                    
                    assets.DescendantAdded:Connect(function(v)
                        check(v) 
                    end)
                    
                    for i, v in pairs(assets:GetDescendants()) do
                        check(v)
                    end
                end 
            end
            
            local roomconnect
            roomconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room) 
	    end

	    table.insert(_G.entityESPInstances, esptable)

        else
            if _G.entityESPInstances then
                for _, instance in pairs(_G.entityESPInstances) do
                    for _, v in pairs(instance.entity) do
                        v.delete()
                    end
                end
                _G.entityESPInstances = nil
            end
        end
    end
})

RightGroup:AddToggle('ESP for FuseObtain', {
    Text = 'FuseObtain ESP',
    Default = false,
    Tooltip = 'Enable ESP for FuseObtain Hitbox',
    Callback = function(state)
        local customSuffix = "FuseObtainESP" -- 自定义后缀
        local flagsName = "espFuseObtain" .. customSuffix
        local espTableName = "fuseObtainESPInstances" .. customSuffix

        if state then
            _G[espTableName] = {}
            _G[flagsName] = state

            local function check(v)
                if v:IsA("Model") and v.Name == "FuseObtain" then
                    local hitbox = v:FindFirstChild("Hitbox")
                    if hitbox then
                        local h = esp(hitbox, Color3.fromRGB(255, 0, 0), hitbox, "FuseKey")
                        table.insert(esptable.fuseESP, h)
                    end
                end
            end

            local function setup(room)
                local assets = room:WaitForChild("Assets")

                if assets then
                    local subaddcon
                    subaddcon = assets.DescendantAdded:Connect(function(v)
                        check(v)
                    end)

                    for i, v in pairs(assets:GetDescendants()) do
                        check(v)
                    end

                    task.spawn(function()
                        repeat task.wait() until not _G[flagsName]
                        subaddcon:Disconnect()
                    end)
                end
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)

            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room)
            end

            table.insert(_G[espTableName], esptable)
        else
            if _G[espTableName] then
                for _, instance in pairs(_G[espTableName]) do
                    for _, v in pairs(instance.fuseESP) do
                        v.delete()
                    end
                end
                _G[espTableName] = nil
            end
        end
    end
})
RightGroup:AddToggle('Esp', {
    Text = 'Guiding Light ESP',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.guidanceESPInstances = {}
            flags.espGuidance = state

            local function check(v)
                if v:IsA("BasePart") and v.Name == "Guidance" then
                    task.wait(0.1)
                    local h = esp(v, currentESPColor, v, "Guidance")
                    table.insert(esptable.guidances, h)
                end
            end

            local function setup(camera)
                if camera then
                    local subaddcon
                    subaddcon = camera.DescendantAdded:Connect(function(v)
                        check(v)
                    end)

                    for _, v in pairs(camera:GetChildren()) do
                        check(v)
                    end

                    task.spawn(function()
                        repeat task.wait() until not flags.espGuidance
                        subaddcon:Disconnect()
                    end)
                end
            end

            local addconnect
            addconnect = workspace.CurrentCamera.ChildAdded:Connect(function(camera)
                setup(camera)
            end)

            for _, camera in pairs(workspace.CurrentCamera:GetChildren()) do
                setup(camera)
            end

            table.insert(_G.guidanceESPInstances, esptable)
        else
            if _G.guidanceESPInstances then
                for _, instance in pairs(_G.guidanceESPInstances) do
                    for _, v in pairs(instance.guidances) do
                        v.delete()
                    end
                end
                _G.guidanceESPInstances = nil
            end
        end
    end
})    
RightGroup:AddToggle('pe', {
    Text = 'Book / Breaker esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            -- Initialize or reset ESP instances
            _G.bookESPInstances = {}
            flags.espbooks = state

            -- Function to check and handle new models
            local function check(v)
                if v:IsA("Model") then
                    local name = ""
                    if v.Name == "LiveHintBook" then
                        name = "Book"
                    elseif v.Name == "LiveBreakerPolePickup" then
                        name = "Breaker"
                    end
                    
                    if name ~= "" then
                        task.wait(0.1)
                        
                        local h = esp(v, Color3.fromRGB(255, 255, 255), v.PrimaryPart, name)
                        table.insert(esptable.books, h)
                        
                        v.AncestryChanged:Connect(function()
                            if not v:IsDescendantOf(room) then
                                h.delete() 
                            end
                        end)
                    end
                end
            end

            -- Function to set up ESP for rooms
            local function setup(room)
                if room.Name == "50" or room.Name == "100" then
                    room.DescendantAdded:Connect(function(v)
                        check(v) 
                    end)
                    
                    for i, v in pairs(room:GetDescendants()) do
                        check(v)
                    end
                end
            end

            -- Connect to new rooms being added
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            -- Set up existing rooms
            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room) 
            end

            -- Store the ESP instances
            table.insert(_G.bookESPInstances, esptable)

        else
            -- Remove all ESP instances if disabled
            if _G.bookESPInstances then
                for _, instance in pairs(_G.bookESPInstances) do
                    for _, v in pairs(instance.books) do
                        v.delete()
                    end
                end
                _G.bookESPInstances = nil
            end
        end
    end
})
RightGroup1:AddToggle('No Clip', {
    Text = 'Library Code',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(val)
        local addConnect
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait() -- Ensure char is defined

        if val then
            -- Function: Decode the code from LibraryHintPaper
            local function decipherCode()
                local paper = char:FindFirstChild("LibraryHintPaper")
                local hints = plr.PlayerGui:WaitForChild("PermUI"):WaitForChild("Hints")
                local code = {"_", "_", "_", "_", "_"}

                if paper then
                    for i, v in pairs(paper:WaitForChild("UI"):GetChildren()) do
                        if v:IsA("ImageLabel") and v.Name ~= "Image" then
                            for _, img in pairs(hints:GetChildren()) do
                                if img:IsA("ImageLabel") and img.Visible and v.ImageRectOffset == img.ImageRectOffset then
                                    local num = img:FindFirstChild("TextLabel") and img.TextLabel.Text or "_"
                                    code[tonumber(v.Name)] = num 
                                end
                            end
                        end
                    end 
                end

                return code
            end

            -- Listen for LibraryHintPaper tool addition
            addConnect = char.ChildAdded:Connect(function(v)
                if v:IsA("Tool") and v.Name == "LibraryHintPaper" then
                    task.wait()
                    local code = table.concat(decipherCode())

                    -- Check for missing books
                    if code:find("_") then
                        local message = "You are still missing some books! The current code is: '" .. code .. "'"
			addAndPlaySound("ExampleSound", 4590657391)
                        Library:Notify(message)  -- Notify about missing books
                    else
                        if not apart then
                            apart = Instance.new("Part", game.ReplicatedStorage)
                            apart.CanCollide = false
                            apart.Anchored = true
                            apart.Position = game.Players.LocalPlayer.Character.PrimaryPart.Position
                            apart.Transparency = 1

                            -- Play sound
                            addAndPlaySound("ExampleSound", 4590657391)

                            -- Notify complete code
                            local successMessage = "The code is '" .. code .. "'."
                            Library:Notify(successMessage)

                            -- Wait for room change
                            repeat 
                                task.wait(0.1) 
                            until game:GetService("ReplicatedStorage").GameData.LatestRoom.Value ~= 50

                            apart:Destroy()
                            apart = nil
                        end
                    end
                end
            end)
        else
            -- If toggled off, disconnect the event
            if addConnect then
                addConnect:Disconnect()
            end
        end
    end
})

RightGroup1:AddToggle('entityEvent', {
    Text = 'Entity Event',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            local entityNames = {"RushMoving", "AmbushMoving", "Snare", "A60", "A120", "A90", "Eyes", "JeffTheKiller", "BackdoorRush"} -- Entity names

            -- Ensure flags and plr are defined
            local flags = flags or {} -- Prevent errors
            local plr = game.Players.LocalPlayer -- Prevent errors

            local function notifyEntitySpawn(entity)
                local entityName = entity.Name:gsub("Moving", ""):lower()
                local entityMessage = entityName .. " " .. (customEntityMessage or "Spawned!")
                addAndPlaySound("ExampleSound", 4590657391)
                Library:Notify(entityMessage)
            end

            local function onChildAdded(child)
                if table.find(entityNames, child.Name) then
                    repeat
                        task.wait()
                    until plr:DistanceFromCharacter(child:GetPivot().Position) < 1000 or not child:IsDescendantOf(workspace)
                    
                    if child:IsDescendantOf(workspace) then
                        notifyEntitySpawn(child)
                    end
                end
            end

            -- Infinite loop to keep the script running and check the hintrush flag
            local running = true
            while running do
                local connection = workspace.ChildAdded:Connect(onChildAdded)
                
                repeat
                    task.wait(1) -- Adjust wait time as needed
                until not flags.hintrush or not running
                
                connection:Disconnect()
            end 
        else 
            -- Turn off notifications or perform other cleanup if needed
            running = false
        end
    end
})
RightGroup1:AddInput('EntityEventTextbox', {
    Default = '!',
    Numeric = false, -- Allows both text and numbers
    Finished = false, -- Callback is called on every change, not just on pressing enter
    ClearTextOnFocus = true, -- Clears the text when the textbox is focused
    Text = 'Enity Event',
    Tooltip = 'Enter a custom message for entity events', -- Tooltip shown on hover
    Placeholder = 'e.g., is approaching!', -- Example placeholder text
    Callback = function(Value)
        customEntityMessage = Value
        print('[cb] Custom entity event message updated:', customEntityMessage)
    end
})
-- Flag to control the state of the toggle

local MiscGroupBox = Tabs.Main:AddRightGroupbox("Misc") do
    MiscGroupBox:AddButton({
        Text = "Revive <Need Robux>",
        Func = function()
            remotesFolder.Revive:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Play Again",
        Func = function()
            remotesFolder.PlayAgain:FireServer()
        end,
        DoubleClick = true
    })

    MiscGroupBox:AddButton({
        Text = "Lobby",
        Func = function()
            remotesFolder.Lobby:FireServer()
        end,
        DoubleClick = true
    })
end
local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab('Speed')
local Tab2 = TabBox:AddTab('Camera')

local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera

Tab1:AddDropdown('SpeedModeDropdown', {
    Values = { 'WalkSpeed', 'CFrame Yield', 'Dash', 'Sprint' },
    Default = 1,
    Multi = false,
    Text = 'Speed Mode',
})

Tab1:AddSlider('MySlider', {
    Text = 'Speed',
    Default = 0,
    Min = 0,
    Max = 45,
    Rounding = 1
})

Tab2:AddSlider('FOVSlider', {
    Text = 'Field of View',
    Default = 70,
    Min = 0,
    Max = 120,
    Rounding = 1
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local originalWalkSpeed = humanoid.WalkSpeed
local lastPosition = character.HumanoidRootPart.Position

local function updateSpeed()
    local sliderValue = Options.MySlider.Value
    local speedMode = Options.SpeedModeDropdown.Value

    if speedMode == 'WalkSpeed' then
        humanoid.WalkSpeed = originalWalkSpeed + sliderValue
    elseif speedMode == 'CFrame Infinite Yield' then
        -- Implementing infinite yield-like movement
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local newPosition = rootPart.CFrame.Position + (rootPart.CFrame.LookVector * sliderValue)
            rootPart.CFrame = CFrame.new(newPosition)
        end
    elseif speedMode == 'Dash' then
        humanoid.WalkSpeed = originalWalkSpeed * 3
    elseif speedMode == 'Sprint' then
        humanoid.WalkSpeed = originalWalkSpeed * 2
    end
end

local function updateFOV()
    Camera.FieldOfView = Options.FOVSlider.Value
end

RunService.RenderStepped:Connect(function()
    updateSpeed()
    updateFOV()
end)

Options.MySlider:OnChanged(function()
    updateSpeed()
end)

Options.SpeedModeDropdown:OnChanged(function()
    updateSpeed()
end)

Options.FOVSlider:OnChanged(function()
    updateFOV()
end)
-- Tab1 中的切换按钮
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local collision = character:WaitForChild("Collision")
local collisionClone

if collision then
    collisionClone = collision:Clone()
    collisionClone.CanCollide = false
    collisionClone.Massless = true
    collisionClone.Name = "CollisionClone"
    
    if collisionClone:FindFirstChild("CollisionCrouch") then
        collisionClone.CollisionCrouch:Destroy()
    end

    collisionClone.Parent = character
end

-- Speed Bypass Toggle
Tab1:AddToggle('SpeedBypass', { Text = 'Speed Bypass' });

Toggles.SpeedBypass:OnChanged(function(value)
    if value then
        while Toggles.SpeedBypass.Value and collisionClone do
            collisionClone.Massless = not collisionClone.Massless
            task.wait(0.225)
        end
    else
        if collisionClone then 
            collisionClone.Massless = true 
        end
    end
end)
-- Create the toggle and slider
-- Create the toggle and slider
Tab1:AddToggle('TranslucentHidingSpot', {
    Text = 'Hide transparency [Toggle]'
})

Tab1:AddSlider('HidingTransparency', {
    Text = 'Hide transparency',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1
})

local connection

-- Function to handle transparency changes
Toggles.TranslucentHidingSpot:OnChanged(function(value)
    local Character = game.Players.LocalPlayer.Character -- Reference the player's character
    if Character and value and Character:GetAttribute("Hiding") then
        connection = task.spawn(function()
            while value do
                for _, obj in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if not obj:IsA("ObjectValue") and obj.Name ~= "HiddenPlayer" then continue end

                    if obj.Value == Character then
                        local affectedParts = {}
                        for _, v in pairs(obj.Parent:GetChildren()) do
                            if not v:IsA("BasePart") then continue end

                            v.Transparency = Options.HidingTransparency.Value
                            table.insert(affectedParts, v)
                        end

                        repeat task.wait()
                            for _, part in pairs(affectedParts) do
                                task.wait()
                                part.Transparency = Options.HidingTransparency.Value
                            end
                        until not Character:GetAttribute("Hiding") or not Toggles.TranslucentHidingSpot.Value
                        
                        for _, v in pairs(affectedParts) do
                            v.Transparency = 0
                        end

                        break
                    end
                end
                task.wait() -- To avoid infinite loop locking the thread
            end
        end)
    elseif connection then
        connection:Cancel()
        connection = nil
    end
end)
-- Ensure the character is loaded
local player = game.Players.LocalPlayer

if not player.Character then
    player.CharacterAdded:Wait()
end

local character = player.Character or player.CharacterAdded:Wait()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 函数：设置角色的跳跃属性
local function setupCharacter(character)
    -- 检查并设置CanJump属性
    if character:GetAttribute("CanJump") == nil then
        character:SetAttribute("CanJump", false)
    end
end

-- 连接角色添加事件
LocalPlayer.CharacterAdded:Connect(function(character)
    setupCharacter(character)
end)

-- 连接能跳跃属性变化事件
LocalPlayer.Character:GetAttributeChangedSignal("CanJump"):Connect(function()
    -- 检查能跳跃属性并设置为正确的值
    local canJump = LocalPlayer.Character:GetAttribute("CanJump")
    LocalPlayer.Character:SetAttribute("CanJump", canJump)
end)

-- 初始设置
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
    local canJump = LocalPlayer.Character:GetAttribute("CanJump")
    if canJump == nil then
        LocalPlayer.Character:SetAttribute("CanJump", false)
    end
end

Tab1:AddToggle('sbt', { Text = 'Can Jump' })

-- 处理SpeedBypass Toggle的OnChanged事件
Toggles.sbt:OnChanged(function(value)
    if value then
        -- 当开关激活时，设置CanJump为true
        if LocalPlayer.Character then
            LocalPlayer.Character:SetAttribute("CanJump", true)
        end
    else
        -- 当开关关闭时，设置CanJump为false
        if LocalPlayer.Character then
            LocalPlayer.Character:SetAttribute("CanJump", false)
        end
    end
end)
local a = Tabs.Main:AddRightGroupbox('Normal Exploit')
a:AddToggle('pe', {
    Text = 'Full bright',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(v)
        if v then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            game:GetService("Lighting").Brightness = 3
            game:GetService("Lighting").ClockTime = 20
            game:GetService("Lighting").FogEnd = 1.1111111533265e+16
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(0.5, 0.5, 0.5)
        end		
    end
})
local Interact = false

-- Function to trigger a prompt
local function triggerPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt)
    end
end

-- Function to handle MinecartSet and MinecartTracks in the entire workspace
local function handleMinecartsAndTracksInWorkspace()
    local player = game.Players.LocalPlayer

    for _, part in pairs(game.Workspace:GetDescendants()) do
        if part:IsA("Model") or part:IsA("BasePart") then
            if part:FindFirstChild("Cart") and part:FindFirstChild("Main") then
                local mainPosition = part.Main.Position
                if (player.Character.Collision.Position - mainPosition).Magnitude < part.Cart.PushPrompt.MaxActivationDistance * 2 then
                    if autoInteract then
                        triggerPrompt(part.Cart.PushPrompt)
                    end
                end
            end
            if part:FindFirstChild("MinecartMoving") and part.MinecartMoving:FindFirstChild("Main") then
                local mainPosition = part.MinecartMoving.Main.Position
                if (player.Character.Collision.Position - mainPosition).Magnitude < part.MinecartMoving.Cart.PushPrompt.MaxActivationDistance * 2 then
                    if autoInteract then
                        triggerPrompt(part.MinecartMoving.Cart.PushPrompt)
                    end
                end
            end
        end
    end
end

-- AddToggle for enabling/disabling the functionality
a:AddToggle('pe', {
    Text = 'Activate All Minecart Prompts',
    Default = false,
    Tooltip = 'Activate all Minecart related prompts',
    Callback = function(state)
        Interact = state  -- Update the flag based on the toggle state

        if state then
            -- Enable the functionality
            handleMinecartsAndTracksInWorkspace()

            -- Listen for new parts being added to the workspace
            game.Workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") or descendant:IsA("BasePart") then
                    if descendant:FindFirstChild("Cart") and descendant:FindFirstChild("Main") then
                        local mainPosition = descendant.Main.Position
                        if (game.Players.LocalPlayer.Character.Collision.Position - mainPosition).Magnitude < descendant.Cart.PushPrompt.MaxActivationDistance * 2 then
                            if autoInteract then
                                triggerPrompt(descendant.Cart.PushPrompt)
                            end
                        end
                    end
                    if descendant:FindFirstChild("MinecartMoving") and descendant.MinecartMoving:FindFirstChild("Main") then
                        local mainPosition = descendant.MinecartMoving.Main.Position
                        if (game.Players.LocalPlayer.Character.Collision.Position - mainPosition).Magnitude < descendant.MinecartMoving.Cart.PushPrompt.MaxActivationDistance * 2 then
                            if autoInteract then
                                triggerPrompt(descendant.MinecartMoving.Cart.PushPrompt)
                            end
                        end
                    end
                end
            end)
        end
    end
})
local function handlePrompt(prompt)
    local interactions = prompt:GetAttribute("Interactions")
    if not interactions then
        task.spawn(function()
            while flags.itemaura and not prompt:GetAttribute("Interactions") do
                task.wait(0.1)
                if game.Players.LocalPlayer:DistanceFromCharacter(prompt.Parent.PrimaryPart.Position) <= 12 then
                    fireproximityprompt(prompt)
                end
            end
        end)
    end
end

-- Function to check items and handle prompts
local function check(v)
    if v:IsA("Model") and (v:GetAttribute("Pickup") or v:GetAttribute("PropType")) then
        task.wait(0.1)
        local part = v:FindFirstChild("Handle") or v:FindFirstChild("Prop")
        if part then
            -- Check if the item has a ModulePrompt
            local prompt = v:FindFirstChild("ModulePrompt")
            if prompt then
                handlePrompt(prompt)
            end
        end
    end
end

-- Function to setup items in a room
local function setup(room)
    local assets = room:WaitForChild("Assets")
    
    if assets then  
        local subaddcon
        subaddcon = assets.DescendantAdded:Connect(function(v)
            check(v)
        end)
        
        for _, v in pairs(assets:GetDescendants()) do
            check(v)
        end
        
        -- Manage the disconnect when item aura is turned off
        return subaddcon
    end
end

-- Function to start room detection
local function startRoomDetection()
    -- Connect to detect new rooms being added
    local roomAddedConnection
    roomAddedConnection = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.itemaura then
            setup(room)
        end
    end)
    
    -- Setup existing rooms
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then
            setup(room)
        end
    end
    
    -- Return the connection to manage its lifecycle
    return roomAddedConnection
end

a:AddToggle('No Clip', {
    Text = 'Item aura',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.itemaura = state  
        
        if flags.itemaura then
            -- Start room detection
            local roomAddedConnection = startRoomDetection()
            
            -- Manage disconnection when item aura is turned off
            task.spawn(function()
                repeat task.wait() until not flags.itemaura
                roomAddedConnection:Disconnect()
            end)
        else
            -- Stop room detection
            if roomAddedConnection then
                roomAddedConnection:Disconnect()
            end
            -- Clear or reset any related data here if needed
        end
    end
})
a:AddToggle('entityEvent', {
    Text = 'Entity Avoid [AT]',
    Default = false,
    Tooltip = 'Walk through walls while avoiding entities',
    Callback = function(state)
        local entityNames = {"RushMoving", "AmbushMoving", "Snare", "A60", "A120", "A90", "Eyes", "JeffTheKiller", "BackdoorRush"}
        local plr = game.Players.LocalPlayer
        local running = state

        local function fireHidePrompt(container)
            local hidePrompt = container:FindFirstChild("HidePrompt")
            if hidePrompt and hidePrompt:GetAttribute("Interactions") then
                while hidePrompt.Enabled do
                    fireproximityprompt(hidePrompt)
                    task.wait(1) -- Adjust this wait time for your needs
                end
            end
        end

        local function toggleHidePrompt(container, state)
            local hidePrompt = container:FindFirstChild("HidePrompt")
            if hidePrompt then
                hidePrompt.Enabled = state
            end
        end

        local function processContainers(room, state)
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, containerName in pairs({"Wardrobe", "Backdoor_Wardrobe", "Rooms_Locker"}) do
                    local container = assets:FindFirstChild(containerName)
                    if container then
                        toggleHidePrompt(container, state)
                        if state then
                            fireHidePrompt(container)
                        end
                    end
                end
            end
        end

        local function avoidEntity(entity)
            task.wait(0.1)
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                processContainers(room, true)
            end
        end

        local function onEntityAdded(entity)
            if table.find(entityNames, entity.Name) then
                local isMoving = true

                repeat
                    task.wait(0.1)
                    isMoving = entity:IsDescendantOf(workspace) and plr:DistanceFromCharacter(entity:GetPivot().Position) < 1000
                    if isMoving then
                        avoidEntity(entity)
                    end
                until not isMoving or not entity:IsDescendantOf(workspace)

                entity.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                            processContainers(room, false)
                        end
                    else
                        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                            processContainers(room, true)
                        end
                    end
                end)
            end
        end

        local connection = workspace.ChildAdded:Connect(onEntityAdded)

        while running do
            task.wait(1)
        end

        connection:Disconnect()
    end
})
a:AddToggle('No Clip', {
    Text = 'Chestbox + Drawers aura',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            -- open
            autoInteract = true

            -- getplayer
            local player = game.Players.LocalPlayer

            -- check
            workspace.CurrentRooms.ChildAdded:Connect(function(room)
                room.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "DrawerContainer" then
                            prompt = descendant:WaitForChild("Knobs"):WaitForChild("ActivateEventPrompt")
                        elseif descendant.Name:sub(1, 8) == "ChestBox" or descendant.Name == "RolltopContainer" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
                        end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end)

            -- check2
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, descendant in pairs(room:GetDescendants()) do
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "DrawerContainer" then
                            prompt = descendant:WaitForChild("Knobs"):WaitForChild("ActivateEventPrompt")
                        elseif descendant.Name:sub(1, 8) == "ChestBox" or descendant.Name == "RolltopContainer" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
                        end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        else
            -- close
            autoInteract = false
        end
    end
})
a:AddToggle('hi', {
    Text = 'Loot Prompt[F2 Test]',
    Default = false,
    Tooltip = 'Walk through walls',
})
Toggles.hi:OnChanged(function(value)
    -- 遍历工作区中的 CurrentRooms
    for _, room in pairs(game.Workspace.CurrentRooms:GetChildren()) do
        -- 查找房间中的 Assets 文件夹
        local assetsFolder = room:FindFirstChild("Assets")
        if assetsFolder then
            -- 查找 Assets 文件夹中的 Locker_Small
            local lockerSmall = assetsFolder:FindFirstChild("Locker_Small")
            if lockerSmall then
                -- 查找 Locker_Small 中的 Door
                local door = lockerSmall:FindFirstChild("Door")
                if door then
                    -- 查找 Door 中的 ActivateEventPrompt
                    local prompt = door:FindFirstChild("ActivateEventPrompt")
                    if prompt then
                        -- 使用 fireproximityprompt 函数触发 ActivateEventPrompt 的点击事件
                        fireproximityprompt(prompt)
                        print("ActivateEventPrompt fired for", door.Name)
                    end
                end
            end

            -- 查找 Assets 文件夹中的 FuseObtain
        
            -- 查找 Assets 文件夹中的 GeneratorMain
            

            -- 查找 Assets 文件夹中的 Toolbox
            local toolbox = assetsFolder:FindFirstChild("Toolbox")
            if toolbox then
                -- 查找 Toolbox 中的 ActivateEventPrompt
                local prompt = toolbox:FindFirstChild("ActivateEventPrompt")
                if prompt then
                    -- 使用 fireproximityprompt 函数触发 ActivateEventPrompt 的点击事件
                    fireproximityprompt(prompt)
                    print("ActivateEventPrompt fired for", toolbox.Name)
                end
            end
        end
    end
end)
a:AddToggle('No Clip', {
    Text = 'TimeLever aura',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            -- open
            daura = true

            -- getplayer
            local player = game.Players.LocalPlayer

            -- check
            workspace.CurrentRooms.ChildAdded:Connect(function(room)
                room.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "TimerLever" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end)

            -- check2
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, descendant in pairs(room:GetDescendants()) do
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "TimerLever" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        else
            -- close
            daura = false
        end
    end
})
a:AddToggle('No Clip', {
    Text = 'Lever aura',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            -- open
            Leveraura = true

            -- getplayer
            local player = game.Players.LocalPlayer

            -- check
            workspace.CurrentRooms.ChildAdded:Connect(function(room)
                room.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "LeverForGate" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end)

            -- check2
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, descendant in pairs(room:GetDescendants()) do
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "LeverForGate" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        else
            -- close
            Leveraura = false
        end
    end
})

-- Add the toggle for Drawer aura
-- 添加Drawer aura的切换开关
a:AddToggle('No Clip', {
    Text = 'Door Aura [Key]',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(val)
        flags.instapp2 = val

        if flags.instapp2 then
            local holdconnect

            holdconnect = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(p)
                fireproximityprompt(p)
            end)

            -- 持续检测，直到关闭 No Clip
            repeat
                task.wait()
            until not flags.instapp2
            
            -- 断开连接
            holdconnect:Disconnect()
        end
    end
})
local ProximityPromptService = game:GetService("ProximityPromptService")

local function check(v, plr)
    if v:IsA("Model") and (v.Name == "KeyObtain" or v.Name == "ElectricalKeyObtain") then
        local prompt = v:WaitForChild("ModulePrompt")
        local interactions = prompt:GetAttribute("Interactions")

        if not interactions then
            task.spawn(function()
                repeat task.wait(0.1)
                    local posok = false
                    pcall(function()
                        posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                    end)

                    if posok then
                        fireproximityprompt(prompt) 
                    end
                until prompt:GetAttribute("Interactions") or not flags.Keyaura
            end)
        end
    end
end

local function setup(room, plr)
    for _, v in pairs(room:GetDescendants()) do
        check(v, plr)
    end

    local subaddcon
    subaddcon = room.DescendantAdded:Connect(function(ve)
        check(ve, plr) 
    end)

    task.spawn(function()
        repeat task.wait() until not flags.Keyaura
        subaddcon:Disconnect() 
    end)
end

local function initializeProximityPrompts(plr)
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        setup(room, plr)
    end)

    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then
            setup(room, plr) 
        end
    end

    setup(workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)], plr)

    repeat task.wait() until not flags.Keyaura
    addconnect:Disconnect() 
end

-- Toggle implementation
a:AddToggle('this', {
    Text = 'Key aura',
    Default = false,
    Tooltip = 'Toggle proximity prompt interactions',
    Callback = function(val)
        flags.Keyaura = val  -- 直接设置 flags.Keyaura
			
        if flags.Keyaura then
            local plr = game.Players.LocalPlayer
            initializeProximityPrompts(plr)
        end
    end
})
-- AddToggle for enabling/disabling the functionality
a:AddToggle('No Clip', {
    Text = 'Activate All FusesPrompt',
    Default = false,
    Tooltip = 'Activate all FusesPrompt',
    Callback = function(state)
        if state then
            -- Enable the functionality
            local player = game.Players.LocalPlayer
            local autoInteract = true

            -- Function to trigger all FusesPrompt
            local function triggerFusesPrompt(prompt)
                if prompt and prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end

            -- Function to handle new rooms being added
            workspace.CurrentRooms.ChildAdded:Connect(function(room)
                room.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") or descendant:IsA("BasePart") then
                        local prompt = descendant:FindFirstChild("FusesPrompt")
                        if prompt then
                            task.spawn(function()
                                while autoInteract and not prompt:GetAttribute("Interactions") do
                                    task.wait(0.1)
                                    if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                        triggerFusesPrompt(prompt)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end)

            -- Function to handle existing rooms
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, descendant in pairs(room:GetDescendants()) do
                    if descendant:IsA("Model") or descendant:IsA("BasePart") then
                        local prompt = descendant:FindFirstChild("FusesPrompt")
                        if prompt then
                            task.spawn(function()
                                while autoInteract and not prompt:GetAttribute("Interactions") do
                                    task.wait(0.1)
                                    if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                        triggerFusesPrompt(prompt)
                                    end
                                end
                            end)
                        end
                    end
                end
            end

        else
            -- Disable the functionality
            autoInteract = false
        end
    end
})
a:AddToggle('No Clip', {
    Text = 'Book / Breaker aura',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            -- open
            Bookaura = true

            -- getplayer
            local player = game.Players.LocalPlayer

            -- check
            workspace.CurrentRooms.ChildAdded:Connect(function(room)
                room.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "LiveBreakerPolePickup" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			elseif descendant.Name == "LiveHintBook" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end)

            -- check2
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, descendant in pairs(room:GetDescendants()) do
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "LiveBreakerPolePickup" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			elseif descendant.Name == "LiveHintBook" then
                            prompt = descendant:WaitForChild("ActivateEventPrompt")
			end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        else
            -- close
            Bookaura = false
        end
    end
})

a:AddToggle('No Clip', {
    Text = 'Gold aura',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            -- open
            autoInteract = true

            -- getplayer
            local player = game.Players.LocalPlayer

            -- check
            workspace.CurrentRooms.ChildAdded:Connect(function(room)
                room.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "GoldPile" then
                            prompt = descendant:WaitForChild("LootPrompt")
                        end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end)

            -- check2
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, descendant in pairs(room:GetDescendants()) do
                    if descendant:IsA("Model") then
                        local prompt = nil
                        if descendant.Name == "GoldPile" then
                            prompt = descendant:WaitForChild("LootPrompt")
                        end

                        if prompt then
                            local interactions = prompt:GetAttribute("Interactions")
                            if not interactions then
                                task.spawn(function()
                                    while autoInteract and not prompt:GetAttribute("Interactions") do
                                        task.wait(0.1)
                                        if player:DistanceFromCharacter(descendant.PrimaryPart.Position) <= 12 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        else
            -- close
            autoInteract = false
        end
    end
})

local MainGroup3 = Tabs.Main2:AddLeftGroupbox('Enity (F1)')
local FTGroup = Tabs.Main2:AddRightGroupbox('Enity (F2)')
MainGroup3:AddToggle('No Clip', {
    Text = 'Expilot Spider jumpscare',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.sj = state -- 鏇存柊 flag 涓哄綋鍓� state
        
        if flags.sj then
            local sj = game.ReplicatedStorage.RemotesFolder:FindFirstChild("SpiderJumpscare")
            if sj then
                -- 褰� noa90 涓� true 涓� A90 瀛樺湪鏃讹紝鍒犻櫎 A90
                sj:Destroy()
            end
        end
    end
})
MainGroup3:AddToggle('No Clip', {
    Text = 'Expilot Eyes',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.eyes = state -- 更新 flag 为当前 state
        
        while flags.eyes do
            local eyes = game.Workspace:FindFirstChild("Eyes")
            if eyes then
                remotesFolder.MotorReplication:FireServer(-650)
            end
            wait(0) -- 等待一秒后再次检查
        end
    end
})
MainGroup3:AddToggle('AntiHalt', {
    Text = 'Expilot halt',
    Default = false,
    Tooltip = 'Walk through walls',
})
MainGroup3:AddToggle('AntiDupe', {
    Text = 'Expilot Dupe',
    Default = false,
    Tooltip = 'Walk through walls',
})
Toggles.AntiDupe:OnChanged(function(value)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        for _, dupeRoom in pairs(room:GetChildren()) do
            if dupeRoom:GetAttribute("LoadModule") == "DupeRoom" or dupeRoom:GetAttribute("LoadModule") == "SpaceSideroom" then
                task.spawn(function() Script.Functions.DisableDupe(dupeRoom, value, dupeRoom:GetAttribute("LoadModule") == "SpaceSideroom") end)
            end
        end
    end
end)
Toggles.AntiHalt:OnChanged(function(value)
    if not entityModules then return end
    local module = entityModules:FindFirstChild("Shade") or entityModules:FindFirstChild("_Shade")

    if module then
        module.Name = value and "_Shade" or "Shade"
    end
end)
MainGroup3:AddToggle('No Clip', {
    Text = 'Expilot Screech',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.sc = state -- 鏇存柊 flag 涓哄綋鍓� state
        
        if flags.sc then
            local entities = game.ReplicatedStorage.Entities
            local remotes = game.ReplicatedStorage.RemotesFolder
            
            local targets = {
                remotes:FindFirstChild("Screech"),
                entities:FindFirstChild("ScreechRetro"),
                entities:FindFirstChild("Screech")
            }
            
            for _, target in ipairs(targets) do
                if target then
                    target:Destroy()
                end
            end
        end
    end
})
MainGroup3:AddToggle('No Clip', {
    Text = 'Expilot Snare',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.sd = state -- 鏇存柊 flag 涓哄綋鍓� state
        
        while flags.sd do
            local currentRooms = game.Workspace:FindFirstChild("CurrentRooms")
            if currentRooms then
                for _, room in ipairs(currentRooms:GetChildren()) do
                    local assets = room:FindFirstChild("Assets")
                    if assets then
                        local snare = assets:FindFirstChild("Snare")
                        if snare then
                            snare:Destroy()
                        end
                    end
                end
            end
            wait(0.1) -- 绛夊緟涓€绉掑悗鍐嶆妫€鏌�
        end
    end
})
MainGroup3:AddToggle('pe', {
    Text = 'Expilot Seek Arm / Fire',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(v)
	flags.r3 = v
	
        if v then
            game:GetService("RunService").RenderStepped:Connect(function()
                pcall(function()
                    if flags.r3 then
                        local latestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value
                        local currentRoom = game.workspace.CurrentRooms[tostring(latestRoom)]
                        local assets = currentRoom:WaitForChild("Assets")

                        -- 閿€姣� ChandelierObstruction 鍜� Seek_Arm
                        if assets:FindFirstChild("ChandelierObstruction") then
                            assets.ChandelierObstruction:Destroy()
                        end

                        for i = 1, 15 do
                            if assets:FindFirstChild("Seek_Arm") then
                                assets.Seek_Arm:Destroy()
                            end
                        end
                    end
                end)
            end)
        end
    end
})


destroy = "Remove Event:Destroy giggle now"
destroy1 = "Remove Event:Destroy GloomPile now"
destroy2 = "Remove Event:Destroy Bat now"
FTGroup:AddToggle('No Clip', {
        Text = 'Expilot GiggleCeiling',
        Default = false,
        Tooltip = 'Remove GiggleCeiling from rooms',
        Callback = function(state)
            flags.gc = state

            while flags.giggleCeiling do
                local currentRooms = game.Workspace:FindFirstChild("CurrentRooms")
                if currentRooms then
                    for _, room in ipairs(currentRooms:GetChildren()) do
                        local giggleCeiling = room:FindFirstChild("GiggleCeiling")
                        if giggleCeiling then
                            giggleCeiling:Destroy()
			    Library:Notify(destroy)
                        end
                    end
                end
                wait(0.1)
            end
        end
    })

    FTGroup:AddToggle('No Clip', {
        Text = 'Expilot GloomPile',
        Default = false,
        Tooltip = 'Remove GloomPile from rooms',
        Callback = function(state)
            flags.g = state

            while flags.g do
                local currentRooms = game.Workspace:FindFirstChild("CurrentRooms")
                if currentRooms then
                    for _, room in ipairs(currentRooms:GetChildren()) do
                        local gloomPile = room:FindFirstChild("GloomPile")
                        if gloomPile then
                            gloomPile:Destroy()
			    Library:Notify(destroy1)
                        end
                    end
                end
                wait(0.1)
            end
        end
    })

    FTGroup:AddToggle('No Clip', {
        Text = 'Expilot bat',
        Default = false,
        Tooltip = 'Remove GloombatSwarm from rooms',
        Callback = function(state)
            flags.g2 = state

            while flags.g2 do
                local spawned = game.Workspace:FindFirstChild("GloombatSwarm")
                if spawned then
                    spawned:Destroy()
		    Library:Notify(destroy2)
                end
                wait(0.1)
            end
        end
    })

MainGroup3:AddToggle('No Clip', {
    Text = 'Expilot A90',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.error = state -- 鏇存柊 flag 涓哄綋鍓� state
        
        if flags.error then
            if LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("A90") then
                LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.A90.Name = "lol"
	    end
        end
    end
})
RightGroup1:AddToggle('No Clip', {
    Text = 'Code [Padlock]',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(val)
        local addConnect
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait() -- Ensure char is defined

        if val then
            -- Listen for LibraryHintPaper tool addition
            addConnect = char.ChildAdded:Connect(function(v)
                if v:IsA("Tool") and v.Name == "LibraryHintPaper" then
                    task.wait()
                    local PadlockCode

                    print("[LOG] Checking current room...")

                    if plr:GetAttribute("CurrentRoom") <= 51 then
                        local Padlock = workspace.CurrentRooms["50"].Door:FindFirstChild("Padlock")

                        if Padlock then
                            print("[LOG] Found padlock. Attempting to fire server with padlock code...")
                            game.ReplicatedStorage.RemotesFolder.PL:FireServer(PadlockCode)
                        end
                    end

                    task.spawn(function()
                        print("[LOG] Task started. Looking for LibraryHintPaper...")

                        local Paper
                        for _, item in ipairs(char:GetChildren()) do
                            if item:IsA("Tool") and item.Name == "LibraryHintPaper" then
                                Paper = item
                                break
                            end
                        end

                        if not Paper then
                            for _, Player in ipairs(game.Players:GetPlayers()) do
                                if Player ~= plr and (Player.Character:FindFirstChild("LibraryHintPaper") or Player.Backpack:FindFirstChild("LibraryHintPaper")) then
                                    Paper = Player.Character:FindFirstChild("LibraryHintPaper") or Player.Backpack:FindFirstChild("LibraryHintPaper")
                                    print("[LOG] Found LibraryHintPaper from another player.")
                                    break
                                end
                            end
                        else
                            print("[LOG] Found LibraryHintPaper.")
                        end

                        if Paper and Paper:FindFirstChild("UI") and workspace.CurrentRooms["50"].Door:FindFirstChild("Padlock") then
                            print("[LOG] Found paper UI and padlock in room 50.")

                            local Code = ""    
                            for _, x in ipairs(Paper.UI:GetChildren()) do
                                if tonumber(x.Name) then
                                    for _, y in ipairs(plr.PlayerGui.PermUI.Hints:GetChildren()) do
                                        if y.Name == "Icon" then
                                            if y.ImageRectOffset == x.ImageRectOffset then
                                                Code = Code .. y.TextLabel.Text
                                                print("[LOG] Adding digit to code: " .. y.TextLabel.Text)
                                            end
                                        end
                                    end
                                end

                                if #Code == 5 then
                                    print("[LOG] Complete padlock code found: " .. Code)
                                    Library:Notify("Padlock code found!", "The code is... '" .. Code .. "', [A4 PadLock]")
                                    PadlockCode_N = Code
                                    PadlockCode = Code
                                end

                                if PadlockCode then break end
                            end
                        end
                    end)
                end
            end)
        else
            -- If toggled off, disconnect the event
            if addConnect then
                addConnect:Disconnect()
            end
        end
    end
})
RightGroup:AddToggle('pe', {
    Text = 'GrumbleRig ESP',
    Default = false,
    Tooltip = 'Highlight GrumbleRig',
    Callback = function(state)
        if state then
            _G.grumbleRigESPInstances = {}
            flags.espGrumbleRig = state

            local function setupGrumbleRig(grumbleRigObject)
                if grumbleRigObject.Name == "GrumbleRig" then
                    local h = esp(grumbleRigObject, Color3.fromRGB(173, 216, 230), grumbleRigObject, "Grumble King") -- Light Blue color
                    table.insert(esptable.grumbleRigs, h)

                    grumbleRigObject.AncestryChanged:Connect(function()
                        h.delete()
                    end)
                end
            end

            local function setup(room)
                for _, v in pairs(room:GetChildren()) do
                    if v.Name == "Assets" then
                        for _, asset in pairs(v:GetChildren()) do
                            if asset:FindFirstChild("GrumbleRig") then
                                for _, root in pairs(asset.GrumbleRig:GetChildren()) do
                                    if root:FindFirstChild("GrumbleRig") then
                                        setupGrumbleRig(root.GrumbleRig)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)
            
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room)
            end

            table.insert(_G.grumbleRigESPInstances, esptable)

        else
            if _G.grumbleRigESPInstances then
                for _, instance in pairs(_G.grumbleRigESPInstances) do
                    for _, v in pairs(instance.grumbleRigs) do
                        v.delete()
                    end
                end
                _G.grumbleRigESPInstances = nil
            end
        end
    end
})
Library:SetWatermarkVisibility(true)

-- Example of dynamically-updating watermark with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
	FrameCounter += 1;

	if (tick() - FrameTimer) >= 1 then
		FPS = FrameCounter;
		FrameTimer = tick();
		FrameCounter = 0;
	end;

	Library:SetWatermark(('Hax Alpha 4 | %s fps | %s ms'):format(
		math.floor(FPS),
		math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
	));
end);

Library:OnUnload(function()
	WatermarkConnection:Disconnect()

	print('Unloaded!')
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:SetSubFolder('specific-place') -- if the game has multiple places inside of it (for example: DOORS) 
					   -- you can use this to save configs for those places separately
					   -- The path in this script would be: MyScriptHub/specific-game/settings/specific-place
					   -- [ This is optional ]

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!

SaveManager:LoadAutoloadConfig()
MainGroup3:AddToggle('pe', {
    Text = 'Seek Remove Handler [SRH]',
    Default = false,
    Tooltip = 'Handle TriggerEventCollision events',
    Callback = function(state)
        if state then
            connection = workspace.CurrentRooms.DescendantAdded:Connect(function(v)
                if v.Name == "TriggerEventCollision" then
                    while task.wait() and v and #v:GetChildren() > 0 do
                        local Part = v:FindFirstChildWhichIsA("BasePart")

                        if Part and state then
                            firetouchinterest(LocalPlayer.Character.Collision, Part, true and false)
                        end
                    end
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end
})
