-- PART 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("GrannyPremiumClean") then
    CoreGui["GrannyPremiumClean"]:Destroy()
end

-- Переключатели режимов
_G.PlayersESP_Enabled = false
_G.ThirdPerson_Enabled = false
_G.AntiKillTrap_Enabled = false
_G.MouseUnlock_Enabled = false -- Переключатель для Shift Lock Unclocker

-- Контроллер мыши (Shift Lock Unclocker)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.MouseUnlock_Enabled then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                LocalPlayer.DevEnableMouseLock = false
            end
        end)
    end
end)

-- Функция для поиска случайного живого игрока (не Гренни)
local function getRandomAlly()
    local allies = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local nL = string.lower(p.Name)
            local isGranny = string.find(nL, "granny") or (p.Team and string.find(string.lower(p.Team.Name), "granny")) or (p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").DisplayName == "Enemy")
            if not isGranny then
                table.insert(allies, p.Character.HumanoidRootPart)
            end
        end
    end
    if #allies > 0 then
        return allies[math.random(1, #allies)]
    end
    return nil
end

-- СИСТЕМА ДЕТЕКТА ХИТБОКСОВ (Touched-Based Anti-Kill & Anti-Trap)
local function setupHitboxProtection(character)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    
    root.Touched:Connect(function(hit)
        if not _G.AntiKillTrap_Enabled then return end
        if not hit or not hit.Parent then return end
        
        local model = hit.Parent
        local modelName = string.lower(model.Name)
        local hitName = string.lower(hit.Name)
        
        -- 1. ЕСЛИ НАШ ХИТБОКС СТОЛКНУЛСЯ С ГРЕННИ
        local isMonster = string.find(modelName, "granny") or string.find(modelName, "grandpa") or string.find(modelName, "monster") or string.find(hitName, "bat") or string.find(hitName, "weapon") or string.find(hitName, "stick")
        local hitPlayer = Players:GetPlayerFromCharacter(model)
        if hitPlayer and hitPlayer.Team and string.find(string.lower(hitPlayer.Team.Name), "granny") then
            isMonster = true
        end
        
        if isMonster then
            local targetAlly = getRandomAlly()
            if targetAlly then
                root.CFrame = targetAlly.CFrame + Vector3.new(0, 2, 0)
            else
                root.CFrame = root.CFrame + Vector3.new(0, 35, 0)
            end
            return
        end
        
        -- 2. ЕСЛИ НАШ ХИТБОКС НАСТУПИЛ НА КАПКАН
        if string.find(modelName, "trap") or string.find(hitName, "trap") or string.find(modelName, "beartrap") or string.find(hitName, "beartrap") then
            task.wait(0.05)
            local targetAlly = getRandomAlly()
            if targetAlly then
                root.CFrame = targetAlly.CFrame + Vector3.new(0, 2, 0)
            else
                root.CFrame = root.CFrame + Vector3.new(0, 35, 0)
            end
        end
    end)
end

if LocalPlayer.Character then setupHitboxProtection(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupHitboxProtection)

-- Функция управления зумом (Теперь ты сам крутишь мышку дальше/ближе!)
local function toggleThirdPerson(enable)
    pcall(function()
        if enable then
            LocalPlayer.CameraMaxZoomDistance = 150
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        else
            LocalPlayer.CameraMaxZoomDistance = 12
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end)
end
-- PART 2
-- Главный фрейм UI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "GrannyPremiumClean", false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name, MainFrame.BackgroundColor3, MainFrame.Position, MainFrame.Size, MainFrame.Active, MainFrame.Draggable = "MainFrame", Color3.fromRGB(25, 25, 30), UDim2.new(0.05, 0, 0.3, 0), UDim2.new(0, 260, 0, 350), true, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

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
EscapesSubBtn.Position, EscapesSubBtn.Size, EscapesSubBtn.BackgroundColor3, EscapesSubBtn.Font, EscapesSubBtn.Text, EscapesSubBtn.TextColor3, EscapesSubBtn.TextSize = UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0), Color3.fromRGB(35, 35, 40), Enum.Font.SourceSansBold, "TELEPORT", Color3.fromRGB(200, 200, 200), 12
Instance.new("UICorner", EscapesSubBtn).CornerRadius = UDim.new(0, 5)

local SF = Instance.new("ScrollingFrame", MainFrame)
SF.BackgroundTransparency, SF.ScrollBarThickness = 1, 6
local LY = Instance.new("UIListLayout", SF)
LY.SortOrder, LY.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)

local RB = Instance.new("TextButton", MainFrame)
RB.BackgroundColor3, RB.Position, RB.Size, RB.Font, RB.Text, RB.TextColor3, RB.TextSize = Color3.fromRGB(255, 60, 60), UDim2.new(0.05, 0, 0.86, 0), UDim2.new(0.9, 0, 0, 35), Enum.Font.SourceSansBold, "REFRESH LIST", Color3.fromRGB(255, 255, 255), 14
Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)

