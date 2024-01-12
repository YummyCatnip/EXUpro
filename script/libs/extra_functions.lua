-- Card has multiple Races
function Card.HasMultipleRaces(c)
	if not c:IsMonster() then return false end
	local races=c:GetRace()
	return races>0 and races&(races-1)~=0
end

-- Cirgon Repetitive Stuff
-- Cirgons Global Check (by Satellaa)
function Auxiliary.CirgonGlobalCheck(s,c)
	if not Duel.HasFlagEffect(0,3935780+1) then
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
		Duel.RegisterFlagEffect(0,3935780+1,0,0,0)
	end
end
function Auxiliary.cirfil(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
function Auxiliary.checkop(e,tp,eg,ep,ev,re,r,rp)
	local p=re:GetHandlerPlayer()
	if eg:IsExists(Auxiliary.cirfil,1,nil,p) then
		Duel.RegisterFlagEffect(p,3935780,0,0,0)
	end
end
function Auxiliary.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if (loc&LOCATION_GRAVE)>0 then
		Duel.RegisterFlagEffect(ep,3935780,0,0,0)
	end
end
function Auxiliary.CirgonRestrictionCheck(tp)
	return not Duel.HasFlagEffect(tp,3935780)
end

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

--[[ Self Destruct and Special Summons Effects that are repeated between all "Fuelfire" Main Deck monsters]]
function Auxiliary.AddFuelfireMDEffects(c,id)
	-- Self Destruct
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(Auxiliary.ffdescond)
	e1:SetTarget(Auxiliary.ffdestarg)
	e1:SetOperation(Auxiliary.ffdesoper)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(1152)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id)
	e4:SetCondition(Auxiliary.ffspcond)
	e4:SetTarget(Auxiliary.ffsptarg)
	e4:SetOperation(Auxiliary.ffspoper)
	c:RegisterEffect(e4)
end
-- Functions for Self Destruct 
function Auxiliary.ffdescond(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FUELFIRE_T),tp,LOCATION_MZONE,0,1,nil)
end
function Auxiliary.ffdestarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function Auxiliary.ffdesoper(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- Functions for Special Summon
function Auxiliary.ffspcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Auxiliary.ffspfilter,tp,LOCATION_GRAVE,0,nil)==0
end
function Auxiliary.ffspfilter(c)
	return c:IsSetCard(SET_FUELFIRE) and c:IsMonster()
end
function Auxiliary.ffsptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function Auxiliary.ffspoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end