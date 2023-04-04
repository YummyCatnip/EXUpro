--Vipera, Tyrant of the Endless Sands
local s,id,o=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,2,2,nil,nil,99)
	c:EnableReviveLimit()
	--ATK reduction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Can use materials as targets
   local e2=Effect.CreateEffect(c)
   e2:SetType(EFFECT_TYPE_SINGLE)
   e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
   e2:SetCode(250820104)
   e2:SetRange(LOCATION_MZONE)
   c:RegisterEffect(e2)
	--Negate an cards effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.ngcond)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetTarget(s.ngtarg)
	e3:SetOperation(s.ngoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc90,0xc89}
--e1 Effect Code
function s.atkval(e,c)
	return c:GetOverlayCount()*-1000
end
--e3 Effect Code
function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.ngcond(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsActivated()
		and re:IsActiveType(TYPE_TRAP+TYPE_CONTINUOUS) and ep==e:GetOwnerPlayer() and rc:IsSetCard(0xc89)
end
function s.ngtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.disfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectTarget(tp,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.ngoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
