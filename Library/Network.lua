local v1 = game:GetService("ReplicatedStorage")
local v2 = game:GetService("RunService")
local v_u_3 = {
	["Logging"] = nil
}
local v_u_4 = v2:IsServer()
local v_u_5 = v2:IsStudio()
local v_u_6 = require(script.Callback)
function SafeInvokeBinding(p7, ...) -- name: SafeInvokeBinding
	local v8 = p7.Callback:ExecuteAsync(...)
	if v8[1] == false or v8[2] == false then
		return false
	else
		return true, unpack(v8, 3)
	end
end
function SafeInvokeWithTimeout(p9, _, ...) -- name: SafeInvokeWithTimeout
	local v_u_10 = nil
	local v_u_11 = nil
	if p9 then
		task.delay(p9, function()
			-- upvalues: (ref) v_u_10, (ref) v_u_11
			if not v_u_10 then
				v_u_10 = table.pack(false)
				if v_u_11 then
					task.spawn(v_u_11)
				end
			end
		end)
	end
	task.spawn(function(...)
		-- upvalues: (ref) v_u_10, (ref) v_u_11
		local v12 = table.pack(pcall(...))
		if not v_u_10 then
			v_u_10 = v12
			if v_u_11 then
				task.spawn(v_u_11)
			end
		end
	end, ...)
	if not v_u_10 then
		local _ = coroutine.running()
		coroutine.yield()
	end
	return v_u_10
end
local v_u_13 = {}
function ExecutePendingEvents() -- name: ExecutePendingEvents
	-- upvalues: (copy) v_u_13
	local v14 = 1
	local v15 = {}
	while v14 <= #v_u_13 do
		local v16 = v_u_13[v14]
		local v17 = v_u_13[v14 + 1]
		if v16.IsBound then
			table.insert(v15, v17)
			table.remove(v_u_13, v14 + 1)
			table.remove(v_u_13, v14)
		else
			v14 = v14 + 2
		end
	end
	for _, v18 in ipairs(v15) do
		task.spawn(v18)
	end
end
if v_u_4 then
	function OnServerEvent(p19, ...) -- name: OnServerEvent
		-- upvalues: (copy) v_u_13
		if not p19.IsBound then
			local v20 = v_u_13
			table.insert(v20, p19)
			local v21 = v_u_13
			local v22 = coroutine.running
			table.insert(v21, v22())
			coroutine.yield()
		end
		for _, v23 in pairs(p19.Bindings) do
			v23.Callback:Execute(...)
		end
	end
	function OnServerInvoke(p24, ...) -- name: OnServerInvoke
		-- upvalues: (copy) v_u_13
		if not p24.IsBound then
			local v25 = v_u_13
			table.insert(v25, p24)
			local v26 = v_u_13
			local v27 = coroutine.running
			table.insert(v26, v27())
			coroutine.yield()
		end
		return SafeInvokeBinding(p24.Binding, ...)
	end
else
	function OnClientEvent(p28, ...) -- name: OnClientEvent
		-- upvalues: (copy) v_u_13
		if not p28.IsBound then
			local v29 = v_u_13
			table.insert(v29, p28)
			local v30 = v_u_13
			local v31 = coroutine.running
			table.insert(v30, v31())
			coroutine.yield()
		end
		for _, v32 in pairs(p28.Bindings) do
			v32.Callback:Execute(...)
		end
	end
	function OnClientInvoke(p33, ...) -- name: OnClientInvoke
		-- upvalues: (copy) v_u_13
		if not p33.IsBound then
			local v34 = v_u_13
			table.insert(v34, p33)
			local v35 = v_u_13
			local v36 = coroutine.running
			table.insert(v35, v36())
			coroutine.yield()
		end
		return SafeInvokeBinding(p33.Binding, ...)
	end
end
local v_u_37, v_u_38
if v_u_4 then
	local v39 = Instance.new("Folder", v1)
	v39.Name = "Communication"
	v_u_37 = Instance.new("Folder", v39)
	v_u_37.Name = "Functions"
	v_u_38 = Instance.new("Folder", v39)
	v_u_38.Name = "Events"
else
	local v40 = v1:WaitForChild("Communication", 10)
	v_u_37 = v40:WaitForChild("Functions")
	v_u_38 = v40:WaitForChild("Events")
