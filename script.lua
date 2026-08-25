-- part 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("GrannyPremiumClean") then CoreGui["GrannyPremiumClean"]:Destroy() end

shared.CheatConfig = shared.CheatConfig or { 
    PlayersESP = false, 
    ThirdPerson = false, 
    AntiKillTrap = false, 
    Fly = false, 
    Noclip = false, 
    ItemsESP = false,
    GrannyESP = false
}

-- ========== ITEMS FOR AUTO ESCAPE ==========
_G.EscapeItems = {
    ["House1_Door"] = {"Master Key", "Padlock Key", "Hammer", "Cutting Pliers", "Screwdriver"},
    ["House1_Car"] = {"Gasoline can", "Car Key", "Car battery"},
    ["House2_Door"] = {"Door handle", "Crowbar", "Cutting pliers", "Padlock key", "Hand wheel"},
    ["House2_Boat"] = {"Boat key", "Padlock key", "Gasoline Can", "Boat Steering Wheel", "Spark Plug"},
    ["Mansion_Gate"] = {"Bridge Crank", "Fuse", "Generator Cable"},
    ["Mansion_Train"] = {"Ticket", "Train Key", "Accelerator"},
    ["School_Door"] = {"Master Key", "Padlock Key", "Hand wheel"},
    ["School_Bus"] = {"Bus Key", "Bus Steering Wheel", "Gallon"},
    ["Ski_Gate"] = {"Remote Control", "Code", "Padlock Key"},
    ["Ski_TeleSiege"] = {"Screwdriver", "Gear"},
    ["Cemetery_Gate"] = {"Gate Key"}
}

-- ========== CHAIN ITEMS ==========
_G.ChainItems = {
    ["House1"] = {
        {Target = "Padlock Key", Requires = {"Screwdriver"}},
        {Target = "Screwdriver", Requires = {"Safe Key"}},
        {Target = "Safe Key", Requires = {}},
        {Target = "Master Key", Requires = {"Playhouse Key"}},
        {Target = "Playhouse Key", Requires = {}}
    },
    ["House2"] = {
        {Target = "Door Handle", Requires = {"Security Key"}},
        {Target = "Cutting Pliers", Requires = {"Safe Key"}},
        {Target = "Safe Key", Requires = {}},
        {Target = "Security Key", Requires = {}},
        {Target = "Padlock Key", Requires = {}},
        {Target = "Hand Wheel", Requires = {}},
        {Target = "Gasoline Can", Requires = {}},
        {Target = "Crowbar", Requires = {}}
    },
    ["Mansion"] = {
        {Target = "Fuse", Requires = {"Coconut"}},
        {Target = "Coconut", Requires = {"Safe Key"}},
        {Target = "Safe Key", Requires = {}},
        {Target = "Generator Cable", Requires = {"Safe Key"}},
        {Target = "Bridge Crank", Requires = {}},
        {Target = "Ticket", Requires = {}},
        {Target = "Train Key", Requires = {}},
        {Target = "Accelerator", Requires = {}}
    },
    ["School"] = {
        {Target = "Security Key", Requires = {"Safe Key"}},
        {Target = "Safe Key", Requires = {}},
        {Target = "Hand Wheel", Requires = {}},
        {Target = "Padlock Key", Requires = {}},
        {Target = "Master Key", Requires = {}},
        {Target = "Bus Key", Requires = {}},
        {Target = "Bus Steering Wheel", Requires = {}},
        {Target = "Gallon", Requires = {}},
        {Target = "Cutting Pliers", Requires = {}},
        {Target = "Screwdriver", Requires = {}}
    },
    ["Ski"] = {
        {Target = "Remote Control", Requires = {"Safe Key"}},
        {Target = "Safe Key", Requires = {}},
        {Target = "Gear", Requires = {"Chest Key"}},
        {Target = "Chest Key", Requires = {}},
        {Target = "Code", Requires = {}},
        {Target = "Padlock Key", Requires = {}},
        {Target = "Screwdriver", Requires = {}}
    },
    ["Cemetery"] = {
        {Target = "Gate Key", Requires = {}},
        {Target = "Ruby", Requires = {}},
        {Target = "Emerald", Requires = {}},
        {Target = "Diamond", Requires = {}}
    }
}

-- ========== ITEM WHITELIST ==========
_G.ItemWhitelist = {
    "Key", "Padlock", "Hammer", "Cog", "Shotgun", "Weapon", "Gasoline", "Fuel",
    "Battery", "Spark", "Crank", "Book", "Teddy", "Plank", "Fuse", "Melon", "Crowbar",
    "Wrench", "Screwdriver", "Meat", "Winch handle","Valve", "Remote", "Card", "Code", 
    "Ticket", "Coin", "Tool", "Gun", "Ammo", "Ruby", "Diamond", "Emerald", "Plank",
    "Lock", "Box", "Crate", "Barrel", "Vase", "Pot", "Pan", "Knife", "Sword", "Axe",
    "Pickaxe", "Shovel", "Safe key", "Car battery", "Master Key", "Cutting Pliers",
    "Lock Code", "Car Key", "Gasoline Can", "Playhouse Key", "Door handle", "Hand wheel",
    "Boat key", "Boat Steering Wheel", "Spark Plug", "Security Key", "Bridge Crank",
    "Generator Cable", "Train Key", "Accelerator", "Coconut", "Bus Key", "Bus Steering Wheel",
    "Gallon", "Lock pick", "Remote Control", "Gear", "Chest Key", "Gate Key",
    "Engine Part", "Stun Gun", "Stun Gun Ammo", "Shotgun Ammo", "Crossbow",
    "Tranquilizer Dart", "Slingshot", "Stone", "Musket", "Firewood", "Matches",
    "Oil Can", "Silver Key", "Ball", "Shed Key", "Weapon Key", "Bird Seed"
}

