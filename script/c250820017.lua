--Astromini Scattering
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate (Special Summon)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcond)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	--Activate (To Hand)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCondition(s.thcond)
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
	--Activate (Banish)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCondition(s.bncond)
	e3:SetTarget(s.bntarg)
	e3:SetOperation(s.bnoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc78}
--e1 Effect Code
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc78) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsType(TYPE_PENDULUM)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),nil)==#g
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--e2 Effect Code
function s.syfilter(c)
	return c:GetOriginalType()&(TYPE_SYNCHRO)
end
function s.thfilter(c)
	return c:IsSetCard(0xc78) and c:IsFaceup() and c:IsAbleToHand() and c:IsType(TYPE_PENDULUM)
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	return #g1>0 and g1:FilterCount(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),nil)==#g1
	and g2 and g2:IsExists(s.syfilter,1,nil)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end
--e3 Effect Code
function s.xyfilter(c)
	return c:GetOriginalType()&(TYPE_XYZ)
end
function s.bnfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.syfilter(c)
	return c:GetOriginalType()&(TYPE_SYNCHRO)
end
function s.bncond(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	return #g1>0 and g1:FilterCount(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),nil)==#g1
	and g2 and g2:IsExists(s.syfilter,1,nil)
end
function s.bntarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.bnfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.bnfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.bnfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.bnoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if g then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end