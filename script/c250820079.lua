--Number 129: Lost Chained Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--Xyz Procedure
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,1,2)
	--Set from Deck
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetCountLimit(1,id)
  e1:SetCost(aux.dxmcostgen(2,2,nil))
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
end
s.xyz_number=129
--e1 Effect Code
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(50078509,tp,LOCATION_DECK,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_SELECT)
  local tc=Duel.SelectMatchingCard(tp,50078509,tp,LOCATION_DECK,0,1,1,nil)
  if tc then
    Duel.SSet(tp,tc)
  end
end