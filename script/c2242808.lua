-- Infinite Faces of the Simulacra
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Add 1 "Simulacrum Core" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_names={CARD_S_CORE,1210351}
-- check
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- e1 Effect Code 
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_FUSION)
end
function s.thfil1(c)
	return c:IsCode(CARD_S_CORE) and c:IsAbleToHand()
end 
function s.thfil2(c)
	return c:IsCode(1210351) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.thfil1,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.thfil2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORIES_SEARCH+CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,4,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,4,1-tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- Seach for 1 "Simulacrum Core"
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil1,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.Search(g,tp) and Duel.IsPlayerCanRemove(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local rg1=Duel.GetDecktopGroup(tp,4)
			local rg2=Duel.GetDecktopGroup(1-tp,4)
			if (#rg1>0 or #rg2>0) then
				Duel.DisableShuffleCheck()
				Duel.BreakEffect()
				if #rg1>0 then
					Duel.Remove(rg1,POS_FACEUP,REASON_EFFECT)
					local og=Duel.GetOperatedGroup()
					for tc in og:Iter() do
					--register a negation effect on tc
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CANNOT_TRIGGER)
					e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
					e1:SetRange(LOCATION_REMOVED)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_REMOVE+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_CANNOT_ACTIVATE)
					tc:RegisterEffect(e2)
					end
				end
			end
			if #rg2>0 then
				Duel.Remove(rg2,POS_FACEUP,REASON_EFFECT)
				local og=Duel.GetOperatedGroup()
				for tc in og:Iter() do
				--register a negation effect on tc
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e1:SetRange(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_REMOVE+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_ACTIVATE)
				tc:RegisterEffect(e2)
				end
			end
		end
	else
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	end
end