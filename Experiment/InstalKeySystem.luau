
    local GetKeyBtn = Instance.new("TextButton", MainFrame)
    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 40)
    GetKeyBtn.Position = UDim2.new(0.525, 0, 0, currentYOffset + 65)
    GetKeyBtn.Text = "GET KEY"
    GetKeyBtn.Font = "GothamBold";
    GetKeyBtn.TextSize = 14
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35);
    GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", GetKeyBtn)

    local Status = Instance.new("TextLabel", MainFrame)
    Status.Name = "StatusLabel"
    Status.Size = UDim2.new(1, 0, 0, 30)
    Status.Position = UDim2.new(0, 0, 0, currentYOffset + 115)
    Status.BackgroundTransparency = 1
    Status.Text = "Waiting for input..."
    Status.TextColor3 = Color3.fromRGB(150, 150, 150)
    Status.Font = Enum.Font.Gotham;
    Status.TextSize = 12
    
    -- Dynamically adjust main frame height based on active elements
    MainFrame.Size = UDim2.new(0, 340, 0, currentYOffset + 160)

    -- Logic
    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key == "" then Status.Text = "Enter a key!"; return end
        Status.Text = "Verifying..."
        local success, msg = redeemKey(key)
        if success then
            Status.Text = "Success! Loading..."
            Status.TextColor3 = Color3.fromRGB(0, 255, 100)
            task.wait(0.5)
            ScreenGui:Destroy()
            StartMainScript()
        else
            Status.Text = msg
            Status.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        Status.Text = "Getting Link..."
        local success, link = cacheLink()
        if success then
            fSetClipboard(link)
            Status.Text = "Link Copied!"
            Status.TextColor3 = Color3.fromRGB(0, 170, 255)
        else
            Status.Text = "Error: " .. tostring(link)
        end
    end)

    -- Auto Check Saved Key
    if isfile and isfile(Config.KeyFileName) then
        local savedKey = readfile(Config.KeyFileName)
        if savedKey ~= "" then
            Status.Text = "Found saved key, verifying..."
            task.spawn(function()
                local success, msg = redeemKey(savedKey)
                if success then
                    Status.Text = "Auto-login success!"
                    Status.TextColor3 = Color3.fromRGB(0, 255, 100)
                    task.wait(0.5)
                    ScreenGui:Destroy()
                    StartMainScript()
                else
                    Status.Text = "Saved key expired or invalid."
                    Status.TextColor3 = Color3.fromRGB(255, 150, 0)
                end
            end)
        end
    end
end

-- Check if main script GUI is already open
local player = game:GetService("Players").LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

if pGui:FindFirstChild(Config.MainGuiName) then
    StartMainScript() -- Run if main script is already active
    return
end

-- Initialize Key System GUI
CreateGUI()
