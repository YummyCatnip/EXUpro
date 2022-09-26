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
end
--e0 Effect Code
function s.imtarg(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c) and c~=e:GetHandler()
end
--e1 Effect Code
function s.mvtarg(e,tp,eg,ep,ev,re,r,rp,chk)
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
end
--e2 Effect Code