-- Paleozoic Ursulinacaris
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Xyz Procedure
	c:EnableReviveLimit()
	--Xyz Summon
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--Unaffected by monsters' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Can attack all monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--"Ally fo Justice" monsters inflict piercing damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.prcond)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PALEOZOIC))
	c:RegisterEffect(e3)
end
s.listed_series={SET_PALEOZOIC}
-- Xyz Code
function s.mfilter(c,xyzc,tp)
	return c:IsFaceup() and (c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) or c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp)) and (c:GetRank()==2 or c:GetLink()==2) and c:IsCanBeXyzMaterial(xyzc) and not c:IsType(TYPE_TOKEN)
end
function s.xyzfilter(c,tp,mg)
	return #mg>=2 and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.xyzcon(e,c,og,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	return mg:IsExists(s.xyzfilter,2,nil,tp,mg)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=mg:FilterSelect(tp,s.xyzfilter,2,2,nil,tp,mg)
	c:SetMaterial(g)
	Duel.Overlay(c,g)
end
-- e1 Effect Code
function s.efilter(e,re)
	return re:IsMonsterEffect() and re:GetOwner()~=e:GetOwner()
end
-- e3 Effect Code
function s.prcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsTrap,1,nil)
end