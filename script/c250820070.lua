--Empyrodraco Victorious, Zufulong
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),3)
	--Prevent targeting by opponent's effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Prevent destruction by opponent's effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.incon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--Gain ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.incon)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={0xc93}
--e1 Effect Code
function s.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
--e2 Effect Code
function s.infilter(c)
	return c:IsSetCard(0xc93) and c:IsFaceup()
end
function s.incon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.infilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,13,e:GetHandler())
	return #g>0 and g:GetClassCount(Card.GetCode)>=13
end
--e3 Effect Code
function s.atfilter(c)
	return c:IsSetCard(0xc93) and c:GetBaseAttack()>0
end
function s.tdfilter(c)
	return c:IsSetCard(0xc93) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_GRAVE,0,3,nil) and
		Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,13,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,13,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #g>0 and c:IsRelateToEffect(e) then
		local atk=g:GetSum(Card.GetAttack)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,13,13,nil)
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
		