_G.StructureBlacklist = {
    "Door", "Frame", "Wall", "Floor", "Ceiling", "Vent", "Slider", "Panel",
    "Window", "Gate", "Fence", "Roof", "Stair", "Step", "Railing", "Pillar",
    "Column", "Beam", "Girder", "Truss", "Scaffold", "Platform", "Ramp",
    "Elevator", "Ladder", "VentFrame", "WallPanel", "Frames", "Floor1", "Floor2",
    "Slider", "Hinge", "Drawer", "Cabinet", "Shelf", "Bookshelf"
}

local ItemCache = {}
local ItemCacheTime = 0

_G.isObjectAnItem = function(obj)
    if not obj or not obj.Parent then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    
    local id = obj:GetDebugId()
    if ItemCache[id] ~= nil and tick() - ItemCacheTime < 5 then
        return ItemCache[id]
    end
    
    local name = obj.Name
    for _, black in pairs(_G.StructureBlacklist) do
        if string.find(name, black) then
            ItemCache[id] = false
            return false
        end
    end
    for _, item in pairs(_G.ItemWhitelist) do
        if string.find(name, item) then
            ItemCache[id] = true
            return true
        end
    end
    ItemCache[id] = false
    return false
end

task.spawn(function()
    while task.wait(10) do
        ItemCache = {}
        ItemCacheTime = tick()
    end
end)

RunService.RenderStepped:Connect(function()
    if shared.CheatConfig.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 35
        LocalPlayer.CameraMinZoomDistance = 10
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = 85
        end
    end
end)

local function toggleThirdPerson(enable)
    pcall(function()
        if not enable then
            LocalPlayer.CameraMaxZoomDistance = 12
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end)
end

-- ========== GRANNY DETECTION ==========
local function isPlayerGranny(p)
    if not p.Character then return false end
    local nL = string.lower(p.Name)
    return string.find(nL, "granny") or 
           (p.Team and string.find(string.lower(p.Team.Name), "granny")) or 
           (p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").DisplayName == "Enemy")
end

local function getRandomAlly()
    local allies = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not isPlayerGranny(p) then
                table.insert(allies, p.Character.HumanoidRootPart)
            end
        end
    end
    return #allies > 0 and allies[math.random(1, #allies)] or nil
end

-- ================================================
-- PLAYER ESP
-- ================================================
local function applyPlayersESP(targetFrame, customName, isEnemy)
    if not targetFrame or not targetFrame.Parent then return end
    local espName = "UniversalWhiteESP"
    if not shared.CheatConfig.PlayersESP then
        if targetFrame:FindFirstChild(espName) then targetFrame[espName]:Destroy() end
        if targetFrame:FindFirstChild(espName.."Text") then targetFrame[espName.."Text"]:Destroy() end
        return
    end
    
    local espColor = isEnemy and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(40, 255, 100)
    local displayName = customName

    if not targetFrame:FindFirstChild(espName) then
        local hl = Instance.new("Highlight", targetFrame)
        hl.Name = espName
        hl.FillColor = espColor
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        pcall(function() 
            targetFrame[espName].FillColor = espColor
            targetFrame[espName].OutlineColor = Color3.fromRGB(255, 255, 255)
        end)
    end
    
    if not targetFrame:FindFirstChild(espName.."Text") then
        local bgui = Instance.new("BillboardGui", targetFrame)
        bgui.Name = espName.."Text"
        bgui.Size = UDim2.new(0, 160, 0, 30)
        bgui.AlwaysOnTop = true
        bgui.StudsOffset = Vector3.new(0, 3.5, 0)
        local label = Instance.new("TextLabel", bgui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = displayName
        label.TextColor3 = espColor
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 13
        label.Parent = bgui
        bgui.Parent = targetFrame
    else
        pcall(function() 
            targetFrame[espName.."Text"].TextLabel.Text = displayName 
            targetFrame[espName.."Text"].TextLabel.TextColor3 = espColor 
        end)
    end
end

-- Watch players (skip local)
local function watchPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if shared.CheatConfig.PlayersESP then
            local isEnemy = isPlayerGranny(p)
            applyPlayersESP(char, p.DisplayName or p.Name, isEnemy)
        end
    end)
end
for _, p in pairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then watchPlayer(p) end
end)

