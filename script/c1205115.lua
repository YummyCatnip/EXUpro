-- Simulacrum Power Nexus
-- Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_SIMULACRA),extrafil=s.fextra}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop(Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
	-- Banish the top 4 cards of each player's Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) end)
end
s.listed_series={SET_SIMULACRA}
s.listed_names={CARD_S_CORE}
function s.applyrestriction(tp,e)
	local c=e:GetHandler()
	-- Cannot Special Summon from the Extra Deck, except Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	-- Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalType(TYPE_FUSION) end)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			fusop(e,tp,eg,ep,ev,re,r,rp)
			s.applyrestriction(tp,e)
		end
	end
end
function s.fcheck(tp,sg,fc)
	local dc=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	return sg:IsExists(Card.IsCode,1,nil,CARD_S_CORE) and (dc==0 or dc==1)
end
function s.fextra(e,tp,mg)
	local g=nil
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
	end
	return g,s.fcheck
end
function s.rmfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(SET_SIMULACRA)
		and c:IsMonster() and c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmfilter,1,nil,tp)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	s.applyrestriction(tp,e)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanRemove(1-tp)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=4
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	local g=eg:Filter(s.rmfilter,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,PLAYER_ALL,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.rmfilter,nil,tp)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local result_g=Group.CreateGroup()
		for p=0,1 do
			local rg=Duel.GetDecktopGroup(p,4)
			if #rg>0 and Duel.IsPlayerCanRemove(p) then
				Duel.DisableShuffleCheck()
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
				result_g:Merge(rg)
			end
		end
		if #result_g==0 then return end
		for tc in result_g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3302)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end