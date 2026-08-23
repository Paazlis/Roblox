-- Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Main.RebirthBackground.RebirthButtons.RebirthButton
game:GetService("Players").LocalPlayer.PlayerGui.Main.RebirthBackground.RequirementsFrame.MoneyNeededBG.Bar
-- need click 5x
game:GetService("Players").LocalPlayer.PlayerGui.LuckyBlock.EndBrainrotFrame.FinalBrainrotFrame.Close

-- Upgrade --
game:GetService("Players").LocalPlayer.PlayerGui.Main.UpgradesBackground.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Main.UpgradesBackground.ScrollingFrame["Aura Headphones"].BuyButton
game:GetService("Players").LocalPlayer.PlayerGui.Main.UpgradesBackground.ScrollingFrame["Aura Headphones"].LockedFrame.Visible == false

-- Click --
local Event = game:GetService("ReplicatedStorage").Remotes.ClickBrainrot
Event:FireServer(
    1
)
game:GetService("Players").LocalPlayer.PlayerGui.Main.AutoClickerButton
game:GetService("Players").LocalPlayer.PlayerGui.Main.AutoClickerButton.TimeLabel.Text == "Ready"
