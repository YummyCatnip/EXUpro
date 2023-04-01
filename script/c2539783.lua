--Mudafi Migrant - Jabar
local s,id,o=GetID()
function s.initial_effect(c)
	--Search 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.srtarg)
	e1:SetOperation(s.sroper)
	c:RegisterEffect(e1)
	--Mudafi effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condit)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operat)
	c:RegisterEffect(e2)
end
s.listed_series={0xc88}
--e1 Effect Code
function s.srtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sroper(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.thcond)
	e1:SetOperation(s.thoper)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return c:IsSetCard(0xc88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--e2 Effect Code
function s.filter(c)
	return c:IsSetCard(0xc88) and c:IsFaceup() and c:GetAttack()>=500
end
function s.condit(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xc88),tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Decrease atk
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		--double attack
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end