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

Window:AddLabel({Name="YouTube: Sampluy"})

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

-- Fungsi Drop Nuke
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
        task.wait(0.1)
        if not CollectNuke then continue end

        local base = getMyBase()
        if not base then continue end
        
        local nukes = getNukes(base)
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
        
        if not humanoid or not hrp then continue end

        local heldNuke = getHeldNuke()
        
        -- JIKA TIDAK ADA NUKE DI BASE (TANAH)
        if #nukes <= 0 then 
            -- Tapi tangan lagi pegang sesuatu, langsung drop karena gak ada pasangannya di tanah
            if heldNuke then
                dropNuke()
                task.wait(0.3)
            end
            continue 
        end

        -- 1. VALIDASI NUKE DI TANGAN (Apakah punya kembaran di tanah?)
        if heldNuke then
            local heldTier = tonumber(heldNuke:GetAttribute("Tier"))
            if heldTier then
                local foundMatch = false
                
                -- Cari di tanah, ada tidak yang tier-nya sama dengan tangan?
                for _, nuke in ipairs(nukes) do
                    if nuke.Parent and tonumber(nuke:GetAttribute("Tier")) == heldTier then
                        foundMatch = true
                        break
                    end
                end
                
                -- KALAU TIDAK ADA PASANGANNYA SAMA SEKALI DI TANAH -> BARU DROP!
                if not foundMatch then
                    dropNuke()
                    task.wait(0.3)
                    continue -- Ulangi loop dari atas
                end
            end
        end

        -- 2. JALAN MENUJU NUKE TARGET
        for _, nuke in ipairs(nukes) do
            if not CollectNuke then break end
            if not (nuke and nuke.Parent) then continue end

            local tier = tonumber(nuke:GetAttribute("Tier"))
            
            -- Jika sedang memegang nuke, WAJIB hanya mendekati nuke yang tier-nya sama
            local currentHeld = getHeldNuke()
            if currentHeld then
                local heldTier = tonumber(currentHeld:GetAttribute("Tier"))
                if heldTier and tier ~= heldTier then
                    continue -- Lewati nuke yang tier-nya berbeda
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
                
                -- Berjalan sampai nuke terambil
                while (hrp.Position - targetPosition).Magnitude > 4 and nuke.Parent and CollectNuke do
                    task.wait(0.05)
                    
                    local cHeld = getHeldNuke()
                    if cHeld then
                       local heldTier = tonumber(cHeld:GetAttribute("Tier"))
                       if heldTier and tier ~= heldTier then
                           break -- Lewati nuke yang tier-nya berbeda
                       end
                    end
                    
                    humanoid:MoveTo(targetPosition)
                end
            end
        end
    end
end)


