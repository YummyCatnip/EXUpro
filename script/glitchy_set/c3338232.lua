--Wicked Booster Vicious Highway
--Scripted by: XGlitchy30

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--fusion summon
	local e2=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_WICKED_BOOSTER))
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(0)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsCode(3328992) and c:IsSSetable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.PlayerHasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SSet(tp,sg)
		end
	end
end