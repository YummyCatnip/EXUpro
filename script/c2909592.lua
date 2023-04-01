-- Vennominature the Emperor of Poisonous Snakes
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Blue-Eyes White Dragon" while on the field on in GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(72677437)
	c:RegisterEffect(e0)
	-- Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chkcond)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Search [2266598]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.chkcond)
	e2:SetTarget(s.srtarg)
	e2:SetOperation(s.sroper)
	c:RegisterEffect(e2)
	-- ED monster check
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PREDRAW)
		ge1:SetCountLimit(1)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.counter_list={COUNTER_VENOM}
s.listed_names={72677437, 2266598}
-- e1 Effect Code
function s.cfilter(c)
	return (c:IsRace(RACE_REPTILE) or c:GetCounter(COUNTER_VENOM)>0) and c:IsReleasableByEffect()
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,LOCATION_MZONE,2,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,LOCATION_MZONE,c)
	if #g<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
	local sg=g:Select(tp,2,2,nil)
	if Duel.Release(sg,REASON_EFFECT)==2 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- e2 Effect Code
function s.srfilter(c)
	return c:IsCode(2266598) and c:IsAbleToHand()
end
function s.srtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sroper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.srfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.rsoper)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
end
function s.rsoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	local c=e:GetHandler()
	if not tc:IsCode(2266598) or not Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_GRAVE then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.BreakEffect()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.Destroy(c,REASON_EFFECT)
end
-- ge1 Effect Code
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_EXTRA,0,nil)
	if #g==0 then return end
	for tc in g:Iter() do
		tc:RegisterFlagEffect(id,RESET_EVENT+EVENT_PHASE+PHASE_END,0,1)
	end
end
function s.chkfil(c)
	return c:GetFlagEffect(id)>0
end
function s.chkcond(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.chkfil,tp,LOCATION_GRAVE,0,1,nil)
end
