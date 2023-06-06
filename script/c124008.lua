-- Conqueror Mion, the Dragonic Songstress
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--fusion proc
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,123885,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CONQUEROR))
	-- Cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	-- Indestructible
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	-- Reduce ATK of opponent's monsters by 1000
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.atkcos)
	e3:SetTarget(s.atktag)
	e3:SetOperation(s.atkope)
	c:RegisterEffect(e3)
	-- Add 1 banished "Conqueror" momster to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.thcond)
	e4:SetTarget(s.thtarg)
	e4:SetOperation(s.thoper)
	c:RegisterEffect(e4)
end
s.listed_names={123885}
s.listed_series={SET_CONQUEROR}
s.material_setcode={SET_CONQUEROR}
-- e1/e2 Effect Code
function s.indval(e,re,tp)
	local atk=e:GetGandler():GetAttack()
	local rc=re:GetGandler()
	return rc and rc:IsMonster() and rc:GetAttack()<atk
end
-- e3 Effect Code
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CONQUEROR) and c:IsAbleToRemoveAsCost()
end
function s.atkcos(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,nil,REASON_COST)
end
function s.atktag(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
end
function s.atkope(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
		end
	end
end
-- e4 Effect Code
function s.thcfil(c,atk)
	return c:IsFaceup() and c:IsSetCard(SET_CONQUEROR) and c:GetAttack()<=atk
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return rc and re:IsActiveType(TYPE_MONSTER) and rp~=tp and not Duel.IsExistingMatchingCard(s.thcfil,tp,LOCATION_MZONE,0,1,nil,rc:GetAttack())
end
function s.thfil(c)
	return c:IsMonster() and c:IsSetCard(SET_CONQUEROR) and c:IsAbleToHand()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end