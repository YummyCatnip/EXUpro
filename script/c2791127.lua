-- Naturia Snail
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--ATK/DEF reduction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- Create 1 Token on Sp Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tktarg)
	e3:SetOperation(s.tkoper)
	c:RegisterEffect(e3)
	-- Create up to 2 Tokens on Release or Destruction
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.rlcond)
	e4:SetTarget(s.tktarg)
	e4:SetOperation(s.rloper)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.tktarg)
	e5:SetOperation(s.rloper)
	c:RegisterEffect(e5)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={2791128}
-- ge1 Effect Code
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- e1 Effect Code
function s.val(e,c)
	return Duel.GetFlagEffect(0,id)*-300
end
-- e3 Effect Code
function s.tktarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0xa2,TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0xa2,TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- e4 Effect Code
function s.rlcond(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0xa2)
end
function s.rloper(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0xa2,TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	if ft<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	ft=Duel.AnnounceNumberRange(tp,1,ft)
	for i=1,ft do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end
