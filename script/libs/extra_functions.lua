-- Card has multiple Races
function Card.HasMultipleRaces(c)
	if not c:IsMonster() then return false end
	local races=c:GetRace()
	return races>0 and races&(races-1)~=0
end

-- Cirgon Repetitive Stuff
--[[ Cirgons Global Check//not working
function Auxiliary.CirgonGlobalCheck(c)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(Auxiliary.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetOperation(Auxiliary.checkop2)
		Duel.RegisterEffect(ge2,0)
	end)
end
function Auxiliary.cirfil(c,ep)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(ep)
end
function Auxiliary.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(aux.cirfil,1,nil,ep) then Duel.RegisterFlagEffect(ep,id,0,0,1) end
end
function Auxiliary.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_GRAVE then Duel.RegisterFlagEffect(ep,id,0,0,0) end
end]]
-- Cirgons Cannot be Banished from the GY
function Auxiliary.CannotbeRemoved(c,loc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(loc)
	c:RegisterEffect(e1)
end
-- Cirgons Locks Your GY
function Auxiliary.CirgonLock(c,tp)
		-- Cannot Activate card effects in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(3934389,3))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(Auxiliary.aclimit)
	Duel.RegisterEffect(e1,tp)
	-- Cannot Special Summon from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(_,c) return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) end)
	Duel.RegisterEffect(e2,tp)
end
function Auxiliary.aclimit(e,re,tp)
	return re:GetActivateLocation()&LOCATION_GRAVE>0
end
