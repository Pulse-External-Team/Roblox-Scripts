-- Soft Aim Settings -- 
local SoftAim = true -- true or false 
local Aim_Part = "Head" -- "Head", "Torso", "LeftLeg", "RightLeg", "LeftArm", "RightArm" 
local Target_Teammates = false -- true or false 
local Aim_Speed = 14 -- 14 is like a Pro 1-14 is Legit 14-... is like _Aimbot 
-- ESP Settings -- 
-- Tracers -- 
Tracers = false
Tracer_Origin = "Bottom" -- Middle or Bottom 
Tracer_FollowMouse = false
-- Box Esp -- 
TeamCheck = false
-- Crosshair -- 
local Crosshair_Show = true
local Crosshair_Length = 5
-- FOV Circle -- 
local FOV_Circle_Show = true
local FOV_Circle_Radius = 125
-- End Settings -- 









local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera

-- Variablen für den aktuellen Zustand der Maustasten
local rightMouseDown = false
local leftMouseDown = false
local lockedEnemy = nil

local canTrackEnemies = SoftAim  -- Wenn 'true', werden Gegner verfolgt; wenn 'false', wird das Verfolgen gestoppt.

local targetTeammates = Target_Teammates  -- Hier festlegen, ob du auch Teamkollegen anvisieren möchtest

local targetBodyPart = Aim_Part  -- Mögliche Werte: "Head", "Torso", "LeftLeg", "RightLeg", "LeftArm", "RightArm"

local rotationSpeed = Aim_Speed  -- Hier kannst du den Wert anpassen, um die Geschwindigkeit zu ändern

-- Funktion, die beim Klicken der rechten Maustaste ausgelöst wird
mouse.Button2Down:Connect(function()
    rightMouseDown = true
end)

-- Funktion, die beim Loslassen der rechten Maustaste ausgelöst wird
mouse.Button2Up:Connect(function()
    rightMouseDown = false
    lockedEnemy = nil -- Lock aufheben, wenn die rechte Maustaste losgelassen wird
end)

-- Funktion zum Zeichnen eines Kreises in der Mitte des Bildschirms
local function drawCircle()
    local circle = Drawing.new("Circle") -- Erstellen eines neuen Kreises
    circle.Visible = FOV_Circle_Show
    circle.Transparency = 1 -- Linie vollständig sichtbar
    circle.Color = Color3.fromRGB(255, 0, 0) -- Rot
    circle.Thickness = 1 -- Dicke der äußeren Linie
    circle.Radius = FOV_Circle_Radius -- Radius des Kreises
    circle.Filled = false -- Innerer Bereich transparent

    -- Berechnung der Bildschirmmitte
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    circle.Position = Vector2.new(screenWidth / 2, screenHeight / 2)

    return circle
end

-- Kreis in der Mitte des Bildschirms zeichnen
local circle = drawCircle()

-- Optional: Aktualisieren, falls sich die Bildschirmgröße ändert
game:GetService("RunService").RenderStepped:Connect(function()
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    circle.Position = Vector2.new(screenWidth / 2, screenHeight / 2)
end)

