-- Aberration-56: Funeral of Black Roses
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- Synchro procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	-- Tribute a card then Summon "Bouquet of Black Roses"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(aux.rsnsynchro)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Tribute 1 "Bouquet of Black Roses" to SS another with a different Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gscond)
	e2:SetTarget(s.gstarg)
	e2:SetOperation(s.gsoper)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BOUQUET}
-- e1 Effect Code
function s.cfilter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
function s.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsCode(CARD_BOUQUET) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,c,e,tp) end
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,c,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)<=e:GetLabel()
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local lv=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,lv)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end
	for tc in sg:Iter() do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- e2 Effect Code
function s.gscond()
	return Duel.IsMainPhase()
end
function s.gscfil(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsCode(CARD_BOUQUET) and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.sgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
function s.sgfilter(c,e,tp,lv)
	return not c:IsLevel(lv) and c:IsCode(CARD_BOUQUET) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gstarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.gscfil,1,false,nil,nil,e,tp) end
	local rg=Duel.SelectReleaseGroupCost(tp,s.gscfil,1,1,false,nil,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.gsoper(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if #g==0 then return end
	Duel.SpecialSummonStep(g,0,tp,tp,false,false,POS_FACEUP)
end