-- Simulacrum Uncanny Eye
-- Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	-- Send/Apply/Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) end)
end
s.listed_series={SET_SIMULACRA}
s.listed_names={CARD_S_CORE}
function s.fusfilter(c,e,tp,eg,ep,ev,re,r,rp,att)
	local params={
			fusfilter=aux.FilterBoolFunction(Card.IsAttributeExcept,att),
			matfilter=function(c) return c:IsLocation(LOCATION_HAND) end,
			extrafil=s.fextra,extraop=s.extraop
		}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) and c:IsSetCard(SET_SIMULACRA)
end
function s.tgfilter(c,e,tp,eg,ep,ev,re,r,rp,coreatt)
	return c:IsMonster() and c:IsSetCard(SET_SIMULACRA) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,eg,ep,ev,re,r,rp,coreatt|c:GetAttribute())
end
function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsCode(CARD_S_CORE) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,eg,ep,ev,re,r,rp,c:GetAttribute())
		and (c:IsLocation(LOCATION_HAND) and Duel.IsPlayerCanDraw(tp,2)
		or Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,1,nil))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	-- Cannot Special Summon from the Extra Deck, except Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	-- Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalType(TYPE_FUSION) end)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	if not tc then return end
	if (Duel.SendtoGrave(tc,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_GRAVE)) then return end
	if tc:IsPreviousLocation(LOCATION_HAND) then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		if Duel.Draw(tp,2,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
		end
	else
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,coreatt):GetFirst()
	if not sc then return end
	if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
		local coreatt=tc:GetAttribute()
		local params={
			fusfilter=function(c) return s.fusfilter(c,e,tp,eg,ep,ev,re,r,rp,coreatt|sc:GetAttribute()) end,
			matfilter=function(c) return c:IsLocation(LOCATION_HAND) end,
			extrafil=s.fextra,extraop=s.extraop
		}
		Duel.BreakEffect()
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
end
function s.extraop(e,tc,tp,sg)
	local sg_g,sg_h=sg:Split(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SendtoDeck(sg_g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	Duel.SendtoGrave(sg_h,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
