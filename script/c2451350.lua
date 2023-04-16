-- Evoltile Eindo
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Link Procedure
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_EVOLTILE),1)
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.nsoper)
	c:RegisterEffect(e1)
	-- Special Summon of Evoltile, Evolsaur and Evolzar cannot be negated
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,{SET_EVOLTILE,SET_EVOULZAR,SET_EVOULZAR}))
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e1)
end
s.listed_series={SET_EVOLTILE,SET_EVOLSAUR,SET_EVOULZAR}
s.listed_names={id}
-- e1 Effect Code
function s.nsoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EVOLTILE))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end