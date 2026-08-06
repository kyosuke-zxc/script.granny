-- part 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("GrannyPremiumClean") then CoreGui["GrannyPremiumClean"]:Destroy() end

shared.CheatConfig = shared.CheatConfig or { PlayersESP = false, ThirdPerson = false, AntiKillTrap = false, Fly = false, Noclip = false }

-- ЖЕСТКИЙ ЦИКЛ ДЛЯ 3RD PERSON
RunService.RenderStepped:Connect(function()
    if shared.CheatConfig.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 150
        if LocalPlayer.CameraMinZoomDistance < 5 then LocalPlayer.CameraMinZoomDistance = 5 end
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

local function getRandomAlly()
    local allies = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local nL = string.lower(p.Name)
            local isGranny = string.find(nL, "granny") or (p.Team and string.find(string.lower(p.Team.Name), "granny")) or (p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").DisplayName == "Enemy")
            if not isGranny then table.insert(allies, p.Character.HumanoidRootPart) end
        end
    end
    return #allies > 0 and allies[math.random(1, #allies)] or nil
end

local function applyPlayersESP(targetFrame, customName)
    if not targetFrame or not targetFrame.Parent then return end
    local espName = "UniversalRedESP"
    if not shared.CheatConfig.PlayersESP then
        if targetFrame:FindFirstChild(espName) then targetFrame[espName]:Destroy() end
        if targetFrame:FindFirstChild(espName.."Text") then targetFrame[espName.."Text"]:Destroy() end
        return
    end
    if not targetFrame:FindFirstChild(espName) then
        local hl = Instance.new("Highlight", targetFrame)
        hl.Name = espName
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
    if not targetFrame:FindFirstChild(espName.."Text") then
        local bgui = Instance.new("BillboardGui", targetFrame)
        bgui.Name = espName.."Text"
        bgui.Size = UDim2.new(0, 150, 0, 40)
        bgui.AlwaysOnTop = true
        bgui.StudsOffset = Vector3.new(0, 3, 0)
        local label = Instance.new("TextLabel", bgui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = customName or targetFrame.Name
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
    else
        pcall(function() targetFrame[espName.."Text"].TextLabel.Text = customName or targetFrame.Name end)
    end
end

local function watchPlayer(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if shared.CheatConfig.PlayersESP then applyPlayersESP(char, p.DisplayName or p.Name) end
    end)
end
for _, p in pairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)

task.spawn(function()
    while task.wait(1.5) do
        if shared.CheatConfig.PlayersESP then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                        local player = Players:GetPlayerFromCharacter(obj)
                        applyPlayersESP(obj, player and (player.DisplayName or player.Name) or "Bot")
                    end
                end
            end)
        end
    end
end)
-- part 2
local function applyPlayersESP(targetFrame, customName)
    if not targetFrame or not targetFrame.Parent then return end
    local espName = "UniversalWhiteESP"
    if not shared.CheatConfig.PlayersESP then
        if targetFrame:FindFirstChild(espName) then targetFrame[espName]:Destroy() end
        if targetFrame:FindFirstChild(espName.."Text") then targetFrame[espName.."Text"]:Destroy() end
        return
    end
    
    -- УМНЫЙ ДЕТЕКТ МАНЬЯКА ИЗ НОВОГО СКРИПТА
    local isKiller = targetFrame:FindFirstChild("Hitbox") ~= nil or string.find(string.lower(customName), "bot") or string.find(string.lower(targetFrame.Name), "granny")
    local espColor = isKiller and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 255, 255)
    local displayName = isKiller and (customName .. " [KILLER]") or customName

    if not targetFrame:FindFirstChild(espName) then
        local hl = Instance.new("Highlight", targetFrame)
        hl.Name = espName
        hl.FillColor = espColor
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    else
        pcall(function() targetFrame[espName].FillColor = espColor end)
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
    else
        pcall(function() targetFrame[espName.."Text"].TextLabel.Text = displayName targetFrame[espName.."Text"].TextLabel.TextColor3 = espColor end)
    end
end

local function watchPlayer(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if shared.CheatConfig.PlayersESP then applyPlayersESP(char, p.DisplayName or p.Name) end
    end)
end
for _, p in pairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)

