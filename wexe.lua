-- // wexe ESP - Purple Theme | Offset Based | Drawing API
-- // Direkt GitHub'a yapıştır, çalıştır.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // ===== GELİŞMİŞ DRAWING ALGILAMA =====
local Drawing = nil

if type(Drawing) == "table" then
    -- zaten globalde var
else
    pcall(function()
        if getrenv then
            Drawing = getrenv().Drawing
        end
    end)
end

if not Drawing and syn and syn.protect then
    pcall(function()
        Drawing = syn.protect(function() return getrenv().Drawing end)()
    end)
end

if not Drawing then
    pcall(function()
        local ds = game:GetService("ReplicatedStorage"):FindFirstChild("Drawing")
        if ds then
            Drawing = require(ds)
        end
    end)
end

if not Drawing then
    warn("wexe ESP: Drawing kütüphanesi bulunamadı!")
    return
end
-- // ===== DRAWING HAZIR =====

local Settings = {
    ESP_Enabled = true,
    Boxes = true,
    Tracers = true,
    Names = true,
    Distance = true,
    HealthBar = true,
    HeadDot = true,
}

local PlayerDrawings = {}

local function ClearPlayerDrawings(player)
    if PlayerDrawings[player] then
        for _, drawing in pairs(PlayerDrawings[player]) do
            pcall(function() drawing:Remove() end)
        end
        PlayerDrawings[player] = nil
    end
end

local function ClearAllDrawings()
    for player, _ in pairs(PlayerDrawings) do
        ClearPlayerDrawings(player)
    end
end

local function UpdateESP()
    if not Settings.ESP_Enabled then
        ClearAllDrawings()
        return
    end

    local currentPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            currentPlayers[player] = true
        end
    end

    for player, _ in pairs(PlayerDrawings) do
        if not currentPlayers[player] then
            ClearPlayerDrawings(player)
        end
    end

    for player, _ in pairs(currentPlayers) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            local rootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local head = character:FindFirstChild("Head")

            local rootScreen, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
            local headScreen, headVisible
            if head then
                headScreen, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            else
                headScreen, headVisible = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2, 0))
            end
            local footScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            local onScreen = rootVisible and headVisible and rootScreen.Z > 0 and headScreen.Z > 0

            if not onScreen then
                ClearPlayerDrawings(player)
                continue
            end

            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            local boxHeight = math.abs(headScreen.Y - footScreen.Y)
            local boxWidth = boxHeight * 0.5
            local boxX = rootScreen.X - boxWidth / 2
            local boxY = headScreen.Y

            if not PlayerDrawings[player] then
                PlayerDrawings[player] = {}
            end
            local drawings = PlayerDrawings[player]

            local function UpdateOrCreateDrawing(name, drawingType, properties)
                if not drawings[name] then
                    drawings[name] = Drawing.new(drawingType)
                end
                local d = drawings[name]
                for prop, value in pairs(properties) do
                    pcall(function() d[prop] = value end)
                end
                return d
            end

            if Settings.Boxes then
                UpdateOrCreateDrawing("Box", "Square", {
                    Visible = true,
                    Position = Vector2.new(boxX, boxY),
                    Size = Vector2.new(boxWidth, boxHeight),
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 2,
                    Filled = false,
                    Transparency = 1
                })
            else
                if drawings["Box"] then drawings["Box"].Visible = false end
            end

            if Settings.Tracers then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                UpdateOrCreateDrawing("Tracer", "Line", {
                    Visible = true,
                    From = rootScreen,
                    To = screenCenter,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1,
                    Transparency = 1
                })
            else
                if drawings["Tracer"] then drawings["Tracer"].Visible = false end
            end

            if Settings.Names then
                UpdateOrCreateDrawing("Name", "Text", {
                    Visible = true,
                    Text = player.Name,
                    Position = Vector2.new(rootScreen.X, headScreen.Y - 20),
                    Color = Color3.fromRGB(255, 255, 255),
                    Size = 13,
                    Center = true,
                    Outline = true,
                    Transparency = 1
                })
            else
                if drawings["Name"] then drawings["Name"].Visible = false end
            end

            if Settings.Distance then
                local distanceText = string.format("%.0f m", distance)
                UpdateOrCreateDrawing("Distance", "Text", {
                    Visible = true,
                    Text = distanceText,
                    Position = Vector2.new(rootScreen.X, headScreen.Y - 35),
                    Color = Color3.fromRGB(255, 255, 255),
                    Size = 12,
                    Center = true,
                    Outline = true,
                    Transparency = 1
                })
            else
                if drawings["Distance"] then drawings["Distance"].Visible = false end
            end

            if Settings.HealthBar then
                local health = humanoid.Health / humanoid.MaxHealth
                local barWidth = 2
                local barHeight = boxHeight
                local barX = boxX - barWidth - 2
                local barY = boxY
                UpdateOrCreateDrawing("HealthBG", "Square", {
                    Visible = true,
                    Position = Vector2.new(barX, barY),
                    Size = Vector2.new(barWidth, barHeight),
                    Color = Color3.fromRGB(50, 50, 50),
                    Filled = true,
                    Transparency = 1
                })
                local healthColor = Color3.fromRGB(255 - (health * 255), health * 255, 0)
                UpdateOrCreateDrawing("HealthFill", "Square", {
                    Visible = true,
                    Position = Vector2.new(barX, barY + (1 - health) * barHeight),
                    Size = Vector2.new(barWidth, health * barHeight),
                    Color = healthColor,
                    Filled = true,
                    Transparency = 1
                })
            else
                if drawings["HealthBG"] then drawings["HealthBG"].Visible = false end
                if drawings["HealthFill"] then drawings["HealthFill"].Visible = false end
            end

            if Settings.HeadDot then
                UpdateOrCreateDrawing("HeadDot", "Circle", {
                    Visible = true,
                    Position = Vector2.new(headScreen.X, headScreen.Y),
                    Radius = 4,
                    Color = Color3.fromRGB(255, 100, 100),
                    Filled = true,
                    Transparency = 1
                })
            else
                if drawings["HeadDot"] then drawings["HeadDot"].Visible = false end
            end

        else
            ClearPlayerDrawings(player)
        end
    end
