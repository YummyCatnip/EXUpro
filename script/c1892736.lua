-- Queltz Storm
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.cfilter(c,e,tp,lp)
	return c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ) and not c:IsPublic() and (Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_SZONE,1,nil) or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) and lp>c:GetDefense()))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lp=Duel.GetLP(tp)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lp) end
	local tc=Duel.Select(HINTMSG_CONFIRM,false,tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabelObject(tc)
	local b1=Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_SZONE,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) and lp>tc:GetDefense()
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	Duel.SetTargetParam(op)
	if op==0 then
		e:SetCategory(CATEGORY_TODECK)
		local g=Duel.Select(HINTMSG_TODECK,true,tp,Card.IsAbleToDeck,tp,0,LOCATION_SZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_HAND)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetTargetParam()
	if not op then return end
	if op==0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	elseif op==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local tc=e:GetLabelObject()
		local lp=Duel.GetLP(tp)
		if tc then
			mustpay=true
			Duel.PayLPCost(tp,tc:GetDefense())
			mustpay=false
			tc:SetMaterial(nil)
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end