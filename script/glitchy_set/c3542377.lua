--Bestia Riciclo Buzz Blaster
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--tohand
	c:Quick(false,0,CATEGORY_TOHAND,EFFECT_FLAG_CARD_TARGET,nil,LOCATION_HAND,true,
		nil,
		aux.DiscardSelfCost,
		aux.Target(s.thfilter,LOCATION_GRAVE,0,1,1,nil,nil,CATEGORY_TOGRAVE),
		aux.SendToHandOperation(SUBJECT_IT)
	)
	--spsummon
	c:SentToHandTrigger(false,1,CATEGORY_SPECIAL_SUMMON,true,true,
		s.thcon,
		nil,
		s.sptg,
		s.spop
	)
	--add flag for user to know which copy was added to hand
	c:SentToHandTrigger(true,3,nil,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,nil,
		s.thcon,
		nil,
		nil,
		s.flagop,
		0
	)
end
function s.thfilter(c)
	return c:IsSetCard(SET_RECYCLE_BEAST) and c:IsAbleToHand()
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousControler(1-tp)) and (c:GetReasonCard() or (re and re:GetHandler()))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_RECYCLE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.flagop(e,tp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_HAND) then return end
	if c:HasFlagEffect(id) then
		c:ResetFlagEffect(id)
	end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
end