end

-- // MENÜ KURULUMU
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "wexeGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 230, 0, 300)
MainFrame.Position = UDim2.new(0.5, -115, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 0, 130)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(120, 0, 190)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "wexe"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 0, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    ClearAllDrawings()
end)

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -50)
ContentFrame.Position = UDim2.new(0, 5, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 250)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 100, 255)
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ContentFrame

local function CreateToggle(name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name
    ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(100, 0, 160)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ContentFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = name
    TextLabel.Size = UDim2.new(0, 120, 1, 0)
    TextLabel.Position = UDim2.new(0, 8, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.GothamMedium
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Text = ""
    Button.Size = UDim2.new(0, 40, 0, 25)
    Button.Position = UDim2.new(1, -50, 0.5, -12)
    Button.BackgroundColor3 = default and Color3.fromRGB(150, 255, 100) or Color3.fromRGB(200, 50, 50)
    Button.BorderSizePixel = 0
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = ToggleFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    local state = default
    local function UpdateVisual()
        Button.BackgroundColor3 = state and Color3.fromRGB(150, 255, 100) or Color3.fromRGB(200, 50, 50)
        Button.Text = state and "ON" or "OFF"
    end
    UpdateVisual()

    Button.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisual()
        callback(state)
    end)

    return {
        SetState = function(newState)
            state = newState
            UpdateVisual()
            callback(state)
        end
    }
end

CreateToggle("ESP Acik", Settings.ESP_Enabled, function(val)
    Settings.ESP_Enabled = val
    if not val then ClearAllDrawings() end
end)
CreateToggle("Kutular (Boxes)", Settings.Boxes, function(val) Settings.Boxes = val end)
CreateToggle("Iz Cizgisi (Tracers)", Settings.Tracers, function(val) Settings.Tracers = val end)
CreateToggle("Isimler (Names)", Settings.Names, function(val) Settings.Names = val end)
CreateToggle("Mesafe (Distance)", Settings.Distance, function(val) Settings.Distance = val end)
CreateToggle("Can Bari (Health)", Settings.HealthBar, function(val) Settings.HealthBar = val end)
CreateToggle("Kafa Noktasi", Settings.HeadDot, function(val) Settings.HeadDot = val end)

local Footer = Instance.new("TextLabel")
Footer.Text = "wexe | offset ESP"
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -20)
Footer.BackgroundTransparency = 1
Footer.TextColor3 = Color3.fromRGB(200, 180, 255)
Footer.Font = Enum.Font.GothamMedium
Footer.TextSize = 11
Footer.Parent = MainFrame

RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

Players.PlayerRemoving:Connect(function(player)
    ClearPlayerDrawings(player)
end)