_G.cM, _G.cS = "Player", "Items"

local iK = {"key", "padlock", "hammer", "cog", "shotgun", "weapon", "gasoline", "fuel", "battery", "spark", "crank", "book", "teddy", "plank", "fuse", "melon"}
local eK = {"car", "boat", "sewer", "helicopter", "gate", "garage", "truck", "main door", "double door"}
local eF = {["main door"] = true, ["front gate"] = true, ["garage door"] = true, ["double door escape"] = true}
local sJ = {"wall", "floor", "ceiling", "hinge", "frame", "window", "furniture", "carfurniture", "car1", "leftcar", "niga"}
-- PART 3
local function updateMenuDisplay()
    for _, child in pairs(SF:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end
    local ad, te = {}, 0
    
    PlayerTabBtn.BackgroundColor3, PlayerTabBtn.TextColor3 = (_G.cM == "Player") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Player") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    GrannyTabBtn.BackgroundColor3, GrannyTabBtn.TextColor3 = (_G.cM == "Granny") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Granny") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    VisualsTabBtn.BackgroundColor3, VisualsTabBtn.TextColor3 = (_G.cM == "Visuals") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40), (_G.cM == "Visuals") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)

    if _G.cM == "Visuals" then
        SubNavFrame.Visible = false
        SF.Position, SF.Size = UDim2.new(0.05, 0, 0.16, 0), UDim2.new(0.9, 0, 0, 225)
        
        local function makeVisBtn(txt, state, cb)
            local v = Instance.new("TextButton", SF)
            v.Size, v.BackgroundColor3, v.Text, v.TextColor3, v.Font, v.TextSize = UDim2.new(1, 0, 0, 35), state and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), txt, Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 13
            Instance.new("UICorner", v).CornerRadius = UDim.new(0, 5)
            v.MouseButton1Click:Connect(cb) return v
        end
        
        local vG; vG = makeVisBtn(_G.PlayersESP_Enabled and "ESP Players: ON (RED)" or "ESP Players: OFF", _G.PlayersESP_Enabled, function() _G.PlayersESP_Enabled = not _G.PlayersESP_Enabled vG.BackgroundColor3, vG.Text = _G.PlayersESP_Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), _G.PlayersESP_Enabled and "ESP Players: ON (RED)" or "ESP Players: OFF" end)
        local v3; v3 = makeVisBtn(_G.ThirdPerson_Enabled and "3rd Person Camera: ON" or "3rd Person Camera: OFF", _G.ThirdPerson_Enabled, function() _G.ThirdPerson_Enabled = not _G.ThirdPerson_Enabled toggleThirdPerson(_G.ThirdPerson_Enabled) v3.BackgroundColor3, v3.Text = _G.ThirdPerson_Enabled and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(45, 45, 50), _G.ThirdPerson_Enabled and "3rd Person Camera: ON" or "3rd Person Camera: OFF" end)
        local vUL; vUL = makeVisBtn(_G.MouseUnlock_Enabled and "Unlock Mouse: ON" or "Unlock Mouse: OFF", _G.MouseUnlock_Enabled, function() _G.MouseUnlock_Enabled = not _G.MouseUnlock_Enabled vUL.BackgroundColor3, vUL.Text = _G.MouseUnlock_Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), _G.MouseUnlock_Enabled and "Unlock Mouse: ON" or "Unlock Mouse: OFF" end)
        
        SF.CanvasSize = UDim2.new(0, 0, 0, 130)
        return
    end
    
    if _G.cM == "Granny" then
        SubNavFrame.Visible = false
        SF.Position, SF.Size = UDim2.new(0.05, 0, 0.16, 0), UDim2.new(0.9, 0, 0, 225)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                te = te + 1
                local eB = Instance.new("TextButton", SF)
                eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. p.Name, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                eB.MouseButton1Click:Connect(function() pcall(function() if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0) end end) end)
            end
        end
    elseif _G.cM == "Player" then
        SubNavFrame.Visible = true
        SF.Position, SF.Size = UDim2.new(0.05, 0, 0.25, 0), UDim2.new(0.9, 0, 0, 195)
        
        te = te + 1
        local vAK = Instance.new("TextButton", SF)
        vAK.Size, vAK.BackgroundColor3, vAK.Text, vAK.TextColor3, vAK.Font, vAK.TextSize = UDim2.new(1, 0, 0, 35), _G.AntiKillTrap_Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60), _G.AntiKillTrap_Enabled and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF", Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 13
        Instance.new("UICorner", vAK).CornerRadius = UDim.new(0, 5)
        
        vAK.MouseButton1Click:Connect(function()
            _G.AntiKillTrap_Enabled = not _G.AntiKillTrap_Enabled
            vAK.BackgroundColor3 = _G.AntiKillTrap_Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60)
            vAK.Text = _G.AntiKillTrap_Enabled and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF"
        end)
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent and not obj:IsDescendantOf(LocalPlayer.Character) then
                local nameLower = string.lower(obj.Name)
                local iV, isJunk = false, false
                
                for _, junk in pairs(sJ) do
                    if string.find(nameLower, junk) then isJunk = true break end
                end
                
                if _G.cS == "Items" then
                    local tE = string.find(nameLower, "car") or string.find(nameLower, "boat") or string.find(nameLower, "truck") or string.find(nameLower, "helicopter")
                    local tL = string.find(nameLower, "lock") or string.find(nameLower, "trigger") or string.find(nameLower, "slot")
                    if not isJunk and not tE and not tL and not string.find(nameLower, "door") and not string.find(nameLower, "gate") then
                        for _, kw in pairs(iK) do if string.find(nameLower, kw) and not string.find(nameLower, "wheel") then iV = true break end end
                    end
                elseif _G.cS == "TELEPORT" then
                    local cK = string.find(nameLower, "key") or string.find(nameLower, "padlock") or string.find(nameLower, "hammer") or string.find(nameLower, "fuse")
                    if not cK and not string.find(nameLower, "furniture") then
                        local hE = false
                        for _, kw in pairs(eK) do if string.find(nameLower, kw) then hE = true break end end
                        if hE then
                            if string.find(nameLower, "door") or string.find(nameLower, "gate") then
                                for allowedName, _ in pairs(eF) do if string.find(nameLower, allowedName) then iV = true break end end
                            else iV = true end
                        end
                        if string.find(nameLower, "wheel") or string.find(nameLower, "carengine") then iV = true end
                    end
                end
                
                if iV and not Players:GetPlayerFromCharacter(obj.Parent) and not ad[obj.Name] then
                    ad[obj.Name] = true
                    te = te + 1
                    local eB = Instance.new("TextButton", SF)
                    eB.BackgroundColor3, eB.Size, eB.Font, eB.Text, eB.TextColor3, eB.TextSize, eB.TextXAlignment = Color3.fromRGB(45, 45, 50), UDim2.new(1, 0, 0, 32), Enum.Font.SourceSans, "  " .. obj.Name, Color3.fromRGB(255, 255, 255), 14, Enum.TextXAlignment.Left
                    Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                    
                    eB.MouseButton1Click:Connect(function() pcall(function()
                        if obj and obj.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local tC = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:FindFirstChildWhichIsA("BasePart", true).CFrame) or obj.CFrame
                            if tC then
                                if _G.cS == "TELEPORT" then LocalPlayer.Character.HumanoidRootPart.CFrame = tC * CFrame.new(0, 0, 5) else LocalPlayer.Character.HumanoidRootPart.CFrame = tC + Vector3.new(0, 3.5, 0) end
                            end
                        end
                    end) end)
                end
            end
        end
    end
    SF.CanvasSize = UDim2.new(0, 0, 0, te * 38)
end

PlayerTabBtn.MouseButton1Click:Connect(function() _G.cM = "Player" updateMenuDisplay() end)
GrannyTabBtn.MouseButton1Click:Connect(function() _G.cM = "Granny" updateMenuDisplay() end)
VisualsTabBtn.MouseButton1Click:Connect(function() _G.cM = "Visuals" updateMenuDisplay() end)

ItemsSubBtn.MouseButton1Click:Connect(function() _G.cS = "Items" ItemsSubBtn.TextColor3, ItemsSubBtn.BackgroundColor3, EscapesSubBtn.TextColor3, EscapesSubBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) updateMenuDisplay() end)
EscapesSubBtn.MouseButton1Click:Connect(function() _G.cS = "TELEPORT" EscapesSubBtn.TextColor3, EscapesSubBtn.BackgroundColor3, ItemsSubBtn.TextColor3, ItemsSubBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60), Color3.fromRGB(45, 45, 50), Color3.fromRGB(200, 200, 200), Color3.fromRGB(35, 35, 40) updateMenuDisplay() end)

RB.MouseButton1Click:Connect(updateMenuDisplay)
updateMenuDisplay()
