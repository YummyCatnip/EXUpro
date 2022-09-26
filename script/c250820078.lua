--Number 108: Divine Wind Dragon
local s,id,o=GetID()
function s.initial_effect(c)
  --Xyz Procedure
	Xyz.AddProcedure(c,nil,6,2,nil,nil,99)
	c:EnableReviveLimit()
	--Shuffle a card into the Deck
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1,{id,1})
  e1:SetCost(aux.dxmcostgen(1,1,nil))
  e1:SerTarget(s.tdtarg)
  e1:SetOperation(s.tdoper)
  c:RegisterEffect(e1)
  --Destroy a Monster
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DESTROY)
  e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_TOGRAVE+EVENT_TODECK)
  e2:SetCountLimit(1,{id,2})
  e2:SetCondition(s.dscond)
  e2:SetCost(aux.dxmcostgen(1,1,nil))
  e2:SetTarget(s.dstarg)
  e2:SetOperation(s.dsoper)
  c:RegisterEffect(e2)
end
s.xyz_number=108
--e1 Effect Code
function s.tdfilter(c)
  return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
function s.tdtarg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,nil) end
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TODECK)
  Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.tdoper(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TOHAND)
  local g=Duel.SelectMatchungCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,1,nil)
  if g and tc and tc:IsRelatedToEffect(e) and Duel.SendToHand(g,tp,REASON_EFFECT) then
    Duel.SendToDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
  end
end
--e2 Effect Code
function s.dsfilter(c)
  return c:IsType(TYPE_MONSTER)
end
function s.cfilter(c)
  return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.dscond(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExist(s.cfilter,1,nil)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.dsfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_MESSAGE,tp,HINT_MSGDESTROY)
  local g=Duel.SelectTarget(tp,s.dsfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end