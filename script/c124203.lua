-- Conqueror Riché, the Linar Enigma
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CONQUEROR),2,3)
	c:EnableReviveLimit()
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(aux.mnphase)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Add 1 "Conqueror" monster from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.zptcon(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION)))
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CONQUEROR}
-- e1 Effect Code 
function s.spfil(c,e,tp)
	return c:IsSetCard(SET_CONQUEROR) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end
-- e2 Effect Code
function s.thfil(c,atts)
	return c:IsSetCard(SET_CONQUEROR) and c:GetAttribute()&atts>0 and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ig=aux.zptgroup(eg,aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),c,tp)
	local atts=ig:GetBitwiseOr(Card.GetAttribute)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_GRAVE,0,1,nil,atts) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att_table=eg:GetClass(Card.GetAttribute)
	local atts=0
	for i=1,#att_table do
		atts=atts|att_table[i]
	end
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil,tp,LOCATION_GRAVE,0,1,1,nil,atts)
	if #g>0 then return
		Duel.Search(g,tp)
	end
end