-- ================================================
-- GRANNY NPC ESP (shows "Bot")
-- ================================================
local function applyGrannyESP(obj)
    if not obj or not shared.CheatConfig.GrannyESP then
        if obj and obj:FindFirstChild("GrannyESP_Highlight") then obj["GrannyESP_Highlight"]:Destroy() end
        if obj and obj:FindFirstChild("GrannyESP_Text") then obj["GrannyESP_Text"]:Destroy() end
        return
    end
    
    if not obj:FindFirstChild("GrannyESP_Highlight") then
        local hl = Instance.new("Highlight", obj)
        hl.Name = "GrannyESP_Highlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
    if not obj:FindFirstChild("GrannyESP_Text") then
        local bgui = Instance.new("BillboardGui", obj)
        bgui.Name = "GrannyESP_Text"
        bgui.Size = UDim2.new(0, 120, 0, 30)
        bgui.StudsOffset = Vector3.new(0, 3.5, 0)
        bgui.AlwaysOnTop = true
        local label = Instance.new("TextLabel", bgui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Bot"
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Parent = bgui
        bgui.Parent = obj
    end
end

local function removeGrannyESP(obj)
    if obj:FindFirstChild("GrannyESP_Highlight") then obj["GrannyESP_Highlight"]:Destroy() end
    if obj:FindFirstChild("GrannyESP_Text") then obj["GrannyESP_Text"]:Destroy() end
end

-- ================================================
-- ITEM ESP
-- ================================================
local function applyItemESP(obj)
    if not obj then return end
    if obj:IsDescendantOf(LocalPlayer.Character) then return end
    
    local hl = obj:FindFirstChild("UniversalWhiteItemESP")
    if not hl then
        hl = Instance.new("Highlight", obj)
        hl.Name = "UniversalWhiteItemESP"
        hl.FillColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.25
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
    local bgui = obj:FindFirstChild("UniversalWhiteItemESPText")
    if not bgui then
        local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if targetPart then
            bgui = Instance.new("BillboardGui", targetPart)
            bgui.Name = "UniversalWhiteItemESPText"
            bgui.Size = UDim2.new(0, 150, 0, 30)
            bgui.StudsOffset = Vector3.new(0, 2.5, 0)
            bgui.AlwaysOnTop = true
            local label = Instance.new("TextLabel", bgui)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = obj.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 12
            label.Parent = bgui
            bgui.Parent = targetPart
        end
    end
end

local function removeItemESP(obj)
    if obj:FindFirstChild("UniversalWhiteItemESP") then obj["UniversalWhiteItemESP"]:Destroy() end
    if obj:FindFirstChild("UniversalWhiteItemESPText") then obj["UniversalWhiteItemESPText"]:Destroy() end
    for _, part in pairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then
            local bg = part:FindFirstChild("UniversalWhiteItemESPText")
            if bg then bg:Destroy() end
        end
    end
end

-- ================================================
-- AUTO ESCAPE FUNCTIONS
-- ================================================
local function teleportChainItems(locationKey)
    local char = LocalPlayer.Character
    if not char then return 0, {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0, {} end
    
    local chain = _G.ChainItems[locationKey]
    if not chain then return 0, {} end
    
    local teleported = {}
    local totalFound = 0
    
    for _, step in pairs(chain) do
        if #step.Requires == 0 then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    if string.find(obj.Name, step.Target) then
                        local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or obj
                        if targetPart and not obj:IsDescendantOf(char) then
                            targetPart.CFrame = hrp.CFrame + Vector3.new(0, 1.5, 0)
                            totalFound = totalFound + 1
                            table.insert(teleported, step.Target)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
    
    local maxIterations = 10
    local iteration = 0
    while #teleported < #chain and iteration < maxIterations do
        iteration = iteration + 1
        for _, step in pairs(chain) do
            if #step.Requires > 0 then
                local canGet = true
                for _, req in pairs(step.Requires) do
                    if not table.find(teleported, req) then
                        canGet = false
                        break
                    end
                end
                if canGet and not table.find(teleported, step.Target) then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") or obj:IsA("BasePart") then
                            if string.find(obj.Name, step.Target) then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or obj
                                if targetPart and not obj:IsDescendantOf(char) then
                                    targetPart.CFrame = hrp.CFrame + Vector3.new(0, 1.5, 0)
                                    totalFound = totalFound + 1
                                    table.insert(teleported, step.Target)
                                    task.wait(0.05)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return totalFound, teleported
end

local function teleportEscapeItems(locationKey)
    local char = LocalPlayer.Character
    if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    
    local itemList = _G.EscapeItems[locationKey]
    if not itemList then return 0 end
    
    local allFound = {}
    local totalFound = 0
    
    local locationName = locationKey:match("(.*)_")
    
    if locationName and _G.ChainItems[locationName] then
        local chainFound, chainItems = teleportChainItems(locationName)
        totalFound = totalFound + chainFound
        for _, item in pairs(chainItems) do
            table.insert(allFound, item)
        end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, itemName in pairs(itemList) do
                if string.find(obj.Name, itemName) then
                    local alreadyFound = false
                    for _, found in pairs(allFound) do
                        if found == itemName then
                            alreadyFound = true
                            break
                        end
                    end
                    if not alreadyFound then
                        local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or obj
                        if targetPart and not obj:IsDescendantOf(char) then
                            targetPart.CFrame = hrp.CFrame + Vector3.new(0, 1.5, 0)
                            totalFound = totalFound + 1
                            table.insert(allFound, itemName)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
    
    return totalFound
end

-- ================================================
-- SCAN LOOP
-- ================================================
task.spawn(function()
    while task.wait(2) do
        if not shared.CheatConfig.PlayersESP and not shared.CheatConfig.ItemsESP and not shared.CheatConfig.GrannyESP then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    if obj:FindFirstChild("UniversalWhiteESP") then obj["UniversalWhiteESP"]:Destroy() end
                    if obj:FindFirstChild("UniversalWhiteESPText") then obj["UniversalWhiteESPText"]:Destroy() end
                    removeItemESP(obj)
                    removeGrannyESP(obj)
                end
            end
            continue
        end
        
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    local player = Players:GetPlayerFromCharacter(obj)
                    if player and player ~= LocalPlayer then
                        if shared.CheatConfig.PlayersESP then
                            local isEnemy = isPlayerGranny(player)
                            applyPlayersESP(obj, player.DisplayName or player.Name, isEnemy)
                        else
                            if obj:FindFirstChild("UniversalWhiteESP") then obj["UniversalWhiteESP"]:Destroy() end
                            if obj:FindFirstChild("UniversalWhiteESPText") then obj["UniversalWhiteESPText"]:Destroy() end
                        end
                        removeItemESP(obj)
                        removeGrannyESP(obj)
                        continue
                    end
                    
                    local nameLower = string.lower(obj.Name)
                    local isGrannyNPC = string.find(nameLower, "granny") or string.find(nameLower, "enemy") or string.find(nameLower, "grandpa")
                    if isGrannyNPC and not Players:GetPlayerFromCharacter(obj) then
                        if shared.CheatConfig.GrannyESP then
                            applyGrannyESP(obj)
                        else
                            removeGrannyESP(obj)
                        end
                        removeItemESP(obj)
                        continue
                    end
                    
                    if shared.CheatConfig.ItemsESP and _G.isObjectAnItem(obj) then
                        applyItemESP(obj)
                    else
                        removeItemESP(obj)
                    end
                    
                    if not isGrannyNPC then
                        removeGrannyESP(obj)
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if shared.CheatConfig.AntiKillTrap and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local needToTeleport = false
                local trapsFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Traps")
                if trapsFolder then
                    for _, trap in pairs(trapsFolder:GetChildren()) do
                        if trap:IsA("Model") or trap:IsA("BasePart") then
                            local trapPart = trap:IsA("Model") and trap:FindFirstChildWhichIsA("BasePart", true) or trap
                            if trapPart and (myRoot.Position - trapPart.Position).Magnitude < 8 then needToTeleport = true break end
                        end
                    end
                end
                if not needToTeleport then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChildOfClass("Humanoid") then
                            if not Players:GetPlayerFromCharacter(obj) and (myRoot.Position - obj.HumanoidRootPart.Position).Magnitude < 15 then needToTeleport = true break end
                        end
                    end
                end
                if needToTeleport then
                    local targetAlly = getRandomAlly()
                    if targetAlly then myRoot.CFrame = targetAlly.CFrame + Vector3.new(0, 3, 0) 
                    else 
                        local spawnLoc = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
                        myRoot.CFrame = spawnLoc and (spawnLoc.CFrame + Vector3.new(0, 3, 0)) or (myRoot.CFrame * CFrame.new(math.random(1) == 1 and 60 or -60, 0, math.random(1) == 1 and 60 or -60))
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
end)

-- ================================================
-- GUI
-- ================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "GrannyPremiumClean", false
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name, MainFrame.BackgroundColor3, MainFrame.Position, MainFrame.Size, MainFrame.Active = "MainFrame", Color3.fromRGB(25, 25, 30), UDim2.new(0.05, 0, 0.3, 0), UDim2.new(0, 260, 0, 350), true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local function createTab(name, text, posX)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Name, btn.Text, btn.Position, btn.Size, btn.BackgroundColor3, btn.Font, btn.TextColor3, btn.TextSize = name, text, UDim2.new(posX, 0, 0.03, 0), UDim2.new(0.29, 0, 0, 35), Color3.fromRGB(35, 35, 40), Enum.Font.SourceSansBold, Color3.fromRGB(200, 200, 200), 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) return btn
end
local PlayerTabBtn = createTab("PlayerTabBtn", "PLAYER", 0.04)
local GrannyTabBtn = createTab("GrannyTabBtn", "GRANNY", 0.35)
local VisualsTabBtn = createTab("VisualsTabBtn", "VISUALS", 0.66)

local SubNavFrame = Instance.new("Frame", MainFrame)
SubNavFrame.Name, SubNavFrame.BackgroundTransparency, SubNavFrame.Position, SubNavFrame.Size = "SubNavFrame", 1, UDim2.new(0.05, 0, 0.15, 0), UDim2.new(0.9, 0, 0, 30)
local ItemsSubBtn = Instance.new("TextButton", SubNavFrame)
ItemsSubBtn.Size, ItemsSubBtn.BackgroundColor3, ItemsSubBtn.Font, ItemsSubBtn.Text, ItemsSubBtn.TextColor3, ItemsSubBtn.TextSize = UDim2.new(0.48, 0, 1, 0), Color3.fromRGB(45, 45, 50), Enum.Font.SourceSansBold, "ITEMS", Color3.fromRGB(255, 60, 60), 12
Instance.new("UICorner", ItemsSubBtn).CornerRadius = UDim.new(0, 5)
local EscapesSubBtn = Instance.new("TextButton", SubNavFrame)
EscapesSubBtn.Position, EscapesSubBtn.Size, EscapesSubBtn.BackgroundColor3, EscapesSubBtn.Font, EscapesSubBtn.Text, EscapesSubBtn.TextColor3, EscapesSubBtn.TextSize = UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0), Color3.fromRGB(35, 35, 40), Enum.Font.SourceSansBold, "MOVEMENT", Color3.fromRGB(200, 200, 200), 12
Instance.new("UICorner", EscapesSubBtn).CornerRadius = UDim.new(0, 5)

