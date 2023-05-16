-- Wistful Memory of the Carcharracks
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_CARCHARRACK))
	--Return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.rhcond)
	e1:SetTarget(s.rhtarg)
	e1:SetOperation(s.rhoper)
	c:RegisterEffect(e1)
	-- Set on the Field 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.stcost)
	e2:SetTarget(s.sttarg)
	e2:SetOperation(s.stoper)
	c:RegisterEffect(e2)
	-- Count activated Carcharrack S/T effects in the GY
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.actfilter)
end
s.listed_series={SET_CARCHARRACK}
-- e1 Effect Code
function s.rhcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	local bc=c:GetBattleTarget()
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and bc and bc:IsControler(1-tp)
		and bc:IsAbleToHand()
end
function s.rhtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler():GetEquipTarget():GetBattleTarget(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
function s.rhoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetEquipTarget():GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- e2 Effect Code
function s.actfilter(re)
	local rc=re:GetHandler()
	return not (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rc:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(SET_CARCHARRACK))
end
function s.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	-- Cannot activate effects in the GY of other Carcharrack Spell/Traps
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(_,re) return not s.actfilter(e,re) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sttarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.stoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end