-- ESP 主模块
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ESP 存储
local espElements = {}

-- ESP 创建函数
local function createESP(params)
    local workspaceName = params.WorkspaceName
    local highlightColor = params.HighlightColor or Color3.new(0, 1, 0)
    local textColor = params.TextColor or Color3.new(1, 1, 1)
    local distance = params.Distance or 50
    local displayName = params.DisplayName or "ESP"
    local useBox = params.UseBox or true -- 新增选项
    local customName = params.CustomName or displayName -- 自定义名字选项

    local function getClosestPart(model)
        local closestPart = nil
        local closestDistance = math.huge

        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                local partDistance = (part.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if partDistance < closestDistance then
                    closestDistance = partDistance
                    closestPart = part
                end
            end
        end

        return closestPart, closestDistance
    end

    local function createESPForPart(part)
        local espLabel = Instance.new("BillboardGui")
        espLabel.Size = UDim2.new(1, 0, 1, 0)
        espLabel.AlwaysOnTop = true
        espLabel.Parent = part

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = textColor
        textLabel.Text = customName -- 使用自定义名字
        textLabel.TextSize = 16
        textLabel.Parent = espLabel

        if useBox then
            local espBox = Instance.new("BoxHandleAdornment")
            espBox.Size = part.Size + Vector3.new(0.2, 0.2, 0.2) -- 加一些边框
            espBox.Color3 = highlightColor
            espBox.AlwaysOnTop = true
            espBox.ZIndex = 5
            espBox.Parent = part
        else
            local highlight = Instance.new("Highlight")
            highlight.FillColor = highlightColor
            highlight.Parent = part
        end

        -- 存储 ESP 元素
        espElements[part] = {label = espLabel, box = espBox, highlight = highlight}

        -- 更新 ESP 位置
        RunService.RenderStepped:Connect(function()
            local playerPosition = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerPosition and part:IsDescendantOf(Workspace) then
                local distanceToPlayer = (part.Position - playerPosition.Position).Magnitude
                if distanceToPlayer <= distance then
                    espLabel.Position = UDim2.new(0, 0, 1.5, 0) -- 在部件上方
                else
                    espLabel:Destroy()
                    if useBox then
                        espBox:Destroy()
                    else
                        highlight:Destroy()
                    end
                    espElements[part] = nil -- 从存储中移除
                end
            else
                espLabel:Destroy()
                if useBox then
                    espBox:Destroy()
                else
                    highlight:Destroy()
                end
                espElements[part] = nil -- 从存储中移除
            end
        end)
    end

    local function checkCurrentRooms()
        for _, room in ipairs(Workspace.CurrentRooms:GetChildren()) do
            if room:FindFirstChild("Assets") then
                for _, asset in ipairs(room.Assets:GetChildren()) do
                    if asset:IsA("Model") then
                        local closestPart, closestDistance = getClosestPart(asset)
                        if closestPart then
                            createESPForPart(closestPart)
                        end
                    elseif asset:IsA("BasePart") or asset:IsA("MeshPart") then
                        createESPForPart(asset)
                    end
                end
            end
        end
    end

    local targetWorkspace = Workspace:FindFirstChild(workspaceName)
    if targetWorkspace then
        for _, item in ipairs(targetWorkspace:GetChildren()) do
            if item:IsA("Model") then
                local closestPart, closestDistance = getClosestPart(item)
                if closestPart then
                    createESPForPart(closestPart)
                end
            elseif item:IsA("BasePart") or item:IsA("MeshPart") then
                createESPForPart(item)
            end
        end
    else
        warn("未找到工作区: " .. workspaceName .. "，正在检查 CurrentRooms")
        checkCurrentRooms()
    end
end

-- 删除指定对象的 ESP
local function removeESP(targetName)
    for part, esp in pairs(espElements) do
        if part.Name == targetName then
            esp.label:Destroy()
            if esp.box then esp.box:Destroy() end
            if esp.highlight then esp.highlight:Destroy() end
            espElements[part] = nil -- 从存储中移除
        end
    end
end
