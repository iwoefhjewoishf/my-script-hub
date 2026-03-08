local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local vim = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- 1. CLEANUP (No-Fall i stare GUI)
if _G.CleanupNoFall then _G.CleanupNoFall() end
if pGui:FindFirstChild("MegaHubV1") then pGui.MegaHubV1:Destroy() end

local sgui = Instance.new("ScreenGui", pGui)
sgui.Name = "MegaHubV1"
sgui.ResetOnSpawn = false

-- 2. GŁÓWNA RAMKA (Czarna, draggable)
local mainFrame = Instance.new("Frame", sgui)
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Tytuł
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "  MEGA HUB (Zwiń: Prawy Shift)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- 3. ZARZĄDZANIE ZAKŁADKAMI
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, -10, 0, 30)
tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)

local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.Size = UDim2.new(1, -10, 1, -75)
contentContainer.Position = UDim2.new(0, 5, 0, 70)
contentContainer.BackgroundTransparency = 1

local frames = {}
local buttons = {}

local function createTab(name, order)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.25, -4, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local frame = Instance.new("Frame", contentContainer)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    frames[name] = frame
    buttons[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        for k, f in pairs(frames) do f.Visible = (k == name) end
        for k, b in pairs(buttons) do b.BackgroundColor3 = (k == name) and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30) end
    end)
    
    return frame
end

local tabPaczki = createTab("PACZKI", 1)
local tabTepeki = createTab("TEPEKI", 2)
local tabKosze = createTab("KOSZE", 3)
local tabPlayer = createTab("PLAYER", 4)

-- Pokaż pierwszą zakładkę na start
frames["PACZKI"].Visible = true
buttons["PACZKI"].BackgroundColor3 = Color3.fromRGB(60, 60, 60)

-- CHOWANIE POD PRAWYM SHIFTEM
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ==========================================
-- ZAKŁADKA 1: PACZKI
-- ==========================================
local btnSort = Instance.new("TextButton", tabPaczki)
btnSort.Size = UDim2.new(1, 0, 0, 40)
btnSort.Text = "SZYBKIE OTWIERANIE (Wrzuca na pasek)"
btnSort.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
btnSort.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSort.Font = Enum.Font.SourceSansBold
btnSort.TextSize = 14
Instance.new("UICorner", btnSort).CornerRadius = UDim.new(0, 6)

btnSort.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local backpack = player:WaitForChild("Backpack")
    local found = 0
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:find("Package") or item.Name:find("Paczka") or item.Name:find("{")) then
            hum:EquipTool(item)
            found = found + 1
            task.wait(0.02)
        end
    end
    local oldText = btnSort.Text
    btnSort.Text = "PRZENIESIONO: " .. found
    task.wait(1)
    btnSort.Text = oldText
end)

local paczkiScroll = Instance.new("ScrollingFrame", tabPaczki)
paczkiScroll.Size = UDim2.new(1, 0, 1, -45)
paczkiScroll.Position = UDim2.new(0, 0, 0, 45)
paczkiScroll.BackgroundTransparency = 1
paczkiScroll.ScrollBarThickness = 4
local paczkiLayout = Instance.new("UIListLayout", paczkiScroll)
paczkiLayout.Padding = UDim.new(0, 5)

-- Logika farmy paczek
local function applyFast(v) if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end
workspace.DescendantAdded:Connect(applyFast)
for _, v in ipairs(workspace:GetDescendants()) do applyFast(v) end

local function pressKey(key) vim:SendKeyEvent(true, key, false, game) task.wait(0.05) vim:SendKeyEvent(false, key, false, game) end

local function getInstantPackage()
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and (p.KeyboardKeyCode == Enum.KeyCode.E or p.ActionText:lower():find("collect")) then
            local dist = (player.Character.HumanoidRootPart.Position - p.Parent.Position).Magnitude
            if dist < 12 then return p end
        end
    end
    return nil
end

