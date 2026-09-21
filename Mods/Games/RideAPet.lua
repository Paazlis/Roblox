-- Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Main.Rebirth.Segment2.ProgressBarFrame.ProgressBar
game:GetService("Players").LocalPlayer.PlayerGui.Main.Rebirth.Rebirth
game:GetService("ReplicatedStorage").Remotes.Game.Rebirth:FireServer()

-- Place Best --
game:GetService("Players").LocalPlayer.PlayerGui.Main.PetsTracker.PlaceBest

-- Claim Index --
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("ClaimIndexReward"):FireServer() game:GetService("Players").LocalPlayer.PlayerGui.Main.Index.PetProgress.Claim.Visible == true

-- my plot --
workspace.Plots.Plot -- NestsOwnerLoaded
workspace.Plots.Plot.Baseplate

-- open egg --
local args = {
	{
		EggKey = "eb7f4366-64c4-437d-b18c-6dc68ac1a5c6"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Hatch"):FireServer(unpack(args))
workspace.Plots.Plot.Eggs["Brown Egg"] -- EggKey and OwnerUserId

-- upgrade  --

-- Hatch Lucky --
local args = {
	"Max"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Plot"):WaitForChild("Upgrades"):FireServer(unpack(args))

-- Buy Food --
local args = {
	"Food",
	"Grass"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("BuyWithCash"):FireServer(unpack(args))
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Food
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Food.Grass
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Food.Grass.CashPayment.Frame.Dollar
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Food.Grass.ProductExpander.Price.Text =="$" or .TextColor3 == 255, 45, 45

-- Buy Gear --
local args = {
	"Gears",
	"Advanced Radar"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("BuyWithCash"):FireServer(unpack(args))
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Gears
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Gears["Advanced Radar"].CashPayment.Frame.Dollar
game:GetService("Players").LocalPlayer.PlayerGui.Main.Shop.Holders.Gears["Advanced Radar"].ProductExpander.Price

-- add settings feature and load config and donate link --
