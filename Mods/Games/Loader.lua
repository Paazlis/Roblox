local HubName="Crokyreo Hub"

local lll1II=setmetatable({},{__index=function(_,ii1l1l) return cloneref and cloneref(game:GetService(ii1l1l)) or game:GetService(ii1l1l) end})
local lIlllI=game
local lIllll=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local IIlllI=lll1II.Players
local IllllI=lll1II.MarketplaceService
local llllII=lll1II.TweenService
local IlIIll=IIlllI.LocalPlayer
local lIlIIl=lIlllI.PlaceId
local IIllIl=nil

local IllIII=Instance.new("ScreenGui")
IllIII.Name=HubName.."Notifications"
IIllIl = lIllll:GetProtectGui(IllIII)
IllIII.Parent=IIllIl;

local IIIIll=Instance.new("Frame")
IIIIll.Size=UDim2.new(0,320,1,0)
IIIIll.Position=UDim2.new(1,-340,0,0)
IIIIll.BackgroundTransparency=1;
IIIIll.Parent=IllIII;

local lIIIlI=Instance.new("UIListLayout")
lIIIlI.Parent=IIIIll;

lIIIlI.SortOrder=Enum.SortOrder.LayoutOrder;
lIIIlI.VerticalAlignment=Enum.VerticalAlignment.Bottom;
lIIIlI.Padding=UDim.new(0,10)

local IlIlII=Instance.new("UIPadding")
IlIlII.Parent=IIIIll;
IlIlII.PaddingBottom=UDim.new(0,20)

local function llIIll(lIIlIl,llIlII,IIlIll)
	local lIIIll=Instance.new("Frame")
	lIIIll.Size=UDim2.new(1,0,0,80)
	lIIIll.BackgroundTransparency=1;
	lIIIll.Parent=IIIIll;
	local IlllII=Instance.new("Frame")
	IlllII.Size=UDim2.new(1,0,1,0)
	IlllII.Position=UDim2.new(1.2,0,0,0)
	IlllII.BackgroundColor3=Color3.fromRGB(30,30,30)
	IlllII.BorderSizePixel=0;
	IlllII.Parent=lIIIll;
	local lIlIlI=Instance.new("UICorner")
	lIlIlI.CornerRadius=UDim.new(0,8)
	lIlIlI.Parent=IlllII;
	local IIlIIl=Instance.new("ImageLabel")
	IIlIIl.Size=UDim2.new(0,60,0,60)
	IIlIIl.Position=UDim2.new(0,10,0,10)
	IIlIIl.BackgroundTransparency=1;
	if IIlIll and IIlIll~=0 then 
		IIlIIl.Image="rbxassetid://"..IIlIll 
	else 
		IIlIIl.Image="rbxassetid://0"
	end;
	IIlIIl.Parent=IlllII;
	local IIllll=Instance.new("TextLabel")
	IIllll.Size=UDim2.new(1,-110,0,20)
	IIllll.Position=UDim2.new(0,80,0,10)
	IIllll.BackgroundTransparency=1;
	IIllll.Text=lIIlIl;
	IIllll.TextColor3=Color3.fromRGB(255,255,255)
	IIllll.TextSize=16;
	IIllll.Font=Enum.Font.GothamBold;
	IIllll.TextXAlignment=Enum.TextXAlignment.Left;
	IIllll.Parent=IlllII;
	local IlIIlI=Instance.new("TextLabel")
	IlIIlI.Size=UDim2.new(1,-90,0,40)
	IlIIlI.Position=UDim2.new(0,80,0,30)
	IlIIlI.BackgroundTransparency=1;
	IlIIlI.Text=llIlII;
	IlIIlI.TextColor3=Color3.fromRGB(200,200,200)
	IlIIlI.TextSize=14;
	IlIIlI.Font=Enum.Font.Gotham;
	IlIIlI.TextXAlignment=Enum.TextXAlignment.Left;
	IlIIlI.TextWrapped=true;
	IlIIlI.Parent=IlllII;
	local lIlIll=Instance.new("TextButton")
	lIlIll.Size=UDim2.new(0,24,0,24)
	lIlIll.Position=UDim2.new(1,-30,0,8)
	lIlIll.BackgroundTransparency=1;
	lIlIll.Text="X";
	lIlIll.TextColor3=Color3.fromRGB(255,80,80)
	lIlIll.TextSize=18;
	lIlIll.Font=Enum.Font.GothamBold;
	lIlIll.Parent=IlllII;
	local IIIlll=llllII:Create(IlllII,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
	IIIlll:Play()
	lIlIll.MouseButton1Click:Connect(function()
		lIlIll.Active=false;
		local IIlIII=llllII:Create(IlllII,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(1.2,0,0,0)})
		IIlIII:Play()
		IIlIII.Completed:Wait()
		local lIllIl=llllII:Create(lIIIll,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,0)})
		lIllIl:Play()
		lIllIl.Completed:Wait()
		lIIIll:Destroy()
	end)
end;

local l1Iiil,l1IIll=pcall(function()
	return lIlllI:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Mods/Games/" .. tostring(lIlIIl)..".lua")
end)

if not l1Iiil or #l1IIll == 0 or l1IIll == "404: Not Found" then
	warn("["..HubName.."] Game not supported.")
	llIIll(HubName,"Game not supported, but try our other games!",0)
else
	local llIlIl,IIIlII=pcall(function()return IllllI:GetProductInfo(lIlIIl)end)
	if llIlIl and IIIlII then 
		llIIll(HubName.." Suggestion","This script also supports: "..IIIlII.Name,IIIlII.IconImageAssetId)
	end 
	local lllllI,IIlIlI=pcall(function() loadstring(l1Iiil)() end)
	if not lllllI then 
		warn("["..HubName.."] Error running script: "..tostring(IIlIlI))
	end
end
