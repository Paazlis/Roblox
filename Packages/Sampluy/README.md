# Tora Library
A simple UI library featuring a clean, polished design.
Credit To Paazlis
### Setup The Library
```lua
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau",true))()
```


### Adding Tab
```lua
local Window = UI:CreateWindow("Your Title")
```


### Adding Button
```lua
local Button = Window:AddButton({
	Text = "Click me",
	Callback = function()
      print("hello world")
  end
})
```



### Adding Folder
```lua
local Folder = Window:AddFolder("Folder")
```


### Adding Toggle
```lua
local Toggle = Folder:AddToggle({
	Text = "Toggle",
  Value = false,
	Flag = "toggle",
	Callback = function(value)
      print(value)
  end
})
```




### Adding Label
```lua
local Label = Folder:AddLabel({
	Text = "Credits: None",
})
```





### Adding Slider
```lua
local Slider = Folder:AddSlider({
	Text = "Fov",
  Value = 10,
	Range = {70,170},
  Flag = "slider",
	Callback = function(value)
      print(value)
  end
})
```





### Adding Input
```lua
local Input = Folder:AddInput({
	Text = "Speed",
  Value = "",
	Callback = function(value)
      print(value)
  end
})
```





### Adding Dropdown
```lua
folder:AddList({
    text = "Color",
    values = {"Red", "Green", "Blue"},
    callback = function(value)
        print("Selected color:", value)
    end,
    open = false,
    flag = "color_option"
})
```





### Adding Bind
```lua
folder:AddBind({
    text = "bind",
    key = "X",
    hold = false,
    callback = function()
    end
})
```

### Close Lib
```lua
library:Close()
```


### Credits : Paazlis
