-- Fiery, Burning Cirgon Spirit
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,3934389,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CIRGON))
	-- Cannot be Banished
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	-- effect gain
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- Destroy 1 or SS 1 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.material_setcode=SET_CIRGON
s.listed_series={SET_CIRGON}
-- e1 Effect Code 
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end
-- e2 Effect Code 
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.cfilter(c)
	return c:IsSetCard(SET_CIRGON) and c:IsMonster() and c:IsReleasableByEffect()
end
function s.spfil(c,e,tp)
	return c:IsSetCard(SET_CIRGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) and (b1 or b2) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_HAND,0,1,nil,e,tp)
	local g=Duel.Select(HINTMSG_RELEASE,false,tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and (b1 or b2) and Duel.SendtoGrave(g,REASON_EFFECT+REASON_RELEASE)>0 then
		Duel.BreakEffect()
		local opt=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)}, -- Destroy 1 monster your opponent controls
		{b2,aux.Stringid(id,2)}) -- Special Summon 1 "Cirgon" from hand
		if opt==1 then
			local tc=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsMonster,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.Destroy(tc,REASON_EFFECT)
		else
			local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfil,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetCondition(s.ngcond)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetCondition(s.ngcond)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
function s.ngcond(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==1-tp
end