--Shifting of the Sands
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xc90}
function s.cfilter(c)
	return c:IsSetCard(0xc90) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT) then
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
		else
			Duel.BreakEffect()
			local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
			Duel.SendtoDeck(sg,0,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end