local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera

local function createHighlight(part, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = part
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.5
    highlight.FillTransparency = 0.5
    highlight.Parent = part
    return highlight
end

local function createBillboardGui(core, color, name)
    local bill = Instance.new("BillboardGui", game.CoreGui)
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 50)
    bill.Adornee = core
    bill.MaxDistance = 2000

    local txt = Instance.new("TextLabel", bill)
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Position = UDim2.new(0.5, 0, 0.5, 0)
    txt.Text = name
    txt.TextStrokeTransparency = 0.5
    txt.TextSize = 25
    txt.Font = Enum.Font.Code
    Instance.new("UIStroke", txt)

    local distanceLabel = Instance.new("TextLabel", bill)
    distanceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = color
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0.5, 0, 0.9, 0)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextSize = 20
    distanceLabel.Font = Enum.Font.Code
    Instance.new("UIStroke", distanceLabel)

    local function updateDistance()
        if core and core:IsDescendantOf(workspace) then
            local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local targetPos

            if core:IsA("Model") then
                local primaryPart = core.PrimaryPart or core:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    targetPos = primaryPart.Position
                end
            elseif core:IsA("BasePart") then
                targetPos = core.Position
            end

            if targetPos then
                local distance = math.floor((playerPos - targetPos).Magnitude)
                distanceLabel.Text = string.format("[%d]", distance)
            end
        end
    end

    RunService.RenderStepped:Connect(updateDistance)

    return bill
end

local function createTracer(target, color)
    local line = Drawing.new("Line")
    line.Color = color
    line.Thickness = 2
    line.Transparency = 1

    local function updateTracer()
        if target and target:IsDescendantOf(workspace) then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local screenPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

            line.From = screenPos
            line.To = Vector2.new(targetPos.X, targetPos.Y)
            line.Visible = true
        else
            line.Visible = false
        end
    end

    RunService.RenderStepped:Connect(updateTracer)

    return line
end

function esp(what, color, core, name, enableTracer)
    enableTracer = enableTracer or false

    local parts = {}
    if typeof(what) == "Instance" then
        if what:IsA("Model") then
            for _, v in ipairs(what:GetChildren()) do
                if v:IsA("BasePart") then
                    table.insert(parts, v)
                end
            end
        elseif what:IsA("BasePart") then
            table.insert(parts, what)
        end
    elseif typeof(what) == "table" then
        for _, v in ipairs(what) do
            if v:IsA("BasePart") then
                table.insert(parts, v)
            end
        end
    end

    local highlights = {}
    local tracers = {}

    for _, part in ipairs(parts) do
        local highlight = createHighlight(part, color)
        table.insert(highlights, highlight)

        if enableTracer and #tracers == 0 then
            local tracer = createTracer(part, color)
            table.insert(tracers, tracer)
        end
    end

    local bill
    if core and name then
        bill = createBillboardGui(core, color, name)
    end

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
            if not tracer or not tracer.Visible then
                tracer:Remove()
            end
        end
    end

    RunService.Stepped:Connect(checkAndUpdate)

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
	draweraura = false
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
    guidances = {}
}


local Library = loadstring(game:HttpGet("https://github.com/Drop56796/CreepyEyeHub/blob/main/UI%20Style%20theme.lua?raw=true"))()
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
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)

	Title = 'Expliot Hax Alpha 3',
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
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
	UI = Window:AddTab('setting')
}
local RightGroup = Tabs.Main3:AddLeftGroupbox('ESP')
local LeftGroupBox = Tabs.UI:AddLeftGroupbox('esp color')
local Group = Tabs.Main:AddLeftGroupbox('Chat Nofiction')
local textChannel = game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local objects = {"Door", "Lever", "Closet", "Locker", "Entity", "Key", "Book", "Player", "Item"}
local esp = {
    Item = Color3.fromRGB(255, 255, 255),
    player = Color3.fromRGB(255, 255, 255),
    Book = Color3.fromRGB(255, 255, 255),
    key = Color3.fromRGB(255, 255, 255),
    Entity = Color3.fromRGB(255, 255, 255),
    Locker = Color3.fromRGB(255, 255, 255),
    closet = Color3.fromRGB(255, 255, 255),
    Lever = Color3.fromRGB(255, 255, 255),
    Door = Color3.fromRGB(255, 255, 255)
}
local options = {}

for _, object in ipairs(objects) do
    LeftGroupBox:AddLabel(object .. ' Color'):AddColorPicker(object .. 'ColorPicker', {
        Default = Color3.new(0, 1, 0), -- 默认颜色为亮绿色
        Title = object .. ' Color' -- 自定义颜色选择器标题
    })

    options[object .. 'ColorPicker'] = Options[object .. 'ColorPicker']

    options[object .. 'ColorPicker']:OnChanged(function(val)
        esp[object] = val
    end)
