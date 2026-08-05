-- ВСТАВЛЯЕМ СТРОГО НА 1-Ю СТРОЧКУ (Авто-ожидание спавна)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    LocalPlayer.CharacterAdded:Wait()
    task.wait(1) -- Безопасная секундная пауза, чтобы карта прогрузилась
end

-- Дальше идет твой обычный код...
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- Удаляем старый UI, если скрипт перезапускается
if CoreGui:FindFirstChild("GrannyPremiumClean") then
    CoreGui["GrannyPremiumClean"]:Destroy()
end

-- Simple ON/OFF Toggles (No laggy sliders)
_G.GrannyESP_Enabled = false
_G.TeammateESP_Enabled = false
_G.ThirdPerson_Enabled = false

-- Reliable Camera Controller Matrix (Handles FOV & 3rd Person Toggle)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.ThirdPerson_Enabled then
                LocalPlayer.CameraMaxZoomDistance = 35
                LocalPlayer.CameraMinZoomDistance = 5
                if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
                    LocalPlayer.CameraMode = Enum.CameraMode.Classic
                end
            else
                LocalPlayer.CameraMaxZoomDistance = 12
                LocalPlayer.CameraMinZoomDistance = 0.5
                LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            end
        end)
    end
end)
-- Clean ESP Builder (Name Only)
local function applyCustomESP(targetFrame, isMonster)
    local espName = isMonster and "GrannyRedESP" or "TeammateGreenESP"
    local espColor = isMonster and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    local isEnabled = isMonster and _G.GrannyESP_Enabled or _G.TeammateESP_Enabled
    
    if not isEnabled then
        if targetFrame:FindFirstChild(espName) then targetFrame[espName]:Destroy() end
        if targetFrame:FindFirstChild(espName.."Text") then targetFrame[espName.."Text"]:Destroy() end
        return
    end
    
    if not targetFrame:FindFirstChild(espName) then
        local hl = Instance.new("Highlight", targetFrame)
        hl.Name = espName
        hl.FillColor = espColor
        hl.FillTransparency = 0.6
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
        label.Text = targetFrame.Name
        label.TextColor3 = espColor
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
    end
end

-- Thread Scanner for ESP
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local nLower = string.lower(p.Name)
                    local charLower = string.lower(p.Character.Name)
                    if string.find(nLower, "granny") or string.find(charLower, "granny") or string.find(nLower, "grandpa") or string.find(charLower, "grandpa") then
                        applyCustomESP(p.Character, true)
                    else
                        applyCustomESP(p.Character, false)
                    end
                end
            end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Parent ~= Players then
                    local oLower = string.lower(obj.Name)
                    if string.find(oLower, "granny") or string.find(oLower, "grandpa") or string.find(oLower, "monster") or string.find(oLower, "slendrina") then
                        applyCustomESP(obj, true)
                    end
                end
            end
        end)
    end
end)

-- Main UI Frames
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "GrannyPremiumClean"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local PlayerTabBtn = Instance.new("TextButton", MainFrame)
PlayerTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
PlayerTabBtn.Position = UDim2.new(0.04, 0, 0.03, 0)
PlayerTabBtn.Size = UDim2.new(0.29, 0, 0, 35)
PlayerTabBtn.Font = Enum.Font.SourceSansBold
PlayerTabBtn.Text = "PLAYER"
PlayerTabBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
PlayerTabBtn.TextSize = 12

local GrannyTabBtn = Instance.new("TextButton", MainFrame)
GrannyTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
GrannyTabBtn.Position = UDim2.new(0.35, 0, 0.03, 0)
GrannyTabBtn.Size = UDim2.new(0.29, 0, 0, 35)
GrannyTabBtn.Font = Enum.Font.SourceSansBold
GrannyTabBtn.Text = "GRANNY"
GrannyTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
GrannyTabBtn.TextSize = 12