local function startInstantFarm()
    local packstation = nil
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "Packstation" and v:IsA("Model") then
            if (player.Character.HumanoidRootPart.Position - v.WorldPivot.Position).Magnitude < 25 then
                packstation = v break
            end
        end
    end
    if not packstation then return end
    local tool = player.Backpack:FindFirstChild("Drill") or player.Backpack:FindFirstChild("Wiertlo")
    if tool and player.Character then player.Character.Humanoid:EquipTool(tool) task.wait(0.3) end

    local doors = {}
    for _, d in ipairs(packstation:GetDescendants()) do
        if d.Name == "Door" and d:IsA("BasePart") then table.insert(doors, d) end
    end

    for _, door in ipairs(doors) do
        local function findF()
            for _, p in ipairs(door:GetChildren()) do
                if p:IsA("ProximityPrompt") and p.KeyboardKeyCode == Enum.KeyCode.F then return p end
            end
            return nil
        end
        local pF = findF()
        if pF then
            local att = 0
            while findF() and att < 12 do
                if fireproximityprompt then fireproximityprompt(pF) end
                pressKey(Enum.KeyCode.F)
                task.wait(0.25)
                att = att + 1
            end
            task.wait(0.1)
            local pE = getInstantPackage()
            if pE then
                if fireproximityprompt then fireproximityprompt(pE) end
                pressKey(Enum.KeyCode.E)
                task.wait(0.1)
            end
        end
    end
end

local lokacjePaczki = {
    {nazwa = "FARM PACK 1", pos = Vector3.new(-232.98, 44.21, -684.50)},
    {nazwa = "FARM PACK 2", pos = Vector3.new(505.55, 44.61, -1763.12)},
    {nazwa = "FARM PACK 3", pos = Vector3.new(111.04, 72.06, 903.12)},
    {nazwa = "FARM PACK 4", pos = Vector3.new(-961.04, 44.58, 224.73)},
    {nazwa = "FARM PACK 5", pos = Vector3.new(-2080.92, 44.61, 409.99)},
}
for _, dane in ipairs(lokacjePaczki) do
    local b = Instance.new("TextButton", paczkiScroll)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = dane.nazwa
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        local root = player.Character.HumanoidRootPart
        root.Anchored = true
        root.CFrame = CFrame.new(dane.pos)
        task.wait(0.5)
        root.Anchored = false
        startInstantFarm()
    end)
end
paczkiScroll.CanvasSize = UDim2.new(0, 0, 0, paczkiLayout.AbsoluteContentSize.Y)

-- ==========================================
-- ZAKŁADKA 2: TEPEKI
-- ==========================================
local tepScroll = Instance.new("ScrollingFrame", tabTepeki)
tepScroll.Size = UDim2.new(1, 0, 1, 0)
tepScroll.BackgroundTransparency = 1
tepScroll.ScrollBarThickness = 4
local tepLayout = Instance.new("UIListLayout", tepScroll)
tepLayout.Padding = UDim.new(0, 5)

local lokacjeTep = {
    {nazwa = "BANK", pos = Vector3.new(-471.00, 26.31, -1363.00)},
    {nazwa = "JEWELERY", pos = Vector3.new(-503.34, 44.62, 324.23)},
    {nazwa = "DEALER 1", pos = Vector3.new(-2706.00, 44.22, 181.00)},
    {nazwa = "BAZA", pos = Vector3.new(-1985.00, 16.30, 1004.00)},
    {nazwa = "MEDIC", pos = Vector3.new(534.98, 44.66, -1780.59)},
    {nazwa = "HOUSE 1", pos = Vector3.new(-1638.06, 44.72, -785.78)},
    {nazwa = "HOUSE 2", pos = Vector3.new(-2105.77, 44.80, -878.47)},
    {nazwa = "HOUSE 3", pos = Vector3.new(-2059.31, 44.64, -611.18)},
}
for _, dane in ipairs(lokacjeTep) do
    local b = Instance.new("TextButton", tepScroll)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = dane.nazwa
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Anchored = true
            root.CFrame = CFrame.new(dane.pos + Vector3.new(0, 1, 0))
            task.wait(0.15)
            root.Anchored = false
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
tepScroll.CanvasSize = UDim2.new(0, 0, 0, tepLayout.AbsoluteContentSize.Y)

-- ==========================================
-- ZAKŁADKA 3: KOSZE
-- ==========================================
local btnManual = Instance.new("TextButton", tabKosze)
btnManual.Size = UDim2.new(1, 0, 0, 50)
btnManual.Text = "NASTĘPNY KOSZ (Ręcznie)"
btnManual.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
btnManual.TextColor3 = Color3.fromRGB(255, 255, 255)
btnManual.Font = Enum.Font.SourceSansBold
btnManual.TextSize = 16
Instance.new("UICorner", btnManual).CornerRadius = UDim.new(0, 6)

