--Stalker of the Endless Sands
local s,id,o=GetID()
function s.initial_effect(c)
	--Send To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(aux.StardustCost)
	e1:SetTarget(s.tgtarg)
	e1:SetOperation(s.tgoper)
	c:RegisterEffect(e1)
	--Change battle position
	local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_POSITION)
  e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.escond)
	e2:SetTarget(s.pstarg)
	e2:SetOperation(s.psoper)
	c:RegisterEffect(e2)
end
s.listed_series={0xc90}
--e1 Effect Code
function s.tgfilter(c)
	return c:IsSetCard(0xc90) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
--e2 Effect Code
function s.escond(e)
  return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.pstarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.psoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end