local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ZYRE HUB v4.0", "DarkTheme")

-- Variables
local autoFarmEnabled = false
local autoLeviathanEnabled = false
local autoQuestEnabled = false
local autoChestEnabled = false
local autoCombatEnabled = false
local seaEventEnabled = false
local autoFishingEnabled = false
local killAuraEnabled = false
local autoHealthEnabled = false
local autoFruitEnabled = false
local attackSpeed = 0.2 -- Default: Fast

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Tab & Sections
local FarmingTab = Window:NewTab("🌾 FARMING")
local SeaTab = Window:NewTab("🌊 SEA EVENTS")
local UtilTab = Window:NewTab("⚙️ UTILITIES")
local TeleportTab = Window:NewTab("🗺️ TELEPORT")
local SettingsTab = Window:NewTab("⚙️ SETTINGS")

-- FARMING TAB
local FarmingSection = FarmingTab:NewSection("Auto Farm")
local AttackSpeedSection = FarmingTab:NewSection("Attack Speed")

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
        wait(attackSpeed)
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
        wait(attackSpeed)
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
        wait(attackSpeed)
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

-- Auto Sea Event
local function autoSeaEvent()
    while seaEventEnabled do
        pcall(function()
            local seaBoss = workspace:FindFirstChild("SeaBoss")
            if seaBoss and seaBoss:FindFirstChild("Humanoid") then
                if seaBoss.Humanoid.Health > 0 then
                    HumanoidRootPart.CFrame = seaBoss.HumanoidRootPart.CFrame + seaBoss.HumanoidRootPart.CFrame.LookVector * 10
                    attackEnemy(seaBoss)
                end
            end
        end)
        wait(attackSpeed)
    end
end

-- Auto Fishing
local function autoFishing()
    while autoFishingEnabled do
        pcall(function()
            local fishing = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Fishing")
            if fishing then
                fishing:FireServer("Cast")
            end
        end)
        wait(5)
    end
end

-- Kill Aura
local function killAura()
    while killAuraEnabled do
        pcall(function()
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                        if distance < 50 then
                            attackEnemy(enemy)
                        end
                    end
                end
            end
        end)
        wait(attackSpeed)
    end
end

-- Auto Health
local function autoHealth()
    while autoHealthEnabled do
        pcall(function()
            if Humanoid.Health < Humanoid.MaxHealth * 0.5 then
                local healthRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Heal")
                if healthRemote then
                    healthRemote:FireServer()
                end
            end
        end)
        wait(1)
    end
end

-- Auto Fruit Eat
local function autoFruit()
    while autoFruitEnabled do
        pcall(function()
            local inventory = Player:WaitForChild("Backpack")
            for _, item in pairs(inventory:GetChildren()) do
                if item:IsA("Tool") and item.Name:match("Fruit") then
                    item:Activate()
                    wait(2)
                end
            end
        end)
        wait(5)
    end
end

-- FARMING TAB BUTTONS
FarmingSection:NewButton("Auto Farm Mobs", "Auto attack nearby enemies", function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        task.spawn(farmMobs)
        print("✅ Auto Farm: ON")
    else
        print("❌ Auto Farm: OFF")
    end
end)

FarmingSection:NewButton("Auto Leviathan", "Auto fight Leviathan boss", function()
    autoLeviathanEnabled = not autoLeviathanEnabled
    if autoLeviathanEnabled then
        task.spawn(autoLeviathan)
        print("✅ Auto Leviathan: ON")
    else
        print("❌ Auto Leviathan: OFF")
    end
end)

FarmingSection:NewButton("Auto Quest", "Auto complete quests", function()
    autoQuestEnabled = not autoQuestEnabled
    if autoQuestEnabled then
        task.spawn(completeQuest)
        print("✅ Auto Quest: ON")
    else
        print("❌ Auto Quest: OFF")
    end
end)

FarmingSection:NewButton("Auto Chest", "Auto collect chests", function()
    autoChestEnabled = not autoChestEnabled
    if autoChestEnabled then
        task.spawn(collectChests)
        print("✅ Auto Chest: ON")
    else
        print("❌ Auto Chest: OFF")
    end
end)

-- ATTACK SPEED SELECTION
AttackSpeedSection:NewButton("⚡ Legit Attack (Safe)", "0.5s - Won't get banned", function()
    attackSpeed = 0.5
    print("🟢 Legit Attack Speed Selected")
end)

AttackSpeedSection:NewButton("⚡ Fast Attack", "0.2s - Balanced", function()
    attackSpeed = 0.2
    print("🟡 Fast Attack Speed Selected")
end)

