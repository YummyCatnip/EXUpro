-- Evolute Ipira
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.adcond)
	e1:SetCost(s.adcost)
	e1:SetTarget(s.adtarg)
	e1:SetOperation(s.adoper)
	c:RegisterEffect(e1)
	-- Banish 1 Reptile, but SS ot during your next Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- e1 Effect Code
function s.adcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
function s.adtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.adoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- e2 Effect Code
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAbleToBeRemoved()
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_REMOVED)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
        local c=e:GetHandler()
        local fid=c:GetFieldID()
        local res=(Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.IsTurnPlayer(tp)) and 2 or 1
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
        --Special Summon it during your next Standby Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e1:SetCountLimit(1)
        e1:SetLabel(fid)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.spcond)
        e1:SetOperation(s.spoper2)
        e1:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,res)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsTurnPlayer(tp) and tc:GetFlagEffectLabel(id)==e:GetLabel() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spoper2(e,tp,eg,ep,ev,re,r,rp)
    Duel.SpecialSummon(e:GetLabelObject(),0,tp,tp,false,false,POS_FACEUP)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
        local c=e:GetHandler()
        local fid=c:GetFieldID()
        local res=(Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.IsTurnPlayer(tp)) and 2 or 1
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
        --Special Summon it during your next Standby Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e1:SetCountLimit(1)
        e1:SetLabel(fid)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.spcond)
        e1:SetOperation(s.spoper2)
        e1:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,res)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsTurnPlayer(tp) and tc:GetFlagEffectLabel(id)==e:GetLabel() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spoper2(e,tp,eg,ep,ev,re,r,rp)
    Duel.SpecialSummon(e:GetLabelObject(),0,tp,tp,false,false,POS_FACEUP)
end