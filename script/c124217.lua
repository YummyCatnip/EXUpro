-- Eliane, the Sacred Conqueror
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c)
	-- Use self as material from Pzone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- fusion substitute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(s.subcon)
	c:RegisterEffect(e2)
	-- Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetCondition(s.espcon)
	e3:SetTarget(s.esptg)
	e3:SetOperation(s.espop)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- This card gains 400x the nunber of Fusion monsters that is banished or in the GYs
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCode(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.atkcond)
	e4:SetTarget(s.atktarg)
	e4:SetOperation(s.atkoper)
	c:RegisterEffect(e4)
	--draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.condition)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	-- To hand
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetCountLimit(1,{id,2})
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_CONQUEROR}
-- e2 Effect Code
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_PZONE)
end
-- e3 Effect Code
function s.espfilter(c,tp,sc)
	return c:IsSetCard(SET_CONQUEROR) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:GetLevel()==4 and c:IsFaceup()
end
function s.fsfil(c)
	return c:IsSetCard(SET_FUSION) and c:IsSpell() and c:IsDiscardable()
end
function s.espcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.espfilter,1,false,1,true,c,c:GetControler(),nil,nil,nil,c:GetControler(),c) and
		Duel.IsExistingMatchingCard(s.fsfil,c:GetControler(),LOCATION_HAND,0,1,nil)
end
function s.esptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.fsfil,tp,LOCATION_HAND,0,1,1,true,nil)
	local g1=Duel.SelectReleaseGroup(tp,s.espfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if #g>0 and g1 then
		g:Merge(g1)
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
		return false
end
function s.espop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	local dg,rg=g:Split(s.fsfil,nil)
	if #dg>0 and #rg>0 then
		Duel.SendtoGrave(dg,REASON_DISCARD+REASON_COST)
		Duel.Release(g,REASON_COST+REASON_MATERIAL)
	end
	g:DeleteGroup()
end
-- e4 Effect Code
function s.atkcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.atktarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),tp,LOCATION_REMOVED+LOCATION_GRAVE,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
end
function s.atkoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),tp,LOCATION_REMOVED+LOCATION_GRAVE,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400*ct)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
-- e5 Effect Code
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
-- e6 Effect Code
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if r==REASON_FUSION then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_TOHAND)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.filter(c)
	return c:IsSetCard(SET_CONQUEROR) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end