end
local v_u_41 = {
	["Event"] = {},
	["Function"] = {}
}
function GetHandler(p_u_42, p_u_43) -- name: GetHandler
	-- upvalues: (copy) v_u_41, (copy) v_u_4, (ref) v_u_38, (ref) v_u_37
	local v44 = v_u_41[p_u_42]
	if not v44 then
		error("Invalid handlerType \'" .. tostring(p_u_42) .. "\'")
	end
	local v_u_45 = v44[p_u_43]
	if not v_u_45 then
		v_u_45 = {
			["Name"] = p_u_43,
			["Type"] = p_u_42
		}
		v44[p_u_43] = v_u_45
		if p_u_42 == "Event" then
			v_u_45.Bindings = {}
		end
		task.spawn(function()
			-- upvalues: (ref) v_u_4, (copy) p_u_42, (copy) p_u_43, (ref) v_u_38, (ref) v_u_45, (ref) v_u_37
			if v_u_4 then
				if p_u_42 == "Event" then
					local v46 = Instance.new("RemoteEvent")
					v46.Name = p_u_43
					v46.Parent = v_u_38
					v_u_45.Remote = v46
					local v47 = Instance.new("UnreliableRemoteEvent")
					v47.Name = "Unreliable"
					v47.Parent = v46
					v_u_45.Unreliable = v47
					v46.OnServerEvent:Connect(function(...)
						-- upvalues: (ref) v_u_45
						OnServerEvent(v_u_45, ...)
					end)
					v47.OnServerEvent:Connect(function(...)
						-- upvalues: (ref) v_u_45
						OnServerEvent(v_u_45, ...)
					end)
				else
					local v48 = Instance.new("RemoteFunction")
					v48.Name = p_u_43
					v48.Parent = v_u_37
					v_u_45.Remote = v48
					function v48.OnServerInvoke(...)
						-- upvalues: (ref) v_u_45
						return OnServerInvoke(v_u_45, ...)
					end
				end
			else
				local function v55(p49, p_u_50) -- name: waitForChild
					local v_u_51 = p49:FindFirstChild(p_u_50)
					if not v_u_51 then
						local v_u_52 = coroutine.running()
						local v54 = p49.ChildAdded:Connect(function(p53)
							-- upvalues: (ref) v_u_52, (copy) p_u_50, (ref) v_u_51
							if v_u_52 and p53.Name == p_u_50 then
								v_u_51 = p53
								task.spawn(v_u_52)
							end
						end)
						coroutine.yield()
						v_u_52 = nil
						v54:Disconnect()
					end
					return v_u_51
				end
				v55(p_u_42 == "Event" and v_u_38 or v_u_37, p_u_43)
				if p_u_42 == "Event" then
					local v56 = v55(v_u_38, p_u_43)
					local v57 = v55(v56, "Unreliable")
					v_u_45.Remote = v56
					v_u_45.Unreliable = v57
					if not v_u_4 then
						v56.Name = ""
					end
					v56.OnClientEvent:Connect(function(...)
						-- upvalues: (ref) v_u_45
						OnClientEvent(v_u_45, ...)
					end)
					v57.OnClientEvent:Connect(function(...)
						-- upvalues: (ref) v_u_45
						OnClientEvent(v_u_45, ...)
					end)
				else
					local v58 = v55(v_u_37, p_u_43)
					v_u_45.Remote = v58
					if not v_u_4 then
						v58.Name = ""
					end
					function v58.OnClientInvoke(...)
						-- upvalues: (ref) v_u_45
						return OnClientInvoke(v_u_45, ...)
					end
				end
			end
			if v_u_45.WaitingForRemote then
				local v59 = v_u_45.WaitingForRemote
				v_u_45.WaitingForRemote = nil
				for _, v60 in ipairs(v59) do
					task.spawn(v60)
				end
			end
		end)
	end
	return v_u_45
end
local v_u_61 = setmetatable({}, {
	["__mode"] = "v"
})
local v_u_62 = 0
local v_u_63 = {}
function InitFilter(p64) -- name: InitFilter
	-- upvalues: (copy) v_u_61, (ref) v_u_62
	if v_u_61[p64] then
		return v_u_61[p64]
	end
	local v65 = nil
	if typeof(p64) == "function" then
		v65 = { p64 }
	elseif typeof(p64) == "table" then
		local v66 = p64[1]
		if typeof(v66) == "function" then
			v65 = {}
			for v67, v68 in pairs(p64) do
				v65[v67] = v68
			end
		end
	end
	if v65 then
		v65.Priority = v65.Priority or 0
		v65.RegisterIndex = v_u_62
		v_u_62 = v_u_62 + 1
		v_u_61[p64] = v65
	end
	return v65
