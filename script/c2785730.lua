--Astromini Research
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.thcond)
	e1:SetTarget(s.thtarg)
	e1:SetOperation(s.thoper)
	c:RegisterEffect(e1)
end
s.listed_series={0xc78}
--e1 Effect Code
function s.filter(c)
	return c:IsSetCard(0xc78) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM)
end
function s.psyfilter(c)
	return (c:GetOriginalRace()==RACE_PSYCHIC)
end
function s.syxfilter(c)
	return c:GetOriginalType()&(TYPE_SYNCHRO|TYPE_XYZ)>0
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	return g and g:IsExists(s.psyfilter,1,nil)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		and Duel.IsExistingMatchingCard(s.syxfilter,tp,LOCATION_PZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			Duel.Summon(tp,tc,true,nil)
		end
	end
end