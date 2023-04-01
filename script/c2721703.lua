--Unsealed Chain Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,nil,s.spcheck)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.eqtarg)
	e1:SetOperation(s.eqoper)
	c:RegisterEffect(e1)
	--unequip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
	--destroy sub
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
	--Cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
	--Negate
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetCondition(s.ngcon)
	c:RegisterEffect(e5)
	--Cannot be Link material
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(3312)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
function s.spcheck(g,lc,sumtype,tp)
	return g:CheckSameProperty(Card.GetRace,lc,sumtype,tp)
end
--e1 Effect Code
function s.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function s.eqtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local code=c:GetOriginalCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqfilter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(code)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(code,RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)+RESET_PHASE+PHASE_END,0,1)
end
function s.eqoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then 
		Duel.Equip(tp,c,tc)
		--equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(1-tp)
end
--e2 Effect Code
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local code=c:GetOriginalCode()
	if chk==0 then return ec and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(code)==0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(code,RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)+RESET_PHASE+PHASE_END,0,1)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--e3 Effect Code
function s.repval(e,re,r,rp)
	return (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0
end
--e5 Effect Code
function s.ngcon(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsType(TYPE_EFFECT)
end