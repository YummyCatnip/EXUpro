--Future Mech XX-Absolute - Xyz Emperor
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,11,3,s.xyzfilter,aux.Stringid(id,0),nil,s.xyzop,false,nil)
	c:EnableReviveLimit()
	--Speed 4 During Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--Destroy 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.dstarg)
	e2:SetOperation(s.dsoper)
	c:RegisterEffect(e2)
	--Attach this card to another
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.attcon)
	e3:SetTarget(s.atttar)
	e3:SetOperation(s.attoper)
	c:RegisterEffect(e3)
end
--Summon Code
function s.xyzfilter(c,tp,xyz)
	return c:IsFaceup() and c:IsType(TYPE_XYZ,xyz,sumtype,tp)
end
function s.xyzop(e,tp,chk,mc)
	local xyz=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_ONFIELD,0,2,nil,tp,xyz)
		and Duel.GetFlagEffect(tp,id)==0 end
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,xyz)
	Duel.Overlay(mc,g)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
--e1 Effect Code
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c==e: GetHandler() and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and s.cfilter(a,e,tp)) or (d and s.cfilter(d,e,tp))
end
--e2 Effect Code
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and aux.TRUE(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetoperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--e3 Effect Code
function s.attfil(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLocation(LOCATION_DECK) and rp~=tp
end
function s.atttar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfil,tp,LOCATION_MZONE,0,1,nil) end
end
function s.attoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(s.attfil,tp,LOCATION_MZONE,0,1,nil) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.attfil,tp,LOCATION_MZONE,0,1,1,nil)
	if tc then
		Duel.Overlay(tc,c,true)
	end
end