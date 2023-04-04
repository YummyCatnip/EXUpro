--Bestia Riciclo Lingua Fiocco
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--ss
	c:Ignition(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND,nil,LOCATION_HAND,true,
		aux.LocationGroupCond(s.filter,LOCATION_MZONE,0),
		nil,
		s.sptg,
		s.spop
	)
	--search
	c:SentToHandTrigger(false,2,CATEGORIES_SEARCH,true,true,
		s.thcon,
		nil,
		aux.SearchTarget(s.thfilter),
		aux.SearchOperation(s.thfilter)
	)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain(0) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,c)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.Select(HINTMSG_RTOHAND,false,tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,c)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousControler(1-tp)) and (c:GetReasonCard() or (re and re:GetHandler()))
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_RECYCLE_BEAST) and not c:IsCode(id)
end