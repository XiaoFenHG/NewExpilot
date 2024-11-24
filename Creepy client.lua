local CoreGui = game:GetService("StarterGui")
CoreGui:SetCore("SendNotification", {
    Title = "Creepy Client Welcome<回归>",
    Text = "V1.2",
    Duration = 3, 
})
wait(3)

local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt")()
assert(lib, "Failed to load library")

local win = lib:Window("Welcome ["..game.Players.LocalPlayer.Name.."] Executor:"..identifyexecutor" Game:"..game.GameId..".", Color3.fromRGB(1, 0, 0), Enum.KeyCode.RightControl)
assert(win, "Failed to create window")

local tab1 = win:Tab("Player Setting")
assert(tab1, "Failed to create tab1")

local tab3 = win:Tab("Doors")
assert(tab3, "Failed to create tab3")

local tab4 = win:Tab("忍者传奇")
assert(tab4, "Failed to create tab4")

local tab5 = win:Tab("巴掌")
assert(tab5, "Failed to create tab5")

local tab6 = win:Tab("其他脚本🥵")
assert(tab6, "Failed to create tab6")

local tab7 = win:Tab("bedwars")
assert(tab7, "Failed to create tab7")

local tab8 = win:Tab("⭐😡人生")
assert(tab8, "Failed to create tab8")

local tab9 = win:Tab("Setting")
assert(tab8, "Failed to create tab8")



local autoJumpEnabled = false
local noClipEnabled = false

tab1:Toggle("Auto-Jump", false, function(state)
    autoJumpEnabled = state
    if autoJumpEnabled then
        while autoJumpEnabled do
            -- 执行跳跃操作
            game.Players.LocalPlayer.Character.Humanoid.Jump = true
            wait(0.1) -- 根据需要调整延迟
        end
    end
end)

tab1:Button("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

tab1:Toggle("No-Clip", false, function(state)
    noClipEnabled = state
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local runService = game:GetService("RunService")

    local function setNoClip(enabled)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
        if enabled then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        else
            character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    if noClipEnabled then
        _G.NoClip = runService.Stepped:Connect(function()
            setNoClip(true)
        end)
    else
        if _G.NoClip then
            _G.NoClip:Disconnect()
            _G.NoClip = nil
        end
        setNoClip(false)
    end
end)

-- Custom ESP Function
local espEnabled = false

tab1:Toggle("Player ESP", false, function(state)
    espEnabled = state
    if espEnabled then
        -- Enable ESP
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if player.Character then
                    createESP(player)
                end
            end
        end

        game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                if espEnabled then
                    createESP(player)
                end
            end)
        end)

        game.Players.PlayerRemoving:Connect(function(player)
            if player.Character and player.Character:FindFirstChildOfClass("Highlight") then
                player.Character:FindFirstChildOfClass("Highlight"):Destroy()
            end
            if player.Character and player.Character:FindFirstChildOfClass("BillboardGui") then
                player.Character:FindFirstChildOfClass("BillboardGui"):Destroy()
            end
        end)
    else
        -- Disable ESP
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChildOfClass("Highlight") then
                player.Character:FindFirstChildOfClass("Highlight"):Destroy()
            end
            if player.Character and player.Character:FindFirstChildOfClass("BillboardGui") then
                player.Character:FindFirstChildOfClass("BillboardGui"):Destroy()
            end
        end
    end
end)

function createESP(player)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    highlight.FillColor = Color3.new(1, 0, 0) -- Red color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
    highlight.OutlineTransparency = 0

    -- Create BillboardGui for name and distance
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = player.Character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = player.Character

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.Text = player.Name
    textLabel.Parent = billboard

    -- Update distance
    game:GetService("RunService").RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            textLabel.Text = player.Name .. " (" .. math.floor(distance) .. " studs)"
        end
    end)
end

-- 自动治疗
local autoHealEnabled = false
tab1:Toggle("Auto-Heal", false, function(state)
    autoHealEnabled = state
    if autoHealEnabled then
        while autoHealEnabled do
            -- 执行治疗操作
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
            end
            wait(5) -- 根据需要调整延迟
        end
    else
        -- 停止治疗操作
        autoHealEnabled = false
    end
end)

tab1:Toggle("High Light", false, function(state)
    local Light = game:GetService("Lighting")

    function dofullbright()
        Light.Ambient = Color3.new(1, 1, 1)
        Light.ColorShift_Bottom = Color3.new(1, 1, 1)
        Light.ColorShift_Top = Color3.new(1, 1, 1)
    end

    function resetLighting()
        Light.Ambient = Color3.new(0, 0, 0)
        Light.ColorShift_Bottom = Color3.new(0, 0, 0)
        Light.ColorShift_Top = Color3.new(0, 0, 0)
    end

    if state then  
        while state do
            dofullbright()
            wait(1000000000)
        end
    else
        resetLighting()
    end
end)

