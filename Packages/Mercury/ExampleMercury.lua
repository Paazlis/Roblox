-- loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Mercury/ExampleMercury.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Mercury/init.luau"))()

local Gui = Library:Create({
    Theme = Library.Themes.Serika
})

local Tab = Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot"
})

local Label = Gui:Label({
    Name = "Selemat datang di aimbot",
    Description = "Kegunaan untuk mentarget yang terdekat pemain"
})
