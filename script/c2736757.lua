-- Pumpkin, Pumpkin Eater
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_PUMPKINHEAD}
-- e1 Effect Code
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.pupfil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.Select(HINTMSG_APPLYTO,true,tp,aux.pupfil,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetCode()
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_ALL,nil,code)
		for oc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_PHASE|PHASE_END)
			e1:SetValue(CARD_PUMPKINHEAD)
			oc:RegisterEffect(e1)
		end
	end
end
-- e2 Effect Code
function s.cfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_FUSION)
end
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end