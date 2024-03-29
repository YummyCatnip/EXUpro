--Astromini Constellation
local s,id,o=GetID()
function s.initial_effect(c)
	--Pendulum procedure
	Pendulum.AddProcedure(c)
	--Synchro procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PSYCHIC),1,1,Synchro.NonTuner(nil),1,99)
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
	--Search 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.srcond)
	e2:SetTarget(s.srtarg)
	e2:SetOperation(s.sroper)
	c:RegisterEffect(e2)
	--Swap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
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
function s.srfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0xc78) and c:IsAbleToHand()
end
function s.srcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.srtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,0)
end
function s.sroper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if tc then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end
--e3 Effect Code
function s.swfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.tgfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.swtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
  and Duel.IsExistingTarget(s.swfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) 
  and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TARGET)
  local g1=Duel.SelectTarget(tp,s.swfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
  local g2=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1)
  e:SetLabelObject(g2:GetFirst())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
function s.swoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local tc=e:GetLabelObject()
	g:RemoveCard(tc)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if g and tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		if c:IsLocation(LOCATION_PZONE) then
			Duel.BreakEffect()
			if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e2:SetCountLimit(1)
				e2:SetLabel(Duel.GetTurnCount())
				e2:SetLabelObject(tc)
				e2:SetCondition(s.retcon)
				e2:SetOperation(s.retop)
				if Duel.GetCurrentPhase()<=PHASE_STANDBY then
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
				else
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
				end
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()>e:GetLabel()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end