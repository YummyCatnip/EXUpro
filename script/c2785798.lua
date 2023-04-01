--Astromini Scorpio
local s,id,o=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c,false)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--On Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.lvtarg)
	e2:SetOperation(s.lvoper)
	c:RegisterEffect(e2)
	--On Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.descond)
	e3:SetTarget(s.destarg)
	e3:SetOperation(s.desoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc78}
--e1 Effect Code
function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:IsSetCard(0xc78)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			Duel.SendtoExtraP(tc,tp,REASON_EFFECT)
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
--e2 Effect Code
function s.lvfilter(c)
	return c:IsRace(RACE_PSYCHIC) and (c:GetOriginalLevel()>0) and not c:IsType(TYPE_TUNER)
end
function s.lvtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--e3 Effect Code
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
function s.destarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end