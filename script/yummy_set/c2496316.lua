--Rainbow Flush!
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--e1 Effect Code
function s.filter(c)
	return (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI)) and c:IsType(TYPE_PENDULUM)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.rescon(sg,e,tp,mg)
	return (sg:GetClassCount(Card.GetAttribute)==1 or sg:GetClassCount(Card.GetType)==1) and
		sg:GetClassCount(Card.GetCode)==sg:GetCount()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		local x=0
		if Duel.CheckLocation(tp,LOCATION_PZONE,0) then x=x+1 end
		if Duel.CheckLocation(tp,LOCATION_PZONE,1) then x=x+1 end
		if x==0 then return false end
		return aux.SelectUnselectGroup(g,e,tp,1,x,s.rescon,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local x=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then x=x+1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then x=x+1 end
	if x==0 then return false end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,x,s.rescon,1,tp,HINTMSG_TOFIELD,s.rescon)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=sg:GetFirst()
		for sc in aux.Next(sg) do
			Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end