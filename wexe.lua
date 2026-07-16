-- 100% DIRECT FOCUS AIMBOT, PREMIUM SKELETON (WITH JOINTS) & VISUAL HP BAR ESP

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player Check
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then
    warn("[ERROR] PlayerGui not found!")
    return
end

-- Clear old menu
if PlayerGui:FindFirstChild("TestMenu_TR") then
    PlayerGui:FindFirstChild("TestMenu_TR"):Destroy()
end

-- ==========================================
-- 1. SETTINGS, COLORS & FOV (DRAWING API)
-- ==========================================

local Ayarlar = {
    AimAktif = false,
    HedefKilidi = false,
    AimBolgesi = "Head",
    FOV = 120,
    Yumusaklik = 4,
    SkeletonEspAktif = false,
    BoxEspAktif = false,
    SeciliRenkIndex = 1
}

local RenkPaleti = {
    {Isim = "KIRMIZI", Renk = Color3.fromRGB(255, 40, 40)},
    {Isim = "YESIL", Renk = Color3.fromRGB(40, 255, 40)},
    {Isim = "MAVI", Renk = Color3.fromRGB(40, 140, 255)},
    {Isim = "MOR", Renk = Color3.fromRGB(180, 40, 255)},
    {Isim = "TURUNCU", Renk = Color3.fromRGB(255, 140, 40)},
    {Isim = "CYAN", Renk = Color3.fromRGB(0, 255, 255)}
}

local function getAktifRenk()
    return RenkPaleti[Ayarlar.SeciliRenkIndex].Renk
end

-- Dynamic Health Color Lerp (Green -> Orange -> Red)
local function getHealthColor(percent)
    if percent > 0.5 then
        return Color3.fromRGB(255, 140, 0):Lerp(Color3.fromRGB(0, 255, 40), (percent - 0.5) * 2)
    else
        return Color3.fromRGB(255, 40, 40):Lerp(Color3.fromRGB(255, 140, 0), percent * 2)
    end
end

-- FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Transparency = 1
FovCircle.Visible = false

-- ==========================================
-- 2. GUI MENU (OVERLAY & LAYER FIX)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TestMenu_TR"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

local menuAcik = true

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 515)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -257)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Invisible Modal Button (Allows walking while UI is active)
local ModalButton = Instance.new("TextButton")
ModalButton.Name = "ModalButton"
ModalButton.Size = UDim2.new(0, 0, 0, 0)
ModalButton.BackgroundTransparency = 1
ModalButton.Text = ""
ModalButton.Modal = true
ModalButton.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "TEST PANELI - Gelişmiş V9"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Spacer = Instance.new("Frame")
Spacer.Size = UDim2.new(1, 0, 0, 30)
Spacer.BackgroundTransparency = 1
Spacer.LayoutOrder = 0
Spacer.Parent = MainFrame
Title.Parent = Spacer

