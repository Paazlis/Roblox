local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Bases = workspace:FindFirstChild("Bases")
local CollectNuke = false

local Window = UI:CreateWindow({
    Name = "Merge a Nuke",
    Destroying = function()
        CollectNuke = false
    end
})

Window:AddToggle({
    Name = "Auto Merge",
    Callback = function(value)
        CollectNuke = value
    end
})

-- Fungsi mengambil base milik player
local function getMyBase()
    if not Bases then return nil end
    for _, base in ipairs(Bases:GetChildren()) do
        if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return base
        end
    end
    return nil
end

-- Fungsi mengambil daftar nuke di base (diurutkan dari TIER TERBESAR ke TERKECIL)
-- Diubah ke terbesar dulu agar nuke seperti Tier 64 di foto kamu langsung diprioritaskan untuk di-merge!
local function getNukes(base)
    local nukes = {}
    local nukeFolder = base:FindFirstChild("Nukes")
    
    if nukeFolder then
        for _, nuke in ipairs(nukeFolder:GetChildren()) do
            local tier = tonumber(nuke:GetAttribute("Tier"))
            if tier then
                table.insert(nukes, nuke)
            end
        end

        table.sort(nukes, function(a, b)
            return tonumber(a:GetAttribute("Tier")) > tonumber(b:GetAttribute("Tier"))
        end)
    end
    
    return nukes
end

-- Fungsi Drop Nuke yang aman
local function dropNuke()
    pcall(function()
        local screenGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        local dropButton = screenGui.HoldingFrame.Frame.Drop.TextButton
        if dropButton and firesignal then
            firesignal(dropButton.Activated)
        end
    end)
end

-- Fungsi mendeteksi nuke yang sedang dipegang
local function getHeldNuke()
    local camera = workspace.CurrentCamera
    if camera then
        return camera:FindFirstChild("HeldNukeVisual")
    end
    return nil
end

-- Loop Utama Auto-Farm
task.spawn(function()
    while true do
        task.wait()
        if not CollectNuke then continue end

        local base = getMyBase()
        if not base then continue end
        
        local nukes = getNukes(base)
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
        
        if not humanoid or not hrp then continue end

        local heldNuke = getHeldNuke()

        -- JIKA TANGAN LAGI PEGANG NUKE
        if heldNuke then
            local heldTier = tonumber(heldNuke:GetAttribute("Tier"))
            if heldTier then
                local foundMatch = false
                
                -- Cek apakah ada nuke yang sewarna/setier di tanah
                for _, nuke in ipairs(nukes) do
                    if nuke.Parent and tonumber(nuke:GetAttribute("Tier")) == heldTier then
                        foundMatch = true
                        break
                    end
                end
                
                -- PERBAIKAN UTAMA: Jika tidak ada pasangan di tanah, JANGAN langsung drop!
                -- Cek dulu, apakah nuke di base sudah menumpuk banyak (misal lebih dari 8 nuke)?
                -- Kalau base masih kosong/muat, jangan didrop, biarkan ditaruh atau cari nuke lain.
                if not foundMatch and #nukes >= 12 then 
                    dropNuke()
                    task.wait(0.5) -- Jeda biar tidak spam drop
                    continue
                end
            end
        end

        -- JALAN MENUJU NUKE TARGET
        local walked = false
        for _, nuke in ipairs(nukes) do
            if not CollectNuke then break end
            if not (nuke and nuke.Parent) then continue end

            local tier = tonumber(nuke:GetAttribute("Tier"))
            
            -- Jika sedang memegang nuke, prioritaskan/wajibkan hanya mendekati tier yang sama
            local currentHeld = getHeldNuke()
            if currentHeld then
                local heldTier = tonumber(currentHeld:GetAttribute("Tier"))
                if heldTier and tier ~= heldTier then
                    continue -- Lewati nuke yang beda tier (seperti melewati tier 64 saat pegang 16)
                end
            end

            local targetPosition = nil
            if nuke:IsA("BasePart") then
                targetPosition = nuke.Position
            elseif nuke:IsA("Model") and nuke.PrimaryPart then
                targetPosition = nuke.PrimaryPart.Position
            end

            if targetPosition then
                walked = true
                humanoid:MoveTo(targetPosition)
                
                while (hrp.Position - targetPosition).Magnitude > 4 and nuke.Parent and CollectNuke do
                    task.wait()
                    if getHeldNuke() ~= currentHeld then break end
                    humanoid:MoveTo(targetPosition)
                end
                break
            end
        end

        -- KONDISI PENGAMAN: Jika memegang nuke (seperti 16 di foto) tapi tidak ada target yang bisa didatangi 
        -- karena di tanah cuma ada tier beda (64, 32), maka paksa karakter jalan mendekati nuke apa saja 
        -- di tanah supaya nuke yang di tangan otomatis ter-drop/ter-taruh secara mekanik game.
        if heldNuke and not walked and #nukes > 0 then
            local randomNuke = nukes[1] -- Ambil nuke terbesar di tanah (Tier 64)
            if randomNuke and randomNuke.Parent then
                local pos = randomNuke:IsA("BasePart") and randomNuke.Position or randomNuke.PrimaryPart and randomNuke.PrimaryPart.Position
                if pos then
                    humanoid:MoveTo(pos)
                    task.wait()
                end
            end
        end
    end
end)
