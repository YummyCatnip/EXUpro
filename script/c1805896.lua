--Localized Tornado Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--Xyz Procedure
  c:EnableReviveLimit()
  Xyz.AddProcedure(c,nil,7,2)
  --ATK Gain
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
  e1:SetCode(EVENT_TO_DECK)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTarget(s.atktarg)
  e1:SetOperation(s.atkoper)
  c:RegisterEffect(e1)
  --Shuffle all cards into the Deck
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1,id)
  e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
  e2:SetCondition(function() return Duel.IsMainPhase() end)
  e2:SetCost(aux.dxmcostgen(1,1,nil))
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)
end
--e1 Effect Code
function s.atktarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() end
end
function s.atkoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(100)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
--e2 Effect Code
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRend+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRend+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)
  if #g>0 then
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
  end
  local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
  if tg:IsExists(Card.IsControler,1,nil,tp) then Duel.ShuffleDeck(tp) end
	if tg:IsExists(Card.IsControler,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
end