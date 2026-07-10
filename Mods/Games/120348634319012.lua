local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local PickpocketGui = PlayerGui:WaitForChild("PickpocketGui")
local Root = PickpocketGui:WaitForChild("Root")
local Container = Root:WaitForChild("Container")

local Arrow = Container:WaitForChild("ArrowIndicator")
local ProgressBar = Container:WaitForChild("ProgressBar")
local TapButton = Container:WaitForChild("KeyHint"):WaitForChild("PCButton")

local autoPickpocketEnabled = false
local arrowConnection = nil
local guiEnabledConnection = nil

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
Window:AddToggle({
    Text = "Auto Pick Pocket", 
    Value = false, 
    Callback = function(value)
        autoPickpocketEnabled = value
        
        if autoPickpocketEnabled and PickpocketGui.Enabled then
            startAutomation()
        else
            stopAutomation()
        end
    end
)

Window:AddLabel("YouTube: Crokyreo")