local vAK = Instance.new("TextButton", MainFrame)
vAK.Name, vAK.Size, vAK.Position, vAK.BackgroundColor3, vAK.Text, vAK.TextColor3, vAK.Font, vAK.TextSize = "AntiKillBtn", UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0.26, 0), shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60), shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF", Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 13
Instance.new("UICorner", vAK).CornerRadius = UDim.new(0, 5)
vAK.MouseButton1Click:Connect(function() 
    shared.CheatConfig.AntiKillTrap = not shared.CheatConfig.AntiKillTrap 
    vAK.BackgroundColor3 = shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60) 
    vAK.Text = shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF" 
end)

-- ========== AUTO ESCAPE BUTTON ==========
local AutoEscapeMainBtn = Instance.new("TextButton", MainFrame)
AutoEscapeMainBtn.Name = "AutoEscapeMainBtn"
AutoEscapeMainBtn.Size = UDim2.new(0.9, 0, 0, 35)
AutoEscapeMainBtn.Position = UDim2.new(0.05, 0, 0.34, 0)
AutoEscapeMainBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
AutoEscapeMainBtn.Font = Enum.Font.SourceSansBold
AutoEscapeMainBtn.Text = "Auto Escape"
AutoEscapeMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoEscapeMainBtn.TextSize = 14
Instance.new("UICorner", AutoEscapeMainBtn).CornerRadius = UDim.new(0, 5)

