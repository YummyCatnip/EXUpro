--Astromini Moon
local s,id,o=GetID()
function s.initial_effect(c)
	--Pendulum procedure
	Pendulum.AddProcedure(c)
	--Xyz procedure
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PSYCHIC),3,2)
	--Special Summon 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	--Recovery
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.thcond)
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
	--Swap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.swtarg)
	e3:SetOperation(s.swoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc78}
--e1 Effect Code
function s.spfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xc78)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil) 
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--e2 Effect Code
function s.thfilter(c)
  return c:IsSetCard(0xc78) and c:IsAbleToHand()
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
 end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if tc then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end
--e3 Effect Code
function s.swfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.fdfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.swtarg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
  and Duel.IsExistingTarget(s.swfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) 
  and Duel.IsExistingTarget(s.fdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TARGET)
  local g1=Duel.SelectTarget(tp,s.swfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
  local g2=Duel.SelectTarget(tp,s.fdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1)
  e:SetLabelObject(g2:GetFirst())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
function s.swoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local tc=tg:GetFirst()
	local oc=e:GetLabelObject()
	if tc==oc then tc=tg:GetNext() end
	if not tc then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		if c:IsLocation(LOCATION_PZONE) then
			Duel.BreakEffect()
  		if oc and oc:IsRelateToEffect(e) and oc:IsLocation(LOCATION_MZONE) and oc:IsFaceup() then
        Duel.ChangePosition(oc,POS_FACEDOWN_DEFENSE)
      end
    end
  end
end