-- part 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

if CoreGui:FindFirstChild("GrannyPremiumClean") then CoreGui["GrannyPremiumClean"]:Destroy() end

shared.CheatConfig = shared.CheatConfig or { PlayersESP = false, ThirdPerson = false, AntiKillTrap = false }

local function toggleThirdPerson(enable)
    pcall(function()
        local cam = Workspace.CurrentCamera
        if enable then
            LocalPlayer.CameraMaxZoomDistance = 150
            LocalPlayer.CameraMinZoomDistance = 5
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            if cam then cam.FieldOfView = 90 end
        else
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

task.spawn(function()
    while task.wait(1.5) do
        if shared.CheatConfig.PlayersESP then
            pcall(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then applyPlayersESP(p.Character, p.DisplayName or p.Name) end
                end
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Parent ~= Players and obj.Parent ~= LocalPlayer.Character then
                        local oLower = string.lower(obj.Name)
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local isBot = string.find(oLower, "granny") or string.find(oLower, "grandpa") or string.find(oLower, "bot") or string.find(oLower, "npc") or (hum and (string.lower(hum.DisplayName) == "enemy" or string.find(string.lower(hum.DisplayName), "granny")))
                        if isBot then applyPlayersESP(obj, "Bot / Enemy") end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if shared.CheatConfig.AntiKillTrap and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local needToTeleport = false
                for _, obj in pairs(Workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "trap") or string.find(string.lower(obj.Name), "beartrap") then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                        if part and (myRoot.Position - part.Position).Magnitude < 6 then needToTeleport = true break end
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
                        for _, o in pairs(Workspace:GetDescendants()) do
                            if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and (string.find(string.lower(o.Name), "granny") or string.find(string.lower(o.Name), "grandpa") or string.find(string.lower(o.Name), "bot")) then
                                dangerTarget = o.HumanoidRootPart break
                            end
                        end
                    end
                    if dangerTarget and (myRoot.Position - dangerTarget.Position).Magnitude < 14 then needToTeleport = true end
                end
                if needToTeleport then
                    local targetAlly = getRandomAlly()
                    if targetAlly then myRoot.CFrame = targetAlly.CFrame + Vector3.new(0, 2, 0) else myRoot.CFrame = myRoot.CFrame + Vector3.new(0, 25, 0) end
                    task.wait(0.5)
                end
            end)
        end
    end
end)
-- part 2
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name, ScreenGui.ResetOnSpawn = "GrannyPremiumClean", false
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name, MainFrame.BackgroundColor3, MainFrame.Position, MainFrame.Size, MainFrame.Active = "MainFrame", Color3.fromRGB(25, 25, 30), UDim2.new(0.05, 0, 0.3, 0), UDim2.new(0, 260, 0, 350), true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

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
local sJ = {"wall", "floor", "ceiling", "hinge", "frame", "window", "furniture"}
-- part 3
local function updateMenuDisplay()
    for _, child in pairs(SF:GetChildren()) do if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end end
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
        local vG; vG = makeVisBtn(shared.CheatConfig.PlayersESP and "ESP Players: ON (RED)" or "ESP Players: OFF", shared.CheatConfig.PlayersESP, function() shared.CheatConfig.PlayersESP = not shared.CheatConfig.PlayersESP vG.BackgroundColor3, vG.Text = shared.CheatConfig.PlayersESP and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), shared.CheatConfig.PlayersESP and "ESP Players: ON (RED)" or "ESP Players: OFF" end)
        local v3; v3 = makeVisBtn(shared.CheatConfig.ThirdPerson and "3rd Person Camera: ON" or "3rd Person Camera: OFF", shared.CheatConfig.ThirdPerson, function() shared.CheatConfig.ThirdPerson = not shared.CheatConfig.ThirdPerson toggleThirdPerson(shared.CheatConfig.ThirdPerson) v3.BackgroundColor3, v3.Text = shared.CheatConfig.ThirdPerson and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 50), shared.CheatConfig.ThirdPerson and "3rd Person Camera: ON" or "3rd Person Camera: OFF" end)
        SF.CanvasSize = UDim2.new(0, 0, 0, 90)
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
                eB.MouseButton1Click:Connect(function() pcall(function() if p.Character and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0) end end) end)
            end
        end
    elseif _G.cM == "Player" then
        SubNavFrame.Visible = true
        SF.Position, SF.Size = UDim2.new(0.05, 0, 0.25, 0), UDim2.new(0.9, 0, 0, 195)
        te = te + 1
        local vAK = Instance.new("TextButton", SF)
        vAK.Size, vAK.BackgroundColor3, vAK.Text, vAK.TextColor3, vAK.Font, vAK.TextSize = UDim2.new(1, 0, 0, 35), shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60), shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF", Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 13
        Instance.new("UICorner", vAK).CornerRadius = UDim.new(0, 5)
        vAK.MouseButton1Click:Connect(function() shared.CheatConfig.AntiKillTrap = not shared.CheatConfig.AntiKillTrap vAK.BackgroundColor3 = shared.CheatConfig.AntiKillTrap and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(55, 55, 60) vAK.Text = shared.CheatConfig.AntiKillTrap and "Anti-Kill + Trap: ON" or "Anti-Kill + Trap: OFF" end)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Parent and not obj:IsDescendantOf(LocalPlayer.Character) then
                local nameLower = string.lower(obj.Name)
                local iV, isJunk = false, false
                for _, junk in pairs(sJ) do if string.find(nameLower, junk) then isJunk = true break end end
                if not isJunk then
                    if _G.cS == "Items" then
                        local isCarPart = string.find(nameLower, "wheel") or string.find(nameLower, "carengine") or string.find(nameLower, "door") or string.find(nameLower, "gate")
                        if not isCarPart then
                            for _, kw in pairs(iK) do if string.find(nameLower, kw) then iV = true break end end
                        end
                    elseif _G.cS == "TELEPORT" then
                        local cK = string.find(nameLower, "key") or string.find(nameLower, "padlock") or string.find(nameLower, "hammer") or string.find(nameLower, "fuse")
                        if not cK then
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
                                if tC then if _G.cS == "TELEPORT" then LocalPlayer.Character.HumanoidRootPart.CFrame = tC * CFrame.new(0, 0, 5) else LocalPlayer.Character.HumanoidRootPart.CFrame = tC + Vector3.new(0, 3.5, 0) end end
                            end
                        end) end)
                    end
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