local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Name, SearchBox.Size, SearchBox.Position, SearchBox.BackgroundColor3, SearchBox.TextColor3, SearchBox.TextSize, SearchBox.Font, SearchBox.PlaceholderText, SearchBox.Text = "SearchBox", UDim2.new(0.9, 0, 0, 25), UDim2.new(0.05, 0, 0.38, 0), Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255), 12, Enum.Font.SourceSans, "Type item name here...", ""
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 5)

local MoveControlsFrame = Instance.new("Frame", MainFrame)
MoveControlsFrame.Name = "MoveControlsFrame"
MoveControlsFrame.BackgroundTransparency = 1
MoveControlsFrame.Position = UDim2.new(0.05, 0, 0.38, 0)
MoveControlsFrame.Size = UDim2.new(0.9, 0, 0, 40)

local FlyBtn = Instance.new("TextButton", MoveControlsFrame)
FlyBtn.Name = "FlyBtn"
FlyBtn.Size = UDim2.new(0.48, 0, 1, 0)
FlyBtn.Position = UDim2.new(0, 0, 0, 0)
FlyBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
FlyBtn.Font = Enum.Font.SourceSansBold
FlyBtn.Text = "Fly: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.TextSize = 13
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 5)

local NoclipBtn = Instance.new("TextButton", MoveControlsFrame)
NoclipBtn.Name = "NoclipBtn"
NoclipBtn.Size = UDim2.new(0.48, 0, 1, 0)
NoclipBtn.Position = UDim2.new(0.52, 0, 0, 0)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
NoclipBtn.Font = Enum.Font.SourceSansBold
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipBtn.TextSize = 13
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 5)

local SF = Instance.new("ScrollingFrame", MainFrame)
SF.BackgroundTransparency, SF.ScrollBarThickness = 1, 6
local LY = Instance.new("UIListLayout", SF)
LY.SortOrder, LY.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
local RB = Instance.new("TextButton", MainFrame)
RB.BackgroundColor3, RB.Position, RB.Size, RB.Font, RB.Text, RB.TextColor3, RB.TextSize = Color3.fromRGB(255, 60, 60), UDim2.new(0.05, 0, 0.86, 0), UDim2.new(0.9, 0, 0, 35), Enum.Font.SourceSansBold, "REFRESH LIST", Color3.fromRGB(255, 255, 255), 14
Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)

-- ================================================
-- AUTO ESCAPE SUB-MENU (STYLE LIKE REST OF MENU)
-- ================================================
local AutoEscapeSubMenu = {}

