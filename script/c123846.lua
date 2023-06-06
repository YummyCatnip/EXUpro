-- Mei, Life of the Conquerors
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Special Summon 1 "Conqueror" from Deck, change its name to "id"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.selfreleasecost)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Add 1 of your banished "Conqueror" card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_CONQUEROR}
--e1 Effect Code
function s.spfil(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(SET_CONQUEROR) and not c:IsCode(id)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if g and Duel.SpecialSummonStep(g,0,tp,tp,false,false,POS_FACEUP) then
		-- change its name to "id"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(id)
		g:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
-- e2 Effect Code
function s.cfil(c,tp,tc)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(SET_CONQUEROR)
end
function s.thfil(c)
	return c:IsAbleToHand() and c:IsSetCard(SET_CONQUEROR)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.cfil,tp,LOCATION_GRAVE,0,1,c) and Duel.IsExistingTarget(s.thfil,tp,LOCATION_REMOVED,0,1,nil) end
	local g1=Duel.Select(HINTMSG_ATOHAND,true,tp,s.thfil,tp,LOCATION_REMOVED,0,1,1,nil)
	local g2=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfil,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g2+c,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,tp,LOCATION_REMOVED)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Search(tc,tp)
	end
end