-- Funktion zum Überprüfen, ob der Gegner im Sichtfeld ist
local function isInView(enemy)
    if not enemy or not enemy.Character or not enemy.Character:FindFirstChild("Head") then
        return false
    end

    local enemyPosition = enemy.Character.Head.Position
    local viewportPoint, onScreen = camera:WorldToViewportPoint(enemyPosition)

    if onScreen then
        -- Sichtbarkeitsprüfung (Line of Sight)
        local origin = camera.CFrame.Position
        local direction = (enemyPosition - origin).unit * (enemyPosition - origin).Magnitude
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {player.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local result = workspace:Raycast(origin, direction, raycastParams)
        if result and result.Instance and result.Instance:IsDescendantOf(enemy.Character) then
            return true
        end
    end

    return false
end

-- Funktion zum Überprüfen, ob der Gegner innerhalb des Kreises ist
local function isEnemyInCircle(enemy)
    if not enemy or not enemy.Character or not enemy.Character:FindFirstChild("Head") then
        return false
    end

    local enemyPosition = enemy.Character.Head.Position
    local viewportPoint, onScreen = camera:WorldToViewportPoint(enemyPosition)

    -- Berechne die Entfernung von der Mausposition zum Mittelpunkt des Kreises
    local circleCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local enemyScreenPosition = Vector2.new(viewportPoint.X, viewportPoint.Y)
    local distance = (circleCenter - enemyScreenPosition).Magnitude

    -- Überprüfen, ob der Gegner innerhalb des Kreises ist
    return distance <= circle.Radius
end

-- Funktion zum Verfolgen des Gegners
game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    if rightMouseDown and canTrackEnemies then
        local camera = workspace.CurrentCamera

        -- Wenn kein Gegner gelockt ist oder der aktuelle Gegner nicht mehr gültig ist, suche den nächsten
        if not lockedEnemy or not lockedEnemy.Character or not isInView(lockedEnemy) or not isEnemyInCircle(lockedEnemy) then
            lockedEnemy = nil -- Lock aufheben

            -- Suche nach dem nächsten Gegner im Kreis
            local closestEnemy = nil
            local smallestMouseDistance = math.huge

            for _, potentialEnemy in pairs(game.Players:GetPlayers()) do
                if potentialEnemy ~= player and potentialEnemy.Character and potentialEnemy.Character:FindFirstChild("Head") then
                    -- Überprüfe, ob der Spieler im gleichen Team ist und ob wir Teamkollegen anvisieren dürfen
                    if targetTeammates or potentialEnemy.Team ~= player.Team then
                        if isInView(potentialEnemy) and isEnemyInCircle(potentialEnemy) then
                            -- Berechne die Entfernung der Maus zum Gegner auf dem Bildschirm
                            local enemyPosition = potentialEnemy.Character.Head.Position
                            local viewportPoint = camera:WorldToViewportPoint(enemyPosition)
                            local mousePosition = Vector2.new(mouse.X, mouse.Y)
                            local enemyScreenPosition = Vector2.new(viewportPoint.X, viewportPoint.Y)

                            local distance = (mousePosition - enemyScreenPosition).Magnitude

                            if distance < smallestMouseDistance then
                                closestEnemy = potentialEnemy
                                smallestMouseDistance = distance
                            end
                        end
                    end
                end
            end

            -- Setze den neuen Gegner, falls gefunden
            if closestEnemy then
                lockedEnemy = closestEnemy
            end
        end

        -- Wenn ein Gegner gelockt ist, bewege die Kamera auf das gewählte Körperteil
        if lockedEnemy and lockedEnemy.Character then
            local targetPart = lockedEnemy.Character:FindFirstChild(targetBodyPart)
            if targetPart then
                local enemyPosition = targetPart.Position
                local currentCFrame = camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, enemyPosition)

                -- Interpolation für sanfte Bewegung, angepasst mit der rotationSpeed-Variable
                camera.CFrame = currentCFrame:Lerp(targetCFrame, rotationSpeed * deltaTime)
            end
        end
    else
        -- Lock aufheben, wenn die rechte Maustaste losgelassen wird
        lockedEnemy = nil
    end
end)



-- Preview: https://cdn.discordapp.com/attachments/796378086446333984/818089455897542687/unknown.png
-- Made by Blissful#4992
local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0), -- Standard Box-Farbe (wird überschrieben)
    Tracer_Color = Color3.fromRGB(255, 0, 0), -- Tracer-Farbe
    Tracer_Thickness = 1, -- Tracer-Linienstärke
    Box_Thickness = 1, -- Box-Linienstärke
    Tracer_Origin = "Bottom", -- Middle oder Bottom
    Tracer_FollowMouse = false, -- Tracer folgt der Maus
    Tracers = false -- Tracer an/aus
}

