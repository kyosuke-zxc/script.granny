-- part 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

if CoreGui:FindFirstChild("GrannyPremiumClean") then CoreGui["GrannyPremiumClean"]:Destroy() end

shared.CheatConfig = shared.CheatConfig or { PlayersESP = false, ThirdPerson = false, AntiKillTrap = false }

-- ЖЕСТКИЙ ЦИКЛ ДЛЯ 3RD PERSON (Ломает внутренние скрипты блокировки игры)
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
-- part 2
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

-- ФИКС ESP ДЛЯ НОВЫХ ИСПАВНИВШИХСЯ ИГРОКОВ ЧЕРЕЗ ИВЕНТЫ ДВИЖКА
local function watchPlayer(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if shared.CheatConfig.PlayersESP then
            applyPlayersESP(char, p.DisplayName or p.Name)
        end
    end)
end
for _, p in pairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)

task.spawn(function()
    while task.wait(1.5) do
        if shared.CheatConfig.PlayersESP then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                        if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                            local player = Players:GetPlayerFromCharacter(obj)
                            local nameToDisplay = player and (player.DisplayName or player.Name) or "Bot"
                            applyPlayersESP(obj, nameToDisplay)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.15) do
        if shared.CheatConfig.AntiKillTrap and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local needToTeleport = false
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "trap") or string.find(string.lower(obj.Name), "beartrap")) then
                        if (myRoot.Position - obj.Position).Magnitude < 7 then needToTeleport = true break end
                    elseif obj:IsA("Model") and (string.find(string.lower(obj.Name), "trap") or string.find(string.lower(obj.Name), "beartrap")) then
                        local p = obj:FindFirstChildWhichIsA("BasePart", true)
                        if p and (myRoot.Position - p.Position).Magnitude < 7 then needToTeleport = true break end
                    end
                end
                if not needToTeleport then
                    local dangerTarget = nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local nL, cL = string.lower(p.Name), string.lower(p.Character.Name)
                            local isGranny = string.find(nL, "granny") or string.find(cL, "granny") or (p.Team and string.find(string.lower(p.Team.Name), "granny")) or (p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").DisplayName == "Enemy")
                            if isGranny then dangerTarget = p.Character.HumanoidRootPart break end
                        end
                    end
                    if not dangerTarget then
                        for _, o in pairs(Workspace:GetChildren()) do
                            if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and (string.find(string.lower(o.Name), "granny") or string.find(string.lower(o.Name), "grandpa") or string.find(string.lower(o.Name), "bot")) then
                                dangerTarget = o.HumanoidRootPart break
                            end
                        end
                    end
                    if dangerTarget and (myRoot.Position - dangerTarget.Position).Magnitude < 14 then needToTeleport = true end
                end
                if needToTeleport then
                    local targetAlly = getRandomAlly()
                    if targetAlly then myRoot.CFrame = targetAlly.CFrame + Vector3.new(0, 3, 0) 
                    else 
                        local spawnLoc = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
                        if spawnLoc then myRoot.CFrame = spawnLoc.CFrame + Vector3.new(0, 3, 0)
                        else myRoot.CFrame = myRoot.CFrame * CFrame.new(math.random(1) == 1 and 60 or -60, 0, math.random(1) == 1 and 60 or -60) end
                    end
                    task.wait(0.4)
                end
            end)
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "GrannyPremiumClean", false
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name, MainFrame.BackgroundColor3, MainFrame.Position, MainFrame.Size, MainFrame.Active = "MainFrame", Color3.fromRGB(25, 25, 30), UDim2.new(0.05, 0, 0.3, 0), UDim2.new(0, 260, 0, 350), true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
-- part 3
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
local UIS = UserInputService UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

