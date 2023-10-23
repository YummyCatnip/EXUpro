-- Luminous, Shining Cirgon
-- Scripted by Satellaa
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	-- Must be properly summoned before reviving
	c:EnableReviveLimit()
	-- Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,1)
	-- Add 1 "Cirgon" monster from your Deck to your hand
	c:SummonedTrigger
	(
		false,false,true,false,aux.Stringid(id,0),CATEGORY_TOHAND+CATEGORY_SEARCH,
		EFFECT_FLAG_DELAY,true,function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end,
		s.thcost,s.thtg,s.thop
	)
end
s.listed_series={SET_CIRGON}
function s.tbfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CIRGON) and c:IsReleasable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tbfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.tbfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Sendto(g,LOCATION_GRAVE,REASON_RELEASE|REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_CIRGON) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup()
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			c:UpdateLV(-1)
		end
	end
end