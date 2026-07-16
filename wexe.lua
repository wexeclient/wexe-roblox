-- =========================================================================
-- WEXE PREMIUM V14.0 - THE ULTIMATE REAL-AIM, TRIGGERBOT & THEME REVOLUTION
-- =========================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then return end

-- Eski menüleri tamamen temizle
if PlayerGui:FindFirstChild("Wexe_Premium_Menu") then
    PlayerGui:FindFirstChild("Wexe_Premium_Menu"):Destroy()
end

-- ==========================================
-- 1. SETTINGS & CONFIGS
-- ==========================================

local Ayarlar = {
    -- Combat
    AimAktif = false,
    HedefKilidi = false,
    AimBolgesi = "Head", -- "Head" veya "HumanoidRootPart"
    FOV = 120,
    Yumusaklik = 1.5,
    NoRecoil = false,
    
    -- Triggerbot
    TriggerBot = false,
    TriggerModu = "Head", -- "Head" veya "Body" (Gövde)
    
    -- Visuals
    SkeletonEspAktif = false,
    BoxEspAktif = false,
    
    -- Theme
    SeciliTemaIndex = 1
}

local Temalar = {
    {Isim = "WEXE MORU", Renk = Color3.fromRGB(168, 85, 247)},
    {Isim = "ALEV KIRMIZISI", Renk = Color3.fromRGB(255, 60, 60)},
    {Isim = "ZEHIR YESILI", Renk = Color3.fromRGB(50, 255, 120)},
    {Isim = "BUZ MAVISI", Renk = Color3.fromRGB(60, 160, 255)}
}

local function getAktifRenk()
    return Temalar[Ayarlar.SeciliTemaIndex].Renk
end

-- FOV Çemberi çizimi
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Transparency = 1
FovCircle.Visible = false

-- ==========================================
-- 2. DİNAMİK TEMA GÜNCELLEME SİSTEMİ
-- ==========================================
local GuncellenecekStrokelar = {}
local GuncellenecekTextler = {}
local GuncellenecekArkaplanlar = {}

local function temayiUygula()
    local c = getAktifRenk()
    FovCircle.Color = c
    
    for _, stroke in pairs(GuncellenecekStrokelar) do
        if stroke and stroke.Parent then
            stroke.Color = c
        end
    end
    for _, txt in pairs(GuncellenecekTextler) do
        if txt and txt.Parent then
            txt.TextColor3 = c
        end
    end
    for _, bg in pairs(GuncellenecekArkaplanlar) do
        if bg and bg.Parent then
            bg.BackgroundColor3 = c
        end
    end
end

-- ==========================================
-- 3. MAIN GUI CREATION
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Wexe_Premium_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

local menuAcik = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 530, 0, 430)
MainFrame.Position = UDim2.new(0.5, -265, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 9, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = getAktifRenk()
MainStroke.Parent = MainFrame
table.insert(GuncellenecekStrokelar, MainStroke)

-- Mouse odaklama butonu
local ModalButton = Instance.new("TextButton")
ModalButton.Size = UDim2.new(0, 0, 0, 0)
ModalButton.BackgroundTransparency = 1
ModalButton.Text = ""
ModalButton.Modal = true
ModalButton.Parent = MainFrame

-- Üst Başlık Barı
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 120, 1, 0)
LogoText.Position = UDim2.new(0, 15, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "WEXE"
LogoText.TextColor3 = getAktifRenk()
LogoText.TextSize = 22
LogoText.Font = Enum.Font.SourceSansBold
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = TitleBar
table.insert(GuncellenecekTextler, LogoText)

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 100, 1, 0)
VersionText.Position = UDim2.new(0, 80, 0, 2)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v14.0 ultimate"
VersionText.TextColor3 = Color3.fromRGB(120, 110, 140)
VersionText.TextSize = 12
VersionText.Font = Enum.Font.SourceSansItalic
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

