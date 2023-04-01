-- Cotezical, Terror of Terracotta Towers
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_REPTILE),8,2)
	c:EnableReviveLimit()
	-- Shuffle [3433692] in to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1))
	e1:SetTarget(s.tdtarg)
	e1:SetOperation(s.tdoper)
	c:RegisterEffect(e1)
	-- Send 1 Reptile to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tgcond)
	e2:SetTarget(s.tgtarg)
	e2:SetOperation(s.tgoper)
	c:RegisterEffect(e2)
	-- Negate activation on hand or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.ngcond)
	e3:SetCost(s.ngcost)
	e3:SetTarget(s.ngtarg)
	e3:SetOperation(s.ngoper)
	c:RegisterEffect(e3)
end
s.listed_names={3433692,id}
-- e1 Effect Code
function s.tdfilter(c)
	return c:IsCode(3433692) and c:IsAbleToDeck()
end
function s.tdtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local ct=Duel.GetMatchingGroupCount(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,0,ct,tp,0)
end
function s.tdoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=#g
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,ct,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- e2 Effect Code
function s.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
function s.tgcond()
	return Duel.IsMainPhase()
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and not rc:IsRace(RACE_REPTILE)
end
-- e3 Effec Code
function s.ngfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
function s.rfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
function s.ngcond(e,tp,eg,ep,ev,re,r,rp)
	local activateLocation = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and (activateLocation==LOCATION_GRAVE or activateLocation==LOCATION_HAND)
end
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.ngfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	if sg:IsExists(Card.IsCode,1,nil,3433692) then
		e:SetLabel(1)
	end
end
function s.ngtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_REMOVED)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.ngoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and e:GetLabel()>0 then
		if Duel.Destroy(eg,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_REMOVED,0,2,2,nil)
			Duel.SendtoGrave(g,REASON_EFFECT)
			e:SetLabel(0)
		end
	end
end