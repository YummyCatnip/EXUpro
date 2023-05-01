-- Queltz Dominance
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- Activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Make each player banish 1 card from the field if possible
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.bnoper)
	c:RegisterEffect(e1)
	-- Maintain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
-- e1 Effect Code
function s.filter(c)
	return c:IsAbleToRemove() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return (b1 or b2) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
end
function s.bnoper(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	if #g1==0 and #g2==0 then return end
	if #g1>0 then
		g1=g1:Select(tp,1,1,nil)
		Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
	end
	if #g2>0 then
		g2=g2:Select(1-tp,1,1,nil)
		Duel.Remove(g2,POS_FACEDOWN,REASON_EFFECT,1-tp)
	end
end
-- e2 Effect Code
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	elseif #g==0 then
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end