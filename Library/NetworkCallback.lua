local v_u_1 = {
	["__index"] = {}
}
local v_u_2 = {}
local function v_u_5(p3, p4) -- name: SignalCallback
	-- upvalues: (copy) v_u_2
	while true do
		p4(coroutine.yield())
		v_u_2[p3] = nil
	end
end
local v_u_6 = {}
local function v_u_11(p7, p8) -- name: AsyncCallback
	-- upvalues: (copy) v_u_6
	local v9 = table.pack(true, p8(coroutine.yield()))
	local v10 = v_u_6[p7]
	if v10 and not v10.result then
		v10.result = v9
		if v10.waiting then
			task.spawn(v10.waiting)
		end
	end
end
task.spawn(function()
	-- upvalues: (copy) v_u_6
	while true do
		task.wait()
		for v12, v13 in pairs(v_u_6) do
			if not v13.result and coroutine.status(v12) == "dead" then
				v13.result = { false }
				if v13.waiting then
					task.defer(v13.waiting)
				end
			end
		end
	end
end)
local function v_u_17(p14) -- name: SignalCreator
	local v15 = coroutine.yield()
	while true do
		local v16 = coroutine.create(v15)
		coroutine.resume(v16, v16, p14)
		v15 = coroutine.yield(v16)
	end
end
function v_u_1.__index.Execute(p18, ...) -- name: Execute
	-- upvalues: (copy) v_u_5, (copy) v_u_2
	local v19 = p18.thread
	if v19 then
		p18.thread = nil
	else
		local v20
		v20, v19 = coroutine.resume(p18.creator, v_u_5)
	end
	v_u_2[v19] = true
	task.spawn(v19, ...)
	if v_u_2[v19] then
		v_u_2[v19] = nil
	else
		p18.thread = v19
	end
end
function v_u_1.__index.ExecuteAsync(p21, ...) -- name: ExecuteAsync
	-- upvalues: (copy) v_u_11, (copy) v_u_6
	local _, v22 = coroutine.resume(p21.creator, v_u_11)
	local v23 = {
		["result"] = nil,
		["waiting"] = nil
	}
	v_u_6[v22] = v23
	task.spawn(v22, ...)
	if not v23.result then
		v23.waiting = coroutine.running()
		coroutine.yield()
	end
	v_u_6[v22] = nil
	return v23.result
end
function v_u_1.new(p24) -- name: new
	-- upvalues: (copy) v_u_17, (copy) v_u_1
	local v25 = coroutine.create(v_u_17)
	coroutine.resume(v25, p24)
	local v26 = v_u_1
	return setmetatable({
		["fn"] = nil,
		["creator"] = nil,
		["thread"] = nil,
		["fn"] = p24,
		["creator"] = v25
	}, v26)
end
return v_u_1
