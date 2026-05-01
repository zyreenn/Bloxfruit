‎-- Blox Fruits Auto Leviathan & M1 Kitsune Script
‎-- Luau 5.1 compatible
‎
‎local Players = game:GetService("Players")
‎local Workspace = game:GetService("Workspace")
‎local RunService = game:GetService("RunService")
‎local ReplicatedStorage = game:GetService("ReplicatedStorage")
‎local UserInputService = game:GetService("UserInputService")
‎
‎local LocalPlayer = Players.LocalPlayer
‎local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
‎local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
‎
‎-- Configuration
‎local Config = {
‎    AutoLeviathan = true,
‎    M1Kitsune = true,
‎    AttackRange = 50,
‎    LeviathanDistance = 100,
‎    AttackSpeed = 0.1,
‎    TargetPriority = "Leviathan"
‎}
‎
‎-- Utilities
‎local function GetClosestTarget()
‎    local closest = nil
‎    local closestDistance = Config.AttackRange
‎    
‎    for _, enemy in pairs(Workspace:GetChildren()) do
‎        if enemy.Name == "Leviathan" and Config.AutoLeviathan then
‎            local distance = (HumanoidRootPart.Position - enemy.PrimaryPart.Position).Magnitude
‎            if distance <= Config.LeviathanDistance then
‎                return enemy
‎            end
‎        elseif enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
‎            local distance = (HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
‎            if distance < closestDistance then
‎                closest = enemy
‎                closestDistance = distance
‎            end
‎        end
‎    end
‎    return closest
‎end
‎
‎-- M1 Kitsune Attack System
‎local M1Kitsune = {
‎    Active = false,
‎    Combo = 1,
‎    LastAttack = 0
‎}
‎
‎local function PerformM1Attack(target)
‎    if not target or tick() - M1Kitsune.LastAttack < Config.AttackSpeed then return end
‎    
‎    M1Kitsune.LastAttack = tick()
‎    
‎    -- Simulate M1 attack (adjust based on actual game mechanics)
‎    local attackEvent = ReplicatedStorage:FindFirstChild("AttackEvent")
‎    if attackEvent then
‎        attackEvent:FireServer(target, M1Kitsune.Combo)
‎        M1Kitsune.Combo = M1Kitsune.Combo + 1
‎        if M1Kitsune.Combo > 5 then M1Kitsune.Combo = 1 end
‎    end
‎    
‎    -- Visual feedback
‎    print("M1 Kitsune Attack #" .. M1Kitsune.Combo .. " on " .. target.Name)
‎end
‎
‎-- Auto Leviathan System
‎local LeviathanSystem = {
‎    LeviathanFound = false,
‎    LeviathanHP = 0
‎}
‎
‎local function AttackLeviathan()
‎    local leviathan = Workspace:FindFirstChild("Leviathan")
‎    if not leviathan then
‎        LeviathanSystem.LeviathanFound = false
‎        return nil
‎    end
‎    
‎    LeviathanSystem.LeviathanFound = true
‎    LeviathanSystem.LeviathanHP = leviathan:FindFirstChild("Health") and leviathan.Health.Value or 0
‎    
‎    if (HumanoidRootPart.Position - leviathan.PrimaryPart.Position).Magnitude <= Config.LeviathanDistance then
‎        PerformM1Attack(leviathan)
‎        return leviathan
‎    end
‎    
‎    -- Move towards Leviathan
‎    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, leviathan.PrimaryPart.Position)
‎    return leviathan
‎end
‎
‎-- Main Loop
‎local MainLoop = RunService.RenderStepped:Connect(function()
‎    if Config.AutoLeviathan then
‎        local leviathanTarget = AttackLeviathan()
‎        if leviathanTarget then return end
‎    end
‎    
‎    if Config.M1Kitsune then
‎        local target = GetClosestTarget()
‎        if target then
‎            PerformM1Attack(target)
‎        end
‎    end
‎end)
‎
‎-- UI Controls (Optional)
‎local function CreateUI()
‎    local ScreenGui = Instance.new("ScreenGui")
‎    ScreenGui.Name = "BloxFruitsScriptUI"
‎    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
‎    
‎    local Frame = Instance.new("Frame")
‎    Frame.Size = UDim2.new(0, 200, 0, 150)
‎    Frame.Position = UDim2.new(0, 10, 0, 10)
‎    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
‎    Frame.Parent = ScreenGui
‎    
‎    local Title = Instance.new("TextLabel")
‎    Title.Text = "Auto Leviathan Script"
‎    Title.Size = UDim2.new(1, 0, 0, 30)
‎    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
‎    Title.TextColor3 = Color3.new(1, 1, 1)
‎    Title.Parent = Frame
‎    
‎    -- Toggle buttons
‎    local LeviathanToggle = Instance.new("TextButton")
‎    LeviathanToggle.Text = "Auto Leviathan: ON"
‎    LeviathanToggle.Size = UDim2.new(1, 0, 0, 30)
‎    LeviathanToggle.Position = UDim2.new(0, 0, 0, 40)
‎    LeviathanToggle.MouseButton1Click:Connect(function()
‎        Config.AutoLeviathan = not Config.AutoLeviathan
‎        LeviathanToggle.Text = "Auto Leviathan: " .. (Config.AutoLeviathan and "ON" or "OFF")
‎    end)
‎    LeviathanToggle.Parent = Frame
‎    
‎    local KitsuneToggle = Instance.new("TextButton")
‎    KitsuneToggle.Text = "M1 Kitsune: ON"
‎    KitsuneToggle.Size = UDim2.new(1, 0, 0, 30)
‎    KitsuneToggle.Position = UDim2.new(0, 0, 0, 80)
‎    KitsuneToggle.MouseButton1Click:Connect(function()
‎        Config.M1Kitsune = not Config.M1Kitsune
‎        KitsuneToggle.Text = "M1 Kitsune: " .. (Config.M1Kitsune and "ON" or "OFF")
‎    end)
‎    KitsuneToggle.Parent = Frame
‎end
‎
‎-- Initialize
‎CreateUI()
‎print("Blox Fruits Auto Leviathan & M1 Kitsune Script loaded!")
‎print("Features:")
‎print("- Auto Leviathan detection & attack")
‎print("- Enhanced M1 Kitsune combo system")
‎print("- Target priority system")
‎print("- Configurable settings via UI")
‎
‎-- Cleanup on script end
‎game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(newChar)
‎    Character = newChar
‎    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
‎end)
‎
‎-- Instructions for user
‎print("\nInstructions:")
‎print("1. The script automatically starts")
‎print("2. Use UI buttons to toggle features")
‎print("3. Ensure you have Kitsune fruit equipped")
‎print("4. Script will auto-target Leviathan when in range")
‎