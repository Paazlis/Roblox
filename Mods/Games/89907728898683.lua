-- Game Name: Garden Cleaner Evolution

-- Auto Sell --
workspace.SellZones.Can1.Bin.ProximityPrompt

-- Auto Pickup --
local Event = game:GetService("ReplicatedStorage").Remotes.LeafPickedUp
Event:FireServer(
    {
        {
            AreaName = "Shed",
            IsLucky = false
        },
        {
            AreaName = "Shed",
            IsLucky = false
        },
        {
            AreaName = "Shed",
            IsLucky = false
        },
       {
            AreaName = "Shed",
            IsLucky = false
        },
       {
            AreaName = "Shed",
            IsLucky = false
        }
    }
)

-- Auto Upgrade --
-- Capacity, Cooldown, Yield,  RakeSpeed, RakeArea, RakeRange, BlowerRange, BlowerRadius, BlowerCooldown
local Event = game:GetService("ReplicatedStorage").Remotes.UpgradeRequest
Event:FireServer(
    "Capacity"
)

-- Claim Quest --
game:GetService("Players").LocalPlayer.PlayerGui.QuestGui.ActiveQuestFrame.ScrollingFrame.QuestCard.Visible and Parent
game:GetService("Players").LocalPlayer.PlayerGui.QuestGui.ActiveQuestFrame.ScrollingFrame:GetChildren()[11].ButtonFrame.ClaimButton
game:GetService("Players").LocalPlayer.PlayerGui.QuestGui.ActiveQuestFrame.ScrollingFrame:GetChildren()[5].ButtonFrame.ClaimButton.ClaimGradient.Enabled
game:GetService("Players").LocalPlayer.PlayerGui.QuestGui.ActiveQuestFrame.ScrollingFrame:GetChildren()[5].ButtonFrame.ClaimButton.LockedGradient

-- Collect Secret Stars --
workspace.SecretStars.Star1
workspace.SecretStars.Star1.Transparency

-- Auto Rebirth --
