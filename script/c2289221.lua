-- Iterator 29: Fusha, Administrator of Dark World
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	c:EnableReviveLimit()
	-- Increase ATK/DEF by the number of discarded cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- Destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
	-- Global check
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DISCARD)
		ge1:SetOperation(s.globalsummoncheck)
		Duel.RegisterEffect(ge1,0)
	end)
end
-- Xyz Summon code
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,xyz,sumtype,tp) and (c:IsLevel(8) or c:IsSetCard(SET_DARK_WORLD,xyz,sumtype,tp))
end
function s.alternfilter(c)
	return c:IsSetCard(SET_DARK_WORLD) and not c:IsLevel(8)
end
function s.xyzcheck(g,tp,xyz)
	return g:FilterCount(s.alternfilter,nil)<=1
end
-- Gloval check code
function s.globalsummoncheck(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in eg:Iter() do
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- e1/e2 Effect code
function s.val(e)
	local ct=Duel.GetFlagEffect(e:GetHandlerPlayer(),id)
	return 200*ct
end
-- e3 Effect Code
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp
		and c:GetOverlayCount()>0 end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(s.stcond)
		e1:SetOperation(s.stoper)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		return true
	else return false end
end
function s.sfilter(c)
	return c:IsSetCard(SET_DARK_WORLD) and c:IsST() and c:IsCanTurnSet()
end
function s.stcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.stoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.Select(HINTMSG_SET,false,tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end