--Wicked Booster Advance
--Scripted by: XGlitchy30

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:Activate(0,CATEGORY_SPECIAL_SUMMON,nil,nil,aux.HOPT(true),
		nil,
		aux.CreateCost(
			aux.CustomLabelCost(2),
			aux.SSRestrictionCost(aux.RaceFilter(RACE_MACHINE),true,nil,id,nil,1)
		),
		aux.SSTarget(s.filter,LOCATION_HAND+LOCATION_GRAVE),
		aux.SSOperation(s.filter,LOCATION_HAND+LOCATION_GRAVE)
	)
end
function s.filter(c,e)
	return c:IsSetCard(SET_WICKED_BOOSTER) and c:HasLevel() and c:IsLevelBelow(7)
		and (not e:IsHasType(EFFECT_TYPE_ACTIVATE) or e:GetLabel()~=2 or c:IsRace(RACE_MACHINE))
end