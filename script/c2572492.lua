--Ashren, Dragon of Incinerating Void Khreygond
local s,id,o=GetID()
function s.initial_effect(c)
	--Synchro procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Spell/Trap destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dscond)
	e1:SetTarget(s.dstarg)
	e1:SetOperation(s.dsoper)
	c:RegisterEffect(e1)
	--ATK boost or indes
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.aicond)
	e2:SetCost(s.aicost)
	e2:SetTarget(s.aitarg)
	e2:SetOperation(s.aioper)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.dscond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if tc then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--e2 Effect Code
function s.aicond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.aicost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.aitarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.GetFlagEffect(tp,id+1)==0
	if chk==0 then return b1 or b2 end
end
function s.aioper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.GetFlagEffect(tp,id+1)==0
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,2))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
	else return end
	if op==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	else
		--Cannot be destroyed by card effects.
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,4))
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	end
end