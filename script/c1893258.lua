-- Fury Queltz
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Handes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.hdtarg)
	e1:SetOperation(s.hdoper)
	c:RegisterEffect(e1)
	-- Banish 5 cards from both Decks Face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.hdtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>1 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,2,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,2,nil) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,1-tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.hdoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local td=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,nil)
	if #td>1 then
		td=Duel.Select(HINTMSG_TODECK,false,1-tp,Card.IsAbleToDeck,tp,0,LOCATION_REMOVED,2,2,nil)
		if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,1-tp)>0 then
			local g0=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
			Duel.ConfirmCards(tp,g0)
			local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
			local sg=g:Select(tp,2,2,nil)
			local tc=sg:Select(1-tp,1,1,nil):GetFirst()
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT,nil,1-tp)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
-- e2 Effect Code
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetDecktopGroup(tp,5)
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end