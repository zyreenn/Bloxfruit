‎-- Blox Fruits Leviathan Automation Script
‎-- Version: 2.0
‎-- Compatible with Roblox Luau 5.1
‎
‎local HttpService = game:GetService("HttpService")
‎local Players = game:GetService("Players")
‎local Workspace = game:GetService("Workspace")
‎local ReplicatedStorage = game:GetService("ReplicatedStorage")
‎local VirtualUser = game:GetService("VirtualUser")
‎
‎local Player = Players.LocalPlayer
‎local Character = Player.Character or Player.CharacterAdded:Wait()
‎local Humanoid = Character:WaitForChild("Humanoid")
‎local RootPart = Character:WaitForChild("HumanoidRootPart")
‎
‎-- Configuration Settings
‎local Config = {
‎    AutoStartLeviathan = true,
‎    AutoFindLeviathan = true,
‎    AutoShootHeart = true,
‎    AutoSailBackTiki = true,
‎    AutoSailBackHydra = true,
‎    BoatSpeed = 100,
‎    UseFruitM1Only = true,
‎    UseFruitSkills = true,
‎    SuperFastAttack = true,
‎    AttackDelay = 0.05,
‎    HeartDetectionRange = 500,
‎    LeviathanDetectionRange = 2000,
‎    SafeDistance = 50,
‎    TeleportDistance = 300,
‎    MaxSearchTime = 60,
‎}
‎
‎-- State Variables
‎local LeviathanModel = nil
‎local LeviathanHeart = nil
‎local LeviathanDead = false
‎local CurrentBoat = nil
‎local TikiIsland = nil
‎local HydraIsland = nil
‎local FruitTool = nil
‎local IsAttacking = false
‎
‎-- Utility Functions
‎function WaitForChild(parent, childName, timeout)
‎    timeout = timeout or 10
‎    local child = parent:FindFirstChild(childName)
‎    if child then return child end
‎    
‎    for i = 1, timeout do
‎        child = parent:FindFirstChild(childName)
‎        if child then return child end
‎        task.wait(1)
‎    end
‎    return nil
‎end
‎
‎function GetDistance(pos1, pos2)
‎    return math.sqrt((pos1.X - pos2.X)^2 + (pos1.Y - pos2.Y)^2 + (pos1.Z - pos2.Z)^2)
‎end
‎
‎function TeleportTo(position)
‎    if RootPart then
‎        RootPart.CFrame = CFrame.new(position)
‎    end
‎end
‎
‎function MoveTo(position, speed)
‎    if RootPart and Humanoid then
‎        local direction = (position - RootPart.Position).Unit
‎        RootPart.CFrame = CFrame.new(RootPart.Position + direction * speed)
‎    end
‎end
‎
‎function FindNearestBoat()
‎    local boats = Workspace:GetChildren()
‎    for _, boat in pairs(boats) do
‎        if boat.Name:find("Boat") or boat.Name:find("Ship") then
‎            return boat
‎        end
‎    end
‎    return nil
‎end
‎
‎function GetBoatSpeed(boat)
‎    if boat and boat:FindFirstChild("Speed") then
‎        return boat.Speed.Value
‎    end
‎    return Config.BoatSpeed
‎end
‎
‎function SetBoatSpeed(boat, speed)
‎    if boat and boat:FindFirstChild("Speed") then
‎        boat.Speed.Value = speed
‎    end
‎end
‎
‎-- Leviathan Detection Functions
‎function FindLeviathan()
‎    local models = Workspace:GetChildren()
‎    for _, model in pairs(models) do
‎        if model.Name == "Leviathan" or model.Name:find("Leviathan") then
‎            return model
‎        end
‎    end
‎    
‎    -- Search in deeper structures
‎    for _, model in pairs(models) do
‎        local leviathan = model:FindFirstChild("Leviathan")
‎        if leviathan then
‎            return leviathan
‎        end
‎    end
‎    
‎    return nil
‎end
‎
‎function FindLeviathanHeart(leviathan)
‎    if not leviathan then return nil end
‎    
‎    local parts = leviathan:GetChildren()
‎    for _, part in pairs(parts) do
‎        if part.Name == "Heart" or part.Name:find("Heart") then
‎            return part
‎        end
‎    end
‎    
‎    return nil
‎end
‎
‎function IsLeviathanDead(leviathan)
‎    if not leviathan then return true end
‎    
‎    local humanoid = leviathan:FindFirstChild("Humanoid")
‎    if humanoid and humanoid.Health <= 0 then
‎        return true
‎    end
‎    
‎    -- Check for death indicators
‎    local deadSigns = leviathan:FindFirstChild("Dead") or leviathan:FindFirstChild("Destroyed")
‎    if deadSigns then
‎        return true
‎    end
‎    
‎    return false
‎end
‎
‎-- Island Location Functions
‎function FindTikiIsland()
‎    local islands = Workspace:GetChildren()
‎    for _, island in pairs(islands) do
‎        if island.Name == "Tiki Island" or island.Name:find("Tiki") then
‎            return island
‎        end
‎    end
‎    
‎    -- Try to find via map markers
‎    local map = WaitForChild(Workspace, "Map", 5)
‎    if map then
‎        local tiki = map:FindFirstChild("Tiki")
‎        if tiki then return tiki end
‎    end
‎    
‎    return nil
‎end
‎
‎function FindHydraIsland()
‎    local islands = Workspace:GetChildren()
‎    for _, island in pairs(islands) do
‎        if island.Name == "Hydra Island" or island.Name:find("Hydra") then
‎            return island
‎        end
‎    end
‎    
‎    local map = WaitForChild(Workspace, "Map", 5)
‎    if map then
‎        local hydra = map:FindFirstChild("Hydra")
‎        if hydra then return hydra end
‎    end
‎    
‎    return nil
‎end
‎
‎-- Fruit Attack Functions
‎function FindFruitTool()
‎    local backpack = Player:FindFirstChild("Backpack")
‎    if not backpack then return nil end
‎    
‎    local tools = backpack:GetChildren()
‎    for _, tool in pairs(tools) do
‎        if tool.Name:find("Fruit") or tool:FindFirstChild("FruitSkill") then
‎            return tool
‎        end
‎    end
‎    
‎    -- Check character tools
‎    local charTools = Character:GetChildren()
‎    for _, tool in pairs(charTools) do
‎        if tool.Name:find("Fruit") or tool:FindFirstChild("FruitSkill") then
‎            return tool
‎        end
‎    end
‎    
‎    return nil
‎end
‎
‎function HasM1Attack(fruitTool)
‎    if not fruitTool then return false end
‎    
‎    local m1 = fruitTool:FindFirstChild("M1") or fruitTool:FindFirstChild("Attack1")
‎    if m1 then return true end
‎    
‎    -- Check for attack animations/scripts
‎    local scripts = fruitTool:GetChildren()
‎    for _, script in pairs(scripts) do
‎        if script.Name:find("Attack") or script.Name:find("M1") then
‎            return true
‎        end
‎    end
‎    
‎    return false
‎end
‎
‎function PerformM1Attack(fruitTool)
‎    if not fruitTool then return false end
‎    
‎    -- Equip fruit tool
‎    if fruitTool.Parent ~= Character then
‎        fruitTool.Parent = Character
‎        task.wait(0.5)
‎    end
‎    
‎    -- Simulate M1 attack via mouse click
‎    VirtualUser:ClickButton1(Vector2.new(0,0))
‎    
‎    -- Additional fruit skill activation if configured
‎    if Config.UseFruitSkills then
‎        local skills = fruitTool:FindFirstChild("Skills")
‎        if skills then
‎            for _, skill in pairs(skills:GetChildren()) do
‎                if skill:IsA("RemoteEvent") or skill:IsA("RemoteFunction") then
‎                    skill:FireServer()
‎                    task.wait(0.1)
‎                end
‎            end
‎        end
‎    end
‎    
‎    return true
‎end
‎
‎function RapidAttack(leviathan, fruitTool)
‎    if not leviathan or not fruitTool then return end
‎    
‎    IsAttacking = true
‎    
‎    while IsAttacking and not LeviathanDead and leviathan and fruitTool do
‎        -- Move close to Leviathan if needed
‎        local heartPos = LeviathanHeart and LeviathanHeart.Position or leviathan.Position
‎        local distance = GetDistance(RootPart.Position, heartPos)
‎        
‎        if distance > Config.SafeDistance then
‎            MoveTo(heartPos, Config.TeleportDistance)
‎        end
‎        
‎        -- Perform M1 attack
‎        PerformM1Attack(fruitTool)
‎        
‎        -- Super fast attack mode
‎        if Config.SuperFastAttack then
‎            for i = 1, 3 do
‎                PerformM1Attack(fruitTool)
‎                task.wait(Config.AttackDelay)
‎            end
‎        else
‎            task.wait(Config.AttackDelay * 2)
‎        end
‎        
‎        -- Check if Leviathan is dead
‎        LeviathanDead = IsLeviathanDead(leviathan)
‎        if LeviathanDead then
‎            IsAttacking = false
‎            break
‎        end
‎        
‎        -- Update Leviathan heart position
‎        LeviathanHeart = FindLeviathanHeart(leviathan)
‎        
‎        task.wait(Config.AttackDelay)
‎    end
‎    
‎    IsAttacking = false
‎end
‎
‎-- Main Automation Loop
‎function AutoLeviathanProcess()
‎    print("[Leviathan Automation] Starting process...")
‎    
‎    -- Step 1: Find Fruit Tool
‎    FruitTool = FindFruitTool()
‎    if not FruitTool then
‎        print("[Error] No fruit tool found!")
‎        return
‎    end
‎    
‎    print("[Info] Fruit tool found:", FruitTool.Name)
‎    
‎    -- Step 2: Auto Start Leviathan (if enabled)
‎    if Config.AutoStartLeviathan then
‎        print("[Info] Attempting to start Leviathan event...")
‎        
‎        -- Look for Leviathan summon items/triggers
‎        local summonItems = Workspace:GetChildren()
‎        for _, item in pairs(summonItems) do
‎            if item.Name:find("LeviathanSummon") or item.Name:find("StartLeviathan") then
‎                TeleportTo(item.Position)
‎                task.wait(1)
‎                
‎                -- Try to interact with summon item
‎                local remote = item:FindFirstChild("RemoteEvent") or item:FindFirstChild("Activate")
‎                if remote then
‎                    remote:FireServer()
‎                    print("[Info] Leviathan summon activated")
‎                end
‎                break
‎            end
‎        end
‎        
‎        task.wait(5) -- Wait for Leviathan spawn
‎    end
‎    
‎    -- Step 3: Auto Find Leviathan (if enabled)
‎    if Config.AutoFindLeviathan then
‎        print("[Info] Searching for Leviathan...")
‎        
‎        local searchStart = time()
‎        while not LeviathanModel and (time() - searchStart) < Config.MaxSearchTime do
‎            LeviathanModel = FindLeviathan()
‎            if LeviathanModel then
‎                print("[Success] Leviathan found!")
‎                break
‎            end
‎            
‎            -- Move around to search
‎            local randomPos = RootPart.Position + Vector3.new(math.random(-100,100), 0, math.random(-100,100))
‎            MoveTo(randomPos, 50)
‎            
‎            task.wait(2)
‎        end
‎        
‎        if not LeviathanModel then
‎            print("[Error] Leviathan not found within time limit!")
‎            return
‎        end
‎    else
‎        LeviathanModel = FindLeviathan()
‎        if not LeviathanModel then
‎            print("[Error] Leviathan not found!")
‎            return
‎        end
‎    end
‎    
‎    -- Step 4: Find Leviathan Heart
‎    LeviathanHeart = FindLeviathanHeart(LeviathanModel)
‎    if not LeviathanHeart then
‎        print("[Warning] Leviathan heart not found, attacking main body")
‎        LeviathanHeart = LeviathanModel:FindFirstChild("HumanoidRootPart") or LeviathanModel.PrimaryPart or LeviathanModel
‎    end
‎    
‎    -- Step 5: Get Boat for transportation
‎    CurrentBoat = FindNearestBoat()
‎    if CurrentBoat then
‎        print("[Info] Boat found:", CurrentBoat.Name)
‎        SetBoatSpeed(CurrentBoat, Config.BoatSpeed)
‎    else
‎        print("[Warning] No boat found, using teleportation")
‎    end
‎    
‎    -- Step 6: Auto Shoot Heart (Attack Sequence)
‎    if Config.AutoShootHeart then
‎        print("[Info] Starting attack on Leviathan heart...")
‎        
‎        -- Move to Leviathan heart position
‎        if LeviathanHeart then
‎            TeleportTo(LeviathanHeart.Position + Vector3.new(Config.SafeDistance, 10, 0))
‎        end
‎        
‎        -- Start rapid attack
‎        RapidAttack(LeviathanModel, FruitTool)
‎        
‎        print("[Info] Leviathan defeated!")
‎    end
‎    
‎    -- Step 7: Auto Sail Back to Tiki Island (if enabled)
‎    if Config.AutoSailBackTiki and CurrentBoat then
‎        print("[Info] Returning to Tiki Island...")
‎        
‎        TikiIsland = FindTikiIsland()
‎        if TikiIsland then
‎            TeleportTo(TikiIsland.Position + Vector3.new(0, 10, 0))
‎            
‎            -- Use boat to sail back if available
‎            if CurrentBoat then
‎                TeleportTo(CurrentBoat.Position)
‎                task.wait(2)
‎                
‎                -- Simulate sailing to Tiki Island
‎                local tikiPos = TikiIsland.Position
‎                while GetDistance(RootPart.Position, tikiPos) > 100 do
‎                    MoveTo(tikiPos, GetBoatSpeed(CurrentBoat))
‎                    task.wait(0.5)
‎                end
‎            end
‎            
‎            print("[Success] Arrived at Tiki Island")
‎        else
‎            print("[Warning] Tiki Island not found")
‎        end
‎    end
‎    
‎    -- Step 8: Auto Sail Back to Hydra Island (if enabled)
‎    if Config.AutoSailBackHydra and CurrentBoat then
‎        print("[Info] Returning to Hydra Island...")
‎        
‎        HydraIsland = FindHydraIsland()
‎        if HydraIsland then
‎            TeleportTo(HydraIsland.Position + Vector3.new(0, 10, 0))
‎            
‎            if CurrentBoat then
‎                TeleportTo(CurrentBoat.Position)
‎                task.wait(2)
‎                
‎                local hydraPos = HydraIsland.Position
‎                while GetDistance(RootPart.Position, hydraPos) > 100 do
‎                    MoveTo(hydraPos, GetBoatSpeed(CurrentBoat))
‎                    task.wait(0.5)
‎                end
‎            end
‎            
‎            print("[Success] Arrived at Hydra Island")
‎        else
‎            print("[Warning] Hydra Island not found")
‎        end
‎    end
‎    
‎    print("[Leviathan Automation] Process completed!")
‎end
‎
‎-- Control Functions for User Interaction
‎function StartAutomation()
‎    AutoLeviathanProcess()
‎end
‎
‎function StopAutomation()
‎    IsAttacking = false
‎    LeviathanDead = true
‎    print("[Leviathan Automation] Stopped")
‎end
‎
‎function ToggleSetting(settingName)
‎    if Config[settingName] ~= nil then
‎        Config[settingName] = not Config[settingName]
‎        print("[Config]", settingName, "set to:", Config[settingName])
‎    else
‎        print("[Error] Setting not found:", settingName)
‎    end
‎end
‎
‎function SetBoatSpeedCustom(speed)
‎    Config.BoatSpeed = speed
‎    if CurrentBoat then
‎        SetBoatSpeed(CurrentBoat, speed)
‎    end
‎    print("[Config] Boat speed set to:", speed)
‎end
‎
‎-- UI Setup (Optional - can be removed if GUI is not needed)
‎function CreateSimpleUI()
‎    -- This creates a basic text UI for controlling the automation
‎    -- Remove this function if you don't want any UI
‎    
‎    local ScreenGui = Instance.new("ScreenGui")
‎    ScreenGui.Name = "LeviathanAutomationUI"
‎    ScreenGui.Parent = Player.PlayerGui
‎    
‎    local MainFrame = Instance.new("Frame")
‎    MainFrame.Size = UDim2.new(0, 300, 0, 400)
‎    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
‎    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
‎    MainFrame.Parent = ScreenGui
‎    
‎    local Title = Instance.new("TextLabel")
‎    Title.Text = "Leviathan Automation"
‎    Title.Size = UDim2.new(1, 0, 0, 40)
‎    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
‎    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
‎    Title.Parent = MainFrame
‎    
‎    -- Start Button
‎    local StartBtn = Instance.new("TextButton")
‎    StartBtn.Text = "START AUTOMATION"
‎    StartBtn.Size = UDim2.new(1, -20, 0, 40)
‎    StartBtn.Position = UDim2.new(0, 10, 0, 50)
‎    StartBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
‎    StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
‎    StartBtn.Parent = MainFrame
‎    
‎    StartBtn.MouseButton1Click:Connect(function()
‎        StartAutomation()
‎    end)
‎    
‎    -- Stop Button
‎    local StopBtn = Instance.new("TextButton")
‎    StopBtn.Text = "STOP AUTOMATION"
‎    StopBtn.Size = UDim2.new(1, -20, 0, 40)
‎    StopBtn.Position = UDim2.new(0, 10, 0, 100)
‎    StopBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
‎    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
‎    StopBtn.Parent = MainFrame
‎    
‎    StopBtn.MouseButton1Click:Connect(function()
‎        StopAutomation()
‎    end)
‎    
‎    -- Settings Buttons (Toggle)
‎    local settingsY = 160
‎    for settingName, value in pairs(Config) do
‎        if type(value) == "boolean" then
‎            local ToggleBtn = Instance.new("TextButton")
‎            ToggleBtn.Text = settingName .. ": " .. tostring(value)
‎            ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
‎            ToggleBtn.Position = UDim2.new(0, 10, 0, settingsY)
‎            ToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
‎            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
‎            ToggleBtn.Parent = MainFrame
‎            
‎            ToggleBtn.MouseButton1Click:Connect(function()
‎                ToggleSetting(settingName)
‎                ToggleBtn.Text = settingName .. ": " .. tostring(Config[settingName])
‎            end)
‎            
‎            settingsY = settingsY + 35
‎        end
‎    end
‎    
‎    -- Boat Speed Control
‎    local SpeedLabel = Instance.new("TextLabel")
‎    SpeedLabel.Text = "Boat Speed: " .. Config.BoatSpeed
‎    SpeedLabel.Size = UDim2.new(1, -20, 0, 30)
‎    SpeedLabel.Position = UDim2.new(0, 10, 0, settingsY)
‎    SpeedLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
‎    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
‎    SpeedLabel.Parent = MainFrame
‎    
‎    local SpeedUpBtn = Instance.new("TextButton")
‎    SpeedUpBtn.Text = "+"
‎    SpeedUpBtn.Size = UDim2.new(0.5, -15, 0, 30)
‎    SpeedUpBtn.Position = UDim2.new(0, 10, 0, settingsY + 35)
‎    SpeedUpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
‎    SpeedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
‎    SpeedUpBtn.Parent = MainFrame
‎    
‎    SpeedUpBtn.MouseButton1Click:Connect(function()
‎        SetBoatSpeedCustom(Config.BoatSpeed + 10)
‎        SpeedLabel.Text = "Boat Speed: " .. Config.BoatSpeed
‎    end)
‎    
‎    local SpeedDownBtn = Instance.new("TextButton")
‎    SpeedDownBtn.Text = "-"
‎    SpeedDownBtn.Size = UDim2.new(0.5, -15, 0, 30)
‎    SpeedDownBtn.Position = UDim2.new(0.5, 5, 0, settingsY + 35)
‎    SpeedDownBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
‎    SpeedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
‎    SpeedDownBtn.Parent = MainFrame
‎    
‎    SpeedDownBtn.MouseButton1Click:Connect(function()
‎        SetBoatSpeedCustom(math.max(50, Config.BoatSpeed - 10))
‎        SpeedLabel.Text = "Boat Speed: " .. Config.BoatSpeed
‎    end)
‎    
‎    print("[UI] Automation control panel created!")
‎end
‎
‎-- Initialization and Setup Instructions
‎print("=== Blox Fruits Leviathan Automation ===")
‎print("Loaded successfully!")
‎print("Features:")
‎print("- Auto Start Leviathan")
‎print("- Auto Find Leviathan")
‎print("- Auto Shoot Heart")
‎print("- Auto Sail Back to Tiki/Hydra")
‎print("- Boat Speed Control")
‎print("- Fruit M1 Attack Priority")
‎print("- Super Fast Attack Mode")
‎
‎-- Create UI (optional)
‎CreateSimpleUI()
‎
‎-- Auto-start if configured (can be disabled for manual control)
‎if Config.AutoStartLeviathan then
‎    task.wait(5) -- Wait for game to fully load
‎    StartAutomation()
‎end
‎
‎-- Command Line Interface (Alternative to UI)
‎Players.LocalPlayer.Chatted:Connect(function(message)
‎    if message == "!startleviathan" then
‎        StartAutomation()
‎    elseif message == "!stopleviathan" then
‎        StopAutomation()
‎    elseif message:sub(1, 7) == "!speed " then
‎        local speed = tonumber(message:sub(8))
‎        if speed then
‎            SetBoatSpeedCustom(speed)
‎        end
‎    elseif message == "!toggle m1" then
‎        ToggleSetting("UseFruitM1Only")
‎    elseif message == "!toggle skills" then
‎        ToggleSetting("UseFruitSkills")
‎    elseif message == "!toggle fast" then
‎        ToggleSetting("SuperFastAttack")
‎    end
‎end)
‎
‎print("=== Setup Instructions ===")
‎print("1. Paste this script into a Luau executor")
‎print("2. Make sure you have a fruit with M1 attack equipped")
‎print("3. Be near the Leviathan spawn area or islands")
‎print("4. Use commands:")
‎print("   !startleviathan - Start automation")
‎print("   !stopleviathan - Stop automation")
‎print("   !speed [number] - Set boat speed")
‎print("5. Or use the UI buttons to control automation")
‎print("6. For best results, use a fast fruit (like Dragon, Leopard, etc.)")
‎