local Team_Check = {
    TeamCheck = false, -- Teamfarben an/aus
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local TeamColor = false -- Standard Teamfarbe an/aus

-- // SEPARATION
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0, 0)
    quad.PointB = Vector2.new(0, 0)
    quad.PointC = Vector2.new(0, 0)
    quad.PointD = Vector2.new(0, 0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    for _, x in pairs(lib) do
        x.Visible = state
    end
end

local function IsVisible(plr)
    -- Funktion zur Sichtbarkeitsprüfung
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = plr.Character.HumanoidRootPart
        local origin = camera.CFrame.Position
        local direction = (rootPart.Position - origin).unit * (rootPart.Position - origin).magnitude
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {plr.Character, player.Character} -- Ignoriere Spieler und eigene Hindernisse
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local result = workspace:Raycast(origin, direction, raycastParams)
        return result == nil -- Wenn kein Hindernis, ist der Spieler sichtbar
    end
    return false
end

local function ESP(plr)
    local library = {
        black = NewQuad(Settings.Box_Thickness * 2, Color3.fromRGB(0, 0, 0)), -- Schwarzer Rand
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color), -- Box
        healthbar = NewLine(3, Color3.fromRGB(0, 0, 0)), -- Schwarze Healthbar
        greenhealth = NewLine(1.5, Color3.fromRGB(0, 255, 0)) -- Grüne Healthbar
    }

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                    local function Size(item)
                        item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY * 2)
                        item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2)
                        item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)
                        item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY * 2)
                    end
                    Size(library.box)
                    Size(library.black)

                    -- Update the health bar size based on the player's health
                    local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude 
                    local healthOffset = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * d

                    library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                    library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthOffset)

                    library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                    library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)

                    -- Colorize health bar based on health
                    local green = Color3.fromRGB(0, 255, 0)
                    local red = Color3.fromRGB(255, 0, 0)
                    library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)

                    -- Sichtbarkeitsprüfung
                    if IsVisible(plr) then
                        library.box.Color = Color3.fromRGB(0, 255, 0) -- Grün, wenn sichtbar
                    else
                        library.box.Color = Color3.fromRGB(255, 0, 0) -- Rot, wenn nicht sichtbar
                    end

                    Visibility(true, library)
                else
                    Visibility(false, library)
                end
            else
                Visibility(false, library)
                if not game.Players:FindFirstChild(plr.Name) then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= player.Name then
        coroutine.wrap(ESP)(v)
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name then
        coroutine.wrap(ESP)(newplr)
    end
end)

local camera = game:GetService("Workspace").CurrentCamera

-- Funktion zum Zeichnen eines Crosshairs in der Mitte des Bildschirms
local function drawCrosshair()
    -- Horizontale Linie des Crosshairs
    local horizontalLine = Drawing.new("Line")
    horizontalLine.Visible = Crosshair_Show
    horizontalLine.Color = Color3.fromRGB(255, 0, 0) -- Rot
    horizontalLine.Thickness = 1
    horizontalLine.Transparency = 1
    horizontalLine.From = Vector2.new(0, 0)
    horizontalLine.To = Vector2.new(0, 0)

    -- Vertikale Linie des Crosshairs
    local verticalLine = Drawing.new("Line")
    verticalLine.Visible = Crosshair_Show
    verticalLine.Color = Color3.fromRGB(255, 0, 0) -- Rot
    verticalLine.Thickness = 1
    verticalLine.Transparency = 1
    verticalLine.From = Vector2.new(0, 0)
    verticalLine.To = Vector2.new(0, 0)

    -- Berechnung der Bildschirmmitte
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    local centerX = screenWidth / 2
    local centerY = screenHeight / 2

    -- Setzen der Positionen der Linien, um ein Crosshair zu bilden
    local lineLength = Crosshair_Length -- Kürzere Linien (10 Pixel Länge)
    
    horizontalLine.From = Vector2.new(centerX - lineLength, centerY)  -- Linke Linie
    horizontalLine.To = Vector2.new(centerX + lineLength, centerY)    -- Rechte Linie

    verticalLine.From = Vector2.new(centerX, centerY - lineLength)    -- Obere Linie
    verticalLine.To = Vector2.new(centerX, centerY + lineLength)      -- Untere Linie

    return horizontalLine, verticalLine
end

-- Crosshair in der Mitte des Bildschirms zeichnen
local horizontalLine, verticalLine = drawCrosshair()

