--Astromini Fishing
local s,id,o=GetID()
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.ngcond)
	e1:SetCost(s.ngcost)
	e1:SetTarget(s.ngtarg)
	e1:SetOperation(s.ngoper)
	c:RegisterEffect(e1)
	--To hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
end
s.listed_series={0xc78}
--e1 Effect Code
function s.cfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&(TYPE_SYNCHRO|TYPE_XYZ)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc78) and c:IsAbleToGraveAsCost()
end
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.ngcond(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.ngtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.ngoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
--e2 Effect Code
function s.thfilter(c)
	return c:IsSetCard(0xc78) and c:IsFaceup() and c:IsAbleToHand() and c:IsType(TYPE_PENDULUM)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end
end