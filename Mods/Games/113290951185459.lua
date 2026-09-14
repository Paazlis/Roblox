-- Equip Best Unit --
local Event = game:GetService("ReplicatedStorage").Network.PlotService.RE.EquipBest
Event:FireServer()

-- Auto Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.Rebirth.Requirement.ProgressBar.InnerBar
game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.Rebirth.Buttons.Rebirth
game:GetService("ReplicatedStorage").Network.RebirthService.RE.Rebirth:FireServer()

-- Collect Cash --
local Event = game:GetService("ReplicatedStorage").Network.PlotService.RE.CollectBalance
Event:FireServer(
    2 -- Slot Index
)

workspace.Plots.Claimed["4c4a0c44-79b7-406a-919d-ee63dd4f40e9"].Slots["2"]

-- Buy Dice --
game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.DiceShop.Content.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.DiceShop.Content.ScrollingFrame.Water
game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.DiceShop.Content.ScrollingFrame.Water.Buttons.Buy
game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.DiceShop.Content.ScrollingFrame.Water.Buttons.Buy.Frame.Info.Price.Text -- $, equipped, equip.
--game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.DiceShop.Content.ScrollingFrame.Water.Info.Title.Rarity
--game:GetService("Players").LocalPlayer.PlayerGui.Root.Menus.DiceShop.Content.ScrollingFrame.Water.Info.Title.Dice
local Event = game:GetService("ReplicatedStorage").Network.DiceShopService.RE.BuyDice
Event:FireServer(
    "Water"
)

-- Auto Roll --
local Event = game:GetService("ReplicatedStorage").Network.RollService.RE.SetAutoRoll
Event:FireServer(
    true -- on/off
)

-- Plot --
workspace.Plots.Claimed["4c4a0c44-79b7-406a-919d-ee63dd4f40e9"].Label.BillboardGui.Avatar.Image
workspace.Plots.Claimed

-- need load configuration --
