-- UI Library
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

-- Services & Player UI Elements
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local PickpocketGui = PlayerGui:WaitForChild("PickpocketGui")
local Root = PickpocketGui:WaitForChild("Root")
local Container = Root:WaitForChild("Container")

local Arrow = Container:WaitForChild("ArrowIndicator")
local ProgressBar = Container:WaitForChild("ProgressBar")
local TapButton = Container:WaitForChild("KeyHint"):WaitForChild("PCButton")

-- State Variables
local autoPickpocketEnabled = false
local arrowConnection = nil
local guiEnabledConnection = nil

-- Fungsi untuk memeriksa apakah Arrow berada di dalam GreenZone
local function checkArrowPosition()
    if not autoPickpocketEnabled or not PickpocketGui.Enabled then return end

    -- Mengambil titik tengah (Center X) dari Arrow
    local arrowCenter = Arrow.AbsolutePosition.X + (Arrow.AbsoluteSize.X / 2)

    -- Memeriksa semua children di dalam ProgressBar
    for _, zone in ipairs(ProgressBar:GetChildren()) do
        if zone:IsA("GuiObject") and zone.Name:find("GreenZone") and zone.Visible then
            local zoneLeft = zone.AbsolutePosition.X
            local zoneRight = zoneLeft + zone.AbsoluteSize.X

            -- Jika Arrow berada di dalam GreenZone
            if arrowCenter >= zoneLeft and arrowCenter <= zoneRight then
                
                -- FIX: Membuat data input palsu agar script game tidak error nil
                local fakeInput = {
                    UserInputType = Enum.UserInputType.MouseButton1,
                    UserInputState = Enum.UserInputState.Begin,
                    Position = Vector3.new(0,0,0)
                }
                
                -- Kirim sinyal Activated bersamaan dengan data input palsu
                firesignal(TapButton.Activated, fakeInput)
                
                break -- Keluar dari loop setelah berhasil menekan
            end
        end
    end
end

-- Fungsi untuk mulai mengamati pergerakan Arrow
local function startAutomation()
    if not arrowConnection then
        arrowConnection = Arrow:GetPropertyChangedSignal("AbsolutePosition"):Connect(checkArrowPosition)
    end
end

-- Fungsi untuk menghentikan pengamatan
local function stopAutomation()
    if arrowConnection then
        arrowConnection:Disconnect()
        arrowConnection = nil
    end
end

-- Mengamati perubahan PickpocketGui.Enabled
guiEnabledConnection = PickpocketGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if PickpocketGui.Enabled and autoPickpocketEnabled then
        startAutomation()
    else
        stopAutomation()
    end
end)

-- Pembuatan Window UI
local Window = UI:CreateWindow({
    Name = "Pickpocket",
    Destroying = function()
        stopAutomation()
        if guiEnabledConnection then
            guiEnabledConnection:Disconnect()
        end
    end
})

-- Toggle Button
Window:AddToggle("Auto Pick Pocket", false, function(value)
    autoPickpocketEnabled = value
    
    if autoPickpocketEnabled and PickpocketGui.Enabled then
        startAutomation()
    else
        stopAutomation()
    end
end)
