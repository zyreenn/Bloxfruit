local screenSize = game:GetService("UserInputService"):GetMouseLocation()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create Main GUI
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "ZyreHub"
mainGui.ResetOnSpawn = false
mainGui.Parent = PlayerGui

-- Main Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui

-- Add Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(0, 200, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.Text = "⭐ ZYRE HUB v4.0"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainGui:Destroy()
    print("❌ ZYRE HUB Closed")
end)

-- Content Frame (Scrollable)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Scroll View
local scrollView = Instance.new("ScrollingFrame")
scrollView.Name = "ScrollView"
scrollView.Size = UDim2.new(1, 0, 1, 0)
scrollView.BackgroundTransparency = 1
scrollView.BorderSizePixel = 0
scrollView.ScrollBarThickness = 8
scrollView.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollView.Parent = contentFrame

-- Layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = scrollView

-- Variables
local autoFarmEnabled = false
local autoLeviathanEnabled = false
local autoQuestEnabled = false
local autoChestEnabled = false
local autoCombatEnabled = false
local killAuraEnabled = false
local autoHealthEnabled = false
local attackSpeed = 0.2 -- Default: Fast

local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Helper Function: Create Button
local function createButton(text, description, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Text = "▶ " .. text
    btn.Parent = scrollView
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    return btn
end

-- Helper Function: Create Toggle Button
local function createToggleButton(text, description, enabledVar, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Text = "◯ " .. text
    btn.Parent = scrollView
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback()
        btn.BackgroundColor3 = enabledVar and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 50)
        btn.Text = (enabledVar and "✓ " or "◯ ") .. text
    end)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    return btn
end

-- Helper Function: Create Copy Button
local function createCopyButton(text, copyText)
    local btn = Instance.new("TextButton")
    btn.Name = "Copy_" .. text
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Text = "📋 " .. text
    btn.Parent = scrollView
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        setclipboard(copyText)
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        btn.Text = "✅ Copied!"
        wait(2)
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        btn.Text = "📋 " .. text
    end)
    
    return btn
end

-- Functions
local function getNearestEnemy()
    local nearest = nil
    local shortestDistance = math.huge
    
    pcall(function()
        for _, enemy in pairs(workspace:FindFirstChild("Enemies"):GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                if enemy.Humanoid.Health > 0 then
                    local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance and distance < 100 then
                        shortestDistance = distance
                        nearest = enemy
                    end
                end
            end
        end
    end)
    
    return nearest
end

local function attackEnemy(target)
    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
        pcall(function()
            HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame + target.HumanoidRootPart.CFrame.LookVector * 5
            local combatRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Combat")
            if combatRemote then
                combatRemote:FindFirstChild("Melee"):FireServer(target)
            end
        end)
    end
end

-- FARMING SECTION
createButton("🌾 FARMING", "Farming Features", function() end)

createToggleButton("⚔️ Auto Farm Mobs", "Auto attack enemies", autoFarmEnabled, function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        task.spawn(function()
            while autoFarmEnabled do
                pcall(function()
                    local enemy = getNearestEnemy()
                    if enemy then
                        attackEnemy(enemy)
                    end
                end)
                wait(attackSpeed)
            end
        end)
        print("✅ Auto Farm: ON")
    else
        print("❌ Auto Farm: OFF")
    end
end)

createToggleButton("⚡ Auto Combat", "Advanced combat", autoCombatEnabled, function()
    autoCombatEnabled = not autoCombatEnabled
    if autoCombatEnabled then
        task.spawn(function()
            while autoCombatEnabled do
                pcall(function()
                    local enemy = getNearestEnemy()
                    if enemy then
                        HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame + enemy.HumanoidRootPart.CFrame.LookVector * 8
                        attackEnemy(enemy)
                    end
                end)
                wait(0.1)
            end
        end)
        print("✅ Auto Combat: ON")
    else
        print("❌ Auto Combat: OFF")
    end
end)

createToggleButton("👹 Auto Leviathan", "Fight Leviathan boss", autoLeviathanEnabled, function()
    autoLeviathanEnabled = not autoLeviathanEnabled
    if autoLeviathanEnabled then
        task.spawn(function()
            while autoLeviathanEnabled do
                pcall(function()
                    local leviathan = workspace:FindFirstChild("Leviathan")
                    if leviathan and leviathan:FindFirstChild("Humanoid") then
                        if leviathan.Humanoid.Health > 0 then
                            HumanoidRootPart.CFrame = leviathan.HumanoidRootPart.CFrame + leviathan.HumanoidRootPart.CFrame.LookVector * 10
                            attackEnemy(leviathan)
                        end
                    end
                end)
                wait(0.5)
            end
        end)
        print("✅ Auto Leviathan: ON")
    else
        print("❌ Auto Leviathan: OFF")
    end
end)

-- ATTACK SPEED SELECTION
createButton("⚡ ATTACK SPEED", "Select Attack Speed", function() end)

createButton("🐢 Legit Attack (0.5s)", "Safe - Won't get banned", function()
    attackSpeed = 0.5
    print("✅ Legit Attack Selected (0.5s)")
end)

createButton("⚡ Fast Attack (0.2s)", "Faster farming", function()
    attackSpeed = 0.2
    print("✅ Fast Attack Selected (0.2s)")
end)

createButton("💥 SuperFast Attack (0.05s)", "Maximum speed", function()
    attackSpeed = 0.05
    print("✅ SuperFast Attack Selected (0.05s)")
end)

-- UTILITIES
createButton("🛠️ UTILITIES", "Utility Features", function() end)

createToggleButton("🎯 Kill Aura", "Attack all nearby", killAuraEnabled, function()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        task.spawn(function()
            while killAuraEnabled do
                pcall(function()
                    for _, enemy in pairs(workspace:FindFirstChild("Enemies"):GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                            if distance < 50 then
                                attackEnemy(enemy)
                            end
                        end
                    end
                end)
                wait(0.1)
            end
        end)
        print("✅ Kill Aura: ON")
    else
        print("❌ Kill Aura: OFF")
    end
end)

createToggleButton("❤️ Auto Health", "Auto heal", autoHealthEnabled, function()
    autoHealthEnabled = not autoHealthEnabled
    if autoHealthEnabled then
        task.spawn(function()
            while autoHealthEnabled do
                pcall(function()
                    local humanoid = Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health < humanoid.MaxHealth * 0.5 then
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Heal"):FireServer()
                    end
                end)
                wait(1)
            end
        end)
        print("✅ Auto Health: ON")
    else
        print("❌ Auto Health: OFF")
    end
end)

-- COPY BUTTONS
createButton("📋 COPY CODE", "Copy Script Links", function() end)

createCopyButton("Copy Script URL", "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zyreenn/Bloxfruit/main/bloxfruit.lua\"))()")

createCopyButton("Copy Legit Attack", "attackSpeed = 0.5")

createCopyButton("Copy Fast Attack", "attackSpeed = 0.2")

createCopyButton("Copy SuperFast Attack", "attackSpeed = 0.05")

-- STOP ALL
createButton("⛔ STOP ALL", "Disable all features", function()
    autoFarmEnabled = false
    autoLeviathanEnabled = false
    autoQuestEnabled = false
    autoCombatEnabled = false
    killAuraEnabled = false
    autoHealthEnabled = false
    print("⛔ All features stopped")
end)

-- Dragging Logic
local dragging = false
local dragInput
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("✅ ZYRE HUB v4.0 Loaded! Drag the menu to move it!")