local function createTab(name, text, posX)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Name, btn.Text, btn.Position, btn.Size, btn.BackgroundColor3, btn.Font, btn.TextColor3, btn.TextSize = name, text, UDim2.new(posX, 0, 0.03, 0), UDim2.new(0.29, 0, 0, 35), Color3.fromRGB(35, 35, 40), Enum.Font.SourceSansBold, Color3.fromRGB(200, 200, 200), 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
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

local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Name, SearchBox.Size, SearchBox.Position, SearchBox.BackgroundColor3, SearchBox.TextColor3, SearchBox.TextSize, SearchBox.Font, SearchBox.PlaceholderText, SearchBox.Text = "SearchBox", UDim2.new(0.9, 0, 0, 25), UDim2.new(0.05, 0, 0.25, 0), Color3.fromRGB(35, 35, 40), Color3.fromRGB(255, 255, 255), 12, Enum.Font.SourceSans, "Type item name here...", ""
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 5)

local vAK = Instance.new("TextButton", MainFrame)
vAK.Name, vAK.Size, vAK.Position, vAK.BackgroundColor3, vAK.Text, vAK.TextColor3, vAK.Font, vAK.TextSize = "AntiKillBtn", UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0.34, 0), shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60), shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF", Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 13
Instance.new("UICorner", vAK).CornerRadius = UDim.new(0, 5)
vAK.MouseButton1Click:Connect(function() shared.CheatConfig.AntiKillTrap = not shared.CheatConfig.AntiKillTrap vAK.BackgroundColor3 = shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60) vAK.Text = shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF" end)

local MoveControlsFrame = Instance.new("Frame", MainFrame)
MoveControlsFrame.Name, MoveControlsFrame.BackgroundTransparency, MoveControlsFrame.Position, MoveControlsFrame.Size = "MoveControlsFrame", 1, UDim2.new(0.05, 0, 0.45, 0), UDim2.new(0.9, 0, 0, 40)

local FlyBtn = Instance.new("TextButton", MoveControlsFrame)
FlyBtn.Name, FlyBtn.Size, FlyBtn.Position, FlyBtn.BackgroundColor3, FlyBtn.Font, FlyBtn.Text, FlyBtn.TextColor3, FlyBtn.TextSize = "FlyBtn", UDim2.new(0.48, 0, 0, 35), UDim2.new(0, 0, 0, 0), Color3.fromRGB(55, 55, 60), Enum.Font.SourceSansBold, "Fly: OFF", Color3.fromRGB(255, 255, 255), 13
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 5)

local NoclipBtn = Instance.new("TextButton", MoveControlsFrame)
NoclipBtn.Name, NoclipBtn.Size, NoclipBtn.Position, NoclipBtn.BackgroundColor3, NoclipBtn.Font, NoclipBtn.Text, NoclipBtn.TextColor3, NoclipBtn.TextSize = "NoclipBtn", UDim2.new(0.48, 0, 0, 35), UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(55, 55, 60), Enum.Font.SourceSansBold, "Noclip: OFF", Color3.fromRGB(255, 255, 255), 13
Instance.new("UICorner", NoclipBtn).CornerRadius = UDim.new(0, 5)

local SF = Instance.new("ScrollingFrame", MainFrame)
SF.BackgroundTransparency, SF.ScrollBarThickness = 1, 6
local LY = Instance.new("UIListLayout", SF)
LY.SortOrder, LY.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)

local RB = Instance.new("TextButton", MainFrame)
RB.BackgroundColor3, RB.Position, RB.Size, RB.Font, RB.Text, RB.TextColor3, RB.TextSize = Color3.fromRGB(255, 60, 60), UDim2.new(0.05, 0, 0.86, 0), UDim2.new(0.9, 0, 0, 35), Enum.Font.SourceSansBold, "REFRESH LIST", Color3.fromRGB(255, 255, 255), 14
Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)

_G.cM, _G.cS, _G.SearchQuery = "Player", "Items", ""
shared.CheatConfig.Fly = false
shared.CheatConfig.Noclip = false

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    _G.SearchQuery = SearchBox.Text
    if _G.updateMenuDisplay then _G.updateMenuDisplay() end
