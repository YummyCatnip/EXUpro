-- Akefalos Kavalaris
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	-- ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	-- Change a card effect 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.cgcond)
	e2:SetCost(s.cgcost)
	e2:SetTarget(s.cgtarg)
	e2:SetOperation(s.cgoper)
	c:RegisterEffect(e2)
end
-- e1 Effect Code
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if #mg>0 and #mg==mg:FilterCount(Card.IsRace,nil,RACE_ZOMBIE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
-- e2 Effect Code
function s.cgcond(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.cfilter(c,rt)
	return c:IsAbleToRemoveAsCost() and c:IsType(rt)
end
function s.cgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rt=re:GetActiveType()&(TYPE_SPELL|TYPE_MONSTER|TYPE_TRAP)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,rt)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,rt)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.cgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOW_DEFENSE)
end
function s.cgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.cgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.cgfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return ((b1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or (b2 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.cgoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.cgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.cgfilter,tp,0,LOCATION_GRAVE,nil,e,tp)
	if #g1==0 and #g2==0 then return end
	if #g1>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local sg1=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.cgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	if #g2>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		local sg2=Duel.Select(HINTMSG_SPSUMMON,false,1-tp,s.cgfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		Duel.SpecialSummon(sg2,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end