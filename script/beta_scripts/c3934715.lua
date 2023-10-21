-- Glace, Ice Crystal Cirgon
-- Scripted by Satellaa
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	aux.CirgonGlobalCheck(s,c)
	-- Special Summon itself from the hand
	c:SSProc
	(
		aux.Stringid(id,0),nil,LOCATION_HAND,true,
		s.spcon,nil,function(e,tp) aux.CirgonLock(e:GetHandler(),tp) end
	)
	-- Look at your opponent's hand
	c:SummonedTrigger
	(
		false,false,true,false,aux.Stringid(id,1),CATEGORY_LVCHANGE,
		true,nil,nil,s.lookcost,s.looktg,s.lookop
	)
end
s.listed_names={id}
s.listed_series={SET_CIRGON,SET_C_CIRGON}
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetMatchingGroupCount(nil,c:GetControler(),LOCATION_MZONE,0,nil)==0
end
function s.tbfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_C_CIRGON)
		and c:IsReleasable()
		and not c:IsCode(id)
end
function s.lookcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.CirgonRestrictionCheck(tp) end
	aux.CirgonLock(e:GetHandler(),tp)
	local g=Duel.SelectMatchingCard(tp,s.tbfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Sendto(g,LOCATION_GRAVE,REASON_RELEASE|REASON_COST)
end
function s.looktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
end
function s.lookop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Cannot Normal or Special Summon, except "Cirgon" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsSetCard(SET_CIRGON) end)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	-- Reset restriction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.resetop(e1,e2))
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	Duel.RegisterEffect(e4,tp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(p,g)
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			c:UpdateLV(-1)
		end
	end
end
function s.cirgonfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_CIRGON) and c:IsSummonPlayer(tp)
end
function s.resetop(e1,e2)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if eg:IsExists(s.cirgonfilter,1,nil,tp) then
					e1:Reset()
					e2:Reset()
					e:Reset()
				end
			end
end
