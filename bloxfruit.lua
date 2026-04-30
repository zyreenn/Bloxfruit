-- ZYRE HUB v5.0 - Complete Rewrite
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local humanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZyreHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 18
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Text = "⭐ ZYRE HUB v5.0"
TitleBar.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    print("ZYRE HUB Closed")
end)

-- Scroll Frame for Content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 10
ScrollFrame.TopImage = ""
ScrollFrame.BottomImage = ""
ScrollFrame.MidImage = ""
ScrollFrame.Parent = MainFrame

-- UIListLayout for automatic spacing
local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollFrame

-- Function to create buttons
local function CreateButton(text, description, callback)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Size = UDim2.new(1, -10, 0, 50)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.Text = text .. "\n" .. description
    Button.TextWrapped = true
    Button.Parent = ScrollFrame
    Button.MouseButton1Click:Connect(callback)
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    return Button
end

-- Variables
local autoFarmEnabled = false
local autoLeviathanEnabled = false
local autoChestEnabled = false
local autoFishingEnabled = false
local attackSpeedMode = "Normal" -- Normal, Fast, SuperFast

-- Get Nearest Mob
local function getNearestMob()
    local nearest = nil
    local shortestDistance = math.huge
    
    pcall(function()
        local Enemies = workspace:FindFirstChild("Enemies")
        if Enemies then
            for _, enemy in pairs(Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    if enemy.Humanoid.Health > 0 then
                        local distance = (enemy.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if distance < shortestDistance and distance < 150 then
                            shortestDistance = distance
                            nearest = enemy
                        end
                    end
                end
            end
        end
    end)
    
    return nearest
end

-- Attack Function
local function attackMob(target)
    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
        pcall(function()
            humanoidRootPart.CFrame = target.HumanoidRootPart.CFrame + target.HumanoidRootPart.CFrame.LookVector * 5
            
            local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if Remotes then
                local Combat = Remotes:FindFirstChild("Combat")
                if Combat then
                    local Melee = Combat:FindFirstChild("Melee")
                    if Melee then
                        Melee:FireServer(target)
                    end
                end
            end
        end)
    end
end

-- Auto Farm Function
local function autoFarm()
    while autoFarmEnabled do
        pcall(function()
            local mob = getNearestMob()
            if mob then
                attackMob(mob)
            end
        end)
        
        if attackSpeedMode == "Normal" then
            wait(0.5)
        elseif attackSpeedMode == "Fast" then
            wait(0.2)
        elseif attackSpeedMode == "SuperFast" then
            wait(0.05)
        end
    end
end

-- Auto Leviathan Function
local function autoLeviathan()
    while autoLeviathanEnabled do
        pcall(function()
            local leviathan = workspace:FindFirstChild("Leviathan")
            if leviathan and leviathan:FindFirstChild("Humanoid") then
                if leviathan.Humanoid.Health > 0 then
                    humanoidRootPart.CFrame = leviathan.HumanoidRootPart.CFrame + leviathan.HumanoidRootPart.CFrame.LookVector * 10
                    attackMob(leviathan)
                end
            end
        end)
        wait(0.3)
    end
end

-- Auto Chest Function
local function autoChest()
    while autoChestEnabled do
        pcall(function()
            local Chests = workspace:FindFirstChild("Chests")
            if Chests then
                for _, chest in pairs(Chests:GetChildren()) do
                    if chest:FindFirstChild("ClickDetector") then
                        local distance = (chest.Position - humanoidRootPart.Position).Magnitude
                        if distance < 100 then
                            fireclickdetector(chest.ClickDetector)
                            wait(0.3)
                        end
                    end
                end
            end
        end)
        wait(1)
    end
end

-- Auto Fishing Function
local function autoFishing()
    while autoFishingEnabled do
        pcall(function()
            local Fishing = workspace:FindFirstChild("Fishing")
            if Fishing then
                for _, fish in pairs(Fishing:GetChildren()) do
                    if fish:FindFirstChild("ClickDetector") then
                        fireclickdetector(fish.ClickDetector)
                        wait(0.5)
                    end
                end
            end
        end)
        wait(2)
    end
end

-- BUTTONS

-- Title
CreateButton("🌾 FARMING FEATURES", "Click buttons below to use farming", function() end).TextColor3 = Color3.fromRGB(255, 200, 0)

-- Auto Farm Mobs
CreateButton("Auto Farm Mobs", "Toggle auto farming", function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        print("✅ Auto Farm: ON")
        task.spawn(autoFarm)
    else
        print("❌ Auto Farm: OFF")
    end
end)

-- Attack Speed Selection
CreateButton("Attack Speed: Normal", "Switch attack speed", function()
    if attackSpeedMode == "Normal" then
        attackSpeedMode = "Fast"
        print("⚡ Attack Speed: FAST")
    elseif attackSpeedMode == "Fast" then
        attackSpeedMode = "SuperFast"
        print("⚡⚡ Attack Speed: SUPER FAST")
    else
        attackSpeedMode = "Normal"
        print("🐢 Attack Speed: NORMAL")
    end
end)

-- Auto Leviathan
CreateButton("Auto Leviathan", "Fight Leviathan boss automatically", function()
    autoLeviathanEnabled = not autoLeviathanEnabled
    if autoLeviathanEnabled then
        print("✅ Auto Leviathan: ON")
        task.spawn(autoLeviathan)
    else
        print("❌ Auto Leviathan: OFF")
    end
end)

-- Auto Chest
CreateButton("Auto Chest", "Collect chests automatically", function()
    autoChestEnabled = not autoChestEnabled
    if autoChestEnabled then
        print("✅ Auto Chest: ON")
        task.spawn(autoChest)
    else
        print("❌ Auto Chest: OFF")
    end
end)

-- Sea Events
CreateButton("🌊 SEA EVENTS", "Sea event features", function() end).TextColor3 = Color3.fromRGB(0, 150, 255)

-- Auto Fishing
CreateButton("Auto Fishing", "Auto collect fishing items", function()
    autoFishingEnabled = not autoFishingEnabled
    if autoFishingEnabled then
        print("✅ Auto Fishing: ON")
        task.spawn(autoFishing)
    else
        print("❌ Auto Fishing: OFF")
    end
end)

-- Utilities
CreateButton("⚙️ UTILITIES", "Utility features", function() end).TextColor3 = Color3.fromRGB(150, 150, 255)

-- Stop All
CreateButton("STOP ALL", "Disable all features", function()
    autoFarmEnabled = false
    autoLeviathanEnabled = false
    autoChestEnabled = false
    autoFishingEnabled = false
    print("⛔ All features stopped")
end)

-- Settings
CreateButton("📋 COPY SCRIPT", "Copy script URL to clipboard", function()
    setclipboard("loadstring(game:HttpGet('https://raw.githubusercontent.com/zyreenn/Bloxfruit/main/bloxfruit.lua'))()")
    print("✅ Script copied to clipboard!")
end)

-- Update ScrollFrame size
local UISizeConstraint = Instance.new("UISizeConstraint")
UISizeConstraint.MaxSize = Vector2.new(400, math.huge)
UISizeConstraint.Parent = ScrollFrame

print("✅ ZYRE HUB v5.0 Loaded! Drag the menu to move it around.")
print("✅ Click buttons to enable features")
print("✅ Click ✕ button to close menu")
