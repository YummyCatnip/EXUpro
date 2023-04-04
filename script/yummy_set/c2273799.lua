--Elusive Dashing Techniques
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.equip)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	--Prevent effect target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--Banish up to 3 cards
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.condit)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operat)
	c:RegisterEffect(e4)
end
function s.equip(c)
	return c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
--e4 Effect Code
function s.filter(c)
	return c:IsAbleToRemove()
end
function s.condit(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==Duel.GetMatchingGroupCount(Card.IsInExtraMZone,tp,LOCATION_MZONE,0,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,LOCATION_GRAVE)
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if tc then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end