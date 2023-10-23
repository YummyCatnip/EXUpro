-- Eruptio, Volcano Crystal Cirgon
-- Scripted by Satellaa
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	aux.CirgonGlobalCheck(s,c)
	-- Increase its Level by 1 or 2/Additional Normal Summon
	c:SummonedTrigger
	(
		false,true,true,false,nil,nil,
		EFFECT_FLAG_DELAY,true,nil,s.effcost,s.efftg,s.effop
	)
end
s.listed_series={SET_CIRGON}
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.CirgonRestrictionCheck(tp) end
	aux.CirgonLock(e:GetHandler(),tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=true
	local b2=e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
	if chk==0 then return (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b2 and b1,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op~=2 then
		e:SetCategory(CATEGORY_LVCHANGE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	local raf=c:IsRelateToEffect(e) and c:IsFaceup()
	if op~=2 and raf then
		local lv=Duel.AnnounceNumber(tp,1,2)
		c:UpdateLV(lv)
	end
	if op~=1 then
		s.RegisterAdditionalNS(c,tp)
	end
end
function s.RegisterAdditionalNS(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_CIRGON))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
