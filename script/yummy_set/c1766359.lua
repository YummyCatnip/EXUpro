--Number 119: Mega Whale
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--Token Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcond)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.tktarg)
	e1:SetOperation(s.tkoper)
	c:RegisterEffect(e1)
	--Destroy Tokens
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.dstarg)
	e2:SetOperation(s.dsoper)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetLabelObject(e2)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e4:SetOperation(s.clearop)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetOperation(s.clearop)
	c:RegisterEffect(e5)
end
s.listed_names={id+1}
s.xyz_number=119
--e1 Effect Code
function s.tkcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.tktarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1500,1500,4,RACE_AQUA,ATTRIBUTE_WATER) end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.tkoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1500,1500,4,RACE_AQUA,ATTRIBUTE_WATER) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		g:AddCard(token)
		if #g>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_EP)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE)
			Duel.RegisterEffect(e1,tp)
			Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
		end
	end
	Duel.SpecialSummonComplete()
end
--e2 Effect Code
function s.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsReason(REASON_BATTLE)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,id+1) end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,LOCATION_MZONE,nil,id+1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,LOCATION_MZONE,nil,id+1)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		local db=e:GetLabel()
		local dmg=(db+ct)*300
		Duel.Damage(tp,dmg,REASON_EFFECT)
		Duel.Damage(1-tp,dmg,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:FilterCount(Card.IsMonster,nil)
	if ec>0 then
		local val=e:GetLabelObject():GetLabel()
		e:GetLabelObject():SetLabel(val+ec)
	end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end