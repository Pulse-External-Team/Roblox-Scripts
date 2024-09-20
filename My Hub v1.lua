local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- Hauptfenster
local windowFrame = Instance.new("Frame", screenGui)
windowFrame.Size = UDim2.new(0, 700, 0, 400)
windowFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
windowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
windowFrame.BorderSizePixel = 0
windowFrame.BackgroundTransparency = 0.05

-- Kopfzeile
local titleBar = Instance.new("Frame", windowFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Roblox Executor"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSans

-- Minimieren-Button
local minimizeButton = Instance.new("TextButton", titleBar)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minimizeButton.BorderSizePixel = 0
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 14

-- Schließen-Button
local closeButton = Instance.new("TextButton", titleBar)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14

-- Minimieren
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    windowFrame.Visible = not isMinimized
    isMinimized = not isMinimized
end)

-- STRG-Taste zum Öffnen
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl and isMinimized then
        windowFrame.Visible = true
        isMinimized = false
    end
end)

-- Hover-Effekt für den Schließen-Button
closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(232, 17, 35)
end)

closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end)

-- Schließen des Fensters
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- TextBox für Lua-Code
local textBox = Instance.new("TextBox", windowFrame)
textBox.Size = UDim2.new(0, 600, 0, 250)
textBox.Position = UDim2.new(0, 50, 0, 40)
textBox.Text = "-- Made by 321Remag\nprint(\"Hello World\")"
textBox.TextSize = 14
textBox.Font = Enum.Font.Code
textBox.TextColor3 = Color3.fromRGB(0, 255, 255)
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBox.BorderSizePixel = 0
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.MultiLine = true

-- Buttons erstellen
local function createButton(text, position)
    local button = Instance.new("TextButton", windowFrame)
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14

    -- Hover-Effekte
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)

    return button
end

local executeButton = createButton("Execute", UDim2.new(0, 50, 0, 300))
local clearButton = createButton("Clear", UDim2.new(0, 160, 0, 300))
local settingsButton = createButton("Settings", UDim2.new(0, 270, 0, 300))
local scriptHubButton = createButton("Script Hub", UDim2.new(0, 380, 0, 300))

-- Zuerst inaktiv setzen
executeButton.Active = false
executeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Funktion für Clear-Button
clearButton.MouseButton1Click:Connect(function()
    textBox.Text = ""
end)

-- Funktion für Execute-Button
executeButton.MouseButton1Click:Connect(function()
    local code = textBox.Text
    if validateCode(code) then
        loadstring(code)()  -- Nur validierten Code ausführen
    else
        warn("Code validation failed.")
    end
end)

function validateCode(code)
    return true  -- Placeholder für Validierungslogik
end

-- Bewegung des Fensters durch Ziehen der Titelleiste
local dragging = false
local dragInput, mousePos, framePos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = windowFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        windowFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Script Hub GUI erstellen
local function createScriptHub()
    local hubFrame = Instance.new("Frame", screenGui)
    hubFrame.Size = UDim2.new(0, 400, 0, 300)
    hubFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    hubFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hubFrame.BorderSizePixel = 0
    hubFrame.Visible = false  -- Standardmäßig unsichtbar

    local hubTitle = Instance.new("TextLabel", hubFrame)
    hubTitle.Size = UDim2.new(1, 0, 0, 30)
    hubTitle.BackgroundTransparency = 1
    hubTitle.Text = "Script Hub"
    hubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hubTitle.TextSize = 20
    hubTitle.Font = Enum.Font.SourceSansBold

    -- Buttons im Script Hub
    local infiniteYieldButton = createButton("Infinite Yield", UDim2.new(0, 50, 0, 50))
    local walkSpeedButton = createButton("Walk Speed", UDim2.new(0, 160, 0, 50))
    local uncCheckEnvButton = createButton("UNCCheckEnv", UDim2.new(0, 270, 0, 50))
    local dexExplorerButton = createButton("DEX Explorer", UDim2.new(0, 50, 0, 100))
    local namelessAdminButton = createButton("NamelessAdmin", UDim2.new(0, 160, 0, 100))
    local aimbotButton = createButton("Aimbot by Gordon", UDim2.new(0, 270, 0, 100))
    local myESPButton = createButton("My ESP", UDim2.new(0, 50, 0, 150))
    local fakeBanButton = createButton("Fake Ban", UDim2.new(0, 160, 0, 150))
    local tpPlayerButton = createButton("TP Player", UDim2.new(0, 270, 0, 150))
    local backButton = createButton("Back", UDim2.new(0, 50, 0, 200))

    infiniteYieldButton.Parent = hubFrame
    walkSpeedButton.Parent = hubFrame
    uncCheckEnvButton.Parent = hubFrame
    dexExplorerButton.Parent = hubFrame
    namelessAdminButton.Parent = hubFrame
    aimbotButton.Parent = hubFrame
    myESPButton.Parent = hubFrame
    fakeBanButton.Parent = hubFrame
    tpPlayerButton.Parent = hubFrame
    backButton.Parent = hubFrame

    -- Funktionalitäten der Buttons
    infiniteYieldButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    walkSpeedButton.MouseButton1Click:Connect(function()
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        getgenv().Theme = "DarkTheme"
        
        local Window = Library.CreateLib("Test", getgenv().Theme)
        local Tab = Window:NewTab("LocalPlayer")
        local Section = Tab:NewSection("Speed")

        Section:NewTextBox("Character speed", "Type in a number to make the speed u want", function(txt)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = txt
        end)

        Section:NewSlider("speed but slider", "Yo", 500, 0, function(speed)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end)

        Section:NewButton("Infinite yield", "alot of better", function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)

        Section:NewKeybind("Toggle ui", "makes the gui invisible, press again to make it visible", Enum.KeyCode.RightAlt, function()
            Library:ToggleUI()
        end)
    end)

    uncCheckEnvButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/unified-naming-convention/NamingStandard/refs/heads/main/UNCCheckEnv.lua'))()
    end)

    dexExplorerButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0", true))()
    end)

    namelessAdminButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))()
    end)

    aimbotButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Mick-gordon/Hyper-Escape/main/DeleteMobCheatEngine.lua'))()
    end)

    myESPButton.MouseButton1Click:Connect(function()
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer

        local function markPlayer(player)
            if player == localPlayer then return end

            if player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.Parent = player.Character
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            markPlayer(player)
        end

        Players.PlayerAdded:Connect(markPlayer)
    end)

    fakeBanButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Pulse-External-Team/Roblox-Scripts/main/Pulse%20External.lua'))()
    end)

    tpPlayerButton.MouseButton1Click:Connect(function()
        -- https://rbxscript.com/scripts-copy/RobloxWalkSpeedGUI-mDtmJ
        loadstring(game:HttpGet("https://pastebin.com/raw/AbDM2er1"))()
    end)

    -- Zurück-Button
    backButton.MouseButton1Click:Connect(function()
        hubFrame.Visible = false
        windowFrame.Visible = true
    end)

    return hubFrame
end

local scriptHubFrame = createScriptHub()

-- Script Hub Button Funktion
scriptHubButton.MouseButton1Click:Connect(function()
    windowFrame.Visible = false
    scriptHubFrame.Visible = true
end)
