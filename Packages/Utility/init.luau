local GENERIC_OBJECT_CLEANUP_FUNCS={'Destroy','Disconnect','destroy','disconnect'}

local Utility={}

function Utility.CallSafely(func,...)
	if func then
		local success,result=pcall(func,...)
		if not success then
			warn('function failed with error: ',result)
			return false
		else
			return result
		end
	end
end

function Utility.Cleanup(object)
	if not object or object==nil then return nil end
	local objectType=typeof(object)
	if objectType=='function' then
		pcall(function() object() end)
	elseif objectType=='RBXScriptConnection' then
		object:Disconnect()
	elseif objectType=='Instance' then
		if object and object.Parent then object:Destroy() end
	elseif objectType=='thread' then
		local wasCancelled:boolean?=nil
		if coroutine.running()~=object then
			wasCancelled=pcall(function()
				task.cancel(object)
			end)
		end
		if not wasCancelled then
			local toClean=object
			task.defer(function()
				task.cancel(toClean)
			end)
		end
	elseif objectType=='table' then
		for i,k in ipairs(GENERIC_OBJECT_CLEANUP_FUNCS) do
			local func=object[k]
			if typeof(func)=='function' then
				pcall(func)
				break
			end
		end
	else
		warn('[Utility]: Unable to cleanup unknown object:',objectType)
	end
	return nil
end

function Utility.Missing(t,f,callback)
	if type(f)==t then return f end return callback
end

return Utility
