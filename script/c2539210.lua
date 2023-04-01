--Mudafi Matter - Fayiz
local s,id,o=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.srcond)
	e1:SetTarget(s.srtarg)
	e1:SetOperation(s.sroper)
	c:RegisterEffect(e1)
	--Steal monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(aux.bdogcon)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
	--Extra Normal Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.StardustCost)
	e3:SetTarget(s.nstarg)
	e3:SetOperation(s.nsoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc88}
--e1 Effect Code
function s.thfilter(c)
	return c:IsSetCard(0xc88) and c:IsAbleToHand()
end
function s.srcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.srtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sroper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--e2 Effect Code
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(0xc88)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
--e3 Effect Code
function s.nsfilter(c)
	return c:IsSetCard(0xc88) and c:IsSummonable(true,nil)
end
function s.nstarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end