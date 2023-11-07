-- Simulacrum Subspace Bubble
-- Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	-- Send/Banish/Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
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
function s.tgfilter(c)
	return c:IsSetCard(SET_SIMULACRA) and c:IsAbleToGrave()
end
function s.cfilter(c,rm_chk)
	return c:IsCode(CARD_S_CORE) and (not rm_chk or c:IsAbleToRemove())
end
function s.check_rm_core(tp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,1-tp,LOCATION_EXTRA,0,2,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil)
		and (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,true) or s.check_rm_core(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if not sc then return end
	local att=sc:GetAttribute()
	if Duel.SendtoGrave(sc,REASON_EFFECT)==0 then return end
	local sg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,true)
	if s.check_rm_core(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		sg=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,1-tp,LOCATION_EXTRA,0,2,2,nil)
	elseif #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		sg=g:Select(tp,1,1,nil)
	end
	local params={
		fusfilter=function(c) return c:IsAttributeExcept(att) end,
		matfilter=aux.FALSE,
		extrafil=s.fextra,extraop=s.extraop
	}
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0
		and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_S_CORE)
end
function s.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		return g,s.fcheck
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	Duel.SendtoGrave(sg,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION|REASON_RETURN)
	sg:Clear()
end