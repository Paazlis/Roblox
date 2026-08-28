local v1 = game:GetService("Players")
local v_u_2 = game:GetService("SocialService")
local v3 = game:GetService("ProximityPromptService")
local v_u_4 = v1.LocalPlayer
local v_u_5 = false
v3.PromptTriggered:Connect(function(p6, p7)
	-- upvalues: (copy) v_u_4, (ref) v_u_5, (copy) v_u_2
	if p6.Name == "FeedbackPrompt" then
		if p7 == v_u_4 then
			if not v_u_5 then
				v_u_5 = true
				task.spawn(function()
					-- upvalues: (ref) v_u_2, (ref) v_u_5
					local v8, v9 = pcall(function()
						-- upvalues: (ref) v_u_2
						v_u_2:PromptFeedbackSubmissionAsync()
					end)
					if not v8 then
						warn("[FeedbackPromptClient] feedback dialog unavailable: " .. tostring(v9))
					end
					v_u_5 = false
				end)
			end
		else
			return
		end
	else
		return
	end
end)
print("[FeedbackPromptClient] ready -- mailbox prompt opens Roblox\'s feedback dialog (live game only, not Studio)")
