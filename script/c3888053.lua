-- Aberration-50-B: Blood Stained Wolf
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Must be Special Summoned by a Beast monster effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- Prevent targeting
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- Gain ATK and a second attack during each Battle Phase this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atcond)
	e2:SetCost(s.atcost)
	e2:SetTarget(s.attarg)
	e2:SetOperation(s.atoper)
	c:RegisterEffect(e2)
	-- Give this card's previous effects and a new one for a Beast Xyz monster using it as material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_ADD_RACE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetValue(RACE_BEAST)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e4:SetCondition(s.condition)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_XMATERIAL)
	e5:SetCondition(s.condition2)
	c:RegisterEffect(e5)
end
-- e0 Effect Code
function s.splimit(e,se,sp,st)
	return se:IsMonsterEffect() and se:GetHandler():IsRace(RACE_BEAST)
end
-- e1 Effect Code
function s.tg(e,c)
	return c:IsRace(RACE_BEAST) and c~=e:GetHandler()
end
-- e1 Effect Code
function s.atcond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and (ph~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.cfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToGraveAsCost() and c:HasNonZeroAttack()
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c) end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,c)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.attarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.atoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local c=e:GetHandler()
	local atk=tc:GetBaseAttack()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(atk)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- e3 Effect Code
function s.condition(e)
	return e:GetHandler():GetRace()==RACE_BEAST
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and (ph~=PHASE_DAMAGE or not Duel.IsDamageCalculated()) and e:GetHandler():GetRace()==RACE_BEAST
end