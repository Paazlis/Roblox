local mt = getrawmetatable(game)
setreadonly(mt, false)

local hook = nil
hook = hookmetamethod(game, '__namecall', function(self, ...)
    local method = getnamecallmethod()

    local success = false
    if typeof(self) == "Instance" and self:IsA("BasePart") then
       print("BasePart Success:",self:GetFullName())
       success = true
    elseif method == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
       print("RemoteEvent Success:",self:GetFullName())
       success = true
    elseif typeof(self) == "table" then
       print("Table Success:", table.concat(self,","))
       success= true 
    end
    
    if success then print("Hooked!") end
    
    return hook(self, ...)
end)