tab1:Button("Vape V4", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Drop56796/Vape-V4/main/%E7%94%B5%E5%AD%90%E7%83%9FV4.lua"))()
end)

tab1:Textbox("Speed", true, function(t)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = t
end)

tab1:Textbox("FOV", true, function(t)
    game.Workspace.CurrentCamera.FieldOfView = t
end)

tab1:Textbox("Gravity", true, function(t)
    game.Workspace.Gravity = t
end)

tab1:Textbox("JumpPower", true, function(t)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = t
end)

tab3:Button("WeShan old {MrWhite独家制作}", function()
    loadstring(game:HttpGet("https://github.com/Drop56796/CreepyEyeHub/blob/main/DoorsFixed.lua?raw=true"))()
end)

tab3:Button("Bobhub", function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\54\53\84\119\84\56\106\97"))()
end)

tab3:Button("Slience Hub V2", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Drop56796/Moonsec/moonsec/moonsec.lua"))()
end)

tab3:Button("Super Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Fazedrab/EntitySpawner/main/doors(orionlib).lua"))()
end)

tab3:Button("心跳永远胜利", function()
    firesignal(game.ReplicatedStorage.Bricks.ClutchHeartbeat.OnClientEvent)
end)

tab4:Button("1", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zerpqe/script/main/NinjaLegends.lua"))()
end)

tab4:Button("2", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/harisiskandar178/5repo/main/script4.lua"))()
end)

tab5:Button("1", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Unknownkellymc1/Unknownscripts/main/slap-battles'))()
end)

tab6:Button("导管🥵", function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\117\115\101\114\97\110\101\119\114\102\102\47\114\111\98\108\111\120\45\47\109\97\105\110\47\37\69\54\37\57\68\37\65\49\37\69\54\37\65\67\37\66\69\37\69\53\37\56\68\37\56\70\37\69\56\37\65\69\37\65\69\34\41\41\40\41\10")()
end) 

tab6:Button("XC", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/PAFzYx0F"))()
end)

tab6:Button("Rooms＆Doors {NB}", function()
    loadstring(game:HttpGet("https://github.com/DocYogurt/Main/raw/main/Scripts/Rooms&Doors?raw=true"))()
end)

tab6:Button("hoho hub(15+ Game)", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ascn123/HOHO_H/main/Loading_UI'))()
end)

tab7:Button("vape v4", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Drop56796/Vape-V4/main/%E7%94%B5%E5%AD%90%E7%83%9FV4.lua"))()
end)

tab9:Toggle("Show Time", false, function(state)
    if state then
        local LBLG = Instance.new("ScreenGui", getParent)
        local LBL = Instance.new("TextLabel", getParent)
        local player = game.Players.LocalPlayer

        LBLG.Name = "LBLG"
        LBLG.Parent = game.CoreGui
        LBLG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        LBLG.Enabled = true

        LBL.Name = "LBL"
        LBL.Parent = LBLG
        LBL.BackgroundColor3 = Color3.new(1, 1, 1)
        LBL.BackgroundTransparency = 1
        LBL.BorderColor3 = Color3.new(0, 0, 0)
        LBL.Position = UDim2.new(0.75, 0, 0.010, 0)
        LBL.Size = UDim2.new(0, 133, 0, 30)
        LBL.Font = Enum.Font.GothamSemibold
        LBL.Text = "TextLabel"
        LBL.TextColor3 = Color3.new(1, 1, 1)
        LBL.TextScaled = true
        LBL.TextSize = 14
        LBL.TextWrapped = true
        LBL.Visible = true

        local FpsLabel = LBL
        local Heartbeat = game:GetService("RunService").Heartbeat
        local LastIteration, Start
        local FrameUpdateTable = {}

        local function HeartbeatUpdate()
            LastIteration = tick()
            for Index = #FrameUpdateTable, 1, -1 do
                FrameUpdateTable[Index + 1] = (FrameUpdateTable[Index] >= LastIteration - 1) and FrameUpdateTable[Index] or nil
            end
            FrameUpdateTable[1] = LastIteration
            local CurrentFPS = (tick() - Start >= 1 and #FrameUpdateTable) or (#FrameUpdateTable / (tick() - Start))
            CurrentFPS = CurrentFPS - CurrentFPS % 1
            FpsLabel.Text = ("China time" .. os.date("%H") .. "H" .. os.date("%M") .. "M" .. os.date("%S"))
        end

        Start = tick()
        Heartbeat:Connect(HeartbeatUpdate)
    else
        LBLG.Name = "5"
        LBLG.Parent = game.CoreGui
        LBLG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        LBLG.Enabled = true

        LBL.Name = "5"
        LBL.Parent = LBLG
        LBL.BackgroundColor3 = Color3.new(1, 1, 1)
        LBL.BackgroundTransparency = 1
        LBL.BorderColor3 = Color3.new(0, 0, 0)
        LBL.Position = UDim2.new(100, 0, 10, 20)
        LBL.Size = UDim2.new(0.5, 0, 0.5, 30)
        LBL.Font = Enum.Font.GothamSemibold
        LBL.Text = "0"
        LBL.TextColor3 = Color3.new(155, 155, 155)
        LBL.TextScaled = true
        LBL.TextSize = 14
        LBL.TextWrapped = true
        LBL.Visible = true
    end
end)

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local aimbotEnabled = false
local targetPart = "Head" -- 锁定目标的部位
local connection -- 用于存储RenderStepped连接

-- 查找最近的目标
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player and target.Team ~= player.Team then
            local targetCharacter = target.Character
            if targetCharacter and targetCharacter:FindFirstChild(targetPart) then
                local distance = (targetCharacter[targetPart].Position - camera.CFrame.Position).Magnitude
                if distance < shortestDistance then
                    closestTarget = targetCharacter[targetPart]
                    shortestDistance = distance
                end
            end
        end
    end

    return closestTarget
end

-- 启动/关闭自瞄
tab8:Toggle("自瞄(有些老爷😡)", false, function(state)
    if state then
        print("开启自瞄")
        aimbotEnabled = true

        -- 自瞄功能
        connection = runService.RenderStepped:Connect(function()
            if aimbotEnabled then
                local closestTarget = getClosestTarget()
                if closestTarget then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Position)
                end
            end
        end)
    else
        print("关闭自瞄")
        aimbotEnabled = false
        if connection then
            connection:Disconnect()
        end
    end
end)

