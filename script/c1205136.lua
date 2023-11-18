-- Simulacrum Core
-- Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	-- Dice
	local params={matfilter=aux.FALSE,extrafil=s.fextra,extraop=s.extraop,gc=Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.dicecost)
	e1:SetTarget(s.dicetg(Fusion.SummonEffTG(params)))
	e1:SetOperation(s.diceop(Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) end)
end
s.roll_dice=true
function s.check(tp)
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_ALL&~ATTRIBUTE_DIVINE)
end
function s.rmfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemove()
end
function s.dicecost(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.dicetg(fustg)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return s.check(tp) and s.check(1-tp)
			and fustg(e,tp,eg,ep,ev,re,r,rp,chk) end
		fustg(e,tp,eg,ep,ev,re,r,rp,chk)
		Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED)
	end
end
function s.diceop(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local atts={ATTRIBUTE_WIND,ATTRIBUTE_WATER,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK}
		local d=Duel.TossDice(tp,1)
		local sg=Group.CreateGroup()
		for p=0,1 do
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(p,s.rmfilter,p,LOCATION_DECK,0,1,1,nil,atts[d])
			if #g>0 then
				sg:Merge(g)
			end
		end
		if #sg==0 then return end
		local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		if ct>0 and e:GetHandler():IsRelateToEffect(e) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.matfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_MZONE) then return nil end
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)+c
end
function s.extraop(e,tc,tp,sg)
	local sg_r,c=sg:Split(Card.IsLocation,nil,LOCATION_REMOVED)
	Duel.SendtoDeck(sg_r,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	Duel.SendtoGrave(c,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end