local CloseTip = Instance.new("TextLabel")
CloseTip.Size = UDim2.new(0, 150, 1, 0)
CloseTip.Position = UDim2.new(1, -240, 0, 0)
CloseTip.BackgroundTransparency = 1
CloseTip.Text = "Menü Aç/Kapat: [V]"
CloseTip.TextColor3 = Color3.fromRGB(100, 95, 120)
CloseTip.TextSize = 12
CloseTip.Font = Enum.Font.SourceSansSemibold
CloseTip.TextXAlignment = Enum.TextXAlignment.Right
CloseTip.Parent = TitleBar

-- ==========================================
-- 3.2 WINDOW CONTROLS
-- ==========================================

local ControlsContainer = Instance.new("Frame")
ControlsContainer.Size = UDim2.new(0, 80, 0, 30)
ControlsContainer.Position = UDim2.new(1, -90, 0, 10)
ControlsContainer.BackgroundTransparency = 1
ControlsContainer.Parent = TitleBar

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlsLayout.Padding = UDim.new(0, 8)
ControlsLayout.Parent = ControlsContainer

local function toggleMenu(forceState)
    if forceState ~= nil then
        menuAcik = forceState
    else
        menuAcik = not menuAcik
    end
    MainFrame.Visible = menuAcik
    ModalButton.Modal = menuAcik
end

local isClosed = false
local EspObjeleri = {}

local function espTemizle(oyuncu)
    if EspObjeleri[oyuncu] then
        for _, line in pairs(EspObjeleri[oyuncu].Lines) do pcall(function() line:Remove() end) end
        for _, joint in pairs(EspObjeleri[oyuncu].Joints) do pcall(function() joint:Remove() end) end
        pcall(function() EspObjeleri[oyuncu].Box:Remove() end)
        pcall(function() EspObjeleri[oyuncu].Isim:Remove() end)
        EspObjeleri[oyuncu] = nil
    end
end

local function shutDownEverything()
    isClosed = true
    ScreenGui:Destroy()
    if FovCircle then FovCircle:Remove() end
    for oyuncu, _ in pairs(EspObjeleri) do
        espTemizle(oyuncu)
    end
    RunService:UnbindFromRenderStep("Wexe_ESP_Pipeline")
end

-- KÜÇÜLTME BUTONU
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 170, 200)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = ControlsContainer

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local MinStroke = Instance.new("UIStroke")
MinStroke.Thickness = 1
MinStroke.Color = Color3.fromRGB(40, 32, 60)
MinStroke.Parent = MinimizeBtn

MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 25, 55), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 14, 28), TextColor3 = Color3.fromRGB(180, 170, 200)}):Play()
end)

-- KAPATMA BUTONU
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = ControlsContainer

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1
CloseStroke.Color = Color3.fromRGB(90, 25, 35)
CloseStroke.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(180, 40, 40), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 15, 25), TextColor3 = Color3.fromRGB(255, 90, 90)}):Play()
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    toggleMenu(false)
end)

CloseBtn.MouseButton1Click:Connect(function()
    shutDownEverything()
end)

-- ==========================================
-- 4. NAVIGATION & PAGES
-- ==========================================

local NavBar = Instance.new("Frame")
NavBar.Size = UDim2.new(0, 120, 1, -50)
NavBar.Position = UDim2.new(0, 0, 0, 50)
NavBar.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
NavBar.BorderSizePixel = 0
NavBar.Parent = MainFrame

local LeftNavCorner = Instance.new("UICorner")
LeftNavCorner.CornerRadius = UDim.new(0, 12)
LeftNavCorner.Parent = NavBar

local CoverFrame = Instance.new("Frame")
CoverFrame.Size = UDim2.new(0, 15, 1, 0)
CoverFrame.Position = UDim2.new(1, -15, 0, 0)
CoverFrame.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
CoverFrame.BorderSizePixel = 0
CoverFrame.Parent = NavBar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -20)
TabContainer.Position = UDim2.new(0, 0, 0, 10)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = NavBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -135, 1, -65)
PagesContainer.Position = UDim2.new(0, 128, 0, 58)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local CombatPage = Instance.new("Frame")
CombatPage.Name = "Combat"
CombatPage.Size = UDim2.new(1, 0, 1, 0)
