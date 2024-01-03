-- Inubouzaki Fuu's Special Sight
-- Scripted by Power Calculator
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.shuffleTarget)
	e1:SetOperation(s.shuffleOperation)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.searchCondition)
	e2:SetCost(s.searchCost)
	e2:SetCountLimit(1,id+1)
	e2:SetOperation(s.searchOperation)
	c:RegisterEffect(e2)
end

function s.shuffleTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shuffleFilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 3, nil) and Duel.IsPlayerCanDraw(tp,2) end

	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_GRAVE + LOCATION_REMOVED,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.shuffleFilter(c)
	return c:IsAbleToDeck() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end

function s.shuffleOperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.shuffleFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	if #g==3 then
		Duel.HintSelection(g,true)
		Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

function s.searchCost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local m=e:GetHandler()
	if chk==0 then return m:IsAbleToRemoveAsCost() end

	local th= Duel.SelectMatchingCard(tp,s.checkEligibleCardsInHand,tp,LOCATION_HAND,0,1,1,nil,tp)
	
	Duel.Remove(th, POS_FACEUP, REASON_COST)
	Duel.Remove(m, POS_FACEUP, REASON_COST)
	Auxiliary.InubouzakiBanishedCardForEffectResolution = th:GetFirst()
end

function s.searchCondition(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not (aux.exccon(e,tp,eg,ep,ev,re,r,rp,chk,chkc)) then return false	end
	if not (chk == 0) then
	
	-- Take all the monsters in the hand
	local monstersInHand = Duel.GetMatchingGroup(s.checkEligibleCardsInHand, tp, LOCATION_HAND, 0, 1, tp)
	return #monstersInHand > 0
	end
end

function s.checkEligibleCardsInHand(c,tp)
	if not (c:IsMonster() and c:IsAbleToRemoveAsCost()) then return false end
	local g = Duel.GetMatchingGroup(s.singleprop, tp, LOCATION_DECK, 0, 1,c)
	return #g > 0
end

function s.checkEligibleCardsInDeck(c)
	if not (c:IsMonster() and c:IsAbleToHand()) then return false end
	return s.singleprop(c,Auxiliary.InubouzakiBanishedCardForEffectResolution)
end

function s.searchOperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local th= Duel.SelectMatchingCard(tp,s.checkEligibleCardsInDeck,tp,LOCATION_DECK,0,1,1, nil)
	Auxiliary.InubouzakiBanishedCardForEffectResolution = nil
	if #th>0 then
	   if Duel.SendtoHand(th,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,th)
	   end
	end
	
	
	
end

function s.singleprop(c,d)
	local ct=0
	if c:IsRace(d:GetRace()) then ct=ct+1 end
	if c:IsAttribute(d:GetAttribute()) then ct=ct+1 end
	if c:IsAttack(d:GetAttack()) and d:IsAttack(c:GetAttack()) then ct=ct+1 end
	if c:IsDefense(d:GetDefense()) and d:IsDefense(c:GetDefense()) then ct=ct+1 end
	return ct==1
end
function s.thfilter(c,mc)
	return c:IsMonster() and c:IsAbleToHand() and s.singleprop(c,mc)
end
function s.showfilter(c,tp,mc)
	return c:IsMonster() and not c:IsPublic() and c:IsAbleToRemove() and s.singleprop(c,mc)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
function s.revfilter(c,tp)
	return c:IsMonster() and not c:IsPublic() and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_DECK,0,1,nil,tp,c)
 
end