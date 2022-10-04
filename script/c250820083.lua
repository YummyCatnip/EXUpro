--Noble People, Arc Angel
local s,id,o=GetID()
function s.initial_effect(c)
  --Limit 1
	c:SetUniqueOnField(1,0,id)
	--Synchro Summon Procedure
  c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,99)
	--Targeted protection
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_FIELD)
  e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
  e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
  e0:SetRange(LOCATION_MZONE)
  e0:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
  e0:SetTarget(s.imtarg)
  e0:SetValue(aux.tgoval)
  c:RegisterEffect(e0)
  --Move a monster
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1)
  e1:SetTarget(s.mvtarg)
  e1:SetOperation(s.mvoper)
  c:RegisterEffect(e1)
  --Return a card to the hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_MOVE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCondition(s.thcond)
  e2:SetTarget(s.thtarg)
  e2:SetOperation(s.thoper)
  c:RegisterEffect(e2)
end
--e0 Effect Code
function s.imtarg(e,c)
	return (e:GetHandler():GetColumnGroup():IsContains(c)) and c~=e:GetHandler()
end
--e1 Effect Code
function s.mvtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.TRUE(chkc) end
  if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.mvoper(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
		local ttp=tc:GetControler()
		if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(ttp,LOCATION_MZONE,ttp,LOCATION_REASON_CONTROL)<=0 then return end
  local p1,p2,i
		if tc:IsControler(tp) then
			i=0
			p1=LOCATION_MZONE
			p2=0
		else
			i=16
			p2=LOCATION_MZONE
			p1=0
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
end
--e2 Effect Code
function s.mvfilter(c)
  return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.mvfilter,1,nil)
end
function s.cfilter(c,rc)
    local ag=rc:GetColumnGroup(1,1)-rc:GetColumnGroup()
    return ag and ag:IsContains(c)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and s.cfilter(chkc,c) end
    if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,c)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    Duel.SendtoHand(tc,nil,REASON_EFFECT)
  end
end