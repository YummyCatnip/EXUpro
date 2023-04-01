--CXyz Amphisbanea, Unleashed Nightmare
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),3,3)
	c:EnableReviveLimit()
	--ATK Boost
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.atkcon)
	e0:SetValue(500)
	c:RegisterEffect(e0)
	--Return 1 Hourglass
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.tdcond)
	e1:SetTarget(s.tdtarg)
	e1:SetOperation(s.tdoper)
	c:RegisterEffect(e1)
	--Negate opponent's field monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.negcon)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.negtar)
	e2:SetOperation(s.negope)
	c:RegisterEffect(e2)
end
--e0 Effect Code
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.atkfil,tp,LOCATION_SZONE,0,1,nil)
end
--e1 Effect Code 
function s.tdfilter(c)
	return c:IsSetCard(0xc89) and c:IsType(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsAbleToDeck()
end
function s.tdcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.tdtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ckhc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	end
end
--e2 Effect Code
function s.cfilter(c)
	return c:IsSetCard(0xc89) and c:IsType(TYPE_TRAP+TYPE_CONTINUOUS)
end
function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),1,nil)
end
function s.negtar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.negope(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dt=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_ONFIELD,nil)
	if dt and dt:IsRelateToEffect(e) and Duel.Destroy(dt,REASON_EFFECT) then
		if #g==0 then return end
		for tc in aux.Next(g) do
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			--Negate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end