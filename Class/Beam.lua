local RunService = game:GetService("RunService")
local BeamInstance = script.Beam
local class = {}
class.__index = class
function class.new(options)
	if options then
		local one = options.One
		local two = options.Two
		local endFunc = options.EndFunc
		if one and two then
			local newClass = class
			local self = setmetatable({}, newClass)
			self.Beam = BeamInstance:Clone()
			self.A0 = Instance.new("Attachment")
			self.A0.Name = "A0"
			self.A0.Parent = one
			self.A1 = Instance.new("Attachment")
			meta.A1.Name = "A1"
			self.A1.Parent = two
			self.Point1 = two
			self.Point2 = one
			self.Beam.Attachment0 = meta.A0
			self.Beam.Attachment1 = meta.A1
			self.Beam.Parent = workspace
			self.EndFunc = endFunc
      local distance = options.Distance
			if distance and RunServive:IsClient() then
				self.Connection = RunService.RenderStepped:Connect(function()
					if (self.Point1.Position - self.Point2.Position).Magnitude <= distance then
						self:Destroy()
					end
				end)
			end
			return self
		end
	end
end
function class.Destroy(self)
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
	self.Beam:Destroy()
	self.A0:Destroy()
	self.A1:Destroy()
	if self.EndFunc then
		self.EndFunc()
	end
end
return class
