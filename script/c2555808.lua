--Art of Persistence
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.equip)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	--battle indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--pierce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	--Banish 1 monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.condit)
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operat)
	c:RegisterEffect(e5)
end
function s.equip(c)
	return c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
--e5 Effect Code
function s.filter(c)
	return c:IsAbleToRemove()
end
function s.condit(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==Duel.GetMatchingGroupCount(Card.IsInExtraMZone,tp,LOCATION_MZONE,0,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end