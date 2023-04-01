--Mudafi Maneuvres
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xc88}
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0xc88) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,tp)
	if #g>0 and Duel.IsMainPhase() then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TARGET)
	local tc=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--Defense boost
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end