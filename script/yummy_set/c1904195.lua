-- Winged Ipiria
local s,id,o=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	-- EMZ Summon Limit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e)return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)end)
	e0:SetOperation(s.limit)
	c:RegisterEffect(e0)
	-- Both Players can add 1 Reptile from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcond)
	e1:SetTarget(s.thtarg)
	e1:SetOperation(s.thoper)
	c:RegisterEffect(e1)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_REPTILE,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
-- e0 Effect Code
function s.limit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(~0xf60)
	Duel.RegisterEffect(e1,tp)
end
-- e1 Effect Code
function s.thfilter(c,at)
	return c:IsRace(RACE_REPTILE) and c:GetAttack()<at and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.atfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.atfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local at=g:GetSum(Card.GetAttack)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,at) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SEARCH,nil,1,1-tp,LOCATION_DECK)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local h1,h2=0
	local g=Duel.GetMatchingGroup(s.atfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local at=g:GetSum(Card.GetAttack)
	local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,at)
	local g2=Duel.GetMatchingGroup(s.thfilter,1-tp,LOCATION_DECK,0,nil,at)
	if #g1==0 and #g2==0 then return end
	if #g1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg1=g1:Select(tp,1,1,nil)
		if #sg1>0 then
			Duel.SendtoHand(sg1,nil,REASON_EFFECT)
			Duel.ConfirmCards(tp,sg1)
			h1=1
		end
	end
	if #g2>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(1-tp,1,1,nil)
		if #sg2>0 then
			Duel.SendtoHand(sg2,nil,REASON_EFFECT)
			Duel.ConfirmCards(tp,sg2)
			h2=1
		end
	end
	Duel.BreakEffect()
	if h1>0 then
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	if h2>0 then
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end