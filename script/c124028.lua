-- Conqueror Mei, the Blooming Sorceress
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--fusion proc
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,123846,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CONQUEROR))
	-- Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- Destroy 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.dscond)
	e2:SetTarget(s.dstarg)
	e2:SetOperation(s.dsoper)
	c:RegisterEffect(e2)
	-- Multi Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.macond)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_names={123846}
s.listed_series={SET_CONQUEROR}
s.material_setcode={SET_CONQUEROR}
-- e1 Effect Code 
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*100
end
-- e2 Effect Code
function s.dscond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CONQUEROR)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local gc=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local bc=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	local b1=Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil) and bc>gc
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return (b1 or b2) end
	local g=nil
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		g=Duel.Select(HINTMSG_DESTROY,true,tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
	elseif b1 then
		g=Duel.Select(HINTMSG_DESTROY,true,tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetTargetCards(e)
	if #tc>0 then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- e3 Effect Code
function s.macond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetBaseAttack()~=c:GetAttack()
end