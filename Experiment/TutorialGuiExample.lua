local e,frRGB,UD2,V2=Instance.new,Color3.fromRGB,UDim2.new,Vector2.new
local V={
['1']=e('Model'),['2']=e('Model'),['3']=e('ScreenGui'),['4']=e('Frame'),['5']=e('Frame'),['6']=e('UIStroke'),['7']=e('ImageLabel'),['8']=e('UIAspectRatioConstraint'),['9']=e('UIScale')
}

V['1'].Name='InstalModel';V['1'].Parent=workspace;
V['2'].Name='Gui';V['2'].Parent=V['1'];
V['3'].Name='TutorialHilightMain';V['3'].Parent=V['2'];V['3'].DisplayOrder=125;V['3'].ResetOnSpawn=false;
V['4'].Name='TutorialHighLightHolder';V['4'].Parent=V['3'];V['4'].BackgroundColor3=frRGB(255,255,255);V['4'].BackgroundTransparency=1;V['4'].BorderColor3=frRGB(0,0,0);V['4'].BorderSizePixel=0;V['4'].Size=UD2(1,0,1,0);
V['5'].Name='HighLightMain';V['5'].Parent=V['4'];V['5'].AnchorPoint=V2(0.5,0.5);V['5'].BackgroundColor3=frRGB(255,255,255);V['5'].BackgroundTransparency=1;V['5'].BorderColor3=frRGB(0,0,0);V['5'].BorderSizePixel=0;V['5'].Position=UD2(0,379,0,303);V['5'].Size=UD2(0,98,0,37);V['5'].ZIndex=99;
V['6'].ApplyStrokeMode=Enum.ApplyStrokeMode.Border;V['6'].Thickness=100000;V['6'].Transparency=0.5;V['6'].Parent=V['5'];
V['7'].Name='PointArrow';V['7'].Parent=V['5'];V['7'].BackgroundColor3=frRGB(255,255,255);V['7'].BackgroundTransparency=1;V['7'].BorderColor3=frRGB(0,0,0);V['7'].BorderSizePixel=0;V['7'].Position=UD2(0.263,0,1.147,0);V['7'].Size=UD2(0.726,0,2.054,0);V['7'].ZIndex=100;V['7'].Image="rbxassetid://127206568776222";
V['8'].Parent=V['7'];V['8'].AspectRatio=1.01;
V['9'].Parent=V['5'];V['9'].Scale=1.06;

TutorialGui.TutorialFrame.Main
TutorialGui.TutorialFrame.Main.UIScale -- zoom in/out loop forever until stop with function cleaup

-- Question: 
saat fungsi 
ini terpanggil TargetGui(TutorialGui.TutorialFrame.Main)
