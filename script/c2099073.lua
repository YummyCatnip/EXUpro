-- Queltz Aparition
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.cfilter(c)
	return c:IsRitualMonster() and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and 
		Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,SET_QUELTZ,1600,4000,8,RACE_THUNDER,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,SET_QUELTZ,1600,4000,8,RACE_THUNDER,ATTRIBUTE_FIRE) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return not Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
	e1:SetTarget(s.rltarg)
	e1:SetOperation(s.rloper)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	Duel.SpecialSummonComplete()
end
function s.relfilter(c,e,tp,tc,ft,g)
	local lv=tc:GetLevel()*2
	aux.RitualSummoningLevel=lv
	local mlv=c:GetRitualLevel(tc)
	aux.RitualSummoningLevel=nil
	if not ((mlv&0xffff)>=lv or (mlv>>16)>=lv) then return false end
	if tc.mat_filter and not tc.mat_filter(c) or (tc.ritual_custom_check and not tc.ritual_custom_check(e,tp,Group.FromCards(c),tc)) then return false end
	return (ft>-1 or c:IsControler(tp)) and c:IsReleasableByEffect(e) and g:IsContains(c)
end
function s.ritfil(c,e,tp,ft,g)
	if not c:IsRitualMonster() or not c:IsRace(RACE_THUNDER) or not c:IsAttribute(ATTRIBUTE_FIRE) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) or not Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,c,ft,g) then
		return false
	end
end
function s.rltarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.ritfil),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,ft,cg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mg=Group.FromCards(e:GetHandler())
	local g=Duel.Select(HINTMSG_RITUAL,false,tp,aux.NecroValleyFilter(s.ritfil)tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	local tc=Duel.Select(HINTMSG_RELEASE,false,tp,aux.NecroValleyFilter(s.relfilter),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,e,tp,c,ft):GetFirst()
	if tc then
		mg:AddCard(tc)
		c:SetMaterial(mg)
		if Duel.Release(tc,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()
	end
end