-- Naturia Baihu
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	--Negate (during your turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- Negate (During your opponent's turn)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NATURIA}
-- e1 Effect Code
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev) and (Duel.IsTurnPlayer(tp) or e:GetHandler():GetFlagEffect(id)>0)
end
function s.bfilter(c)
	return c:IsAbleToRemoveAsCost(POS_FACEDOWN) and aux.SpElimFilter(c)
end
function s.cfilter(c)
	return c:IsSetCard(SET_NATURIA) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.filter(c)
	return c:IsSetCard(SET_NATURIA) and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsPlayerCanDiscardDeckAsCost(tp,2) and Duel.GetFlagEffect(tp,id+1)==0
	local b2=Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,2,nil) and Duel.GetFlagEffect(tp,id+2)==0
	local b3=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c) and Duel.GetFlagEffect(tp,id+3)==0
	local b4=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) and Duel.GetFlagEffect(tp,id+4)==0
	if chk==0 then return (b1 or b2 or b3 or b4) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)})
	Duel.RegisterFlagEffect(tp,id+op,RESET_PHASE+PHASE_END,0,1)
	if op==1 then
		Duel.DiscardDeck(tp,2,REASON_COST)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,2,2,nil)
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c)
		Duel.SendtoGrave(g,REASON_COST)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- e2 Effect Code
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,SET_NATURIA) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end