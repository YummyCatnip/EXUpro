-- Cradle Queltz
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtarg)
	e1:SetOperation(s.thoper)
	c:RegisterEffect(e1)
	-- Ritual Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.mnphase)
	e2:SetTarget(s.rttarg)
	e2:SetOperation(s.rtoper)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thfil(c)
	return c:IsSetCard(SET_QUELTZ) and c:IsAbleToHand()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
-- e2 Effect Code
function s.rtfil(c,e,tp)
	return c:IsSetCard(SET_QUELTZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.rttarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect(e) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rtfil),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.rtoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and c:IsReleasableByEffect(e) and c:IsRelateToEffect(e))then return end
	local g=Duel.Select(HINTMSG_RITUAL,false,tp,aux.NecroValleyFilter(s.rtfil),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if g then
		g:SetMaterial(Group.FromCards(c))
		if Duel.Release(c,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		Duel.SpecialSummon(g,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()
	end
end