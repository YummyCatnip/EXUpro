--Mudafi Miscreant - Hadil
local s,id,o=GetID()
function s.initial_effect(c)
	--Search 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.srtarg)
	e1:SetOperation(s.sroper)
	c:RegisterEffect(e1)
	--Mudafi effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condit)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operat)
	c:RegisterEffect(e2)
end
s.listed_series={0xc88}
--e1 Effect Code
function s.srtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sroper(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.thcond)
	e1:SetOperation(s.thoper)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return c:IsSetCard(0xc88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--e2 Effect Code
function s.condit(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xc88),tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_SZONE,nil)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and ct>0 and Duel.CheckLPCost(tp,500) end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	local lp=Duel.GetLP(tp)
	local max=math.min(ct,lp//500,3)
	local t={}
	for i=1,max do
		t[i]=i*500
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,ac)
	e:SetLabel(ac//500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	if chk==0 then return true end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,ct,ct,nil)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return tp==ep or not g:IsContains(e:GetHandler())
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end