end)

-- ИСПРАВЛЕННАЯ СТАБИЛЬНАЯ ФУНКЦИЯ КЛИКОВ (БЕЗ ОПЕЧАТОК)
local function setupTabClicks(PlayerBtn, GrannyBtn, VisualsBtn, ItemsBtn, EscBtn)
    PlayerBtn.MouseButton1Click:Connect(function() _G.cM = "Player" _G.updateMenuDisplay() end)
    GrannyBtn.MouseButton1Click:Connect(function() _G.cM = "Granny" _G.updateMenuDisplay() end)
    VisualsBtn.MouseButton1Click:Connect(function() _G.cM = "Visuals" _G.updateMenuDisplay() end)
    ItemsBtn.MouseButton1Click:Connect(function() _G.cS = "Items" ItemsBtn.TextColor3, ItemsBtn.BackgroundColor3, EscBtn.TextColor3, EscBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) _G.updateMenuDisplay() end)
    EscBtn.MouseButton1Click:Connect(function() _G.cS = "Movement" EscBtn.TextColor3, EscBtn.BackgroundColor3, ItemsBtn.TextColor3, ItemsBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) _G.updateMenuDisplay() end)
end

game:GetService("RunService").Stepped:Connect(function()
    if shared.CheatConfig.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

local flySpeed = 50
game:GetService("RunService").RenderStepped:Connect(function()
    if shared.CheatConfig.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        local velocity = moveDir * flySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, flySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity = velocity + Vector3.new(0, -flySpeed, 0) end
        root.Velocity = velocity
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and not shared.CheatConfig.Fly then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end)

FlyBtn.MouseButton1Click:Connect(function()
    shared.CheatConfig.Fly = not shared.CheatConfig.Fly
    FlyBtn.BackgroundColor3 = shared.CheatConfig.Fly and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60)
    FlyBtn.Text = shared.CheatConfig.Fly and "Fly: ON" or "Fly: OFF"
end)

NoclipBtn.MouseButton1Click:Connect(function()
    shared.CheatConfig.Noclip = not shared.CheatConfig.Noclip
    NoclipBtn.BackgroundColor3 = shared.CheatConfig.Noclip and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60)
    NoclipBtn.Text = shared.CheatConfig.Noclip and "Noclip: ON" or "Noclip: OFF"
end)