end
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
                    local espInstance = esp(player.Character, esp.player, player.Character:FindFirstChild("HumanoidRootPart"), player.Name)
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
                    local h = esp(part, esp.Item, part, v.Name)
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
    Text = 'Door esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        if state then
            _G.doorESPInstances = {}
            flags.espdoors = state
            local doorCounter = 0  -- Initialize a counter for the doors
                
            local function setup(room)
                local door = room:WaitForChild("Door") -- Directly get the Door object
                
                task.wait(0.1)
                
                -- Increment the door counter and format it as a four-digit number starting from 0001
                doorCounter = doorCounter + 1
                local doorIndex = string.format("%04d", doorCounter)
                
                -- Set up ESP with the door index in the format "Door [0001]"
                local h = esp(door:WaitForChild("Door"), esp.Door, door, "Door [" .. doorIndex .. "]")
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
                    if v.Name == "Wardrobe" or v.Name == "Locker_Large" then
                        local h = esp(v.PrimaryPart, esp.closet, v.PrimaryPart, "Closet")
                        table.insert(esptable.lockers, h) 
                    elseif (v.Name == "Rooms_Locker" or v.Name == "Rooms_Locker_Fridge") then
                        local h = esp(v.PrimaryPart, esp.Locker, v.PrimaryPart, "Locker")
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
            local entitynames = {"RushMoving", "AmbushMoving", "Snare", "A60", "A120", "Eyes", "JeffTheKiller", "SeekMoving"}
	    
            local addconnect
            addconnect = workspace.ChildAdded:Connect(function(v)
                if table.find(entitynames, v.Name) then
                    task.wait(0.1)
                    
                    local h = esp(v, esp.Enity, v.PrimaryPart, v.Name:gsub("Moving", ""))
                    table.insert(esptable.entity, h)
                end
            end)

            local function setup(room)
                if room.Name == "50" or room.Name == "100" then
                    local figuresetup = room:WaitForChild("FigureSetup")
                
                    if figuresetup then
                        local fig = figuresetup:WaitForChild("FigureRagdoll")
                        task.wait(0.1)
                        
                        local h = esp(fig, esp.Enity, fig.PrimaryPart, "Figure")
                        table.insert(esptable.entity, h)
                    end 
                else
                    local assets = room:WaitForChild("Assets")
                    
                    local function check(v)
                        if v:IsA("Model") and table.find(entitynames, v.Name) then
                            task.wait(0.1)
                            
                            local h = esp(v:WaitForChild("Base"), esp.Enity, v.Base, "Snare")
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
RightGroup:AddToggle('pe', {
    Text = 'Lever / Key esp',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(state)
        flags.espkeys = state
        
        if state then
            local function check(v)
                if v:IsA("Model") and v.Name == "LeverForGate" then
                    local h = esp(v, esp.Lever, v.PrimaryPart, "Lever")
                    table.insert(esptable.keys, h)
                    
                    v.PrimaryPart:WaitForChild("SoundToPlay").Played:Connect(function()
                        h.delete()
                    end)
                end
            end
            
            local function setup(room)
                local assets = room:WaitForChild("Assets")
                
                if room:GetAttribute("RequiresKey") then
                    local key = room:FindFirstChild("KeyObtain", true)
                    if key then
                        local h = esp(key, esp.key, key.PrimaryPart, "Key")
                        table.insert(esptable.keys, h)
                    end
                end
                
                assets.DescendantAdded:Connect(function(v)
                    check(v)
                end)
                    
                for i, v in pairs(assets:GetDescendants()) do
                    check(v)
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
            
            repeat task.wait() until not flags.espkeys
            addconnect:Disconnect()
            
            for i, v in pairs(esptable.keys) do
                v.delete()
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
                        
                        local h = esp(v, esp.Book, v.PrimaryPart, name)
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
            local entityNames = {"RushMoving", "AmbushMoving", "Snare", "A60", "A120", "A90", "Eyes", "JeffTheKiller"} -- Entity names

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
    Values = { 'WalkSpeed', 'CFrame' },
    Default = 1,
    Multi = false,
    Text = 'Speed Mode',
})

Tab1:AddSlider('MySlider', {
    Text = 'Speed',
    Default = 0,
    Min = 0,
    Max = 15,
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
    elseif speedMode == 'CFrame' then
        local currentPosition = character.HumanoidRootPart.Position
        local distanceMoved = (currentPosition - lastPosition).magnitude

        if distanceMoved > 0 then
            local direction = character.HumanoidRootPart.CFrame.LookVector
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + direction * sliderValue
        end

        lastPosition = currentPosition
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

MainGroup3:AddToggle('No Clip', {
    Text = 'Expilot Seek',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(val)
        flags.noseek = val  -- Set the flags.noseek value

        if flags.noseek then
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                local trigger = room:WaitForChild("TriggerEventCollision", 2)

                if trigger then
                    -- Find BasePart named "Primary" within the trigger
                    local primaryPart = trigger:FindFirstChild("PrimaryPart")
                    if primaryPart and primaryPart:IsA("BasePart") then
                        if fireTouch then
                            repeat
                                fireTouch(primaryPart, rootPart, 1)
                                task.wait()
                                fireTouch(primaryPart, rootPart, 0)
                                task.wait()
                            until not flags.noseek
                        else
                            primaryPart.Position = rootPart.Position + Vector3.new(0, primaryPart.Size.Y, 0)
                        end
                    end

                    -- Optionally remove the trigger
                    -- trigger:Destroy()
                end
            end)

            -- Wait until noseek is disabled, then disconnect
            repeat task.wait() until not flags.noseek
            addconnect:Disconnect()
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
