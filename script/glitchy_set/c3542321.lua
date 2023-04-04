--Bestia Riciclo Dente Fucile
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--search
	c:SummonedTrigger(false,true,true,false,0,CATEGORIES_SEARCH,true,true,
		nil,
		aux.DiscardCost(aux.ArchetypeFilter(SET_RECYCLE_BEAST)),
		aux.SearchTarget(aux.ArchetypeFilter(SET_RECYCLE_BEAST)),
		s.thop
	)
	--fusion summon
	c:SentToHandTrigger(false,2,CATEGORIES_FUSION_SUMMON,true,true,
		s.thcon,
		nil,
		Fusion.SummonEffTG(aux.Filter(Card.IsSetCard,SET_RECYCLE_BEAST),false,s.extramat,false,false,false,false,false,false,false,false,false,s.extratg),
		Fusion.SummonEffOP(aux.Filter(Card.IsSetCard,SET_RECYCLE_BEAST),false,s.extramat,false,false,false,false,false,false,false,false,false)
	)
end
function s.thfilter(c)
	return c:IsSetCard(SET_RECYCLE_BEAST) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetReset(RESET_PHASE+PHASE_END)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	Duel.RegisterEffect(e0,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_RECYCLE_BEAST)
end
function s.lizfilter(e,c)
	return not c:IsOriginalSetCard(SET_RECYCLE_BEAST)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousControler(1-tp)) and (c:GetReasonCard() or (re and re:GetHandler()))
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.extramat(e,tp,mg)
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=2 then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_RECYCLE_BEAST) and c:IsAbleToGrave()
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end 