tab8:Button("美化{自瞄}", function()
    local ScreenGui = Instance.new("ScreenGui")
local OuterFrame = Instance.new("Frame")
local OuterUICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- 外圆
OuterFrame.Parent = ScreenGui
OuterFrame.BackgroundTransparency = 1 -- 使背景透明
OuterFrame.Size = UDim2.new(0, 220, 0, 220) -- 调整外圆的大小
OuterFrame.Position = UDim2.new(0.5, -110, 0.5, -110)

OuterUICorner.Parent = OuterFrame
OuterUICorner.CornerRadius = UDim.new(1, 0) -- 使外圆变成圆形

UIStroke.Parent = OuterFrame
UIStroke.Thickness = 10 -- 设置边框宽度为10
UIStroke.Color = Color3.new(1, 1, 1) -- 初始颜色

local TweenService = game:GetService("TweenService")

local function createRainbowTween(uiElement, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local goal = {Color = Color3.new(math.random(), math.random(), math.random())}
    local tween = TweenService:Create(uiElement, tweenInfo, goal)
    tween:Play()
end

while true do
    createRainbowTween(UIStroke, 1)
    wait(1)
end
end)

tab8:Button("警察team", function()
    local Player = game.Players.LocalPlayer
local PlayerName = Player.Name

local function switchTeam(teamColor)
    local args = {
        [1] = teamColor
    }
    workspace.Remote.TeamEvent:FireServer(unpack(args))
    local args = {
        [1] = PlayerName
    }
    workspace.Remote.loadchar:InvokeServer(unpack(args))
end

-- 切换到警卫团队
switchTeam("Bright blue")
end)

tab8:Button("犯人team", function()
    local Player = game.Players.LocalPlayer
local PlayerName = Player.Name

local function switchTeam(teamColor)
    local args = {
        [1] = teamColor
    }
    workspace.Remote.TeamEvent:FireServer(unpack(args))
    local args = {
        [1] = PlayerName
    }
    workspace.Remote.loadchar:InvokeServer(unpack(args))
end

-- 切换到囚犯团队
switchTeam("Bright orange")
end)

tab8:Button("犯罪分子team", function()
    local player = game.Players.LocalPlayer
    if player then
        player.Team = CriminalsTeam
        player.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(100, 10, 100)) -- 传送到犯罪分子基地
        end
end)
local Enable = false

tab8:Toggle("杀戮光环", false, function(state)
    if state then
        Enable = true
        
        -- 自动攻击功能
        spawn(function()
            while Enable do
                wait(0.1)
                for i, v in pairs(game:GetService("Players"):GetChildren()) do
                    pcall(function()
                        if v ~= game:GetService("Players").LocalPlayer and not v.Character:FindFirstChildOfClass("ForceField") and v.Character.Humanoid.Health > 0 then
                            while v.Character:WaitForChild("Humanoid").Health > 0 and Enable do
                                wait()
                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                                for x, c in pairs(game:GetService("Players"):GetChildren()) do
                                    if c ~= game:GetService("Players").LocalPlayer then 
                                        game.ReplicatedStorage.meleeEvent:FireServer(c)
                                    end
                                end
                            end
                        end
                    end)
                    wait()
                end
            end
        end)
    else
        Enable = false
    end
end)

tab9:Colorpicker("Setting UI Color",Color3.fromRGB(44, 120, 224), function(t)
lib:ChangePresetColor(Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255))
end)
