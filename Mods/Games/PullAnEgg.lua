-- Auto Train --
local Event = game:GetService("ReplicatedStorage").SharedModules.Network.Remotes["Activate Dumbell"]
Event:FireServer()

-- Auto Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Rebirth.Main.Rebirth
game:GetService("Players").LocalPlayer.PlayerGui.Rebirth.Main.ProgressBar.Bar

-- Auto Farm --
workspace.Live.Guardians
workspace.Live.Friends:GetChildren()[24].RootPart.StealPromptAttach.StealPrompt

-- Turn Fling --
local v1 = script.Parent:WaitForChild("Humanoid", 30)
v1:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
v1:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
v1:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)


