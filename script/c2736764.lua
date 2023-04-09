-- A Chance Meeting at Pumpkin Castle
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_PUMPKINHEAD}
-- e1 Effect Code
function s.cfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_FUSION)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if (#g<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0) then return end
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local cn=Duel.Select(HINTMSG_APPLYTO,false,tp,aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil):GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(CARD_PUMPKINHEAD)
		cn:RegisterEffect(e1)
	end
end