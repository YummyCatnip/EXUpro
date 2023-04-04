--Bestia Riciclo Coda Affilata
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--ss
	c:SentToHandFieldTrigger(s.cfilter,false,0,CATEGORY_SPECIAL_SUMMON,true,LOCATION_HAND+LOCATION_GRAVE,true,
		nil,
		nil,
		aux.SSTarget(SUBJECT_THIS_CARD),
		aux.SSOperation(SUBJECT_THIS_CARD)
	)
	--search
	c:SentToHandTrigger(false,2,CATEGORIES_SEARCH,true,true,
		s.thcon,
		nil,
		aux.SearchTarget(s.thfilter),
		aux.SearchOperation(s.thfilter)
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

function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsMonster() and c:IsSetCard(SET_RECYCLE_BEAST) and c:IsControler(tp)
		and (not c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousControler(1-tp)) and (c:GetReasonCard() or (re and re:GetHandler()))
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousControler(1-tp)) and (c:GetReasonCard() or (re and re:GetHandler()))
end
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(SET_RECYCLE_BEAST)
end

function s.flagop(e,tp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_HAND) then return end
	if c:HasFlagEffect(id) then
		c:ResetFlagEffect(id)
	end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end