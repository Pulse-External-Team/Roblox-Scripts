local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Funktion, um das FOV zu setzen
local function setFOV(newFOV)
    camera.FieldOfView = newFOV
end

-- Beispiel: FOV auf 90 setzen
setFOV(120)

-- Du kannst den Wert hier anpassen