-- Optional: Aktualisieren, falls sich die Bildschirmgröße ändert
game:GetService("RunService").RenderStepped:Connect(function()
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    local centerX = screenWidth / 2
    local centerY = screenHeight / 2

    -- Update der Position der Linien
    local lineLength = Crosshair_Length -- Kürzere Linien (10 Pixel Länge)
    
    horizontalLine.From = Vector2.new(centerX - lineLength, centerY)
    horizontalLine.To = Vector2.new(centerX + lineLength, centerY)

    verticalLine.From = Vector2.new(centerX, centerY - lineLength)
    verticalLine.To = Vector2.new(centerX, centerY + lineLength)
end)

local camera = game:GetService("Workspace").CurrentCamera



-- Funktion zum Zeichnen eines Kreises in der Mitte des Bildschirms
local function drawCircle()
    local circle = Drawing.new("Circle") -- Erstellen eines neuen Kreises
    circle.Visible = FOV_Circle_Show
    circle.Transparency = 1 -- Linie vollständig sichtbar
    circle.Color = Color3.fromRGB(255, 0, 0) -- Rot
    circle.Thickness = 1 -- Dicke der äußeren Linie
    circle.Radius = FOV_Circle_Radius -- Radius des Kreises
    circle.Filled = false -- Innerer Bereich transparent

    -- Berechnung der Bildschirmmitte
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    circle.Position = Vector2.new(screenWidth / 2, screenHeight / 2)

    return circle
end

-- Kreis in der Mitte des Bildschirms zeichnen
local circle = drawCircle()

-- Optional: Aktualisieren, falls sich die Bildschirmgröße ändert
game:GetService("RunService").RenderStepped:Connect(function()
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    circle.Position = Vector2.new(screenWidth / 2, screenHeight / 2)
end)

-- Made by Blissful#4992

local DistFromCenter = FOV_Circle_Radius + 1
local TriangleHeight = 16
local TriangleWidth = 16
local TriangleFilled = true
local TriangleTransparency = 0
local TriangleThickness = 1
local TriangleColor = Color3.fromRGB(255, 0, 0)
local AntiAliasing = false

----------------------------------------------------------------