-- ПОСТОЯННЫЙ ДИНАМИЧЕСКИЙ ЦИКЛ ОБНОВЛЕНИЯ ИГРОКОВ И ПРЕДМЕТОВ (БЕЗ ЛАГОВ)
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    -- 1. Рендерим игроков и ботов
                    if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                        if shared.CheatConfig.PlayersESP then
                            local player = Players:GetPlayerFromCharacter(obj)
                            applyPlayersESP(obj, player and (player.DisplayName or player.Name) or "Bot")
                        else
                            if obj:FindFirstChild("UniversalWhiteESP") then obj["UniversalWhiteESP"]:Destroy() end
                            if obj:FindFirstChild("UniversalWhiteESPText") then obj["UniversalWhiteESPText"]:Destroy() end
                        end
                    end
                    
                    -- 2. ИНТЕГРИРОВАННЫЙ БЕЛОЙ TEXT-ESP НА ПРЕДМЕТЫ С САЙТА
                    if _G.isObjectAnItem and _G.isObjectAnItem(obj) then
                        if shared.CheatConfig.ItemsESP then
                            local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                            if targetPart then
                                if not obj:FindFirstChild("UniversalWhiteItemESP") then
                                    local hl = Instance.new("Highlight", obj)
                                    hl.Name = "UniversalWhiteItemESP"
                                    hl.FillColor = Color3.fromRGB(255, 255, 255)
                                    hl.FillTransparency = 0.5
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    
                                    local bgui = Instance.new("BillboardGui", targetPart)
                                    bgui.Name = "UniversalWhiteItemESPText"
                                    bgui.Size = UDim2.new(0, 120, 0, 25)
                                    bgui.StudsOffset = Vector3.new(0, 2, 0)
                                    bgui.AlwaysOnTop = true
                                    local label = Instance.new("TextLabel", bgui)
                                    label.Size = UDim2.new(1, 0, 1, 0)
                                    label.BackgroundTransparency = 1
                                    label.Text = obj.Name
                                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    label.TextStrokeTransparency = 0
                                    label.Font = Enum.Font.SourceSansBold
                                    label.TextSize = 11
                                end
                            end
                        else
                            if obj:FindFirstChild("UniversalWhiteItemESP") then obj["UniversalWhiteItemESP"]:Destroy() end
                            if obj:FindFirstChildWhichIsA("BasePart", true) and obj:FindFirstChildWhichIsA("BasePart", true):FindFirstChild("UniversalWhiteItemESPText") then
                                obj:FindFirstChildWhichIsA("BasePart", true)["UniversalWhiteItemESPText"]:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    end
end)
-- part 3
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
vAK.MouseButton1Click:Connect(function() shared.CheatConfig.AntiKillTrap = not shared.CheatConfig.AntiKillTrap vAK.BackgroundColor3 = shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60) vAK.Text = shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF" end)

-- НАМЕРТВО ФИКСИРУЕМ КРАСИВЫЙ ЗАЗОР 0.38
local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Name, SearchBox.Size, SearchBox.Position, SearchBox.BackgroundColor3, SearchBox.TextColor3, SearchBox.TextSize, SearchBox.Font, SearchBox.PlaceholderText, SearchBox.Text = "SearchBox", UDim2.new(0.9, 0, 0, 25), UDim2.new(0.05, 0, 0.38, 0), Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255), 12, Enum.Font.SourceSans, "Type item name here...", ""
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 5)

-- НАМЕРТВО ФИКСИРУЕМ КРАСИВЫЙ ЗАЗОР 0.38
local MoveControlsFrame = Instance.new("Frame", MainFrame)
MoveControlsFrame.Name, MoveControlsFrame.BackgroundTransparency, MoveControlsFrame.Position, MoveControlsFrame.Size = "MoveControlsFrame", 1, UDim2.new(0.05, 0, 0.38, 0), UDim2.new(0.9, 0, 0, 40)
local FlyBtn = Instance.new("TextButton", MoveControlsFrame)
FlyBtn.Name, FlyBtn.Size, FlyBtn.Position, FlyBtn.BackgroundColor3, FlyBtn.Font, FlyBtn.Text, FlyBtn.TextColor3, FlyBtn.TextSize = "FlyBtn", UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(55, 55, 60), Enum.Font.SourceSansBold, "Fly: OFF", Color3.fromRGB(255, 255, 255), 13
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 5)
local NoclipBtn = Instance.new("TextButton", MoveControlsFrame)
NoclipBtn.Name, NoclipBtn.Size, NoclipBtn.Position, NoclipBtn.BackgroundColor3, NoclipBtn.Font, NoclipBtn.Text, NoclipBtn.TextColor3, NoclipBtn.TextSize = "NoclipBtn", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(55, 55, 60), Enum.Font.SourceSansBold, "Noclip: OFF", Color3.fromRGB(255, 255, 255), 13
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 5)

