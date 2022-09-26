--Mitori Geiko
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetTarget(s.dstarg)
	e2:SetOperation(s.dsoper)
	c:RegisterEffect(e2)
end
--e1 Effect Code
function s.spfilter(c)
  return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp, LOCATION_ONFIELD,0,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,s.spfilter,tp, LOCATION_ONFIELD,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  if tc and tc:IsRelatedToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
  end
end
--e2 Effect Code
function s.dsfilter(c)
  return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.dsfilter,tp, LOCATION_ONFIELD,0,1,nil) end
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,s.spfilter,tp, LOCATION_ONFIELD,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end