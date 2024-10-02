-- Skript um alle anderen Spieler rot zu markieren, außer dem lokalen Spieler

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Funktion, um einen Spieler rot zu markieren
local function markPlayerRed(player)
    if player ~= LocalPlayer then
        local character = player.Character
        if character then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Bright red") -- Setze die Farbe auf Rot
                end
            end
        end
    end
end

-- Markiere bestehende Spieler
for _, player in ipairs(Players:GetPlayers()) do
    markPlayerRed(player)
end

-- Funktion, die aufgerufen wird, wenn ein neuer Spieler beitritt
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        markPlayerRed(player)
    end)
end)

-- Überwache die Charaktere bestehender Spieler
Players.PlayerRemoving:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        markPlayerRed(player)
    end)
end)
