--Sintesi Bestia Riciclo
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,
		aux.FilterBoolFunction(Card.IsSetCard,SET_RECYCLE_BEAST),
		Fusion.OnFieldMat(Card.IsAbleToDeck),
		s.fextra,
		s.matop,
		nil,nil,nil,nil,nil,nil,
		aux.Stringid(id,0),
		nil,nil,
		s.extratg
	)
	e1:HOPT()
	e1:SetCost(aux.SSRestrictionCost(aux.Filter(Card.IsSetCard,SET_RECYCLE_BEAST),false,false,id,false,1))
	c:RegisterEffect(e1)
	--additional normal summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.sumcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil), s.fcheck
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsAbleToHand,1,nil)
end
function s.matop(e,fc,tp,mg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tohand=mg:FilterSelect(tp,s.validtohand,1,1,nil,mg)
	local todeck=mg:Sub(tohand)
	if #todeck>0 then
		local fd=todeck:Filter(Card.IsFacedown,nil)
		if #fd>0 then
			Duel.ConfirmCards(1-tp,fd)
		end
		Duel.SendtoDeck(todeck,nil,SEQ_DECKTOP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION) 
		for p=tp,1-tp,1-2*tp do
			local ct=todeck:FilterCount(aux.PLChk,nil,p,LOCATION_DECK)
			if ct>1 then
				Duel.SortDecktop(tp,p,ct)
			end
		end
	end
	if #tohand>0 then
		local fd=tohand:Filter(Card.IsFacedown,nil)
		if #fd>0 then
			Duel.ConfirmCards(1-tp,fd)
		end
		Duel.SendtoHand(tohand,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	end
	mg:Clear()
end
function s.validtohand(c,mg)
	return c:IsAbleToHand() and not mg:IsExists(aux.NOT(Card.IsAbleToDeck),1,c)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerCanAdditionalSummon(tp)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSummon(tp) end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RECYCLE_BEAST))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end