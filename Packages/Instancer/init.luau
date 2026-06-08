-- Instancer by @Paazlis

local Players,RunService=game:GetService("Players"),game:GetService("RunService")

local PartProperties={"Name","Anchored","Locked","CanCollide","Transparency","Color","Material","Reflectance","CFrame","BackSurface","BottomSurface","FrontSurface","LeftSurface","RightSurface","TopSurface","Size"}

local function InvalidArgumentInstance(v,i,s)
	assert(typeof(v)=="Instance",`Invalid argument #{i} (Instance expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentFunction(v,i,s)
	assert(type(v)=="function",`Invalid argument #{i} (function expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentString(v,i,s)
	assert(type(v)=="string",`Invalid argument #{i} (string expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentTable(v,i,s)
	assert(type(v)=="table",`Invalid argument #{i} (table expected, got {typeof(v)}) to Instancer.{s}`)
end

local Instancer={}

function Instancer.IsAlive(instance)
	if instance and instance.Parent then return true else return false end
end

function Instancer.IsCharacter(instance)
	return Instancer.IsAlive(instance) and instance.ClassName=='Model' and instance:FindFirstChildOfClass('Humanoid')
end

function Instancer.IsDied(instance)
	if Instancer.IsAlive(instance) then
		local humanoid=instance:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health>0 and humanoid.MaxHealth>0 then
			return false
		end
		return false
	end
	return true
end

function Instancer.IsNPC(instance)
	return instance and instance:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(instance)
end

function Instancer.IsAs(instance,classNames)
	for i,v in ipairs(classNames) do if Instancer.IsAlive(instance) and instance:IsA(v) then return true end end return false
end

function Instancer.AddInstance(className,data)
	local instance=nil
	local success,message=pcall(function() instance=Instance.new(className) end)
	if not success then
		warn(`[Instancer] Error while Instance.new, got {className} and`,message)
	end
	if instance~=nil then
		local parent=nil
		if type(data)=="table" then
			for k,v in pairs(data) do 
				if k=="Parent" then parent=v continue end
				pcall(function() instance[k]=v end) 
			end
		elseif typeof(data)=="Instance" then
			parent=data
		end
		if parent~=nil then
			instance.Parent=parent
		end
	end
	return instance
end

function Instancer.FindOrCreateChild(instance,name,className,data)
	InvalidArgumentInstance(instance,1,"FindOrCreateChild")
	InvalidArgumentString(name,2,"FindOrCreateChild")
	InvalidArgumentString(className,3,"FindOrCreateChild")
	data=type(data)=="table" and data or {}
	local c=nil
	for i,v in ipairs(instance:GetChildren()) do if v.Name==name and v:IsA(className) then c=v break end end
	if not c then
		c=Instance.new(className)
		c.Name=name
		local parent=instance
		for k,v in pairs(data) do
			if type(k)=="string" then
				if k=="Parent" then
					parent=v
				else
					pcall(function() c[k]=v end)
				end
			end
		end
		c.Parent=parent
	end
	return c
end

function Instancer.CreateVariable(instance,variables,name)
	InvalidArgumentInstance(instance,1,"CreateVariable")
	InvalidArgumentTable(variables,2,"CreateVariable")

	local currentName=type(name)=="string" and name or instance.Name

	-- Remove symbols
	local nameWithoutSymbols=""
	for v in string.gmatch(currentName,"[%w_]") do nameWithoutSymbols=nameWithoutSymbols..v end

	-- Check for string
	local baseName=""
	if #nameWithoutSymbols==0 then
		baseName=instance.ClassName
	elseif string.find(string.sub(nameWithoutSymbols,1,1),"%d") then
		baseName="_"..nameWithoutSymbols
	else
		baseName=nameWithoutSymbols
	end

	-- Check for original name
	local isOriginal=true
	for i,v in pairs(variables) do if v==baseName then isOriginal=false break end end
	if isOriginal then variables[instance]=baseName return end

	-- Check for duplicate name
	local count=1
	local isDuplicate=false
	while true do
		isDuplicate=false
		local mainBaseName=baseName.."_"..tostring(count)
		for i,v in pairs(variables) do if v==mainBaseName then isDuplicate=true break end end
		count=count+1
		if not isDuplicate then variables[instance]=mainBaseName return end
		task.wait()
	end
end

function Instancer.ConvertMeshPartToSpecialMesh(instance)
	if instance and instance.Parent and instance:IsA("MeshPart") then
		local meshId,textureId=instance.MeshId,instance.TextureID
		local part=Instance.new("Part")
		for i,v in ipairs(PartProperties) do if pcall(function() return part[v] end) then part[v]=instance[v] end end
		local specialMesh=Instance.new("SpecialMesh")
		specialMesh.Name="SpecialMesh"
		specialMesh.MeshType=Enum.MeshType.FileMesh
		specialMesh.MeshId=meshId
		specialMesh.TextureId=textureId
		specialMesh.Scale=(1/instance.MeshSize)*instance.ExtentsSize
		specialMesh.Parent=part
		part.Parent=instance.Parent
		local t={}
		for j,k in ipairs(instance:GetDescendants()) do if not k:IsA("SurfaceAppearance") then k.Parent=part else table.insert(t,k) end end
		if next(t) then for i,v in ipairs(t) do if not v:IsA("SurfaceAppearance") then v.Parent=part table.remove(t,i) end end end
		if next(t) then for i,v in ipairs(t) do v:Destroy() end end
		instance:Destroy()
	end
end

function Instancer.GetInstanceProperty(instance,properties,func)
	InvalidArgumentInstance(instance,1,"GetInstanceProperty")
	InvalidArgumentTable(properties,2,"GetInstanceProperty")
	InvalidArgumentFunction(func,1,"GetInstanceProperty")
	for i,v in ipairs(properties) do 
		local success=pcall(function() return instance[v] end)
		if success then
			pcall(func,typeof(instance[v]),instance[v],v,i)
		end 
	end 
end

function Instancer.GetAncestorsAndSelf(instance)
	InvalidArgumentInstance(instance,1,"GetAncestorsAndSelf")
	local current=nil
	local function NextParent()
		if current==nil then current=instance else current=current.Parent end return current
	end
	return NextParent
end

function Instancer.CopyInstance(className,instance,properties)
	InvalidArgumentString(className,1,"CopyInstance")
	InvalidArgumentInstance(instance,2,"CopyInstance")
	InvalidArgumentTable(properties,3,"CopyInstance")
	local newInstance=Instance.new(className)  
	local i=1  
	for j,k in pairs(properties) do  
		local v=properties[i] 
		if v then 
			i=i+1 
			local success=pcall(function() return newInstance[v] end)
			if success then  
				newInstance[v]=instance[v] 
			end 
		end 
	end 
	return newInstance
end

function Instancer.CopyInstanceWith(list,objectClasses,object,match)
	InvalidArgumentTable(list,1,"CopyInstanceWith")
	InvalidArgumentTable(objectClasses,2,"CopyInstanceWith")
	InvalidArgumentFunction(match,4,"CopyInstanceWith")
	local parent=typeof(object)=="Instance" and object or nil
	local func=type(object)=="function" and object or nil
	if func~=nil or parent~=nil then else return end
	for j,k in ipairs(list) do 
		if k and k.Parent then 
			for i,v in ipairs(k:GetDescendants()) do 
				if v and v.Parent and match(v) then
					local className=v.ClassName
					if func~=nil then
						func(v)
					elseif parent~=nil then
						local nv=Instancer.CopyInstance(className,v,objectClasses[className]) 
						nv.Parent=parent 
						RunService.Stepped:Wait() 
					end
				end 
			end 
		end
	end
end

function Instancer.SetChildrenParent(instance,parent)
	InvalidArgumentInstance(instance,1,"SetChildrenParent")
	for i,v in ipairs(instance:GetChildren()) do v.Parent=parent  end
end

function Instancer.GetChildrenWhichIsA(instance,className)
	InvalidArgumentInstance(instance,1,"GetChildrenWhichIsA")
	InvalidArgumentString(className,2,"GetChildrenWhichIsA")
	local list={}
	for i,v in ipairs(instance:GetChildren()) do if v:IsA(className) then table.insert(list,v) end end
	return list
end

function Instancer.GetDescendantsWhichIsA(instance,className)
	InvalidArgumentInstance(instance,1,"GetDescendantsWhichIsA")
	InvalidArgumentString(className,2,"GetDescendantsWhichIsA")
	local list={}
	for i,v in ipairs(instance:GetDescendants()) do if v:IsA(className) then table.insert(list,v) end end
	return list
end

function Instancer.SetPartAnchoredChildren(v,anchored)
	if Instancer.IsAlive(v) then for i,v in ipairs(v:GetChildren()) do if Instancer.IsAlive(v) and v.ClassName=="Part" or v.ClassName=="MeshPart" then v.Anchored=anchored end end end
end

function Instancer.GetCharacterInfo(instance,data)
	local characterInfo={}

	if Instancer.IsCharacter(instance) then 
		local noParts,callback=data and data.NoParts,data and data.Callback

		local headPart=instance:FindFirstChild("Head") 
		if Instancer.IsAlive(headPart) and headPart:IsA("BasePart") then 
			characterInfo.Head=headPart
			if callback and type(callback)=="function" then pcall(callback,"Head",headPart) end
		end 

		local rootPart=instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Torso") or instance:FindFirstChild("UpperTorso") or instance.PrimaryPart 
		if Instancer.IsAlive(rootPart) then 
			characterInfo.HumanoidRootPart=rootPart 
			if callback and type(callback)=="function" then pcall(callback,"HumanoidRootPart",rootPart) end
		end

		local humanoid=instance:FindFirstChildOfClass("Humanoid") :: Humanoid
		if Instancer.IsAlive(humanoid) then 
			characterInfo.Humanoid=humanoid
			characterInfo.RigType=humanoid.RigType
			if callback and type(callback)=="function" then pcall(callback,"Humanoid",humanoid) end
		end 

		if not noParts then
			characterInfo.Parts={}
			for i,v in ipairs(instance:GetChildren()) do if v:IsA('BasePart') then table.insert(characterInfo.Parts,v) end end
			if #characterInfo.Parts>=2 then
				characterInfo.RandomPart=characterInfo.Parts[math.random(1,#characterInfo.Parts)]
			else
				characterInfo.RandomPart=characterInfo.HumanoidRootPart
			end
			if callback and type(callback)=="function" then pcall(callback,"RandomPart",characterInfo.RandomPart) end
		end
	end

	return characterInfo
end

function Instancer.GetPlayer(object)
    if not object then return nil end
	local result,objectType=nil,typeof(object)
	if objectType=="Instance" then
		if object and object.Parent then
			if object.ClassName=="Model" then 
				for i,v in ipairs(Players:GetPlayers()) do if v and v.Parent and (v.Character and v.Character.Parent) and v.Character==object then result=v break end end
			elseif object.ClassName=="Player" then
				result=object 
			end
		end
	elseif objectType=="string" or objectType=="number" then
		local inputNumber=tonumber(object)
		if inputNumber then
			for i,v in ipairs(Players:GetPlayers()) do if v and v.Parent and v.UserId==inputNumber then result=v break end end
		else
			local s=tostring(object) or ""
			local ls=string.lower(s)
			if ls=="!me" then
				if RunService:IsClient() and Players.LocalPlayer and Players.LocalPlayer.Parent then result=Players.LocalPlayer end
			elseif ls=="!random" then
				local matches={}
				if RunService:IsClient() then
					for i,v in ipairs(Players:GetPlayers()) do 
						if v.Parent and Players.LocalPlayer and Players.LocalPlayer.Parent and v.UserId~=Players.LocalPlayer.UserId then 
							table.insert(matches,v) 
						end 
					end
				else
					for i,v in ipairs(Players:GetPlayers()) do 
						if v.Parent then 
							table.insert(matches,v) 
						end 
					end
				end
				if #matches>=2 then result=matches[math.random(1,#matches)] end
			else
				for i=1,4 do
					for j,v in ipairs(Players:GetPlayers()) do
						if v and v.Parent then
							local name=if i==1 then v.Name elseif i==2 then v.DisplayName elseif i==3 then string.lower(v.Name) else string.lower(v.DisplayName)
							if string.find(name,s) then result=v break end
						end
					end
					if typeof(result)=="Instance" then break end
				end
			end
		end
	end
	if callback and type(callback)=="function" and typeof(result)=="Instance" then pcall(callback,result) end
	return result
end

return Instancer