function AutoEscapeSubMenu:Show()
    local Backdrop = Instance.new("Frame", ScreenGui)
    Backdrop.Name = "AutoEscapeBackdrop"
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Backdrop.BackgroundTransparency = 0.5
    Backdrop.ZIndex = 10

    local SubFrame = Instance.new("Frame", Backdrop)
    SubFrame.Name = "AutoEscapeFrame"
    SubFrame.Size = UDim2.new(0, 280, 0, 340)
    SubFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
    SubFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SubFrame.BorderSizePixel = 0
    SubFrame.ZIndex = 11
    Instance.new("UICorner", SubFrame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", SubFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Auto Escape"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.ZIndex = 12

    local CloseBtn = Instance.new("TextButton", SubFrame)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 16
    CloseBtn.ZIndex = 12
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
    CloseBtn.MouseButton1Click:Connect(function()
        Backdrop:Destroy()
    end)

    local Scroll = Instance.new("ScrollingFrame", SubFrame)
    Scroll.Size = UDim2.new(0.95, 0, 0, 250)
    Scroll.Position = UDim2.new(0.025, 0, 0.15, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ZIndex = 12

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)

    local function createLocationButton(parent, text, routes)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 15
        btn.ZIndex = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            local RouteBackdrop = Instance.new("Frame", Backdrop)
            RouteBackdrop.Name = "RouteBackdrop"
            RouteBackdrop.Size = UDim2.new(1, 0, 1, 0)
            RouteBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            RouteBackdrop.BackgroundTransparency = 0.3
            RouteBackdrop.ZIndex = 20

            local RouteFrame = Instance.new("Frame", RouteBackdrop)
            RouteFrame.Size = UDim2.new(0, 240, 0, 150)
            RouteFrame.Position = UDim2.new(0.5, -120, 0.5, -75)
            RouteFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            RouteFrame.BorderSizePixel = 0
            RouteFrame.ZIndex = 21
            Instance.new("UICorner", RouteFrame).CornerRadius = UDim.new(0, 10)

            local RouteTitle = Instance.new("TextLabel", RouteFrame)
            RouteTitle.Size = UDim2.new(1, 0, 0, 35)
            RouteTitle.Position = UDim2.new(0, 0, 0, 5)
            RouteTitle.BackgroundTransparency = 1
            RouteTitle.Text = text
            RouteTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            RouteTitle.Font = Enum.Font.GothamBold
            RouteTitle.TextSize = 18
            RouteTitle.ZIndex = 22

            local RouteClose = Instance.new("TextButton", RouteFrame)
            RouteClose.Size = UDim2.new(0, 30, 0, 30)
            RouteClose.Position = UDim2.new(1, -35, 0, 5)
            RouteClose.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            RouteClose.Text = "X"
            RouteClose.TextColor3 = Color3.fromRGB(255, 255, 255)
            RouteClose.Font = Enum.Font.SourceSansBold
            RouteClose.TextSize = 16
            RouteClose.ZIndex = 22
            Instance.new("UICorner", RouteClose).CornerRadius = UDim.new(0, 5)
            RouteClose.MouseButton1Click:Connect(function()
                RouteBackdrop:Destroy()
            end)

            local RouteScroll = Instance.new("ScrollingFrame", RouteFrame)
            RouteScroll.Size = UDim2.new(0.95, 0, 0, 70)
            RouteScroll.Position = UDim2.new(0.025, 0, 0.15, 0)
            RouteScroll.BackgroundTransparency = 1
            RouteScroll.ScrollBarThickness = 4
            RouteScroll.ZIndex = 22

            local RouteLayout = Instance.new("UIListLayout", RouteScroll)
            RouteLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RouteLayout.Padding = UDim.new(0, 5)

            for _, route in pairs(routes) do
                local rbtn = Instance.new("TextButton", RouteScroll)
                rbtn.Size = UDim2.new(1, 0, 0, 30)
                rbtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                rbtn.Text = route.text
                rbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                rbtn.Font = Enum.Font.SourceSansBold
                rbtn.TextSize = 13
                rbtn.ZIndex = 23
                Instance.new("UICorner", rbtn).CornerRadius = UDim.new(0, 5)

                rbtn.MouseButton1Click:Connect(function()
                    local count = teleportEscapeItems(route.key)
                    local msg = count > 0 and string.format("Items teleported: %d", count) or "No items found!"
                    print(string.format("[Auto Escape] %s: %s", route.text, msg))

                    local notif = Instance.new("TextLabel", RouteFrame)
                    notif.Size = UDim2.new(0.9, 0, 0, 30)
                    notif.Position = UDim2.new(0.05, 0, 0.85, 0)
                    notif.BackgroundColor3 = count > 0 and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
                    notif.Text = count > 0 and "Items teleported!" or "No items found!"
                    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
                    notif.Font = Enum.Font.SourceSansBold
                    notif.TextSize = 14
                    notif.ZIndex = 23
                    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 5)
                    task.wait(2)
                    notif:Destroy()

                    if count > 0 then
                        task.wait(0.5)
                        RouteBackdrop:Destroy()
                        Backdrop:Destroy()
                    end
                end)
            end
        end)
        return btn
    end

    local locations = {
        {name = "House 1", routes = {{text = "Door", key = "House1_Door"}, {text = "Car", key = "House1_Car"}}},
        {name = "House 2", routes = {{text = "Door", key = "House2_Door"}, {text = "Boat", key = "House2_Boat"}}},
        {name = "Mansion", routes = {{text = "Gate", key = "Mansion_Gate"}, {text = "Train", key = "Mansion_Train"}}},
        {name = "School", routes = {{text = "Door", key = "School_Door"}, {text = "Bus", key = "School_Bus"}}},
        {name = "Ski Resort", routes = {{text = "Gate", key = "Ski_Gate"}, {text = "TeleSiege", key = "Ski_TeleSiege"}}},
        {name = "Cemetery", routes = {{text = "Gate", key = "Cemetery_Gate"}}}
    }

    for _, loc in pairs(locations) do
        createLocationButton(Scroll, loc.name, loc.routes)
    end

    local CloseBottom = Instance.new("TextButton", SubFrame)
    CloseBottom.Size = UDim2.new(0.8, 0, 0, 30)
    CloseBottom.Position = UDim2.new(0.1, 0, 0.92, 0)
    CloseBottom.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    CloseBottom.Text = "Close"
    CloseBottom.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBottom.Font = Enum.Font.SourceSansBold
    CloseBottom.TextSize = 14
    CloseBottom.ZIndex = 13
    Instance.new("UICorner", CloseBottom).CornerRadius = UDim.new(0, 5)
    CloseBottom.MouseButton1Click:Connect(function()
        Backdrop:Destroy()
    end)
