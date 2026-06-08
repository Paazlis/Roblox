local MathHuge,MathFloor,MathAbs,StringGsub,StringFormat,StringFind,StringMatch,StringLen,Huge=math.huge,math.floor,math.abs,string.gsub,string.format,string.find,string.match,string.len,math.huge
local BoolData={["yes"]=true,["no"]=false,["true"]=true,["false"]=false,["active"]=true,["unactive"]=false,["start"]=true,["stop"]=false}

local Strs={
	['Icons']={
		['Robux']=utf8.char(0xE002),
		['Premium']=utf8.char(0xE001),
		['Verified']=utf8.char(0xE000),
	},
}

function Strs.ToNaN(x:number,s:string?)
	return x~=x and "NaN" or s
end

function Strs.ToInf(x:number,s:string?)
	return (x>=Huge or x<=-Huge) and '∞' or s
end

function Strs.GetLines(s:string):()->(string)
	local lastBreak=0
	local function NextLine()
		if lastBreak==#s then return nil end
		local line,nextBreak=nil,StringFind(s,"\n",lastBreak+1)	
		if nextBreak then
			line=s:sub(lastBreak+1,nextBreak-1)
			lastBreak=nextBreak
		else
			line=s:sub(lastBreak+1,#s)
			lastBreak=#s
		end
		return line
	end
	return NextLine
end

function Strs.IsStrings(s1,s2)
	for i,v in ipairs(s2) do if s1==v then return true end end return false
end

function Strs.IsOriginal(s)
	s=string.lower(tostring(s)) 
	for i,v in ipairs({"reset","default","original","origin"}) do if string.find(s,v) then return true end end
	return false
end

function Strs.IsEmpty(s:any):boolean
	if type(s)=="string" then
		if StringLen(s)==0 then return true end
		local v=StringMatch(s,"^%s*$")
		if v==nil then return false end
		return true
	end
	return true
end

function Strs.TryNumber(s,defautValue,originalValue)
	if type(s)=="string" or type(s)=="number" then
		if tonumber(s) then return tonumber(s) end
		local ls=string.lower(s)
		if ls=="reset" or ls=="default" or ls=="original" or ls=="origin" then return tonumber(originalValue) or tonumber(defautValue) end
		if ls=="inf" or ls=="huge" or "infinite" then return math.huge end
		if ls=="-inf" or ls=="-huge" or "-infinite" then return -math.huge end
		return tonumber(defautValue)
	end
	return nil
end

function Strs.ToNumber(v,maxFloat)
	local x=type(v)=="string" and tonumber(v) or v
	if not x or type(x)~="number" then return "nil" end
	if not maxFloat or type(maxFloat)~="number" or maxFloat<=0 then 
		maxFloat=3
	end
	local xFloor=MathFloor(x)
	if x==xFloor then return tostring(xFloor) end
	local s=StringFormat(`%.{maxFloat}f`,x)
	s=StringGsub(s,"%.?0+$","")
	return s
end

function Strs.ToPersentase(x:number,max:number?,maxFloat:number?,reverse:boolean?):string
	if type(x)~="number" or x==0 then return "0%" end
	if (x>=MathHuge or x<=-MathHuge) then return "∞%" end
	maxFloat=if type(maxFloat)=="number" and maxFloat>0 then maxFloat else 2
	local percentage=MathFloor(x)*100
	if not reverse then
		if max then percentage=MathFloor(x/max)*100 end
	else
		if max then
			percentage=(1/max)*x
			if percentage>=1 then 
				return "100%"
			else
				percentage=percentage*100
			end
		end
	end
	local s=StringFormat(`%.{maxFloat}f`,percentage)
	s=s.."%"
	if max and x>=max then s="100%" end
	return s
end

local Suffixes={' ','K','M','B','T','Qd','Qn','Sx','Sp','Oc','No','De','UDe','DDe','TDe','QdDe','QnDe','SxDe','SpDe','OcDe','NoDe','Vg','UVg','DVg','TVg'}

function Strs.FormatNumber(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	local isNegative=x<=0
	x=MathAbs(x)
	local s=tostring(x)
	for i=1,#Suffixes do
		if x<10^(i*3) then
			local v=x/(10^((i-1)*3)/100)
			local result=tostring(math.floor(v)/100)..Suffixes[i]
			return isNegative and '-'..result or result
		end
	end
	return isNegative and '-'..s or s
end

function Strs.FormatTime(x:number):string
	local checkString=Strs.ToInf(x) or Strs.ToNaN(x)
	if checkString then return checkString end
	x=MathFloor(x)
	local seconds=x%60
	local minutes=MathFloor(x/60)%60
	local hours=MathFloor(x/60^2)
	local days=MathFloor(x/86400)
	if x<60 then
		return StringFormat('%02i',seconds)
	elseif x < 3600 then
		return StringFormat('%02i:%02i',minutes,seconds)
	elseif x < 86400 then
		return StringFormat('%02i:%02i:%02i',hours,minutes,seconds)
	else
		return StringFormat('%02i:%02i:%02i:%02i',days,hours,minutes,seconds)
	end
end

function Strs.ToMS(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	x=MathFloor(x)
	local seconds=x%60
	local minutes=MathFloor(x/60)%60
	return StringFormat('%02i:%02i',minutes,seconds)
end

function Strs.ToHMS(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	x=MathFloor(x)
	local seconds=x%60
	local minutes=MathFloor(x/60)%60
	local hours=MathFloor(x/60^2)
	return StringFormat('%02i:%02i:%02i',hours,minutes,seconds)
end

function Strs.ToDHMS(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	x=MathFloor(x)
	local seconds=x%60
	local minutes=MathFloor(x/60)%60
	local hours=MathFloor(x/60^2)
	local days=MathFloor(x/86400)
	return StringFormat('%02i:%02i:%02i:%02i',days,hours,minutes,seconds)
end

function Strs.ToBoolean(s)
	if s and type(s)=="string" then return BoolData[string.lower(s)] or false end return false
end

function Strs.Random()
	local length=math.random(10,20)
	local array={}
	for i=1,length do
		array[i]=string.char(math.random(32,126))
	end
	return table.concat(array)
end

return Strs
