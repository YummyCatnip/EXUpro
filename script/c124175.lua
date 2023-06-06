-- Conqueror Mariana, the Primordial Reaper
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--fusion proc
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,123962,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CONQUEROR))
	-- Each time a "Conqueror" monster declares an attack, deal 500 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.dgcond)
	e1:SetTarget(s.dgtarg)
	e1:SetOperation(s.dgoper)
	c:RegisterEffect(e1)
	-- Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	--Double damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.damcon)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	-- Cards in your GY are unnaffected by your opponent
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetTargetRange(LOCATION_GRAVE,0)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.immcond)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end
s.listed_names={123962}
s.listed_series={SET_CONQUEROR}
s.material_setcode={SET_CONQUEROR}
-- e1 Effect Code
function s.dgcond(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsSetCard(SET_CONQUEROR)
end
function s.dgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.dgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
-- e2 Effect Code
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CONQUEROR)
end
function s.atkcon(e)
	local c=e:GetHandler()
	local gc=Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	local bc=Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)
	return bc>gc
end
-- e3 Effect Code
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- e4 Effect Code
function s.immcond(e)
	local gc=Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,SET_CONQUEROR)
	local bc=Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil,SET_CONQUEROR)
	return gc>bc
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end