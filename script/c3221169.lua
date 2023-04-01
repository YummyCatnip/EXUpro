--Icecap Inu
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,nil,s.spcheck)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Your opponent's monsters with less ATK than their original ATK cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.atktarget)
	c:RegisterEffect(e2)
	--Reduce ATK by 400 and gain 400 ATK 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operat)
	c:RegisterEffect(e3)
end
function s.spcheck(g,lc,sumtype,tp)
	return g:CheckSameProperty(Card.GetAttribute,lc,sumtype,tp)
end
--e2 Effect Code
function s.atktarget(c)
	return c:GetAttack()<c:GetTextAttack()
end
--e3 Effect Code
function s.filter(c,e)
	return c:GetAttack()>=400 and not (c==e:GetHandler()) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and c:IsFaceup() and tc:UpdateAttack(-400)==-400 and tc:IsRelateToEffect(e) then
		c:UpdateAttack(400)
	end
end