local btnAutoKosz = Instance.new("TextButton", tabKosze)
btnAutoKosz.Size = UDim2.new(1, 0, 0, 50)
btnAutoKosz.Position = UDim2.new(0, 0, 0, 60)
btnAutoKosz.Text = "AUTO-FARM KOSZE: OFF"
btnAutoKosz.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Czerwony na start
btnAutoKosz.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoKosz.Font = Enum.Font.SourceSansBold
btnAutoKosz.TextSize = 16
Instance.new("UICorner", btnAutoKosz).CornerRadius = UDim.new(0, 6)

local indexKosze = 1
local kontenery = {}
local isFarmingKosze = false

local function pobierzKontenery()
    kontenery = {}
    for _, nazwa in ipairs({"ContainerTonneS", "ContainerTonneG", "ContainerTonneB"}) do
        local f = workspace:FindFirstChild(nazwa, true)
        if f then
            for _, k in ipairs(f:GetChildren()) do table.insert(kontenery, k) end
        end
    end
end

local function zbierzZKontenera(cel)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local target = cel:FindFirstChild("Main") or cel.PrimaryPart or cel:FindFirstChildWhichIsA("BasePart")
    if target then
        root.CFrame = target.CFrame * CFrame.new(0, 0, 3.5)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 2, 0), target.Position)
        task.wait(0.5)
        local prompt = cel:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.3)
            prompt:InputHoldEnd()
            camera.CameraType = Enum.CameraType.Custom
            return true
        end
    end
    camera.CameraType = Enum.CameraType.Custom
    return false
end

btnAutoKosz.MouseButton1Click:Connect(function()
    isFarmingKosze = not isFarmingKosze
    if isFarmingKosze then
        btnAutoKosz.Text = "AUTO-FARM KOSZE: ON"
        btnAutoKosz.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Zielony
        pobierzKontenery()
        for i = indexKosze, #kontenery do
            if not isFarmingKosze then break end
            indexKosze = i
            btnAutoKosz.Text = "Farming... (" .. i .. "/" .. #kontenery .. ")"
            zbierzZKontenera(kontenery[i])
            task.wait(1)
        end
        isFarmingKosze = false
        btnAutoKosz.Text = "AUTO-FARM KOSZE: OFF"
        btnAutoKosz.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    else
        btnAutoKosz.Text = "AUTO-FARM KOSZE: OFF"
        btnAutoKosz.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

btnManual.MouseButton1Click:Connect(function()
    if isFarmingKosze then return end
    pobierzKontenery()
    if indexKosze > #kontenery then indexKosze = 1 end
    zbierzZKontenera(kontenery[indexKosze])
    indexKosze = indexKosze + 1
end)

-- ==========================================
-- ZAKŁADKA 4: PLAYER (No Fall)
-- ==========================================
local btnNoFall = Instance.new("TextButton", tabPlayer)
btnNoFall.Size = UDim2.new(1, 0, 0, 50)
btnNoFall.Text = "NO FALL DAMAGE: OFF"
btnNoFall.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Czerwony na start
btnNoFall.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNoFall.Font = Enum.Font.SourceSansBold
btnNoFall.TextSize = 16
Instance.new("UICorner", btnNoFall).CornerRadius = UDim.new(0, 6)

local activeNoFall = false
local event = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2", 5) 
if event then event = event:WaitForChild("dataRemoteEvent", 5) end

_G.NoFallRunning = true
_G.CleanupNoFall = function()
    _G.NoFallRunning = false
    activeNoFall = false
    _G.CleanupNoFall = nil
end

local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local m = getnamecallmethod()
    local a = {...}
    if not _G.NoFallRunning then return old(self, ...) end
    if activeNoFall and self == event and (m == "FireServer" or m == "fireServer") then
        if a[1] and a[1][2] == "\127" and a[1][1].KevArgs and a[1][1].KevArgs[1] > 20 then
            a[1][1].KevArgs[1] = 0
            a[1][1].KevArgs[2] = false
            return old(self, unpack(a))
        end
    end
    return old(self, ...)
end)

btnNoFall.MouseButton1Click:Connect(function()
    activeNoFall = not activeNoFall
    if activeNoFall then
        btnNoFall.Text = "NO FALL DAMAGE: ON"
        btnNoFall.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Zielony
    else
        btnNoFall.Text = "NO FALL DAMAGE: OFF"
        btnNoFall.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Czerwony
    end
end)
