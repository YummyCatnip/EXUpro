-- Hallowed Queltz
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Banish 1 card Face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rvtarg)
	e1:SetOperation(s.rvoper)
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
function s.tdfil(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function s.rvfil(c,g,mc)
	return c:IsAbleToRemove() and (g:IsContains(c) or c==mc)
end
function s.rvtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfil,tp,0,LOCATION_REMOVED,3,nil) and Duel.IsExistingTarget(s.rvfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,cg,c) end
	local g1=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfil,tp,0,LOCATION_REMOVED,3,3,nil)
	local g2=Duel.Select(HINTMSG_REMOVE,true,tp,s.rvfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,cg,c):GetFirst()
	e:SetLabelObject(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
function s.rvoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local tc=e:GetLabelObject()
	g:RemoveCard(tc)
	if #g>0 and tc and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(c)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
-- e2 Effect Code
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetDecktopGroup(tp,5)
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end