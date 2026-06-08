local Tabler={}

function Tabler.GetProperties(t)
	local i=0
	local function NextProperty() i=i+1 if t[i] then return t[i],t[t[i]],i end end
	return NextProperty
end

function Tabler.IsAlive(t)
	return if t and type(t)=="table" and getmetatable(t) then true else false
end

function Tabler.NextValue(t,i)
	if i>=#t then i=1 else i=i+1 end if not t[i] then i=i+1 end if not t[i] then i=1 end return i,t[i]
end

function Tabler.PreviousValue(t,i)
	if i==0 or i==1 then i=#t else i=i-1 end if not t[i] then i=i-1 end if not t[i] then i=#t end return i,t[i]
end

-- Author: @Sleitnick
local success,tableUtil=pcall(function()
	if game:GetService("RunService"):IsStudio() then return nil end
	local func=loadstring(game:HttpGet('https://raw.githubusercontent.com/Sleitnick/RbxUtil/refs/heads/main/modules/table-util/init.luau'))
	if func then return func() end return nil
end)

if success and tableUtil then
	for k,v in pairs(tableUtil) do if Tabler[k]==nil then Tabler[k]=v end end
end

return Tabler
