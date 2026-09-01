workspace.Map.Plots.Plot_2 -- Owner string 

-- Collect Cash --
workspace.Map.Plots.Plot_2.CollectAll.PRIMARY

local Event = game:GetService("ReplicatedStorage").GameSystems.Packages.Networker["leifstout_networker@0.3.0"].networker._remotes.PlotService.RemoteEvent
Event:FireServer(
    "Collect"
)

-- Auto Upgrade --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.UpgradeFrame.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Frames.UpgradeFrame.ScrollingFrame.MaxPlacement.info.name
game:GetService("Players").LocalPlayer.PlayerGui.Frames.UpgradeFrame.ScrollingFrame.ObbySize.buttons.buy.BackgroundColor3 == Color3.fromRGB(0, 255, 0)

-- Buy Part --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame["Big Wedge"].info.name
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame["Big Wedge"].info.stock.TextColor3 == Color3.fromRGB(0, 255, 0)
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame["Big Wedge"].buttons.buy.BackgroundColor3 == Color3.fromRGB(0, 255, 0)

-- Buy ASMR --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.ASMRFrame.ScrollingFrame["67 Keyboard"].buttons.buy.BackgroundColor3 == Color3.fromRGB(0, 255, 0)
game:GetService("Players").LocalPlayer.PlayerGui.Frames.ASMRFrame.ScrollingFrame["67 Keyboard"].info.name
game:GetService("Players").LocalPlayer.PlayerGui.Frames.ASMRFrame.ScrollingFrame["67 Keyboard"].info.stock.TextColor3 == Color3.fromRGB(0, 255, 0)

-- Like Button --
local Event = game:GetService("ReplicatedStorage").GameSystems.Packages.Networker["leifstout_networker@0.3.0"].networker._remotes.PlotService.RemoteEvent
Event:FireServer(
    "LikePlot",
    game:GetService("Players").hermans121314
)

-- Auto Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.RebirthFrame.ScrollingFrame.Buttons.Rebirth
game:GetService("Players").LocalPlayer.PlayerGui.Frames.RebirthFrame.ScrollingFrame.Bar.Frame
