local teamName = "Survivor"  -- Der Name des Teams, aus dem der Spieler zufällig ausgewählt wird
local players = game:GetService("Players")
local teams = game:GetService("Teams")

-- Funktion, die einen zufälligen Spieler aus dem Team "Survivor" auswählt und dich dorthin teleportiert
local function teleportToRandomSurvivor()
    -- Hole das Team "Survivor"
    local team = teams:FindFirstChild(teamName)
    if not team then
        warn("Team " .. teamName .. " wurde nicht gefunden!")
        return
    end

    -- Hole alle Spieler, die sich im Team "Survivor" befinden
    local survivors = {}
    for _, player in ipairs(players:GetPlayers()) do
        if player.Team == team then
            table.insert(survivors, player)
        end
    end

    -- Falls es keine Spieler im Team gibt
    if #survivors == 0 then
        warn("Keine Spieler im Team " .. teamName)
        return
    end

    -- Wähle einen zufälligen Spieler aus
    local randomSurvivor = survivors[math.random(1, #survivors)]
    
    -- Teleportiere den Spieler zum zufälligen Survivor
    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(randomSurvivor.Character.PrimaryPart.CFrame)
end

-- Rufe die Funktion auf, um zu einem zufälligen Spieler zu teleportieren
teleportToRandomSurvivor()
