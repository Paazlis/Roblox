local RunService = game:GetService("RunService")
local BadgeService = game:GetService("BadgeService")
local Badges = {
  ["Badges"] = {
    ["Joined"] = 0
  }
}
Badges.Give = function(player, badgeName)
		if not RunService:IsStudio() then
			if player and player.Parent then
        local userId = player.UserId
        local badgeId = Badges.Badges[badgeName]
				if badgeId == nil then
					return nil
				end
        local ok, owned = pcall(function()
			     return BadgeService:UserHasBadgeAsync(userId, badgeId)
		    end)
				if not (ok and owned) then
					return false
				end
        local success, message = pcall(function()
			     BadgeService:AwardBadgeAsync(userId, badgeId)
		    end)
        return success
			end
			return false
		end
	end,
	["IsOwned"] = function(_, player, badgeName)
		local success, owned = pcall(function()
			  return BadgeService:UserHasBadgeAsync(player.UserId, Badges.Badges[badgeName])
		end)
    return (success and owned)
	end
}
return Badges