local Players = game:service("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:service("RunService")

local V3 = Vector3.new
local V2 = Vector2.new
local CF = CFrame.new
local COS = math.cos
local SIN = math.sin
local RAD = math.rad
local DRAWING = Drawing.new
local CWRAP = coroutine.wrap
local ROUND = math.round

local function GetRelative(pos, char)
    if not char then return V2(0,0) end

    local rootP = char.PrimaryPart.Position
    local camP = Camera.CFrame.Position
    local relative = CF(V3(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)

    return V2(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return Camera.ViewportSize/2 - v
end

local function RotateVect(v, a)
    a = RAD(a)
    local x = v.x * COS(a) - v.y * SIN(a)
    local y = v.x * SIN(a) + v.y * COS(a)

    return V2(x, y)
end

local function DrawTriangle(color)
    local l = DRAWING("Triangle")
    l.Visible = false
    l.Color = color
    l.Filled = TriangleFilled
    l.Thickness = TriangleThickness
    l.Transparency = 1-TriangleTransparency
    return l
end

local function AntiA(v)
    if (not AntiAliasing) then return v end
    return V2(ROUND(v.x), ROUND(v.y))
end

local function ShowArrow(PLAYER)
    local Arrow = DrawTriangle(TriangleColor)

    local function Update()
        local c ; c = RS.RenderStepped:Connect(function()
            if PLAYER and PLAYER.Character then
                local CHAR = PLAYER.Character
                local HUM = CHAR:FindFirstChildOfClass("Humanoid")

                if HUM and CHAR.PrimaryPart ~= nil and HUM.Health > 0 then
                    local _,vis = Camera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                    if vis == false then
                        local rel = GetRelative(CHAR.PrimaryPart.Position, Player.Character)
                        local direction = rel.unit

                        local base  = direction * DistFromCenter
                        local sideLength = TriangleWidth/2
                        local baseL = base + RotateVect(direction, 90) * sideLength
                        local baseR = base + RotateVect(direction, -90) * sideLength

                        local tip = direction * (DistFromCenter + TriangleHeight)
                        
                        Arrow.PointA = AntiA(RelativeToCenter(baseL))
                        Arrow.PointB = AntiA(RelativeToCenter(baseR))

                        Arrow.PointC = AntiA(RelativeToCenter(tip))

                        Arrow.Visible = true

                    else Arrow.Visible = false end
                else Arrow.Visible = false end
            else 
                Arrow.Visible = false

                if not PLAYER or not PLAYER.Parent then
                    Arrow:Remove()
                    c:Disconnect()
                end
            end
        end)
    end

    CWRAP(Update)()
end

for _,v in pairs(Players:GetChildren()) do
    if v.Name ~= Player.Name then
        ShowArrow(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v.Name ~= Player.Name then
        ShowArrow(v)
    end
end)

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local function DrawLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = Color3.fromRGB(255, 0, 0)  -- Standardfarbe (rot)
    l.Thickness = 1
    l.Transparency = 1
    return l
end

local function DrawESP(plr)
    repeat wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local limbs = {}
    local R15 = (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false
    if R15 then 
        limbs = {
            -- Spine
            Head_UpperTorso = DrawLine(),
            UpperTorso_LowerTorso = DrawLine(),
            -- Left Arm
            UpperTorso_LeftUpperArm = DrawLine(),
            LeftUpperArm_LeftLowerArm = DrawLine(),
            LeftLowerArm_LeftHand = DrawLine(),
            -- Right Arm
            UpperTorso_RightUpperArm = DrawLine(),
            RightUpperArm_RightLowerArm = DrawLine(),
            RightLowerArm_RightHand = DrawLine(),
            -- Left Leg
            LowerTorso_LeftUpperLeg = DrawLine(),
            LeftUpperLeg_LeftLowerLeg = DrawLine(),
            LeftLowerLeg_LeftFoot = DrawLine(),
            -- Right Leg
            LowerTorso_RightUpperLeg = DrawLine(),
            RightUpperLeg_RightLowerLeg = DrawLine(),
            RightLowerLeg_RightFoot = DrawLine(),
        }
    else 
        limbs = {
            Head_Spine = DrawLine(),
            Spine = DrawLine(),
            LeftArm = DrawLine(),
            LeftArm_UpperTorso = DrawLine(),
            RightArm = DrawLine(),
            RightArm_UpperTorso = DrawLine(),
            LeftLeg = DrawLine(),
            LeftLeg_LowerTorso = DrawLine(),
            RightLeg = DrawLine(),
            RightLeg_LowerTorso = DrawLine()
        }
    end

    local function Visibility(state)
        for i, v in pairs(limbs) do
            v.Visible = state
        end
    end

    local function SetColor(color)
        for i, v in pairs(limbs) do
            v.Color = color
        end
    end

    local function IsVisible(plr)
        -- Raycast, um zu überprüfen, ob der Spieler sichtbar ist
        local character = plr.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local origin = Camera.CFrame.Position
            local direction = (rootPart.Position - origin).unit * (rootPart.Position - origin).magnitude
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character, Player.Character} -- Ignoriere eigene Charaktere und Hindernisse
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local result = workspace:Raycast(origin, direction, raycastParams)
            return result == nil -- Wenn kein Hindernis, ist der Spieler sichtbar
        end
        return false
    end

    local function UpdaterR15()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    -- Update aller Limbs für R15
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local UT = Camera:WorldToViewportPoint(plr.Character.UpperTorso.Position)
                    local LT = Camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                    local LUA = Camera:WorldToViewportPoint(plr.Character.LeftUpperArm.Position)
                    local LLA = Camera:WorldToViewportPoint(plr.Character.LeftLowerArm.Position)
                    local LH = Camera:WorldToViewportPoint(plr.Character.LeftHand.Position)
                    local RUA = Camera:WorldToViewportPoint(plr.Character.RightUpperArm.Position)
                    local RLA = Camera:WorldToViewportPoint(plr.Character.RightLowerArm.Position)
                    local RH = Camera:WorldToViewportPoint(plr.Character.RightHand.Position)
                    local LUL = Camera:WorldToViewportPoint(plr.Character.LeftUpperLeg.Position)
                    local LLL = Camera:WorldToViewportPoint(plr.Character.LeftLowerLeg.Position)
                    local LF = Camera:WorldToViewportPoint(plr.Character.LeftFoot.Position)
                    local RUL = Camera:WorldToViewportPoint(plr.Character.RightUpperLeg.Position)
                    local RLL = Camera:WorldToViewportPoint(plr.Character.RightLowerLeg.Position)
                    local RF = Camera:WorldToViewportPoint(plr.Character.RightFoot.Position)

                    -- Update limb positions
                    limbs.Head_UpperTorso.From = Vector2.new(H.X, H.Y)
                    limbs.Head_UpperTorso.To = Vector2.new(UT.X, UT.Y)

                    limbs.UpperTorso_LowerTorso.From = Vector2.new(UT.X, UT.Y)
                    limbs.UpperTorso_LowerTorso.To = Vector2.new(LT.X, LT.Y)

                    limbs.UpperTorso_LeftUpperArm.From = Vector2.new(UT.X, UT.Y)
                    limbs.UpperTorso_LeftUpperArm.To = Vector2.new(LUA.X, LUA.Y)

                    limbs.LeftUpperArm_LeftLowerArm.From = Vector2.new(LUA.X, LUA.Y)
                    limbs.LeftUpperArm_LeftLowerArm.To = Vector2.new(LLA.X, LLA.Y)

                    limbs.LeftLowerArm_LeftHand.From = Vector2.new(LLA.X, LLA.Y)
                    limbs.LeftLowerArm_LeftHand.To = Vector2.new(LH.X, LH.Y)

                    limbs.UpperTorso_RightUpperArm.From = Vector2.new(UT.X, UT.Y)
                    limbs.UpperTorso_RightUpperArm.To = Vector2.new(RUA.X, RUA.Y)

                    limbs.RightUpperArm_RightLowerArm.From = Vector2.new(RUA.X, RUA.Y)
                    limbs.RightUpperArm_RightLowerArm.To = Vector2.new(RLA.X, RLA.Y)

                    limbs.RightLowerArm_RightHand.From = Vector2.new(RLA.X, RLA.Y)
                    limbs.RightLowerArm_RightHand.To = Vector2.new(RH.X, RH.Y)

                    limbs.LowerTorso_LeftUpperLeg.From = Vector2.new(LT.X, LT.Y)
                    limbs.LowerTorso_LeftUpperLeg.To = Vector2.new(LUL.X, LUL.Y)

                    limbs.LeftUpperLeg_LeftLowerLeg.From = Vector2.new(LUL.X, LUL.Y)
                    limbs.LeftUpperLeg_LeftLowerLeg.To = Vector2.new(LLL.X, LLL.Y)

                    limbs.LeftLowerLeg_LeftFoot.From = Vector2.new(LLL.X, LLL.Y)
                    limbs.LeftLowerLeg_LeftFoot.To = Vector2.new(LF.X, LF.Y)

                    limbs.LowerTorso_RightUpperLeg.From = Vector2.new(LT.X, LT.Y)
                    limbs.LowerTorso_RightUpperLeg.To = Vector2.new(RUL.X, RUL.Y)

                    limbs.RightUpperLeg_RightLowerLeg.From = Vector2.new(RUL.X, RUL.Y)
                    limbs.RightUpperLeg_RightLowerLeg.To = Vector2.new(RLL.X, RLL.Y)

                    limbs.RightLowerLeg_RightFoot.From = Vector2.new(RLL.X, RLL.Y)
                    limbs.RightLowerLeg_RightFoot.To = Vector2.new(RF.X, RF.Y)

                    -- Setze die Farbe basierend auf der Sichtbarkeit
                    if IsVisible(plr) then
                        SetColor(Color3.fromRGB(0, 255, 0)) -- Grün, wenn sichtbar
                    else
                        SetColor(Color3.fromRGB(255, 0, 0)) -- Rot, wenn nicht sichtbar
                    end

                    if limbs.Head_UpperTorso.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_UpperTorso.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_UpperTorso.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    connection:Disconnect() 
                end
            end
        end)
    end

    UpdaterR15()
end

-- Erstelle ESP für alle Spieler
for i, plr in pairs(game:GetService("Players"):GetPlayers()) do
    if plr ~= Player then
        DrawESP(plr)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    if plr ~= Player then
        DrawESP(plr)
    end
end)