local VisualsTabBtn = Instance.new("TextButton", MainFrame)
VisualsTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
VisualsTabBtn.Position = UDim2.new(0.66, 0, 0.03, 0)
VisualsTabBtn.Size = UDim2.new(0.3, 0, 0, 35)
VisualsTabBtn.Font = Enum.Font.SourceSansBold
VisualsTabBtn.Text = "VISUALS"
VisualsTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
VisualsTabBtn.TextSize = 12

local SubNavFrame = Instance.new("Frame", MainFrame)
SubNavFrame.Name = "SubNavFrame"
SubNavFrame.BackgroundTransparency = 1
SubNavFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
SubNavFrame.Size = UDim2.new(0.9, 0, 0, 30)

local ItemsSubBtn = Instance.new("TextButton", SubNavFrame)
ItemsSubBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
ItemsSubBtn.Size = UDim2.new(0.48, 0, 1, 0)
ItemsSubBtn.Font = Enum.Font.SourceSansBold
ItemsSubBtn.Text = "ITEMS"
ItemsSubBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
ItemsSubBtn.TextSize = 12

local EscapesSubBtn = Instance.new("TextButton", SubNavFrame)
EscapesSubBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
EscapesSubBtn.Position = UDim2.new(0.52, 0, 0, 0)
EscapesSubBtn.Size = UDim2.new(0.48, 0, 1, 0)
EscapesSubBtn.Font = Enum.Font.SourceSansBold
EscapesSubBtn.Text = "TELEPORT"
EscapesSubBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
EscapesSubBtn.TextSize = 12

for _, btn in pairs({PlayerTabBtn, GrannyTabBtn, VisualsTabBtn, ItemsSubBtn, EscapesSubBtn}) do
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)
end

local SF = Instance.new("ScrollingFrame", MainFrame)
SF.BackgroundTransparency = 1
SF.ScrollBarThickness = 6

local LY = Instance.new("UIListLayout", SF)
LY.SortOrder = Enum.SortOrder.LayoutOrder
LY.Padding = UDim.new(0, 5)

local RB = Instance.new("TextButton", MainFrame)
RB.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
RB.Position = UDim2.new(0.05, 0, 0.86, 0)
RB.Size = UDim2.new(0.9, 0, 0, 35)
RB.Font = Enum.Font.SourceSansBold
RB.Text = "REFRESH LIST"
RB.TextColor3 = Color3.fromRGB(255, 255, 255)
RB.TextSize = 14
Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)

_G.cM, _G.cS = "Player", "Items"

