--Superdreadnought Rail Cannon Gustav Mini
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	c:EnableReviveLimit()
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
--Xyz material
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRankBelow(5) and c:IsRace(RACE_MACHINE,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
--e1 Effect Code
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end