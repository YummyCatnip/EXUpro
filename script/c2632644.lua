--Havely Praid
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	--Def
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Send card to GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START)
	e4:SetCountLimit(1,id)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.tgcond)
	e4:SetTarget(s.tgtarg)
	e4:SetOperation(s.tgoper)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(s.spcond)
	e5:SetTarget(s.sptarg)
	e5:SetOperation(s.spoper)
	c:RegisterEffect(e5)
end
--e2 Effect Code
function s.tg(e,c)
	local lv=c:GetLevel()
	return lv>0 and lv<=2 and c:IsRace(RACE_BEAST)
end
--e4 Effect Code
function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or Duel.IsBattlePhase()
end
function s.tgfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if sc then
		Duel.SendtoGrave(sc,REASON_EFFECT)
	end
end
--e5 Effect Code
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	if #sg > 0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end