--Quan, Unleashed Hope
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),4,4)
	c:EnableReviveLimit()
	--Indestructable by battle
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Atk Gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Return cards to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.thcond)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
end
s.listed_series={0xc90,0xc89}
--e1 Effect Code
function s.atkfilter(c)
	return c:IsSetCard(0xc90) and c:IsType(TYPE_MONSTER)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)*300
end
--e2 Effect Code
function s.matfil(c,e)
	return c:IsSetCard(0xc89) and c:IsType(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsCanBeEffectTarget(e)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(s.matfil,tp,LOCATION_ONFIELD,0,1,nil,e) end
	local hgc=Duel.GetMatchingGroupCount(s.matfil,tp,LOCATION_ONFIELD,0,nil,e)
	local tgc=Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local ct=math.min(hgc,tgc)
	c:RemoveOverlayCard(tp,1,ct,REASON_COST)
	local og=Duel.GetOperatedGroup()
	e:SetLabel(#og)
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHIC),1,nil)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.matfil(chkc,e) end
	if chk==0 then return true end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.matfil,tp,LOCATION_ONFIELD,0,ct,ct,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,ct*2,0,0)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if not Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,#tc,nil) then return false end
	if #tc>0 and Duel.SendtoHand(tc,tp,REASON_EFFECT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,#tc,#tc,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end