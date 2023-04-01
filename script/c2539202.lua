--Mudafi Mechanics
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--atk/def increase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xc88))
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcond)
	e3:SetTarget(s.sptarg)
	e3:SetOperation(s.spoper)
	c:RegisterEffect(e3)
	--Draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.drcond)
	e5:SetTarget(s.drtarg)
	e5:SetOperation(s.droper)
	c:RegisterEffect(e5)
	--Count cards discarded
	aux.GlobalCheck(s,function()
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_DISCARD)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0xc88}
--e1 Effect Code
function s.atfil(c)
	return c:IsSetCard(0xc88) and c:IsType(TYPE_MONSTER)
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(s.atkfil,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*100
end
--e3 Effect Code
function s.sfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--e4 Effect Code
function s.myfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc88)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsBattlePhase() then return end
    local newg=eg:Filter(s.myfilter,nil)
    for tc in newg:Iter() do
        Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
    end
end
--e5 Effect Code
function s.drcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(0,id)>0
end
function s.drtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFlagEffect(0,id)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.droper(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end