-- Conqueror Helaenestra, the Twofold Singularity
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CONQUEROR),2,2)
	c:EnableReviveLimit()
	-- To Pendulum
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tpcon)
	e1:SetTarget(s.tptarg)
	e1:SetOperation(s.tpoper)
	c:RegisterEffect(e1)
	-- Fusion Summon
	local fusparam=aux.FilterBoolFunction(Card.IsSetCard,SET_CONQUEROR)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost)
	e2:SetTarget(Fusion.SummonEffTG(fusparam))
	e2:SetOperation(Fusion.SummonEffOP(fusparam))
	c:RegisterEffect(e2)
end
s.listed_names={124217}
s.listed_series={SET_CONQUEROR}
-- e1 Effect Code 
function s.tpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.pcfilter(c)
	return c:IsCode(124217) and not c:IsForbidden()
end
function s.tptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function s.tpoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp)) then return end
	local g=Duel.Select(HINTMSG_TOFIELD,false,tp,s.pcfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- e2 Effect Code
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end