local iK = {
    "key", "padlock", "hammer", "cog", "shotgun", "weapon", "gasoline", "fuel", "battery", 
    "spark", "crank", "book", "teddy", "plank", "fuse", "melon", "pliers", "cutting", 
    "crossbow", "arrow", "bolt", "wrench", "screwdriver", "meat", "crowbar", "winch", 
    "handle", "valve", "remote", "card", "code", "ticket", "coin", "tool", "item", "gun", "ammo"
}
local sJ = {"wall", "floor", "ceiling", "hinge", "frame", "window", "furniture", "carfurniture", "puzzle"}
-- part 4
_G.updateMenuDisplay = function()
    for _, child in pairs(SF:GetChildren()) do if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end end
    local ad, te = {}, 0
    
    PlayerTabBtn.Visible, GrannyTabBtn.Visible, VisualsTabBtn.Visible = true, true, true
    
    PlayerTabBtn.BackgroundColor3, PlayerTabBtn.TextColor3 = (_G.cM == "Player") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Player") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    GrannyTabBtn.BackgroundColor3, GrannyTabBtn.TextColor3 = (_G.cM == "Granny") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Granny") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    VisualsTabBtn.BackgroundColor3, VisualsTabBtn.TextColor3 = (_G.cM == "Visuals") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Visuals") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    
    if _G.cM == "Visuals" then
        -- УЛЬТРА-ФИКС: Телепортируем SearchBox далеко за экран (в -500), чтобы убрать черную полосу
        MainFrame.SearchBox.Position = UDim2.new(0.05, 0, 0, -500)
        SubNavFrame.Visible, MainFrame.SearchBox.Visible, MainFrame.AntiKillBtn.Visible, MainFrame.MoveControlsFrame.Visible, SF.Visible, SF.Position, SF.Size = false, false, false, false, true, UDim2.new(0.05, 0, 0.16, 0), UDim2.new(0.9, 0, 0, 225)
        
        local vG = Instance.new("TextButton", SF)
        vG.Size, vG.BackgroundColor3, vG.Font, vG.Text, vG.TextColor3, vG.TextSize = UDim2.new(1, 0, 0, 35), shared.CheatConfig.PlayersESP and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), Enum.Font.SourceSansBold, shared.CheatConfig.PlayersESP and "ESP Players: ON (RED)" or "ESP Players: OFF", Color3.fromRGB(255, 255, 255), 13
        Instance.new("UICorner", vG).CornerRadius = UDim.new(0, 5)
        vG.MouseButton1Click:Connect(function()
            shared.CheatConfig.PlayersESP = not shared.CheatConfig.PlayersESP
            vG.BackgroundColor3 = shared.CheatConfig.PlayersESP and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50)
            vG.Text = shared.CheatConfig.PlayersESP and "ESP Players: ON (RED)" or "ESP Players: OFF"
        end)
        
        local v3 = Instance.new("TextButton", SF)
        v3.Size, v3.BackgroundColor3, v3.Font, v3.Text, v3.TextColor3, v3.TextSize = UDim2.new(1, 0, 0, 35), shared.CheatConfig.ThirdPerson and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), Enum.Font.SourceSansBold, shared.CheatConfig.ThirdPerson and "3rd Person Camera: ON" or "3rd Person Camera: OFF", Color3.fromRGB(255, 255, 255), 13
        Instance.new("UICorner", v3).CornerRadius = UDim.new(0, 5)
        v3.MouseButton1Click:Connect(function()
            shared.CheatConfig.ThirdPerson = not shared.CheatConfig.ThirdPerson
            toggleThirdPerson(shared.CheatConfig.ThirdPerson)
            v3.BackgroundColor3 = shared.CheatConfig.ThirdPerson and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50)
            v3.Text = shared.CheatConfig.ThirdPerson and "3rd Person Camera: ON" or "3rd Person Camera: OFF"
        end)
        
        te = 2 SF.CanvasSize = UDim2.new(0, 0, 0, 90) return
    end
    
    if _G.cM == "Granny" then
        -- УЛЬТРА-ФИКС: Телепортируем SearchBox далеко за экран (в -500)
        MainFrame.SearchBox.Position = UDim2.new(0.05, 0, 0, -500)
        SubNavFrame.Visible, MainFrame.SearchBox.Visible, MainFrame.AntiKillBtn.Visible, MainFrame.MoveControlsFrame.Visible, SF.Visible, SF.Position, SF.Size = false, false, false, false, true, UDim2.new(0.05, 0, 0.16, 0), UDim2.new(0.9, 0, 0, 225)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                te = te + 1 local eB = Instance.new("TextButton", SF)
                eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. p.Name, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                eB.MouseButton1Click:Connect(function() pcall(function() if p.Character and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0) end end) end)
            end
        end
