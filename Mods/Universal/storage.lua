local e,V2,frRGB,UD2,UD=Instance.new,Vector2.new,Color3.fromRGB,UDim2.new,UDim.new
local V={
['1']=e('Model'),['2']=e('Model'),['3']=e('ScreenGui'),['4']=e('Frame'),['5']=e('Frame'),['6']=e('Frame'),['7']=e('UICorner'),['8']=e('UICorner'),['9']=e('UIListLayout'),['10']=e('UIAspectRatioConstraint'),['11']=e('ImageLabel'),['12']=e('UIAspectRatioConstraint'),['13']=e('Frame'),['14']=e('Frame'),['15']=e('UICorner'),['16']=e('UICorner'),['17']=e('UIListLayout'),['18']=e('UIAspectRatioConstraint'),['19']=e('ImageLabel'),['20']=e('UIAspectRatioConstraint'),['21']=e('UIListLayout'),['22']=e('UIAspectRatioConstraint'),['23']=e('UIAspectRatioConstraint'),['24']=e('UIAspectRatioConstraint')
}
V['1'].Name='InstalModel';V['1'].Parent=workspace;
V['2'].Name='Gui';V['2'].Parent=V['1'];
V['3'].Name='InterfaceUI';V['3'].Parent=V['2'];V['3'].ZIndexBehavior=Enum.ZIndexBehavior.Sibling;V['3'].ResetOnSpawn=false;
V['4'].Name='StatsUI';V['4'].Parent=V['3'];V['4'].AnchorPoint=V2(0.5,0.5);V['4'].BackgroundColor3=frRGB(255,255,255);V['4'].BackgroundTransparency=1;V['4'].BorderColor3=frRGB(0,0,0);V['4'].BorderSizePixel=0;V['4'].Position=UD2(0.08,0,0.825,0);V['4'].Size=UD2(0.142,0,0.331,0);
V['5'].Name='ProgressBar';V['5'].Parent=V['4'];V['5'].AnchorPoint=V2(0.5,0.5);V['5'].BackgroundColor3=frRGB(0,0,0);V['5'].BackgroundTransparency=0.9;V['5'].BorderColor3=frRGB(0,0,0);V['5'].BorderSizePixel=0;V['5'].Position=UD2(0.5,0,0.422,0);V['5'].Size=UD2(0.386,0,0.775,0);
V['6'].Name='BarFrame';V['6'].Parent=V['5'];V['6'].AnchorPoint=V2(0.5,0.5);V['6'].BackgroundColor3=frRGB(255,255,255);V['6'].BorderColor3=frRGB(0,0,0);V['6'].BorderSizePixel=0;V['6'].Position=UD2(0.5,0,0.5,0);V['6'].Size=UD2(1,0,1,0);
V['7'].CornerRadius=UD(0,5);V['7'].Parent=V['6'];
V['8'].CornerRadius=UD(0,5);V['8'].Parent=V['5'];
V['9'].Parent=V['5'];V['9'].HorizontalAlignment=Enum.HorizontalAlignment.Center;V['9'].SortOrder=Enum.SortOrder.LayoutOrder;V['9'].VerticalAlignment=Enum.VerticalAlignment.Bottom;
V['10'].Parent=V['5'];V['10'].AspectRatio=0.11;
V['11'].Name='ProgressIcon';V['11'].Parent=V['4'];V['11'].AnchorPoint=V2(0.5,0.5);V['11'].BackgroundColor3=frRGB(255,255,255);V['11'].BackgroundTransparency=1;V['11'].BorderColor3=frRGB(0,0,0);V['11'].BorderSizePixel=0;V['11'].Position=UD2(0.5,0,0.896,0);V['11'].Size=UD2(0.6,0,0.127,0);V['11'].Image="rbxassetid://106046965382342";
V['12'].Parent=V['11'];
V['13'].Name='ProgressBar';V['13'].Parent=V['4'];V['13'].AnchorPoint=V2(0.5,0.5);V['13'].BackgroundColor3=frRGB(0,0,0);V['13'].BackgroundTransparency=0.9;V['13'].BorderColor3=frRGB(0,0,0);V['13'].BorderSizePixel=0;V['13'].Position=UD2(0.5,0,0.422,0);V['13'].Size=UD2(0.386,0,0.775,0);
V['14'].Name='BarFrame';V['14'].Parent=V['13'];V['14'].AnchorPoint=V2(0.5,0.5);V['14'].BackgroundColor3=frRGB(255,255,255);V['14'].BorderColor3=frRGB(0,0,0);V['14'].BorderSizePixel=0;V['14'].Position=UD2(0.5,0,0.5,0);V['14'].Size=UD2(1,0,0,0);
V['15'].CornerRadius=UD(0,5);V['15'].Parent=V['14'];
V['16'].CornerRadius=UD(0,5);V['16'].Parent=V['13'];
V['17'].Parent=V['13'];V['17'].HorizontalAlignment=Enum.HorizontalAlignment.Center;V['17'].SortOrder=Enum.SortOrder.LayoutOrder;V['17'].VerticalAlignment=Enum.VerticalAlignment.Bottom;
V['18'].Parent=V['13'];V['18'].AspectRatio=0.11;
V['19'].Name='ProgressIcon';V['19'].Parent=V['4'];V['19'].AnchorPoint=V2(0.5,0.5);V['19'].BackgroundColor3=frRGB(255,255,255);V['19'].BackgroundTransparency=1;V['19'].BorderColor3=frRGB(0,0,0);V['19'].BorderSizePixel=0;V['19'].Position=UD2(0.5,0,0.896,0);V['19'].Size=UD2(0.6,0,0.127,0);V['19'].Image="rbxassetid://98407220538849";
V['20'].Parent=V['19'];
V['21'].Parent=V['4'];V['21'].FillDirection=Enum.FillDirection.Horizontal;V['21'].SortOrder=Enum.SortOrder.LayoutOrder;V['21'].VerticalAlignment=Enum.VerticalAlignment.Center;
V['22'].Parent=V['4'];V['22'].AspectRatio=0.83;
V['23'].Parent=V['4'];V['23'].AspectRatio=0.21;
V['24'].Parent=V['4'];V['24'].AspectRatio=0.21;