local SF = Instance.new("ScrollingFrame", MainFrame)
SF.BackgroundTransparency, SF.ScrollBarThickness = 1, 6
local LY = Instance.new("UIListLayout", SF)
LY.SortOrder, LY.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
local RB = Instance.new("TextButton", MainFrame)
RB.BackgroundColor3, RB.Position, RB.Size, RB.Font, RB.Text, RB.TextColor3, RB.TextSize = Color3.fromRGB(255, 60, 60), UDim2.new(0.05, 0, 0.86, 0), UDim2.new(0.9, 0, 0, 35), Enum.Font.SourceSansBold, "REFRESH LIST", Color3.fromRGB(255, 255, 255), 14
Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)

_G.cM, _G.cS, _G.SearchQuery = "Player", "Items", ""
local iK = {"key", "padlock", "hammer", "cog", "shotgun", "weapon", "gasoline", "fuel", "battery", "spark", "crank", "book", "teddy", "plank", "fuse", "melon", "pliers", "cutting", "crossbow", "arrow", "bolt", "wrench", "screwdriver", "meat", "crowbar", "winch", "handle", "valve", "remote", "card", "code", "ticket", "coin", "tool", "item", "gun", "ammo"}
local sJ = {"wall", "floor", "ceiling", "hinge", "frame", "window", "furniture", "carfurniture", "puzzle"}

local function setupTabClicks(PlayerBtn, GrannyBtn, VisualsBtn, ItemsBtn, EscBtn)
    PlayerBtn.MouseButton1Click:Connect(function() _G.cM = "Player" _G.updateMenuDisplay() end)
    GrannyBtn.MouseButton1Click:Connect(function() _G.cM = "Granny" _G.updateMenuDisplay() end)
    VisualsBtn.MouseButton1Click:Connect(function() _G.cM = "Visuals" _G.updateMenuDisplay() end)
    ItemsBtn.MouseButton1Click:Connect(function() _G.cS = "Items" ItemsBtn.TextColor3, ItemsBtn.BackgroundColor3, EscBtn.TextColor3, EscBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) _G.updateMenuDisplay() end)
    EscBtn.MouseButton1Click:Connect(function() _G.cS = "Movement" EscBtn.TextColor3, EscBtn.BackgroundColor3, ItemsBtn.TextColor3, ItemsBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) _G.updateMenuDisplay() end)
end
-- part 4
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
        
        shared.CheatConfig.ItemsESP = shared.CheatConfig.ItemsESP or false
        makeVis(shared.CheatConfig.ItemsESP and "ESP Items + Text: ON" or "ESP Items + Text: OFF", shared.CheatConfig.ItemsESP, function() 
            shared.CheatConfig.ItemsESP = not shared.CheatConfig.ItemsESP 
            _G.updateMenuDisplay() 
        end)
        
        makeVis(shared.CheatConfig.ThirdPerson and "3rd Person Camera: ON" or "3rd Person Camera: OFF", shared.CheatConfig.ThirdPerson, function() shared.CheatConfig.ThirdPerson = not shared.CheatConfig.ThirdPerson toggleThirdPerson(shared.CheatConfig.ThirdPerson) _G.updateMenuDisplay() end)
        SF.CanvasSize = UDim2.new(0, 0, 0, 130) return
    elseif _G.cM == "Granny" then
        SubNavFrame.Visible, SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible, SF.Position, SF.Size = false, false, false, false, true, UDim2.new(0.05, 0, 0.15, 0), UDim2.new(0.9, 0, 0, 235)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                te = te + 1 local eB = Instance.new("TextButton", SF) eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. p.Name, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4) eB.MouseButton1Click:Connect(function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0) end) end)
            end
        end
        SF.CanvasSize = UDim2.new(0, 0, 0, te * 38) return
