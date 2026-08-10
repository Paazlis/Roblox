game:GetService("Players")
game:GetService("ServerStorage")
local v_u_1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("RunService")
local v3 = {}
local v_u_4 = {}
function v3.get(p5) -- name: get
	-- upvalues: (copy) v_u_4
	if string.match(type(p5), "string") then
		if v_u_4[p5] then
			return v_u_4[p5]
		end
		local v6 = script:FindFirstChild(p5) or (script.Imported:FindFirstChild(p5) or script.Configs:FindFirstChild(p5))
		if v6 and v6:IsA("ModuleScript") then
			v_u_4[p5] = require(v6)
			return v_u_4[p5]
		end
	end
end
function v3.Initialize(_) -- name: Initialize
	-- upvalues: (copy) v_u_4, (copy) v_u_2, (copy) v_u_1
	tick()
	local v_u_7 = 0
	local v13, v14 = pcall(function()
		-- upvalues: (ref) v_u_4, (ref) v_u_7
		local v8 = next
		local v9, v10 = script:GetChildren()
		for _, v_u_11 in v8, v9, v10 do
			if v_u_11:IsA("ModuleScript") then
				v_u_4[v_u_11.Name] = require(v_u_11)
				local v12 = v_u_4[v_u_11.Name]
				if type(v12) == "table" and v_u_4[v_u_11.Name].Initialize then
					task.spawn(function()
						-- upvalues: (ref) v_u_4, (copy) v_u_11, (ref) v_u_7
						v_u_4[v_u_11.Name]:Initialize()
						v_u_7 = tick()
					end)
				end
			end
		end
	end)
	if v13 then
		v_u_2.Heartbeat:Wait()
		v_u_1:SetAttribute("ClientLoaded", true)
		PrintMessage()
		return "Success"
	end
	warn(v14)
end
function PrintMessage() -- name: PrintMessage
	-- upvalues: (copy) v_u_2
	if not v_u_2:IsStudio() then
		print("\t\t\n\t\t\n\t\t\226\154\160\239\184\143 Report all messages colored (red or yellow), in our server\n\t\t\n\t\t        - (^^)\n\t\t          \n\t\t          \n\t\t")
	end
end
return v3