local iK = {"key", "padlock", "hammer", "cog", "shotgun", "weapon", "gasoline", "fuel", "battery", "spark", "crank", "book", "teddy", "plank", "fuse", "melon"}
local eK = {"car", "boat", "sewer", "helicopter", "gate", "garage", "truck", "main door", "double door"}
local eF = {["main door"] = true, ["front gate"] = true, ["garage door"] = true, ["double door escape"] = true}
local sJ = {"wall", "floor", "ceiling", "hinge", "frame", "window", "furniture", "carfurniture"}
local function updateMenuDisplay()
    for _, child in pairs(SF:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end
    local ad, te = {}, 0
    
    -- Синхронизация подсветки кнопок вкладок при переключении
    PlayerTabBtn.BackgroundColor3 = (_G.cM == "Player") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40)
    PlayerTabBtn.TextColor3 = (_G.cM == "Player") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    GrannyTabBtn.BackgroundColor3 = (_G.cM == "Granny") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40)
    GrannyTabBtn.TextColor3 = (_G.cM == "Granny") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
    VisualsTabBtn.BackgroundColor3 = (_G.cM == "Visuals") and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(35, 35, 40)
    VisualsTabBtn.TextColor3 = (_G.cM == "Visuals") and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)

    -- Рендеринг вкладки VISUALS с кнопками-переключателями
    if _G.cM == "Visuals" then
        SubNavFrame.Visible = false
        SF.Position = UDim2.new(0.05, 0, 0.16, 0)
        SF.Size = UDim2.new(0.9, 0, 0, 225)
        
        -- Кнопка ESP Granny (Красный)
        local vG = Instance.new("TextButton", SF)
        vG.Size = UDim2.new(1, 0, 0, 35)
        vG.BackgroundColor3 = _G.GrannyESP_Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50)
        vG.Text = _G.GrannyESP_Enabled and "ESP Granny: ON (RED)" or "ESP Granny: OFF"
        vG.TextColor3 = Color3.fromRGB(255, 255, 255)
        vG.Font = Enum.Font.SourceSansBold
        vG.TextSize = 13
        Instance.new("UICorner", vG).CornerRadius = UDim.new(0, 5)
        
        vG.MouseButton1Click:Connect(function()
            _G.GrannyESP_Enabled = not _G.GrannyESP_Enabled
            vG.BackgroundColor3 = _G.GrannyESP_Enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50)
            vG.Text = _G.GrannyESP_Enabled and "ESP Granny: ON (RED)" or "ESP Granny: OFF"
        end)
        
        -- Кнопка ESP Allies (Зеленый)
        local vT = Instance.new("TextButton", SF)
        vT.Size = UDim2.new(1, 0, 0, 35)
        vT.BackgroundColor3 = _G.TeammateESP_Enabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(45, 45, 50)
        vT.Text = _G.TeammateESP_Enabled and "ESP Allies: ON (GREEN)" or "ESP Allies: OFF"
        vT.TextColor3 = Color3.fromRGB(255, 255, 255)
        vT.Font = Enum.Font.SourceSansBold
        vT.TextSize = 13
        Instance.new("UICorner", vT).CornerRadius = UDim.new(0, 5)
        
        vT.MouseButton1Click:Connect(function()
            _G.TeammateESP_Enabled = not _G.TeammateESP_Enabled
            vT.BackgroundColor3 = _G.TeammateESP_Enabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(45, 45, 50)
            vT.Text = _G.TeammateESP_Enabled and "ESP Allies: ON (GREEN)" or "ESP Allies: OFF"
        end)

        -- Кнопка вида от Третьего Лица
        local v3 = Instance.new("TextButton", SF)
        v3.Size = UDim2.new(1, 0, 0, 35)
        v3.BackgroundColor3 = _G.ThirdPerson_Enabled and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(45, 45, 50)
        v3.Text = _G.ThirdPerson_Enabled and "3rd Person Camera: ON" or "3rd Person Camera: OFF"
        v3.TextColor3 = Color3.fromRGB(255, 255, 255)
        v3.Font = Enum.Font.SourceSansBold
        v3.TextSize = 13
        Instance.new("UICorner", v3).CornerRadius = UDim.new(0, 5)
        
        v3.MouseButton1Click:Connect(function()
            _G.ThirdPerson_Enabled = not _G.ThirdPerson_Enabled
            v3.BackgroundColor3 = _G.ThirdPerson_Enabled and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(45, 45, 50)
            v3.Text = _G.ThirdPerson_Enabled and "3rd Person Camera: ON" or "3rd Person Camera: OFF"
        end)
        
        SF.CanvasSize = UDim2.new(0, 0, 0, 130)
        return
    end
    if _G.cM == "Granny" then
        SubNavFrame.Visible = false 
        SF.Position = UDim2.new(0.05, 0, 0.16, 0)
        SF.Size = UDim2.new(0.9, 0, 0, 225)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                te = te + 1
                local eB = Instance.new("TextButton", SF)
                eB.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                eB.Size = UDim2.new(1, 0, 0, 32)
                eB.Font = Enum.Font.SourceSans
                eB.Text = "  " .. p.Name
                eB.TextColor3 = Color3.fromRGB(255, 255, 255)
                eB.TextSize = 14
                eB.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                
                eB.MouseButton1Click:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)
                    end
                end)
            end
        end
    elseif _G.cM == "Player" then
        SubNavFrame.Visible = true 
        SF.Position = UDim2.new(0.05, 0, 0.25, 0)
        SF.Size = UDim2.new(0.9, 0, 0, 195)
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:IsDescendantOf(LocalPlayer.Character) then
                local nameLower = string.lower(obj.Name)
                local iV, isJunk = false, false
                
                for _, junk in pairs(sJ) do
                    if string.find(nameLower, junk) then isJunk = true break end
                end
                
                if _G.cS == "Items" then
                    local tE = string.find(nameLower, "car") or string.find(nameLower, "boat") or string.find(nameLower, "truck") or string.find(nameLower, "helicopter")
                    local tL = string.find(nameLower, "lock") or string.find(nameLower, "trigger") or string.find(nameLower, "slot")
                    
                    if not isJunk and not tE and not tL and not string.find(nameLower, "door") and not string.find(nameLower, "gate") then
                        for _, kw in pairs(iK) do
                            if string.find(nameLower, kw) and not string.find(nameLower, "wheel") then iV = true break end
                        end
                    end
                elseif _G.cS == "Teleport" then
                    local cK = string.find(nameLower, "key") or string.find(nameLower, "padlock") or string.find(nameLower, "hammer") or string.find(nameLower, "fuse")
                    
                    if not cK and not string.find(nameLower, "furniture") then
                        local hE = false
                        for _, kw in pairs(eK) do
                            if string.find(nameLower, kw) then hE = true break end
                        end
                        
                        if hE then
                            if string.find(nameLower, "door") or string.find(nameLower, "gate") then
                                for allowedName, _ in pairs(eF) do
                                    if string.find(nameLower, allowedName) then iV = true break end
                                end
                            else
                                iV = true
                            end
                        end
                        if string.find(nameLower, "wheel") or string.find(nameLower, "carengine") then iV = true end
                    end
                end
                
                if iV and not Players:GetPlayerFromCharacter(obj.Parent) and not ad[obj.Name] then
                    ad[obj.Name] = true
                    te = te + 1
                    local eB = Instance.new("TextButton", SF)
                    eB.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                    eB.Size = UDim2.new(1, 0, 0, 32)
                    eB.Font = Enum.Font.SourceSans
                    eB.Text = "  " .. obj.Name
                    eB.TextColor3 = Color3.fromRGB(255, 255, 255)
                    eB.TextSize = 14
                    eB.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", eB).CornerRadius = UDim.new(0, 4)
                    
                    eB.MouseButton1Click:Connect(function()
                        local tC = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:FindFirstChildWhichIsA("BasePart", true).CFrame) or obj.CFrame
                        if tC then
                            if _G.cS == "Teleport" then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = tC * CFrame.new(0, 0, 5)
                            else
                                LocalPlayer.Character.HumanoidRootPart.CFrame = tC + Vector3.new(0, 3.5, 0)
                            end
                        end
                    end)
                end
            end
        end
    end
    SF.CanvasSize = UDim2.new(0, 0, 0, te * 37)
end

PlayerTabBtn.MouseButton1Click:Connect(function() _G.cM = "Player" updateMenuDisplay() end)
GrannyTabBtn.MouseButton1Click:Connect(function() _G.cM = "Granny" updateMenuDisplay() end)
VisualsTabBtn.MouseButton1Click:Connect(function() _G.cM = "Visuals" updateMenuDisplay() end)

ItemsSubBtn.MouseButton1Click:Connect(function() _G.cS = "Items" ItemsSubBtn.TextColor3 = Color3.fromRGB(255, 60, 60) ItemsSubBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) EscapesSubBtn.TextColor3 = Color3.fromRGB(200, 200, 200) EscapesSubBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) updateMenuDisplay() end)
EscapesSubBtn.MouseButton1Click:Connect(function() _G.cS = "Teleport" EscapesSubBtn.TextColor3 = Color3.fromRGB(255, 60, 60) EscapesSubBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) ItemsSubBtn.TextColor3 = Color3.fromRGB(200, 200, 200) ItemsSubBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) updateMenuDisplay() end)

RB.MouseButton1Click:Connect(updateMenuDisplay)
updateMenuDisplay()
