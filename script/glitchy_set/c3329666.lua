--Wicked Booster Onslaught
--Scripted by: XGlitchy30

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:CreateNegateEffect(true,nil,true,0,nil,{true,false,true},
		aux.LocationGroupCond(s.filter,LOCATION_MZONE,0,1),
		nil,
		nil,
		CATEGORY_DESTROY
	)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WICKED_BOOSTER) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_EXTRA)
end