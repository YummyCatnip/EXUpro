--Invoking Inu
local s,id,o=GetID()
function s.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.srtarg)
	e1:SetOperation(s.sroper)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Recover 1 equip Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcond)
	e3:SetTarget(s.thtarg)
	e3:SetOperation(s.thoper)
	c:RegisterEffect(e3)
end
s.listed_names={250820136}
--e1 Effect Code
function s.filter(c)
	return c:IsCode(250820131,250820132,250820133,250820134) and c:IsAbleToHand()
end
function s.srtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,0)
end
function s.sroper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--e3 Effect Code
function s.inufil(c)
	return c:IsCode(250820136) and c:IsFaceup()
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_EQUIP) and c:IsControler(tp) and c:IsAbleToHand()
end
function s.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,1,nil,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
	local tc=g:FilterSelect(tp,s.thfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_GRAVE)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
	Duel.BreakEffect()
	if Duel.IsExistingMatchingCard(s.inufil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and c:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	elseif c:IsAbleToDeck() then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end