-- part 5
    elseif _G.cM == "Player" then
        SubNavFrame.Visible = true
        
        -- СТАБИЛЬНЫЕ СТАНДАРТНЫЕ КООРДИНАТЫ (Убрали тест с -500 пикселей)
        MainFrame.SearchBox.Position = UDim2.new(0.05, 0, 0.25, 0)
        
        if _G.cS == "Movement" then
            MainFrame.SearchBox.Visible = false
            MainFrame.AntiKillBtn.Visible = true
            MainFrame.MoveControlsFrame.Visible = true
            SF.Visible = false
        else
            MainFrame.SearchBox.Visible = true
            MainFrame.AntiKillBtn.Visible = true
            MainFrame.MoveControlsFrame.Visible = false
            SF.Visible = true
            SF.Position, SF.Size = UDim2.new(0.05, 0, 0.46, 0), UDim2.new(0.9, 0, 0, 125)
            
            local currentQuery = string.lower(_G.SearchQuery)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent and not obj:IsDescendantOf(LocalPlayer.Character) then
                    local isInsideMonster = false
                    local checkParent = obj.Parent
                    while checkParent and checkParent ~= Workspace do
                        local pName = string.lower(checkParent.Name)
                        if (string.find(pName, "granny") or string.find(pName, "grandpa") or string.find(pName, "bot") or string.find(pName, "enemy")) and checkParent:FindFirstChildOfClass("Humanoid") then isInsideMonster = true break end
                        checkParent = checkParent.Parent
                    end
                    local isAttackTrigger = string.find(string.lower(obj.Name), "attach") or string.find(string.lower(obj.Name), "kill")
                    
                    if not isInsideMonster and not isAttackTrigger then
                        local targetObj = obj
                        if not Players:GetPlayerFromCharacter(obj.Parent) then
                            local current = obj
                            while current.Parent and current.Parent ~= Workspace and current.Parent:IsA("Model") and not string.find(string.lower(current.Parent.Name), "item") and not string.find(string.lower(current.Parent.Name), "spawn") do current = current.Parent end
                            targetObj = current
                        end
                        
                        local customButtonName = targetObj.Name
                        local nameLower = string.lower(customButtonName) local iV = false local isJunk = false
                        for _, junk in pairs(sJ) do if string.find(nameLower, junk) then isJunk = true break end end
                        
                        if string.find(nameLower, "wheel") then isJunk = true end
                        
                        if not isJunk then
                            if _G.cS == "Items" then
                                local isItemException = string.find(nameLower, "battery") or string.find(nameLower, "spark")
                                local isEscapeObject = string.find(nameLower, "door") or string.find(nameLower, "gate") or string.find(nameLower, "escape") or string.find(nameLower, "car") or string.find(nameLower, "boat") or string.find(nameLower, "helicopter") or string.find(nameLower, "sewer") or string.find(nameLower, "truck")
                                
                                if isItemException then iV = true
                                elseif not isEscapeObject then 
                                    local hasItemTrigger = obj:FindFirstChildWhichIsA("ClickDetector", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if hasItemTrigger then iV = true
                                    else for _, kw in pairs(iK) do if string.find(nameLower, kw) then iV = true break end end end
                                end
                            end
                            if currentQuery ~= "" and not string.find(nameLower, currentQuery) then iV = false end
                        end
                        
                        if iV and not ad[customButtonName] and not Players:GetPlayerFromCharacter(targetObj) then
                            ad[customButtonName] = true te = te + 1
                            local eB = Instance.new("TextButton", SF)
                            eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. customButtonName, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                            Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                            eB.MouseButton1Click:Connect(function() pcall(function()
                                if targetObj and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    local tC = targetObj:IsA("Model") and (targetObj.PrimaryPart and targetObj.PrimaryPart.CFrame or targetObj:FindFirstChildWhichIsA("BasePart", true).CFrame) or targetObj.CFrame
                                    if tC then LocalPlayer.Character.HumanoidRootPart.CFrame = tC + Vector3.new(0, 3.5, 0) end
                                end
                            end) end)
                        end
                    end
                end
            end
        end
    end
    SF.CanvasSize = UDim2.new(0, 0, 0, te * 38)
end

setupTabClicks(PlayerTabBtn, GrannyTabBtn, VisualsTabBtn, ItemsSubBtn, EscapesSubBtn)
RB.MouseButton1Click:Connect(_G.updateMenuDisplay)
_G.updateMenuDisplay()