end
function ApplyFilters(p_u_69, p_u_70) -- name: ApplyFilters
	-- upvalues: (copy) v_u_4, (copy) v_u_3
	return function(...)
		-- upvalues: (copy) p_u_70, (copy) p_u_69, (ref) v_u_4, (ref) v_u_3
		local v_u_71 = table.pack(true, ...)
		for v_u_72, v73 in ipairs(p_u_70.Filters) do
			local v74 = table.pack
			local v75 = v_u_71.n
			v_u_71 = v74(v73(unpack(v_u_71, 2, v75)))
			if v_u_71[1] ~= true then
				if v_u_71[1] ~= nil and v_u_71[1] ~= false then
					task.spawn(function()
						-- upvalues: (copy) v_u_72, (ref) p_u_69, (ref) v_u_71
						local v76 = error
						local v77 = string.format
						local v78 = v_u_72
						local v79 = p_u_69.Name
						local v80 = v_u_71[1]
						v76(v77("Network: Filter #%d to \'%s\' returned invalid first value of type %s. False or nil expected to cancel event", v78, v79, (typeof(v80))), -1)
					end)
				end
				return false
			end
		end
		if v_u_4 and v_u_3.Logging then
			v_u_3.Logging[#v_u_3.Logging + 1] = { true, p_u_69.Remote, ... }
		end
		local v81 = p_u_70[1]
		local v82 = v_u_71.n
		return true, v81(unpack(v_u_71, 2, v82))
	end
end
function InitBinding(p83, p84, p85) -- name: InitBinding
	-- upvalues: (copy) v_u_63, (copy) v_u_6
	local v86 = nil
	if typeof(p84) == "function" then
		v86 = { p84 }
	elseif typeof(p84) == "table" then
		local v87 = p84[1]
		if typeof(v87) == "function" then
			v86 = {}
			for v88, v89 in pairs(p84) do
				v86[v88] = v89
			end
		end
	end
	if not v86 then
		return nil
	end
	local v90 = {}
	for v91, v92 in pairs(v86) do
		if v91 ~= 1 then
			local v93 = v_u_63[v91]
			if not v93 then
				error("Filter \'" .. tostring(v91) .. "\' doesn\'t exist")
			end
			local v94 = v93[1]
			table.insert(v90, v94(p83, v92, v86))
		end
	end
	table.sort(v90, function(p95, p96)
		if p95.Priority == p96.Priority then
			return p95.RegisterIndex < p96.RegisterIndex
		else
			return p95.Priority < p96.Priority
		end
	end)
	if p85 then
		local v97 = typeof(p85) ~= "table" and { p85 } or p85
		for v98, v99 in ipairs(type(v97) == "table" and v97 and v97 or { v97 }) do
			if typeof(v99) ~= "function" then
				error("Invalid custom filter #" .. v98 .. " (function expected, got " .. typeof(v99) .. ")")
			end
			table.insert(v90, v99)
		end
	end
	v86.Filters = v90
	v86.Callback = v_u_6.new(ApplyFilters(p83, v86))
	return v86
end
function BindToHandler(p100, p101, p102, p103) -- name: BindToHandler
	local v104 = InitBinding(p100, p101, p102)
	if not v104 then
		error("Invalid binding to \'" .. p100.Name .. "\'")
	end
	if p100.Type == "Event" then
		local v105 = p100.Bindings
		table.insert(v105, v104)
	else
		if p100.Binding then
			error("Duplicate function handler to \'" .. p100.Name .. "\'")
		end
		p100.Binding = v104
	end
	if not p100.IsBound then
		p100.IsBound = true
		if p103 then
			ExecutePendingEvents()
		end
	end
end
if v_u_4 then
	function FireClient(_, p106, p107, ...) -- name: FireClient
		-- upvalues: (copy) v_u_3
		if v_u_3.Logging then
			v_u_3.Logging[#v_u_3.Logging + 1] = {
				false,
				p106,
				p107,
				...
			}
		end
		p106:FireClient(p107, ...)
	end
	function InvokeClientWithTimeout(p108, p109, p110, ...) -- name: InvokeClientWithTimeout
		-- upvalues: (copy) v_u_3
		if v_u_3.Logging then
			v_u_3.Logging[#v_u_3.Logging + 1] = {
				false,
				p109.Remote,
				p110,
				...
			}
		end
		local v111 = SafeInvokeWithTimeout(p108, p109, p109.Remote.InvokeClient, p109.Remote, p110, ...)
		if v111[1] == false or v111[2] == false then
			return false
		end
		local v112 = v111.n
		return true, unpack(v111, 3, v112)
	end
	function v_u_3.FireClient(_, p113, p114, ...) -- name: FireClient
		local v115 = GetHandler("Event", p114)
		FireClient(v115, v115.Remote, p113, ...)
	end
	function v_u_3.FireAllClients(p116, p117, ...) -- name: FireAllClients
		local v118 = GetHandler("Event", p117)
		for _, v119 in p116:GetPlayers() do
			FireClient(v118, v118.Remote, v119, ...)
		end
	end
	function v_u_3.FireOtherClients(p120, p121, p122, ...) -- name: FireOtherClients
		local v123 = GetHandler("Event", p122)
		for _, v124 in p120:GetPlayers() do
			if v124 ~= p121 then
				FireClient(v123, v123.Remote, v124, ...)
			end
		end
	end
	function v_u_3.FireClientUnreliable(_, p125, p126, ...) -- name: FireClientUnreliable
		local v127 = GetHandler("Event", p126)
		FireClient(v127, v127.Unreliable, p125, ...)
	end
	function v_u_3.FireAllClientsUnreliable(p128, p129, ...) -- name: FireAllClientsUnreliable
		local v130 = GetHandler("Event", p129)
		for _, v131 in p128:GetPlayers() do
			FireClient(v130, v130.Unreliable, v131, ...)
		end
	end
	function v_u_3.FireOtherClientsUnreliable(p132, p133, p134, ...) -- name: FireOtherClientsUnreliable
		local v135 = GetHandler("Event", p134)
		for _, v136 in p132:GetPlayers() do
			if v136 ~= p133 then
				FireClient(v135, v135.Unreliable, v136, ...)
			end
		end
	end
	function v_u_3.FireOtherClientsWithinDistance(p137, p138, p139, p140, ...) -- name: FireOtherClientsWithinDistance
		local v141 = p137:GetPlayerPosition(p138)
		if v141 then
			local v142 = GetHandler("Event", p140)
			for _, v143 in ipairs(p137:GetPlayers()) do
				if v143 ~= p138 then
					local v144 = p137:GetPlayerPosition(v143)
					if v144 and (v141 - v144).Magnitude <= p139 then
						FireClient(v142, v142.Remote, v143, ...)
					end
				end
			end
		end
	end
	function v_u_3.FireAllClientsWithinDistance(p145, p146, p147, p148, ...) -- name: FireAllClientsWithinDistance
		local v149 = GetHandler("Event", p148)
		for _, v150 in ipairs(p145:GetPlayers()) do
			local v151 = p145:GetPlayerPosition(v150)
			if v151 and (p146 - v151).Magnitude <= p147 then
				FireClient(v149, v149.Remote, v150, ...)
			end
		end
	end
	function v_u_3.InvokeClientWithTimeout(_, p152, p153, p154, ...) -- name: InvokeClientWithTimeout
		local v155 = GetHandler("Function", p154)
		return InvokeClientWithTimeout(p152, v155, p153, ...)
	end
	function v_u_3.InvokeClient(_, p156, p157, ...) -- name: InvokeClient
		local v158 = GetHandler("Function", p157)
		return InvokeClientWithTimeout(nil, v158, p156, ...)
	end
	local v_u_159 = game:GetService("Players")
	function v_u_3.GetPlayers(_) -- name: GetPlayers
		-- upvalues: (copy) v_u_159
		return v_u_159:GetPlayers()
	end
	function v_u_3.GetPlayerPosition(_, p160) -- name: GetPlayerPosition
		local v161 = p160 and p160.Character
		if v161 then
			v161 = p160.Character.PrimaryPart
		end
		return v161 and v161.Position or nil
	end
end
if not v_u_4 then
	function FireServer(_, p162, ...) -- name: FireServer
		p162:FireServer(...)
	end
	function InvokeServerWithTimeout(p163, p164, ...) -- name: InvokeServerWithTimeout
		if not p164.Remote then
			if not p164.WaitingForRemote then
				p164.WaitingForRemote = {}
			end
			local v165 = p164.WaitingForRemote
			local v166 = coroutine.running
			table.insert(v165, v166())
			coroutine.yield()
		end
		local v167 = SafeInvokeWithTimeout(p163, p164, p164.Remote.InvokeServer, p164.Remote, ...)
		if v167[1] == false or v167[2] == false then
			error("InvokeServer Error")
		end
		local v168 = v167.n
		return unpack(v167, 3, v168)
	end
	function v_u_3.FireServer(_, p169, ...) -- name: FireServer
		local v_u_170 = GetHandler("Event", p169)
		if v_u_170.Remote then
			FireServer(v_u_170, v_u_170.Remote, ...)
		else
			task.spawn(function(...)
				-- upvalues: (copy) v_u_170
				if not v_u_170.WaitingForRemote then
					v_u_170.WaitingForRemote = {}
				end
				local v171 = v_u_170.WaitingForRemote
				local v172 = coroutine.running
				table.insert(v171, v172())
				coroutine.yield()
				FireServer(v_u_170, v_u_170.Remote, ...)
			end, ...)
		end
	end
	function v_u_3.FireServerUnreliable(_, p173, ...) -- name: FireServerUnreliable
		local v_u_174 = GetHandler("Event", p173)
		if v_u_174.Remote then
			FireServer(v_u_174, v_u_174.Unreliable, ...)
		else
			task.spawn(function(...)
				-- upvalues: (copy) v_u_174
				if not v_u_174.WaitingForRemote then
					v_u_174.WaitingForRemote = {}
				end
				local v175 = v_u_174.WaitingForRemote
				local v176 = coroutine.running
				table.insert(v175, v176())
				coroutine.yield()
				FireServer(v_u_174, v_u_174.Unreliable, ...)
			end, ...)
		end
	end
	function v_u_3.InvokeServerWithTimeout(_, p177, p178, ...) -- name: InvokeServerWithTimeout
		local v179 = GetHandler("Function", p178)
		return InvokeServerWithTimeout(p177, v179, ...)
	end
	function v_u_3.InvokeServer(_, p180, ...) -- name: InvokeServer
		local v181 = GetHandler("Function", p180)
		return InvokeServerWithTimeout(nil, v181, ...)
	end
	v_u_38.ChildAdded:Connect(function(p182)
		GetHandler("Event", p182.Name)
	end)
	for _, v183 in pairs(v_u_38:GetChildren()) do
		task.spawn(GetHandler, "Event", v183.Name)
	end
	v_u_37.ChildAdded:Connect(function(p184)
		GetHandler("Function", p184.Name)
	end)
	for _, v185 in ipairs(v_u_37:GetChildren()) do
		task.spawn(GetHandler, "Function", v185.Name)
	end
end
function v_u_3.BindEvents(_, p186, p187) -- name: BindEvents
	local v188
	if p187 then
		v188 = p186
		p186 = p187
	else
		v188 = nil
	end
	for v189, v190 in pairs(p186) do
		BindToHandler(GetHandler("Event", v189), v190, v188, false)
	end
	ExecutePendingEvents()
end
function v_u_3.BindFunctions(_, p191, p192) -- name: BindFunctions
	local v193
	if p192 then
		v193 = p191
		p191 = p192
	else
		v193 = nil
	end
	for v194, v195 in pairs(p191) do
		BindToHandler(GetHandler("Function", v194), v195, v193, false)
	end
	ExecutePendingEvents()
end
function v_u_3.RegisterFilters(_, p196) -- name: RegisterFilters
	-- upvalues: (copy) v_u_63
	for v197, v198 in pairs(p196) do
		if v_u_63[v197] then
			error("Duplicate filter \'" .. v197 .. "\'")
		end
		local v199 = InitFilter(v198)
		if not v199 then
			error("Invalid filter \'" .. v197 .. "\'")
		end
		v_u_63[v197] = v199
	end
end
local v215 = {
	["MatchParams"] = {
		["Priority"] = -100,
		function(p_u_200, p201)
			-- upvalues: (copy) v_u_4, (copy) v_u_5
			local v_u_202 = { unpack(p201) }
			if v_u_4 then
				table.insert(v_u_202, 1, "Instance")
			end
			for v203, v205 in pairs(v_u_202) do
				if type(v205) == "string" then
					local v205 = string.split(v205:gsub("%?", "|nil"), "|") or v205
				end
				local v206 = ""
				local v207 = {}
				for _, v208 in pairs(v205) do
					local v209 = v208:gsub("^%s+", ""):gsub("%s+$", "")
					v206 = v206 .. (#v206 > 0 and " or " or "") .. v209
					v207[v209:lower()] = true
				end
				v207._string = v206
				v_u_202[v203] = v207
			end
			return function(...)
				-- upvalues: (ref) v_u_202, (ref) v_u_5, (copy) p_u_200
				local v210 = table.pack(...)
				for v211, _ in ipairs(v_u_202) do
					local v212 = v210[v211]
					local v213 = typeof(v212)
					local v214 = v_u_202[v211]
					if not (v214[v213:lower()] or v214.any) then
						if v_u_5 then
							warn(("[Network] Invalid argument #%d to %s (%s expected, got %s)"):format(v211, p_u_200.Name, v214._string, v213))
						end
						return false
					end
				end
				return true, ...
			end
		end
	}
}
v_u_3:RegisterFilters(v215)
if v_u_4 then
	function v_u_3.LogTraffic(_, p216) -- name: LogTraffic
		-- upvalues: (copy) v_u_3
		if not v_u_3.Logging then
			warn("Logging Network Traffic...")
			v_u_3.Logging = {}
			local v_u_217 = tick()
			task.delay(p216, function()
				-- upvalues: (copy) v_u_217, (ref) v_u_3
				local v218 = tick() - v_u_217
				local v219 = v_u_3.Logging
				v_u_3.Logging = nil
				local v220 = {}
				for _, v221 in pairs(v219) do
					local v222 = v221[2]
					local v223 = v221[3]
					local v224 = v220[v223]
					if not v224 then
						v224 = {
							["total"] = 0
						}
						v220[v223] = v224
					end
					local v225 = v224[v222]
					if not v225 then
						v225 = {
							["dataIn"] = {},
							["dataOut"] = {}
						}
						v224[v222] = v225
					end
					local v226 = v221[1] and v225.dataIn or v225.dataOut
					v226[#v226 + 1] = v221
					v224.total = v224.total + 1
				end
				for v227, v228 in pairs(v220) do
					warn(string.format("Player \'%s\', total received: %d", v227.Name, v228.total))
					v228.total = nil
					for v229, v230 in pairs(v228) do
						local v231 = v230.dataIn
						if #v231 > 0 then
							warn(string.format("   %s %s: %d (%.2f/s)", "FireServer", v229.Name, #v231, #v231 / v218))
							local v232 = #v231
							local v233 = math.min(v232, 3)
							for v234 = 1, v233 do
								local v235 = v234 - 1
								local v236 = v233 - 1
								local v237 = v235 / math.max(1, v236) * (#v231 - 1) + 1 + 0.5
								local v238 = math.floor(v237)
								local v239 = v231[1]
								local v240 = #v239
								local v241 = ""
								for v242 = 4, math.min(v240, 7) do
									local v243 = v239[v242]
									v241 = v241 .. (#v241 > 0 and ", " or "") .. (typeof(v243) == "string" and "string[" .. #v243 .. "]" or typeof(v243))
								end
								warn(("      %d: %s"):format(v238, v241))
							end
						end
						local v244 = v230.dataOut
						if #v244 > 0 then
							warn(string.format("   %s %s: %d (%.2f/s)", "FireClient", v229.Name, #v244, #v244 / v218))
							local v245 = #v244
							local v246 = math.min(v245, 3)
							for v247 = 1, v246 do
								local v248 = v247 - 1
								local v249 = v246 - 1
								local v250 = v248 / math.max(1, v249) * (#v244 - 1) + 1 + 0.5
								local v251 = math.floor(v250)
								local v252 = v244[v251]
								local v253 = #v252
								local v254 = ""
								for v255 = 4, math.min(v253, 7) do
									local v256 = v252[v255]
									v254 = v254 .. (#v254 > 0 and ", " or "") .. (typeof(v256) == "string" and "string[" .. #v256 .. "]" or typeof(v256))
								end
								warn(string.format("      %d: %s", v251, v254))
							end
						end
					end
				end
			end)
		end
	end
end
local v_u_257 = {}
local v_u_258 = {}
function v_u_3.AddReference(_, p259, p260, ...) -- name: AddReference
	-- upvalues: (copy) v_u_257, (copy) v_u_258
	local v261 = {
		["Type"] = p260,
		["Reference"] = p259,
		["Objects"] = { ... },
		["Aliases"] = {}
	}
	if not v_u_257[p260] then
		v_u_257[p260] = {}
		v_u_258[p260] = {}
	end
	v_u_257[p260][v261.Reference] = v261
	local v262 = v_u_258[p260]
	for _, v263 in ipairs(v261.Objects) do
		local v264 = v262[v263] or {}
		v262[v263] = v264
		v262 = v264
	end
	v262.__Data = v261
end
function v_u_3.AddReferenceAlias(_, p265, p266, ...) -- name: AddReferenceAlias
	-- upvalues: (copy) v_u_257, (copy) v_u_258
	local v267 = v_u_257[p266]
	if v267 then
		v267 = v_u_257[p266][p265]
	end
	if v267 then
		local v268 = { ... }
		v267.Aliases[#v267.Aliases + 1] = v268
		local v269 = v_u_258[p266]
		for _, v270 in ipairs(v268) do
			local v271 = v269[v270] or {}
			v269[v270] = v271
			v269 = v271
		end
		v269.__Data = v267
	else
		warn("Tried to add an alias to a non-existing reference")
	end
end
function v_u_3.RemoveReference(_, p272, p273) -- name: RemoveReference
	-- upvalues: (copy) v_u_257, (copy) v_u_258
	local v_u_274 = v_u_257[p273]
	if v_u_274 then
		v_u_274 = v_u_257[p273][p272]
	end
	if v_u_274 then
		v_u_257[p273][v_u_274.Reference] = nil
		local function v_u_280(p275, p276, p277) -- name: rem
			-- upvalues: (copy) v_u_280, (copy) v_u_274
			if p277 <= #p276 then
				local v278 = p276[p277]
				local v279 = p275[v278]
				v_u_280(v279, p276, p277 + 1)
				if next(v279) == nil then
					p275[v278] = nil
					return
				end
			elseif p275.__Data == v_u_274 then
				p275.__Data = nil
			end
		end
		local v281 = v_u_258[v_u_274.Type]
		local v282 = v_u_274.Objects
		if #v282 >= 1 then
			local v283 = v282[1]
			local v284 = v281[v283]
			v_u_280(v284, v282, 2)
			if next(v284) == nil then
				v281[v283] = nil
			end
		elseif v281.__Data == v_u_274 then
			v281.__Data = nil
		end
		for _, v285 in ipairs(v_u_274.Aliases) do
			if #v285 >= 1 then
				local v286 = v285[1]
				local v287 = v281[v286]
				v_u_280(v287, v285, 2)
				if next(v287) == nil then
					v281[v286] = nil
				end
			elseif v281.__Data == v_u_274 then
				v281.__Data = nil
			end
		end
	else
		warn("Tried to remove a non-existing reference")
	end
end
function v_u_3.GetObject(_, p288, p289) -- name: GetObject
	-- upvalues: (copy) v_u_257
	local v290 = v_u_257[p289]
	if v290 then
		v290 = v_u_257[p289][p288]
	end
	if not v290 then
		return nil
	end
	local v291 = v290.Objects
	return unpack(v291)
end
function v_u_3.GetReference(_, ...) -- name: GetReference
	-- upvalues: (copy) v_u_257, (copy) v_u_258
	local v292 = { ... }
	local v293 = table.remove(v292)
	if not v_u_257[v293] then
		return nil
	end
	local v294 = v_u_258[v293]
	for _, v295 in ipairs(v292) do
		v294 = v294[v295]
		if not v294 then
			break
		end
	end
	if v294 then
		v294 = v294.__Data
	end
	return v294 and v294.Reference or nil
end
return v_u_3
