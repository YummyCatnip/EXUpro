--Embodiment of the Endless Sands
local s,id,o=GetID()
function s.initial_effect(c)
	--Limit 1
	c:SetUniqueOnField(1,0,id)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,3)
	c:EnableReviveLimit()
	--Recycle 1 Hourglass
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.xyz)
	e1:SetTarget(s.thtarg)
	e1:SetOperation(s.thoper)
	c:RegisterEffect(e1)
	-- Monsters on the opponent's GY become "Endless Sands" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_GRAVE)
	e2:SetTarget(aux.TargetBoolFunction(Card.Type,TYPE_MONSTER))
	e2:SetValue(0xc90)
	c:RegisterEffect(e2)
	--Deal burn damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.condition)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetTarget(s.brtarg)
	e3:SetOperation(s.broper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc90,0xc89}
s.listed_names={id}
--e1 Effect Code
function s.thfilter(c)
	return c:IsSetCard(0xc89) and c:IsType(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsAbleToHand()
end
function s.xyz(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendToHand(tc,nil,REASON_EFFECT)>0 then
		--Cannot activate name
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(tc:GetCode())
end
--e2 Effect Code
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.brtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dmg=eg:FilterCount(s.cfilter,nil)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dmg*500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg*500)
end
function s.broper(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end