wait(1)

game.StarterGui:SetCore("SendNotification", {
    Title = "ANTI AFK";
    Text = "ANTI AFK IS ENABLED";
    Icon = "rbxassetid://6023426923"; -- Beispiel für ein Achievement-ähnliches Icon
    Duration = 2; -- Anzeigezeit in Sekunden
})


local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

-- Wenn der Spieler als inaktiv erkannt wird, simuliert das Skript eine Aktion, um den AFK-Kick zu verhindern
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new()) -- Simuliert einen Rechtsklick

    -- Benachrichtigung anzeigen, wenn der Klick simuliert wird
    game.StarterGui:SetCore("SendNotification", {
        Title = "Anti AFK!";
        Text = "Roblox try to kick you!";
        Icon = "rbxassetid://6023426923"; -- Beispiel für ein Achievement-ähnliches Icon
        Duration = 4; -- Anzeigezeit in Sekunden
    })
end)
