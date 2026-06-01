-- loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Mercury/ExampleMercury.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Mercury/init.luau"))()

local Gui = Library:Create({
    Theme = Library.Themes.Serika
})

Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot2"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot3"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot4"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot5"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot6"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot7"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot8"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot8"
})
Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot9"
})
local Tab = Gui:Tab({
    Icon = "rbxassetid://6034996695",
    Name = "Aimbot"
})


Tab:Button({
    Name = "show prompt",
    Callback = function()
        Tab:Prompt({
            Title = "baby",
            Text = "shark doo doo doo doo im blank lmao",
            Buttons = {
                Ok = function()
                    Tab:Prompt({
                        Followup = true,
                        Title = "really?",
                        Text = "you sure?=",
                        Buttons = {
                            Yes = function()
                                Tab:Prompt({
                                    Followup = true,
                                    Title = "xd",
                                    Text = "wow",
                                    Buttons = {
                                        nice= function()
                                            Gui:SetStatus("github")
                                        end,
                                        test = function()
                                            Gui:SetStatus("money")
                                        end
                                    }
                                })
                            end
                        }
                    })
                end
            }
        })
    end
})
Tab:Keybind({
    Callback = function(Value)
        Gui:Prompt()
    end
})
Tab:Dropdown({
    Name = "Dropdown",
    Description = "Dropdown",
    StartingText = "Bodypart",
    Items = {
        "Head",
        "Torso",
        "Random"
    }
})
Tab:Dropdown({
    Name = "yes",
    StartingText = "Number",
    Items = {
        {"One", 1},
        {"Two", 2},
        {"Three", 3}
    },
    Description = "amongu s",
    Callback = function(Value)
        print(Value)
    end
})
Tab:Slider({
    Callback = function(Value)
        Gui:SetStatus(Value)
    end
})

Tab:Textbox({
    Callback = function(Value)
        Gui:Prompt({Text = Value})
    end
})

Tab:ColorPicker({
    Name = "your mom's color",
    Style = Library.ColorPickerStyles.Legacy,
    Description = "Click to adjust color...",
    Callback = function(Value)
        print(Value)
    end
})