end

AutoEscapeMainBtn.MouseButton1Click:Connect(function()
    AutoEscapeSubMenu:Show()
end)

local function setupTabClicks(PlayerBtn, GrannyBtn, VisualsBtn, ItemsBtn, EscBtn)
    PlayerBtn.MouseButton1Click:Connect(function() _G.cM = "Player" _G.updateMenuDisplay() end)
    GrannyBtn.MouseButton1Click:Connect(function() _G.cM = "Granny" _G.updateMenuDisplay() end)
    VisualsBtn.MouseButton1Click:Connect(function() _G.cM = "Visuals" _G.updateMenuDisplay() end)
    ItemsBtn.MouseButton1Click:Connect(function() _G.cS = "Items" ItemsBtn.TextColor3, ItemsBtn.BackgroundColor3, EscBtn.TextColor3, EscBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) _G.updateMenuDisplay() end)
    EscBtn.MouseButton1Click:Connect(function() _G.cS = "Movement" EscBtn.TextColor3, EscBtn.BackgroundColor3, ItemsBtn.TextColor3, ItemsBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) _G.updateMenuDisplay() end)
end

_G.updateMenuDisplay = function()
    for _, child in pairs(SF:GetChildren()) do if child:IsA("TextButton") or child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end end
    local ad, te = {}, 0
    PlayerTabBtn.BackgroundColor3, PlayerTabBtn.TextColor3 = (_G.cM == "Player") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Player") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    GrannyTabBtn.BackgroundColor3, GrannyTabBtn.TextColor3 = (_G.cM == "Granny") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Granny") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    VisualsTabBtn.BackgroundColor3, VisualsTabBtn.TextColor3 = (_G.cM == "Visuals") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Visuals") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    
    if _G.cM == "Visuals" then
        SubNavFrame.Visible, SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible, SF.Position, SF.Size = false, false, false, false, true, UDim2.new(0.05, 0, 0.15, 0), UDim2.new(0.9, 0, 0, 235)
        local function makeVis(t, s, cb)
            local v = Instance.new("TextButton", SF) v.Size, v.BackgroundColor3, v.Font, v.Text, v.TextColor3, v.TextSize = UDim2.new(1, 0, 0, 35), s and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), Enum.Font.SourceSansBold, t, Color3.fromRGB(255, 255, 255), 13
            Instance.new("UICorner", v).CornerRadius = UDim.new(0, 5) v.MouseButton1Click:Connect(cb)
        end
        makeVis(shared.CheatConfig.PlayersESP and "ESP Players: ON" or "ESP Players: OFF", shared.CheatConfig.PlayersESP, function() shared.CheatConfig.PlayersESP = not shared.CheatConfig.PlayersESP _G.updateMenuDisplay() end)
        makeVis(shared.CheatConfig.ItemsESP and "ESP Items: ON" or "ESP Items: OFF", shared.CheatConfig.ItemsESP, function() shared.CheatConfig.ItemsESP = not shared.CheatConfig.ItemsESP _G.updateMenuDisplay() end)
        makeVis(shared.CheatConfig.GrannyESP and "ESP Granny: ON" or "ESP Granny: OFF", shared.CheatConfig.GrannyESP, function() shared.CheatConfig.GrannyESP = not shared.CheatConfig.GrannyESP _G.updateMenuDisplay() end)
        makeVis(shared.CheatConfig.ThirdPerson and "3rd Person Camera: ON" or "3rd Person Camera: OFF", shared.CheatConfig.ThirdPerson, function() shared.CheatConfig.ThirdPerson = not shared.CheatConfig.ThirdPerson toggleThirdPerson(shared.CheatConfig.ThirdPerson) _G.updateMenuDisplay() end)
        SF.CanvasSize = UDim2.new(0, 0, 0, 160) return
    elseif _G.cM == "Granny" then
        SubNavFrame.Visible, SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible, SF.Position, SF.Size = false, false, false, false, true, UDim2.new(0.05, 0, 0.15, 0), UDim2.new(0.9, 0, 0, 235)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                te = te + 1 local eB = Instance.new("TextButton", SF) eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. p.Name, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4) eB.MouseButton1Click:Connect(function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0) end) end)
            end
        end
        SF.CanvasSize = UDim2.new(0, 0, 0, te * 38) return
    elseif _G.cM == "Player" then
        SubNavFrame.Visible = true
        if _G.cS == "Movement" then 
            SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible = false, true, true, false
        else
            SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible = true, true, false, true
            SF.Position, SF.Size = UDim2.new(0.05, 0, 0.49, 0), UDim2.new(0.9, 0, 0, 115)
            local currentQuery = string.lower(_G.SearchQuery)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent and not obj:IsDescendantOf(LocalPlayer.Character) then
                    if Players:GetPlayerFromCharacter(obj) then continue end
                    if _G.isObjectAnItem(obj) then
                        local current = obj
                        while current.Parent and current.Parent ~= Workspace and current.Parent:IsA("Model") do
                            current = current.Parent
                        end
                        local customButtonName = current.Name
                        local nameLower = string.lower(customButtonName)
                        if currentQuery == "" or string.find(nameLower, currentQuery) then
                            if not ad[customButtonName] then
                                ad[customButtonName] = true te = te + 1
                                local eB = Instance.new("TextButton", SF) eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. customButtonName, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                                Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                                eB.MouseButton1Click:Connect(function()
                                    pcall(function()
                                        local targetPart = current:IsA("Model") and (current.PrimaryPart or current:FindFirstChildWhichIsA("BasePart", true))
                                        if targetPart then
                                            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3.5, 0)
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                end
            end
            if te == 0 and currentQuery ~= "" then
                local label = Instance.new("TextLabel", SF) label.Size = UDim2.new(1, 0, 0, 30) label.BackgroundTransparency = 1
                label.Text = "No items found for '" .. _G.SearchQuery .. "'"
                label.TextColor3 = Color3.fromRGB(255, 60, 60) label.Font = Enum.Font.SourceSansBold label.TextSize = 12 label.Parent = SF te = 1
            end
            SF.CanvasSize = UDim2.new(0, 0, 0, te * 38)
        end
    end
end

MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = MainFrame.Position i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
MainFrame.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragInput = i end end)
UserInputService.InputChanged:Connect(function(i) if i == dragInput and dragging then local delta = i.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

-- ================================================
-- part 6 - FLY (PERFECT CENTER + FREEZE)
-- ================================================
local flySpeed = 30
local flyConnection = nil

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if shared.CheatConfig.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 35
        LocalPlayer.CameraMinZoomDistance = 10
    end

    hum.PlatformStand = true
    hum.AutoRotate = false
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.HipHeight = 0
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    Workspace.Gravity = 0

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not shared.CheatConfig.Fly then
            flyConnection:Disconnect()
            flyConnection = nil
            return
        end

        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        local currentHum = currentChar:FindFirstChildOfClass("Humanoid")
        if not currentHrp or not currentHum then return end

        currentHum.PlatformStand = true
        currentHum.AutoRotate = false
        currentHum.WalkSpeed = 0
        currentHum.JumpPower = 0
        currentHum.HipHeight = 0
        currentHum:ChangeState(Enum.HumanoidStateType.Physics)
        Workspace.Gravity = 0

        local cam = Workspace.CurrentCamera
        local lookVec = cam.CFrame.LookVector
        local rightVec = cam.CFrame.RightVector
        local vel = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - rightVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + rightVec end

        if vel.Magnitude > 0 then
            currentHrp.Velocity = vel.Unit * flySpeed
        else
            currentHrp.Velocity = Vector3.new(0, 0, 0)
            currentHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end

        local lookDir = lookVec
        if lookDir.Magnitude > 0 then
            currentHrp.CFrame = CFrame.lookAt(currentHrp.Position, currentHrp.Position + lookDir, Vector3.new(0, 1, 0))
        end
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.HipHeight = 2
            hum:ChangeState(Enum.HumanoidStateType.Running)
            Workspace.Gravity = 196.2
        end
    end
end

local function toggleFly()
    if shared.CheatConfig.Fly then
        startFly()
    else
        stopFly()
    end
end

setmetatable(shared.CheatConfig, {
    __newindex = function(t, k, v)
        rawset(t, k, v)
        if k == "Fly" then
            if v then startFly() else stopFly() end
        end
    end
})

RunService.Stepped:Connect(function()
    if shared.CheatConfig.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function() _G.SearchQuery = SearchBox.Text _G.updateMenuDisplay() end)
setupTabClicks(PlayerTabBtn, GrannyTabBtn, VisualsTabBtn, ItemsSubBtn, EscapesSubBtn)

FlyBtn.MouseButton1Click:Connect(function()
    shared.CheatConfig.Fly = not shared.CheatConfig.Fly
    FlyBtn.BackgroundColor3 = shared.CheatConfig.Fly and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60)
    FlyBtn.Text = shared.CheatConfig.Fly and "Fly: ON" or "Fly: OFF"
    toggleFly()
end)

NoclipBtn.MouseButton1Click:Connect(function()
    shared.CheatConfig.Noclip = not shared.CheatConfig.Noclip
    NoclipBtn.BackgroundColor3 = shared.CheatConfig.Noclip and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60)
    NoclipBtn.Text = shared.CheatConfig.Noclip and "Noclip: ON" or "Noclip: OFF"
end)

RB.MouseButton1Click:Connect(_G.updateMenuDisplay)
_G.updateMenuDisplay()
