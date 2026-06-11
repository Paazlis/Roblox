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

-- Fungsi mengambil daftar nuke di base (diurutkan dari kecil ke besar)
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
            return tonumber(a:GetAttribute("Tier")) < tonumber(b:GetAttribute("Tier"))
        end)
    end
    
    return nukes
end

-- Fungsi Drop Nuke yang ringkas (langsung tembak ke tombol UI game)
local function dropNuke()
    pcall(function()
        local screenGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        local dropButton = screenGui.HoldingFrame.Frame.Drop.TextButton
        if dropButton and firesignal then
            firesignal(dropButton.Activated)
        end
    end)
end

-- Fungsi untuk mengecek nuke apa yang sedang dipegang karakter saat ini
local function getHeldNuke()
    -- Mengecek visual nuke yang menempel di kamera saat dipegang
    local camera = workspace.CurrentCamera
    if camera then
        local held = camera:FindFirstChild("HeldNukeVisual")
        if held then return held end
    end
    return nil
end

-- Loop Utama Auto-Farm
task.spawn(function()
    while true do
        task.wait(0.1)
        if not CollectNuke then continue end

        local base = getMyBase()
        if not base then continue end
        
        local nukes = getNukes(base)
        if #nukes <= 0 then continue end

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
        
        if not humanoid or not hrp then continue end

        -- 1. CEK APAKAH NUKE DI TANGAN ADALAH "YATIM" (Tidak punya pasangan di base)
        local heldNuke = getHeldNuke()
        if heldNuke then
            local heldTier = tonumber(heldNuke:GetAttribute("Tier"))
            if heldTier then
                local matchCount = 0
                
                -- Hitung ada berapa nuke dengan tier yang sama di base
                for _, nuke in ipairs(nukes) do
                    if nuke.Parent and tonumber(nuke:GetAttribute("Tier")) == heldTier then
                        matchCount = matchCount + 1
                    elseif not nuke.Parent then
                        table.remove(nukes,table.find(nukes,nuke))
                    end
                end

                if matchCount < 2 then
                   table.sort(nukes, function(a, b)
                       return tonumber(a:GetAttribute("Tier")) > tonumber(b:GetAttribute("Tier"))
                   end)
                end
                    
                -- Jika memegang nuke tapi di base cuma ada 1 (berarti itu dirinya sendiri / gak ada kembarannya)
                -- atau malah tidak ada pasangannya sama sekali, langsung DROP!
                if matchCount < 2 then
                    dropNuke()
                    task.wait(0.3) -- Jeda agar nuke benar-benar terlepas
                end
            end
        end

        -- 2. JALAN MENUJU NUKE TARGET
        for _, nuke in ipairs(nukes) do
            if not CollectNuke then break end
            if not (nuke and nuke.Parent) then continue end

            local tier = tonumber(nuke:GetAttribute("Tier"))
            
            -- Jika sedang memegang sesuatu, pastikan hanya mendatangi nuke dengan tier yang sama
            local currentHeld = getHeldNuke()
            if currentHeld then
                local heldTier = tonumber(currentHeld:GetAttribute("Tier"))
                if heldTier and tier ~= heldTier then
                    continue -- Lewati nuke yang beda tier
                end
            end

            local targetPosition = nil
            if nuke:IsA("BasePart") then
                targetPosition = nuke.Position
            elseif nuke:IsA("Model") and nuke.PrimaryPart then
                targetPosition = nuke.PrimaryPart.Position
            end

            if targetPosition then
                humanoid:MoveTo(targetPosition)
                
                while (hrp.Position - targetPosition).Magnitude > 4 and nuke.Parent and CollectNuke do
                    task.wait(0.05)
                    
                    -- Pengaman: Jika di tengah jalan nuke yang dipegang berubah/lepas, batalkan jalan
                    local checkHeld = getHeldNuke()
                    if checkHeld then
                       local heldTier = tonumber(checkHeld:GetAttribute("Tier"))
                       if heldTier and tier ~= heldTier then
                          break
                       end
                    end
                    
                    humanoid:MoveTo(targetPosition)
                end
                
                break
            end
        end
    end
end)