AttackSpeedSection:NewButton("⚡ Super Fast Attack", "0.05s - Maximum", function()
    attackSpeed = 0.05
    print("🔴 Super Fast Attack Speed Selected")
end)

-- SEA EVENTS TAB
local SeaSection = SeaTab:NewSection("Sea Events")

SeaSection:NewButton("Auto Sea Event", "Fight sea bosses", function()
    seaEventEnabled = not seaEventEnabled
    if seaEventEnabled then
        task.spawn(autoSeaEvent)
        print("✅ Auto Sea Event: ON")
    else
        print("❌ Auto Sea Event: OFF")
    end
end)

SeaSection:NewButton("Auto Fishing", "Auto fish", function()
    autoFishingEnabled = not autoFishingEnabled
    if autoFishingEnabled then
        task.spawn(autoFishing)
        print("✅ Auto Fishing: ON")
    else
        print("❌ Auto Fishing: OFF")
    end
end)

-- UTILITIES TAB
local UtilSection = UtilTab:NewSection("Utilities")

UtilSection:NewButton("Kill Aura", "Attack all nearby enemies", function()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        task.spawn(killAura)
        print("✅ Kill Aura: ON")
    else
        print("❌ Kill Aura: OFF")
    end
end)

UtilSection:NewButton("Auto Health", "Auto heal when low HP", function()
    autoHealthEnabled = not autoHealthEnabled
    if autoHealthEnabled then
        task.spawn(autoHealth)
        print("✅ Auto Health: ON")
    else
        print("❌ Auto Health: OFF")
    end
end)

UtilSection:NewButton("Auto Fruit Eat", "Auto eat fruits", function()
    autoFruitEnabled = not autoFruitEnabled
    if autoFruitEnabled then
        task.spawn(autoFruit)
        print("✅ Auto Fruit: ON")
    else
        print("❌ Auto Fruit: OFF")
    end
end)

-- TELEPORT TAB
local TeleSection = TeleportTab:NewSection("Quick Teleport")

TeleSection:NewButton("Teleport to Merchant", "Go to merchant", function()
    pcall(function()
        HumanoidRootPart.CFrame = CFrame.new(100, 50, 100)
        print("📍 Teleported to Merchant")
    end)
end)

TeleSection:NewButton("Teleport to Trainer", "Go to trainer", function()
    pcall(function()
        HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        print("📍 Teleported to Trainer")
    end)
end)

TeleSection:NewButton("Teleport to Quest NPC", "Go to quest NPC", function()
    pcall(function()
        HumanoidRootPart.CFrame = CFrame.new(50, 50, 50)
        print("📍 Teleported to Quest NPC")
    end)
end)

-- SETTINGS TAB
local CopySection = SettingsTab:NewSection("📋 COPY CODE")

CopySection:NewLabel("Copy Script URL:")
CopySection:NewButton("📋 Copy Script URL", "Click to copy in clipboard", function()
    local url = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/zyreenn/Bloxfruit/main/bloxfruit.lua\"))()"
    print("✅ Copied to clipboard: " .. url)
    setclipboard(url)
end)

CopySection:NewLabel("Copy Features:")
CopySection:NewButton("📋 Copy Legit Attack Code", "Legit attack method", function()
    local code = "attackSpeed = 0.5 -- Legit Attack"
    setclipboard(code)
    print("✅ Copied Legit Attack code")
end)

CopySection:NewButton("📋 Copy Fast Attack Code", "Fast attack method", function()
    local code = "attackSpeed = 0.2 -- Fast Attack"
    setclipboard(code)
    print("✅ Copied Fast Attack code")
end)

CopySection:NewButton("📋 Copy SuperFast Code", "SuperFast attack method", function()
    local code = "attackSpeed = 0.05 -- Super Fast Attack"
    setclipboard(code)
    print("✅ Copied SuperFast code")
end)

local StopSection = SettingsTab:NewSection("Control")

StopSection:NewButton("⛔ Stop All", "Disable all features", function()
    autoFarmEnabled = false
    autoLeviathanEnabled = false
    autoQuestEnabled = false
    autoChestEnabled = false
    autoCombatEnabled = false
    seaEventEnabled = false
    autoFishingEnabled = false
    killAuraEnabled = false
    autoHealthEnabled = false
    autoFruitEnabled = false
    print("⛔ All features stopped")
end)

StopSection:NewButton("❌ Close Menu", "Close ZYRE HUB", function()
    Window:Close()
    print("ZYRE HUB Closed")
end)

print("✅ ZYRE HUB v4.0 Loaded! - All features ready!")
