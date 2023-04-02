-- Number 188: Jade Machine Marauder
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,9,2)
	-- Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1))
	e1:SetTarget(s.atktarg)
	e1:SetOperation(s.atkoper)
	c:RegisterEffect(e1)
	-- Trap destruction protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtarg)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--Negate Trap card or effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.ngcond)
	e3:SetTarget(s.ngtarg)
	e3:SetOperation(s.ngoper)
	c:RegisterEffect(e3)
end
s.xyz_number=188
-- e1 Effect Code
function s.atktarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:UpdateAttack(500,RESET_EVENT|RESETS_STANDARD,e:GetHandler())
	end
end
-- e2 Effect Code
function s.indtarg(c)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
end
function s.indval(e,re,tp)
	return re:IsTrapEffect()
end
-- e3 Effect Code
function s.ngcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and Duel.IsChainNegatable(ev)
		and re and re:IsActiveType(TYPE_TRAP)
	end
function s.ngtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.setfilter(c)
	return c:IsTrap() and c:IsSSetable(true)
end
function s.ngoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local ov=c:GetOverlayCount()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 and ov==0 and rc:IsLocation(LOCATION_HAND+LOCATION_DECK) and aux.nvfilter(rc) then
			if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and rc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.SSet(tp,rc)
			local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_DECK,nil)
			if #g>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
				local sg=g:Select(1-tp,1,1,nil)
				Duel.SSet(1-tp,sg:GetFirst())
			end
		end
	end
end