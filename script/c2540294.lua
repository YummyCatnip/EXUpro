--Mudafi Mighty Mark
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xc88}
function s.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc88) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
