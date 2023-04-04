--Number C70: Benevolent Virtue
local s,id,o=GetID()
function s.initial_effect(c)
	--XYZ Procedure
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,5,2)
	--Banish 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(0,id))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.rmvtag)
	e1:SetOperation(s.rmvope)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Modulate rk, gain ATK rkx100
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1,id))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(s.rkcon)
	e2:SetTarget(s.rktag)
	e2:SetOperation(s.rkope)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(s.rkcon2)
	c:RegisterEffect(e3)
	--Cannot be destroyed by battle vs level/rank higher
	local e4=Effect.CreateEffect(c) 
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetCondition(s.immcon)
	e4:SetValue(s.efilter1)
	c:RegisterEffect(e4)
	--Cannot be destroyed by effect vs level/rank lower
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetValue(s.efilter2)
	c:RegisterEffect(e5)
end
s.xyz_number=70
s.listed_names={80796456}
--e1 Effect code
function s.rmvtag(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmvope(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
--e2 Effect code
function s.rkcon(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetHandler():GetAttack()
	local tc=Duel.GetAttacker()
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if not (tc and tc:IsFaceup()) then return false end
	return tc and tc:IsControler(1-tp) and tc:IsAttackAbove(atk)
end
function s.rkcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c)
end
function s.rktag(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local rk=Duel.AnnounceNumber(tp,1,2,3)
		e:SetLabel(rk)
end
function s.rkope(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rk=e:GetLabel(rk)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_RANK)
		if opt==0 then
			e1:SetValue(rk)
		else
			e1:SetValue(-rk)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		Duel.BreakEffect()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(s.atkval)
		c:RegisterEffect(e2)
	end
end
function s.atkval(e,c)
	return c:GetRank()*100
end
--e4 effect code
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,80796456)
end
function s.efilter1(e,c)
	local stat=c:IsType(TYPE_XYZ) and c:GetRank() or c:GetLevel()
	return stat>e:GetHandler():GetRank()
end
--e5 effect code
function s.efilter2(e,re)
	local rc=re:GetHandler()
	if not rc then return false end
	local stat=rc:IsType(TYPE_XYZ) and rc:GetRank() or rc:GetLevel()
	return stat<e:GetHandler():GetRank()
end