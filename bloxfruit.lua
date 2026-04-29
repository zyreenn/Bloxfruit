local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ZYRE HUB", "DarkTheme")
local Tab = Window:NewTab("BloxFruits")
local Section = Tab:NewSection("Auto Farm")

-- Variables
local autoFarmEnabled = false
local autoLeviathanEnabled = false
local autoQuestEnabled = false
local autoChestEnabled = false
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Helper Functions
local function getNearestMob()
    local nearest = nil
    local shortestDistance = math.huge
    
    for _, npc in pairs(workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local distance = (npc.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortest = distance
                nearest = npc
            end
        end
    end
    return nearest
end

local function attack(target)
    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
        local args = {
            [1] = target
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat"):WaitForChild("Melee"):FireServer(args)
    end
end

local function farmMobs()
    while autoFarmEnabled do
        wait(0.5)
        local mob = getNearestMob()
        if mob then
            attack(mob)
        end
    end
end

local function autoLeviathan()
    while autoLeviathanEnabled do
        wait(1)
        local leviathan = workspace:FindFirstChild("Leviathan")
        if leviathan and leviathan:FindFirstChild("Humanoid") then
            attack(leviathan)
        end
    end
end

local function collectChests()
    while autoChestEnabled do
        wait(0.5)
        for _, chest in pairs(workspace:FindFirstChild("Chests"):GetChildren()) do
            if chest:FindFirstChild("ClickDetector") then
                local distance = (chest.Position - Character.HumanoidRootPart.Position).Magnitude
                if distance < 50 then
                    fireclickdetector(chest.ClickDetector)
                end
            end
        end
    end
end

local function completeQuest()
    while autoQuestEnabled do
        wait(1)
        local questRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
        questRemote:InvokeServer("StartQuest", "AutoQuest")
    end
end

-- UI Buttons
Section:NewButton("Auto Farm Mobs", "Auto attack nearby mobs for XP", function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        task.spawn(farmMobs)
        print("Auto Farm: ON")
    else
        print("Auto Farm: OFF")
    end
end)

Section:NewButton("Auto Leviathan", "Auto fight Leviathan boss", function()
    autoLeviathanEnabled = not autoLeviathanEnabled
    if autoLeviathanEnabled then
        task.spawn(autoLeviathan)
        print("Auto Leviathan: ON")
    else
        print("Auto Leviathan: OFF")
    end
end)

Section:NewButton("Auto Quest", "Auto complete quests", function()
    autoQuestEnabled = not autoQuestEnabled
    if autoQuestEnabled then
        task.spawn(completeQuest)
        print("Auto Quest: ON")
    else
        print("Auto Quest: OFF")
    end
end)

Section:NewButton("Auto Chest", "Auto collect chests nearby", function()
    autoChestEnabled = not autoChestEnabled
    if autoChestEnabled then
        task.spawn(collectChests)
        print("Auto Chest: ON")
    else
        print("Auto Chest: OFF")
    end
end)

Section:NewButton("Stop All", "Disable all features", function()
    autoFarmEnabled = false
    autoLeviathanEnabled = false
    autoQuestEnabled = false
    autoChestEnabled = false
    print("All features stopped")
end)

print("ZYRE HUB Loaded! Click buttons to enable features.")