local function butonOlustur(name, text, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansSemibold
    button.TextSize = 13
    button.Text = text
    button.LayoutOrder = layoutOrder
    button.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    return button
end

local function inputOlustur(name, labelText, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(0.9, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = layoutOrder
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 25)
    box.Position = UDim2.new(0, 0, 0, 18)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 13
    box.Parent = frame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    
    return box
end

-- UI Controls
local ToggleAimBtn = butonOlustur("ToggleAim", "Aim Kilidi: KAPALI", 1)
local TargetLockBtn = butonOlustur("TargetLock", "Hedef Sabitleme: KAPALI", 2)
local AimPartBtn = butonOlustur("AimPart", "Aim Bolgesi: KAFA", 3)
local ToggleSkeletonBtn = butonOlustur("ToggleSkeleton", "Skeleton ESP: KAPALI", 4)
local ToggleBoxBtn = butonOlustur("ToggleBox", "Box ESP: KAPALI", 5)
local ToggleColorBtn = butonOlustur("ToggleColor", "ESP Rengi: KIRMIZI", 6)
local FovInput = inputOlustur("FovInput", "Aim FOV Cember Boyutu (Derece):", 7)
local SmoothnessInput = inputOlustur("SmoothnessInput", "Aim Yumusakligi (1-10):", 8)

FovInput.Text = "120"
SmoothnessInput.Text = "4"

-- ==========================================
-- 3. INTERACTIVE BUTTON FUNCTIONS
-- ==========================================

ToggleAimBtn.MouseButton1Click:Connect(function()
    Ayarlar.AimAktif = not Ayarlar.AimAktif
    ToggleAimBtn.Text = Ayarlar.AimAktif and "Aim Kilidi: ACIK" or "Aim Kilidi: KAPALI"
    ToggleAimBtn.BackgroundColor3 = Ayarlar.AimAktif and Color3.fromRGB(46, 117, 89) or Color3.fromRGB(35, 35, 35)
end)

TargetLockBtn.MouseButton1Click:Connect(function()
    Ayarlar.HedefKilidi = not Ayarlar.HedefKilidi
    TargetLockBtn.Text = Ayarlar.HedefKilidi and "Hedef Sabitleme: ACIK" or "Hedef Sabitleme: KAPALI"
    TargetLockBtn.BackgroundColor3 = Ayarlar.HedefKilidi and Color3.fromRGB(46, 117, 89) or Color3.fromRGB(35, 35, 35)
end)

AimPartBtn.MouseButton1Click:Connect(function()
    if Ayarlar.AimBolgesi == "Head" then
        Ayarlar.AimBolgesi = "HumanoidRootPart"
        AimPartBtn.Text = "Aim Bolgesi: GOVDE"
    else
        Ayarlar.AimBolgesi = "Head"
        AimPartBtn.Text = "Aim Bolgesi: KAFA"
    end
end)

ToggleSkeletonBtn.MouseButton1Click:Connect(function()
    Ayarlar.SkeletonEspAktif = not Ayarlar.SkeletonEspAktif
    ToggleSkeletonBtn.Text = Ayarlar.SkeletonEspAktif and "Skeleton ESP: ACIK" or "Skeleton ESP: KAPALI"
    ToggleSkeletonBtn.BackgroundColor3 = Ayarlar.SkeletonEspAktif and Color3.fromRGB(46, 117, 89) or Color3.fromRGB(35, 35, 35)
end)

ToggleBoxBtn.MouseButton1Click:Connect(function()
    Ayarlar.BoxEspAktif = not Ayarlar.BoxEspAktif
    ToggleBoxBtn.Text = Ayarlar.BoxEspAktif and "Box ESP: ACIK" or "Box ESP: KAPALI"
    ToggleBoxBtn.BackgroundColor3 = Ayarlar.BoxEspAktif and Color3.fromRGB(46, 117, 89) or Color3.fromRGB(35, 35, 35)
end)

-- Color Cycle
ToggleColorBtn.MouseButton1Click:Connect(function()
    Ayarlar.SeciliRenkIndex = Ayarlar.SeciliRenkIndex + 1
    if Ayarlar.SeciliRenkIndex > #RenkPaleti then
        Ayarlar.SeciliRenkIndex = 1
    end
    local aktifPalet = RenkPaleti[Ayarlar.SeciliRenkIndex]
    ToggleColorBtn.Text = "ESP Rengi: " .. aktifPalet.Isim
    ToggleColorBtn.TextColor3 = aktifPalet.Renk
end)

FovInput.FocusLost:Connect(function()
    local val = tonumber(FovInput.Text)
    Ayarlar.FOV = math.clamp(val or Ayarlar.FOV, 1, 600)
    FovInput.Text = tostring(Ayarlar.FOV)
end)

SmoothnessInput.FocusLost:Connect(function()
    local val = tonumber(SmoothnessInput.Text)
    Ayarlar.Yumusaklik = math.clamp(val or Ayarlar.Yumusaklik, 1, 50)
    SmoothnessInput.Text = tostring(Ayarlar.Yumusaklik)
end)

-- Menu Toggle Only With "V" Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        menuAcik = not menuAcik
        MainFrame.Visible = menuAcik
        ModalButton.Modal = menuAcik
    end
end)

-- ==========================================
-- 4. AIMBOT LOGIC (LEFT ALT HOTKEY)
-- ==========================================

local kilitliHedef = nil

local function enYakinOyuncuyuBul()
    if kilitliHedef and Ayarlar.HedefKilidi and kilitliHedef.Character and kilitliHedef.Character:FindFirstChild("HumanoidRootPart") and kilitliHedef.Character:FindFirstChildOfClass("Humanoid") and kilitliHedef.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
        local _, ekrandaMi = Camera:WorldToViewportPoint(kilitliHedef.Character.HumanoidRootPart.Position)
        if ekrandaMi then
            return kilitliHedef
        end
    end

    local enYakinMesafe = Ayarlar.FOV
    local adayOyuncu = nil

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") then
            if v.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local ekrandakiPozisyon, ekrandaMi = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if ekrandaMi then
                    local farePozisyonu = UserInputService:GetMouseLocation()
                    local mesafe = (Vector2.new(ekrandakiPozisyon.X, ekrandakiPozisyon.Y) - farePozisyonu).Magnitude
                    if mesafe < enYakinMesafe then
                        enYakinMesafe = mesafe
                        adayOyuncu = v
                    end
                end
            end
        end
    end
    kilitliHedef = adayOyuncu
    return adayOyuncu
end

-- ==========================================
-- 5. ESP SYSTEM (PREMIUM DESIGN & HIGH FPS)
-- ==========================================

local EspObjeleri = {}

local function cizgiOlustur()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = Color3.fromRGB(255, 0, 0)
    l.Thickness = 1.5
    l.Transparency = 1
    return l
end

local function kutuOlustur()
    local b = Drawing.new("Square")
    b.Visible = false
    b.Color = Color3.fromRGB(255, 0, 0)
    b.Thickness = 1.5
    b.Filled = false
    return b
end

local function daireOlustur(radius)
    local c = Drawing.new("Circle")
    c.Visible = false
    c.Filled = true
    c.Radius = radius or 2.5
    c.NumSides = 12
    c.Transparency = 1
    return c
end

local function yaziOlustur(color, size)
    local t = Drawing.new("Text")
    t.Visible = false
    t.Color = color or Color3.fromRGB(255, 255, 255)
    t.Size = size or 13
    t.Center = true
    t.Outline = true
    return t
end

local function espOlustur(oyuncu)
    if EspObjeleri[oyuncu] then return end
    
    local lines = {
        Boyun = cizgiOlustur(),
        SolOmuz = cizgiOlustur(),
        SolKol = cizgiOlustur(),
        SagOmuz = cizgiOlustur(),
        SagKol = cizgiOlustur(),
        Omurga = cizgiOlustur(),
        SolKalca = cizgiOlustur(),
        SolBacak = cizgiOlustur(),
        SagKalca = cizgiOlustur(),
        SagBacak = cizgiOlustur()
    }

    -- Aesthetic joint dots
    local joints = {
        Kafa = daireOlustur(3), -- Head is slightly larger
        SolOmuz = daireOlustur(2.2),
        SagOmuz = daireOlustur(2.2),
        SolDirsek = daireOlustur(2.2),
        SagDirsek = daireOlustur(2.2),
        SolKalca = daireOlustur(2.2),
        SagKalca = daireOlustur(2.2),
        SolDiz = daireOlustur(2.2),
        SagDiz = daireOlustur(2.2)
    }
    
    local box = kutuOlustur()
    local isim = yaziOlustur(Color3.fromRGB(255, 255, 255), 13)
    
    -- Visual HP Bar Squares
    local hpBarBG = kutuOlustur()
    local hpBarMain = kutuOlustur()
    
    EspObjeleri[oyuncu] = {
        Lines = lines, 
        Joints = joints,
        Box = box, 
        Isim = isim, 
        HpBarBG = hpBarBG, 
        HpBarMain = hpBarMain
    }
end

local function espTemizle(oyuncu)
    if EspObjeleri[oyuncu] then
        for _, line in pairs(EspObjeleri[oyuncu].Lines) do
            line:Remove()
        end
        for _, joint in pairs(EspObjeleri[oyuncu].Joints) do
            joint:Remove()
        end
        EspObjeleri[oyuncu].Box:Remove()
        EspObjeleri[oyuncu].Isim:Remove()
        EspObjeleri[oyuncu].HpBarBG:Remove()
        EspObjeleri[oyuncu].HpBarMain:Remove()
        EspObjeleri[oyuncu] = nil
    end
end

Players.PlayerAdded:Connect(espOlustur)
Players.PlayerRemoving:Connect(espTemizle)
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then espOlustur(p) end
end

-- Optimized Bone Draw
local function kemikCiz(line, p1, p2, customColor, distance)
    local pos1, ekranda1 = Camera:WorldToViewportPoint(p1.Position)
    local pos2, ekranda2 = Camera:WorldToViewportPoint(p2.Position)
    
    if ekranda1 and ekranda2 then
        line.From = Vector2.new(pos1.X, pos1.Y)
        line.To = Vector2.new(pos2.X, pos2.Y)
        line.Color = customColor
        line.Thickness = math.clamp(30 / (distance * 0.1), 1, 2)
        line.Visible = true
    else
        line.Visible = false
    end
end

-- Optimized Joint Draw
local function eklemCiz(circle, part, customColor, distance)
    local pos, ekranda = Camera:WorldToViewportPoint(part.Position)
    if ekranda then
        circle.Position = Vector2.new(pos.X, pos.Y)
        circle.Color = customColor
        circle.Radius = math.clamp(25 / (distance * 0.1), 1.5, 3)
        circle.Visible = true
    else
        circle.Visible = false
    end
end

-- ==========================================
-- 6. MAIN LOOP (RENDERSTEPPED)
-- ==========================================

RunService.RenderStepped:Connect(function()
    -- FOV Update
    if Ayarlar.AimAktif then
        FovCircle.Visible = true
        FovCircle.Radius = Ayarlar.FOV
        FovCircle.Position = UserInputService:GetMouseLocation()
    else
        FovCircle.Visible = false
    end

    local aktifColor = getAktifRenk()

    -- ESP Loop
    for oyuncu, objeler in pairs(EspObjeleri) do
        local karakter = oyuncu.Character
        local isAlive = karakter and karakter:FindFirstChild("HumanoidRootPart") and karakter:FindFirstChildOfClass("Humanoid") and karakter:FindFirstChildOfClass("Humanoid").Health > 0
        
        if isAlive then
            local Head = karakter:FindFirstChild("Head")
            local hrp = karakter.HumanoidRootPart
            local humanoid = karakter:FindFirstChildOfClass("Humanoid")
            
            -- Viewport Performance Skip
            local hrpPos, ekrandaMi = Camera:WorldToViewportPoint(hrp.Position)
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            if not ekrandaMi then
                for _, line in pairs(objeler.Lines) do line.Visible = false end
                for _, joint in pairs(objeler.Joints) do joint.Visible = false end
                objeler.Box.Visible = false
                objeler.Isim.Visible = false
                objeler.HpBarBG.Visible = false
                objeler.HpBarMain.Visible = false
                continue
            end
            
            local isR15 = karakter:FindFirstChild("UpperTorso") ~= nil
            local Torso = isR15 and karakter:FindFirstChild("UpperTorso") or karakter:FindFirstChild("Torso")
            local Hip = isR15 and karakter:FindFirstChild("LowerTorso") or Torso
            
            -- SKELETON ESP (Smooth & Beautiful Joint System)
            if Ayarlar.SkeletonEspAktif and Head then
                local LeftArm = isR15 and karakter:FindFirstChild("LeftUpperArm") or karakter:FindFirstChild("Left Arm")
                local LeftForearm = isR15 and karakter:FindFirstChild("LeftLowerArm") or LeftArm
                local RightArm = isR15 and karakter:FindFirstChild("RightUpperArm") or karakter:FindFirstChild("Right Arm")
                local RightForearm = isR15 and karakter:FindFirstChild("RightLowerArm") or RightArm
                
                local LeftLeg = isR15 and karakter:FindFirstChild("LeftUpperLeg") or karakter:FindFirstChild("Left Leg")
                local LeftFoot = isR15 and karakter:FindFirstChild("LeftLowerLeg") or LeftLeg
                local RightLeg = isR15 and karakter:FindFirstChild("RightUpperLeg") or karakter:FindFirstChild("Right Leg")
                local RightFoot = isR15 and karakter:FindFirstChild("RightLowerLeg") or RightLeg
                
                if Torso and Hip and LeftArm and RightArm and LeftLeg and RightLeg then
                    -- Render Bones
                    kemikCiz(objeler.Lines.Boyun, Head, Torso, aktifColor, distance)
                    kemikCiz(objeler.Lines.Omurga, Torso, Hip, aktifColor, distance)
                    kemikCiz(objeler.Lines.SolOmuz, Torso, LeftArm, aktifColor, distance)
                    kemikCiz(objeler.Lines.SolKol, LeftArm, LeftForearm, aktifColor, distance)
                    kemikCiz(objeler.Lines.SagOmuz, Torso, RightArm, aktifColor, distance)
                    kemikCiz(objeler.Lines.SagKol, RightArm, RightForearm, aktifColor, distance)
                    kemikCiz(objeler.Lines.SolKalca, Hip, LeftLeg, aktifColor, distance)
                    kemikCiz(objeler.Lines.SolBacak, LeftLeg, LeftFoot, aktifColor, distance)
                    kemikCiz(objeler.Lines.SagKalca, Hip, RightLeg, aktifColor, distance)
                    kemikCiz(objeler.Lines.SagBacak, RightLeg, RightFoot, aktifColor, distance)
                    
                    -- Render Joint Circles (Adds premium visual polish)
                    eklemCiz(objeler.Joints.Kafa, Head, Color3.fromRGB(255, 255, 255), distance) -- White skull core
                    eklemCiz(objeler.Joints.SolOmuz, LeftArm, aktifColor, distance)
                    eklemCiz(objeler.Joints.SagOmuz, RightArm, aktifColor, distance)
                    eklemCiz(objeler.Joints.SolDirsek, LeftForearm, aktifColor, distance)
                    eklemCiz(objeler.Joints.SagDirsek, RightForearm, aktifColor, distance)
                    eklemCiz(objeler.Joints.SolKalca, LeftLeg, aktifColor, distance)
                    eklemCiz(objeler.Joints.SagKalca, RightLeg, aktifColor, distance)
                    eklemCiz(objeler.Joints.SolDiz, LeftFoot, aktifColor, distance)
                    eklemCiz(objeler.Joints.SagDiz, RightFoot, aktifColor, distance)
                else
                    for _, line in pairs(objeler.Lines) do line.Visible = false end
                    for _, joint in pairs(objeler.Joints) do joint.Visible = false end
                end
            else
                for _, line in pairs(objeler.Lines) do line.Visible = false end
                for _, joint in pairs(objeler.Joints) do joint.Visible = false end
            end
            
            -- BOX ESP & DYNAMIC HEALTH BAR (MODIFIED FOR OUTSIDE LEFT PLACEMENT)
            if Ayarlar.BoxEspAktif then
                local yukseklik = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y)
                local genislik = yukseklik * 0.6
                
                local boxX = hrpPos.X - genislik / 2
                local boxY = hrpPos.Y - yukseklik / 2
                
                -- Draw main player box
                objeler.Box.Size = Vector2.new(genislik, yukseklik)
                objeler.Box.Position = Vector2.new(boxX, boxY)
                objeler.Box.Color = aktifColor
                objeler.Box.Visible = true
                
                -- Calculations for Health Bar
                local canOrani = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barGenislik = 3
                local barMesafe = 6 -- Gap between Box and Health Bar (Outside on the left)
                local barYolUzunlugu = yukseklik
                local aktifBarBoyu = barYolUzunlugu * canOrani
                
                -- HP Bar Background (Black outline frame - placed outside of Box)
                objeler.HpBarBG.Size = Vector2.new(barGenislik + 2, barYolUzunlugu + 2)
                objeler.HpBarBG.Position = Vector2.new(boxX - barMesafe - barGenislik - 1, boxY - 1)
                objeler.HpBarBG.Color = Color3.fromRGB(15, 15, 15)
                objeler.HpBarBG.Filled = true
                objeler.HpBarBG.Visible = true
                
                -- HP Bar Foreground (Placed outside of Box)
                objeler.HpBarMain.Size = Vector2.new(barGenislik, aktifBarBoyu)
                objeler.HpBarMain.Position = Vector2.new(boxX - barMesafe - barGenislik, boxY + barYolUzunlugu - aktifBarBoyu)
                objeler.HpBarMain.Color = getHealthColor(canOrani)
                objeler.HpBarMain.Filled = true
                objeler.HpBarMain.Visible = true
            else
                objeler.Box.Visible = false
                objeler.HpBarBG.Visible = false
                objeler.HpBarMain.Visible = false
            end
            
            -- NAME ESP (Anchored safely on top of player's head)
            if (Ayarlar.SkeletonEspAktif or Ayarlar.BoxEspAktif) and Head then
                local kafaUstPos, ekrandaMiKafa = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 2.5, 0))
                if ekrandaMiKafa then
                    objeler.Isim.Text = oyuncu.Name
                    objeler.Isim.Position = Vector2.new(kafaUstPos.X, kafaUstPos.Y)
                    objeler.Isim.Color = Color3.fromRGB(255, 255, 255)
                    objeler.Isim.Visible = true
                else
                    objeler.Isim.Visible = false
                end
            else
                objeler.Isim.Visible = false
            end
            
        else
            -- Clean state when player is dead
            for _, line in pairs(objeler.Lines) do line.Visible = false end
            for _, joint in pairs(objeler.Joints) do joint.Visible = false end
            objeler.Box.Visible = false
            objeler.Isim.Visible = false
            objeler.HpBarBG.Visible = false
            objeler.HpBarMain.Visible = false
        end
    end

    -- AIMBOT (Left Alt Key Hotkey check)
    if Ayarlar.AimAktif and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local hedef = enYakinOyuncuyuBul()
        if hedef and hedef.Character then
            local hedefParca = hedef.Character:FindFirstChild(Ayarlar.AimBolgesi)
            
            if hedefParca then
                local hedefPozisyon = hedefParca.Position
                local yeniKameraCFrame = CFrame.new(Camera.CFrame.Position, hedefPozisyon)
                Camera.CFrame = Camera.CFrame:Lerp(yeniKameraCFrame, 1 / Ayarlar.Yumusaklik)
            end
        end
    else
        kilitliHedef = nil
    end
end)

-- DRAG SYSTEM FOR PANEL
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("[SUCCESS] Test Panel V9.0 Loaded! Joint-Skeleton & Dynamic 2D HP Bar fully active.")
