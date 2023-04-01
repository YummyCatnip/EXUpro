--Moondrop Inu
local s,id,o=GetID()
function s.initial_effect(c)
	--Link Procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Return banished to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.tgtarg)
	e2:SetOperation(s.tgoper)
	c:RegisterEffect(e2)
	--Returned cards are negated
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e3:SetTarget(s.ngtarg)
	c:RegisterEffect(e3)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentPropertyBinary(Card.GetRace,lc,sumtype,tp)
end
--e2 Effect Code
function s.filter(c)
	return c:IsAbleToGrave()
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,LOCATION_REMOVED)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
--e3 Effect Code
function s.ngtarg(e,c)
	return c:GetFlagEffect(id)>0
end