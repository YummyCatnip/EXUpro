--AXyz Vipera, Unleashed Tyrant
local s,id,o=GetID()
function s.initial_effect(c)
	--Summon Condition
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--ATK reduction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Attach 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.attcon)
	e2:SetTarget(s.atttar)
	e2:SetOperation(s.attope)
	c:RegisterEffect(e2)
	--Destruction replace
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
end
--e1 Effect Code
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
--e2 Effect Code
function s.filter(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.atttar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0,1,c,e) and c:IsType(TYPE_XYZ) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,e)
end
function s.attope(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
--e3 Effect Code
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		c:RemoveOverlayCard(tp,1,ct,REASON_COST)
		return true
	else return false end
end