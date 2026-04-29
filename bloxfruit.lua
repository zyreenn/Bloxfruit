local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ZYRE HUB", "DarkTheme")

-- Variables
local autoFarmEnabled = false
local autoLeviathanEnabled = false
local autoQuestEnabled = false
local autoChestEnabled = false
local autoCombatEnabled = false

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Tab & Sections
local Tab = Window:NewTab("BloxFruits")
local AutoFarmSection = Tab:NewSection("Auto Farm")
local SettingsSection = Tab:NewSection("Settings")

-- Get Nearest Enemy
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

-- Attack Function
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

-- Auto Farm Mobs Loop
local function farmMobs()
    while autoFarmEnabled do
        pcall(function()
            local enemy = getNearestEnemy()
            if enemy then
                attackEnemy(enemy)
            end
        end)
        wait(0.3)
    end
end

-- Auto Combat
local function autoCombat()
    while autoCombatEnabled do
        pcall(function()
            local enemy = getNearestEnemy()
            if enemy then
                HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame + enemy.HumanoidRootPart.CFrame.LookVector * 8
                attackEnemy(enemy)
            end
        end)
        wait(0.2)
    end
end

-- Auto Leviathan
local function autoLeviathan()
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
end

-- Auto Chest
local function collectChests()
    while autoChestEnabled do
        pcall(function()
            local chestsFolder = workspace:FindFirstChild("Chests")
            if chestsFolder then
                for _, chest in pairs(chestsFolder:GetChildren()) do
                    if chest:FindFirstChild("ClickDetector") then
                        local distance = (chest.Position - HumanoidRootPart.Position).Magnitude
                        if distance < 100 then
                            fireclickdetector(chest.ClickDetector)
                            wait(0.5)
                        end
                    end
                end
            end
        end)
        wait(1)
    end
end

-- Auto Quest
local function completeQuest()
    while autoQuestEnabled do
        pcall(function()
            local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
            local questRemote = remotes:FindFirstChild("CommF_")
            if questRemote then
                questRemote:InvokeServer("StartQuest", Player)
            end
        end)
        wait(3)
    end
end

-- UI Buttons
AutoFarmSection:NewButton("Auto Farm Mobs", "Auto attack nearby enemies for XP", function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        task.spawn(farmMobs)
        print("✅ Auto Farm: ON")
    else
        print("❌ Auto Farm: OFF")
    end
end)

AutoFarmSection:NewButton("Auto Combat", "Advanced combat mode", function()
    autoCombatEnabled = not autoCombatEnabled
    if autoCombatEnabled then
        task.spawn(autoCombat)
        print("✅ Auto Combat: ON")
    else
        print("❌ Auto Combat: OFF")
    end
end)

AutoFarmSection:NewButton("Auto Leviathan", "Auto fight Leviathan boss", function()
    autoLeviathanEnabled = not autoLeviathanEnabled
    if autoLeviathanEnabled then
        task.spawn(autoLeviathan)
        print("✅ Auto Leviathan: ON")
    else
        print("❌ Auto Leviathan: OFF")
    end
end)

AutoFarmSection:NewButton("Auto Quest", "Auto complete quests", function()
    autoQuestEnabled = not autoQuestEnabled
    if autoQuestEnabled then
        task.spawn(completeQuest)
        print("✅ Auto Quest: ON")
    else
        print("❌ Auto Quest: OFF")
    end
end)

AutoFarmSection:NewButton("Auto Chest", "Auto collect nearby chests", function()
    autoChestEnabled = not autoChestEnabled
    if autoChestEnabled then
        task.spawn(collectChests)
        print("✅ Auto Chest: ON")
    else
        print("❌ Auto Chest: OFF")
    end
end)

-- Settings
SettingsSection:NewButton("Stop All", "Disable all features", function()
    autoFarmEnabled = false
    autoLeviathanEnabled = false
    autoQuestEnabled = false
    autoChestEnabled = false
    autoCombatEnabled = false
    print("⛔ All features stopped")
end)

SettingsSection:NewButton("Close Menu", "Close ZYRE HUB", function()
    Window:Close()
    print("ZYRE HUB Closed")
end)

print("✅ ZYRE HUB v2.0 Loaded! - Click buttons to enable features")