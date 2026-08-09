-- Upgrade --
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Frames.Upgrades.Main.Cards
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Frames.Upgrades.Main.Cards.SwordRange.Header
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Frames.Upgrades.Main.Cards.SwordRange.Buy.BuyButton

-- Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Frames.Rebirth.Main.Holder.Buttons.RebirthButton

-- Auto Merge --
workspace.SwordsRuntime
workspace.SwordsRuntime:GetChildren()[29] -- SwordId string, OwnerUserId number
workspace.SwordsRuntime:GetChildren()[29].GrabHitbox
-- drop --
local Event = game:GetService("ReplicatedStorage").NetRemotes.Event
Event:FireServer(
    "DropSword",
    nil
)
