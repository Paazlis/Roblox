local Private={
	["Shirt"]="144076358",
	["Pants"]="144076760",
	["TShirt"]="",
	["Accessories"]={}
}

Private.UseStudio=game:GetService("RunService"):IsStudio()
local Instancer=nil
if Private.UseStudio then Instancer=require(game.ReplicatedStorage.Mods.InstancerLow) else Instancer=loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Instancer/init.luau"))() end
local Strs=nil
if Private.UseStudio then Strs=require(game.ReplicatedStorage.Mods.StrsLow) else Strs=loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Strs/init.luau"))() end
local Utility=nil
if Private.UseStudio then Utility=require(game.ReplicatedStorage.Mods.UtilityLow) else Utility=loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Utility/init.luau"))() end
local Rayfield=nil
if Private.UseStudio then Rayfield=require(game.ReplicatedStorage.Packages.Rayfield.main) else Rayfield=loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Rayfield/init.luau"))() end

local function ApplyClothing(model,className,id)
	local success, objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(id))
	end)
	if success and type(objects)=="table" and #objects>0 then
		local old,instance=nil,objects[1]
		if instance and instance:IsA(className) then
			old=model:FindFirstChildOfClass(className)
		end
		if old then
			old:Destroy()
			instance.Parent=model
			return instance
		end
	end
end

local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer

local Window=Rayfield:CreateWindow({Name="Maswa",LoadingTitle="Maswa",LoadingSubtitle="Interface Suite"})
local Tab=Window:CreateTab("Avatar")

local ShirtInput=Tab:CreateInput({
	Name="Shirt Id",
	CurrentValue=Private.Shirt,
	Callback=function(Id) 
		if not tonumber(Id) then return end
		warn("Avatar Mods | Shirt:",Id)
		local source=ApplyClothing(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),"Shirt",Id)
		if source then
			Private.Shirt=Id
		end
	end
})

local PantsInput=Tab:CreateInput({
	Name="Pants Id",
	CurrentValue=Private.Pants,
	Callback=function(Id) 
		if not tonumber(Id) then return end
		warn("Avatar Mods | Pants:",Id)
		local source=ApplyClothing(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),"Pants",Id)
		if source then
			Private.Pants=Id
		end
	end
})
		
-- Variabel penyimpan ID, default diisi dengan ID yang kamu minta
local AccessoryID = "97694229491058"

-- Input Field
Tab:CreateInput({
   Name = "Asset ID Aksesori",
   CurrentValue = AccessoryID, -- ID Default yang kamu minta
   PlaceholderText = "Masukkan ID di sini...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      AccessoryID = Text
   end,
})

-- Tombol Eksekusi
Tab:CreateButton({
   Name = "Pasang Aksesori ke Karakter",
   Callback = function()
      local player = game.Players.LocalPlayer
      local char = player.Character
      
      if not char or not char:FindFirstChild("Humanoid") then
         Rayfield:Notify({
            Title = "Error",
            Content = "Karakter tidak ditemukan!",
            Duration = 5,
            Image = 4483362458,
         })
         return
      end

      if AccessoryID == "" or not tonumber(AccessoryID) then
         Rayfield:Notify({
            Title = "ID Salah",
            Content = "Silahkan masukkan ID angka yang valid.",
            Duration = 5,
            Image = 4483362458,
         })
         return
      end

      -- Proses pengambilan dan pemasangan objek
      local success, err = pcall(function()
         local objects = game:GetObjects("rbxassetid://" .. AccessoryID)
         local item = objects[1]

         if item and item:IsA("Accessory") then
            -- Gunakan AddAccessory agar otomatis menempel ke Attachment karakter (Fix 0,0,0)
            char.Humanoid:AddAccessory(item)
            
            Rayfield:Notify({
               Title = "Berhasil!",
               Content = "Aksesori ID " .. AccessoryID .. " terpasang.",
               Duration = 3,
               Image = 4483362458,
            })
         else
            Rayfield:Notify({
               Title = "Gagal",
               Content = "ID ini bukan aksesori atau tidak dapat di-load.",
               Duration = 5,
               Image = 4483362458,
            })
            if item then item:Destroy() end
         end
      end)

      if not success then
         warn("Terjadi kesalahan: " .. err)
         Rayfield:Notify({
            Title = "Cek Console (F9)",
            Content = "Terjadi error saat mengambil object.",
            Duration = 5,
         })
      end
   end,
})

-- Tombol Tambahan: Hapus Aksesori
Tab:CreateButton({
   Name = "Hapus Semua Aksesori",
   Callback = function()
      local char = game.Players.LocalPlayer.Character
      if char then
         for _, v in pairs(char:GetChildren()) do
            if v:IsA("Accessory") then
               v:Destroy()
            end
         end
         Rayfield:Notify({
            Title = "Cleaned",
            Content = "Semua aksesori telah dihapus.",
            Duration = 3,
         })
      end
   end,
})
