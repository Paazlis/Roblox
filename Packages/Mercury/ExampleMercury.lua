-- loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Mercury/ExampleMercury.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Mercury/init.luau"))()

local Window = Library:Create({
    Theme = Library.Themes.Serika
})

local Tab = Window:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot"
}

Tab:Button({
    Name = "Show Prompt",
    Callback = function()
        tab:Prompt{
            Title = "baby",
            Text = "nice to meet you",
            Buttons = {
                Ok = function()
                    Tab:Prompt{
                        Followup = true,
                        Title = "really?",
                        Text = "you sure?=",
                        Buttons = {
                            Yes = function()
                                Tab:Prompt{
                                    Followup = true,
                                    Title = "lol",
                                    Text = "Welcome",
                                    Buttons = {
                                        Learn = function()
                                            Window:set_status("money")
                                        end,
                                        Lazy = function()
                                            Window:set_Status("homeless")
                                        end
                                    }
                                }
                            end,
                        }
                    }
                end,
            }
        }
    end
})

Tab:Keybind({Callback = function()
    Window:Prompt()
end})

Tab:Dropdown({
    Name = "Dropdown",
    Description = "Dropdown Description",
    StartingText = "Bodypart",
    Items = {
        "Head",
        "Torso",
        "Random"
    }
})

Tab:Slider({
    Name = "Slider",
    Description = "Slider Description",
    StartingText = "Aimbot Speed",
    Callback = function(v)
       Window:set_status(v)
    end
})

Tab:Textbox({Callback = function(v)
    Window:Prompt{Text = v}
end,})

Tab:color_picker({
    Name = "Color Picker",
    Style = Library.ColorPickerStyles.Legacy,
    Description = "Click to adjust color...",
    Callback = function(color)
        print(color)
    end,
})