-- part 5
    elseif _G.cM == "Player" then
        SubNavFrame.Visible = true
        if _G.cS == "Movement" then SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible = false, true, true, false
        else
            SearchBox.Visible, vAK.Visible, MoveControlsFrame.Visible, SF.Visible = true, true, false, true
            SF.Position, SF.Size = UDim2.new(0.05, 0, 0.49, 0), UDim2.new(0.9, 0, 0, 115)
            local currentQuery = string.lower(_G.SearchQuery)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent and not obj:IsDescendantOf(LocalPlayer.Character) then
                    local isInsideMonster = false local checkParent = obj.Parent
                    while checkParent and checkParent ~= Workspace do
                        local pName = string.lower(checkParent.Name)
                        if (string.find(pName, "granny") or string.find(pName, "grandpa") or string.find(pName, "bot") or string.find(pName, "enemy")) and checkParent:FindFirstChildOfClass("Humanoid") then isInsideMonster = true break end
                        checkParent = checkParent.Parent
                    end
                    if not isInsideMonster and not (string.find(string.lower(obj.Name), "attach") or string.find(string.lower(obj.Name), "kill")) then
                        local current = obj
                        while current.Parent and current.Parent ~= Workspace and current.Parent:IsA("Model") and not string.find(string.lower(current.Parent.Name), "item") and not string.find(string.lower(current.Parent.Name), "spawn") do current = current.Parent end
                        local customButtonName = current.Name local nameLower = string.lower(customButtonName) local iV, isJunk = false, false
                        for _, junk in pairs(sJ) do if string.find(nameLower, junk) then isJunk = true break end end
                        if string.find(nameLower, "wheel") then isJunk = true end
                        if not isJunk then
                            if string.find(nameLower, "battery") or string.find(nameLower, "spark") then iV = true
                            elseif not (string.find(nameLower, "door") or string.find(nameLower, "gate") or string.find(nameLower, "escape") or string.find(nameLower, "car") or string.find(nameLower, "boat") or string.find(nameLower, "helicopter")) then
                                if obj:FindFirstChildWhichIsA("ClickDetector", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true) then iV = true
                                else for _, kw in pairs(iK) do if string.find(nameLower, kw) then iV = true break end end end
                            end
                        end
                        
                        -- ЛОГИКА БЕЛОГО ESP ПРЕДМЕТОВ
                        if iV and shared.CheatConfig.ItemsESP then
                            if not current:FindFirstChild("UniversalWhiteItemESP") then
                                local hl = Instance.new("Highlight", current)
                                hl.Name = "UniversalWhiteItemESP"
                                hl.FillColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                        end
                        
                        if currentQuery ~= "" and not string.find(nameLower, currentQuery) then iV = false end
                        if iV and not ad[customButtonName] and not Players:GetPlayerFromCharacter(current) then
                            ad[customButtonName] = true te = te + 1
                            local eB = Instance.new("TextButton", SF) eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. customButtonName, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                            Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                            eB.MouseButton1Click:Connect(function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = (current:IsA("Model") and (current.PrimaryPart and current.PrimaryPart.CFrame or current:FindFirstChildWhichIsA("BasePart", true).CFrame) or current.CFrame) + Vector3.new(0, 3.5, 0) end) end)
                        end
                    end
                end
            end
            if te == 0 and currentQuery ~= "" then
                local label = Instance.new("TextLabel", SF) label.Size = UDim2.new(1, 0, 0, 30) label.BackgroundTransparency = 1
                label.Text = "No items found for '" .. _G.SearchQuery .. "'"
                label.TextColor3 = Color3.fromRGB(255, 60, 60) label.Font = Enum.Font.SourceSansBold label.TextSize = 12
                te = 1
            end
            SF.CanvasSize = UDim2.new(0, 0, 0, te * 38)
        end
    end
end

MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = MainFrame.Position i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
MainFrame.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragInput = i end end)
UserInputService.InputChanged:Connect(function(i) if i == dragInput and dragging then local delta = i.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() _G.SearchQuery = SearchBox.Text _G.updateMenuDisplay() end)
setupTabClicks(PlayerTabBtn, GrannyTabBtn, VisualsTabBtn, ItemsSubBtn, EscapesSubBtn)
FlyBtn.MouseButton1Click:Connect(function() shared.CheatConfig.Fly = not shared.CheatConfig.Fly FlyBtn.BackgroundColor3 = shared.CheatConfig.Fly and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60) FlyBtn.Text = shared.CheatConfig.Fly and "Fly: ON" or "Fly: OFF" end)
NoclipBtn.MouseButton1Click:Connect(function() shared.CheatConfig.Noclip = not shared.CheatConfig.Noclip NoclipBtn.BackgroundColor3 = shared.CheatConfig.Noclip and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60) NoclipBtn.Text = shared.CheatConfig.Noclip and "Noclip: ON" or "Noclip: OFF" end)
RB.MouseButton1Click:Connect(_G.updateMenuDisplay)
_G.updateMenuDisplay()
