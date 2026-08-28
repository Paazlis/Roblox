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

local e,frRGB,V3,UD2,V2,Fnt,FfrId,FfrName=Instance.new,Color3.fromRGB,Vector3.new,UDim2.new,Vector2.new,Font.new,Font.fromId,Font.fromName
local V={
['1']=e('Model'),['2']=e('Model'),['3']=e('Model'),['4']=e('Model'),['5']=e('Part'),['6']=e('BillboardGui'),['7']=e('ImageLabel'),['8']=e('Part'),['9']=e('Part'),['10']=e('Part'),['11']=e('BillboardGui'),['12']=e('TextLabel'),['13']=e('UIStroke'),['14']=e('Part')
}
V['1'].Name='InstalModel';V['1'].Parent=workspace;
V['2'].Name='Building';V['2'].Parent=V['1'];
V['3'].Name='FeedbackModel';V['3'].Parent=V['2'];
V['4'].Name='Mailbox';V['4'].Parent=V['3'];
V['5'].Name='ComingSoonGUI';V['5'].Parent=V['3'];V['5'].Color=frRGB(95,95,95);V['5'].Transparency=1;V['5'].Size=V3(1.341,1.341,1.341);V['5'].Position=V3(-12.612,11.921,19.402);V['5'].Rotation=V3(180,39.999,180);V['5'].CanCollide=false;V['5'].Anchored=true;
V['6'].Name='GUI';V['6'].Parent=V['5'];V['6'].ZIndexBehavior=Enum.ZIndexBehavior.Sibling;V['6'].Active=true;V['6'].Size=UD2(33.531,0,25.288,0);
V['7'].Parent=V['6'];V['7'].AnchorPoint=V2(0.5,0.5);V['7'].BackgroundColor3=frRGB(255,255,255);V['7'].BackgroundTransparency=1;V['7'].BorderColor3=frRGB(0,0,0);V['7'].BorderSizePixel=0;V['7'].Position=UD2(0.515,0,0.5,0);V['7'].Size=UD2(0.1,0,0.15,0);V['7'].Image="rbxassetid://108364968985393";
V['8'].Parent=V['3'];V['8'].Color=frRGB(99,95,98);V['8'].Size=V3(15.359,0.165,16.45);V['8'].Position=V3(-11.227,0.722,20.609);V['8'].Rotation=V3(180,-9.998,0);V['8'].Anchored=true;
V['9'].Name='Promixity';V['9'].Parent=V['3'];V['9'].Transparency=1;V['9'].Size=V3(0.27,0.293,0.243);V['9'].Position=V3(-15.148,5.202,17.254);V['9'].Rotation=V3(180,0,180);V['9'].Anchored=true;
V['10'].Name='FeedbackGUI';V['10'].Parent=V['3'];V['10'].Color=frRGB(95,95,95);V['10'].Transparency=1;V['10'].Size=V3(1.341,1.341,1.341);V['10'].Position=V3(-12.727,15.345,19.19);V['10'].Rotation=V3(180,-50.002,180);V['10'].CanCollide=false;V['10'].Anchored=true;
V['11'].Name='GUI';V['11'].Parent=V['10'];V['11'].ZIndexBehavior=Enum.ZIndexBehavior.Sibling;V['11'].Active=true;V['11'].Size=UD2(33.531,0,25.288,0);
V['12'].Parent=V['11'];V['12'].AnchorPoint=V2(0.5,0.5);V['12'].BackgroundColor3=frRGB(255,255,255);V['12'].BackgroundTransparency=1;V['12'].BorderColor3=frRGB(0,0,0);V['12'].BorderSizePixel=0;V['12'].Position=UD2(0.52,0,0.48,0);V['12'].Size=UD2(0.4,0,0.2,0);V['12'].FontFace=Fnt('rbxasset://fonts/families/Montserrat.json',Enum.FontWeight.Heavy,Enum.FontStyle.Normal);V['12'].LineHeight=1.2;V['12'].Text='Feedback!';V['12'].TextColor3=frRGB(0,255,255);V['12'].TextScaled=true;V['12'].TextSize=100;V['12'].TextWrapped=true;V['12'].TextYAlignment=Enum.TextYAlignment.Bottom;
V['13'].Thickness=2;V['13'].Parent=V['12'];
V['14'].Parent=V['3'];V['14'].Color=frRGB(18,238,212);V['14'].Material=Enum.Material.Neon;V['14'].Size=V3(14.426,0.268,14.754);V['14'].Position=V3(-11.271,0.709,20.627);V['14'].Rotation=V3(180,-9.998,0);V['14'].Anchored=true;

print("[FeedbackPromptClient] ready -- mailbox prompt opens Roblox\'s feedback dialog (live game only, not Studio)")
