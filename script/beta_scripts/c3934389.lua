-- Blazy, Cirgon Hatchling
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Cannot Remove
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	-- Global Check
	-- This is were I would place the auxiliary for the global check. IF I HAD ANY
	-- Modulate Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	aux.CirgonGlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetOperation(s.checkop2)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={SET_CIRGON}
-- Global Check
function s.cirfil(c,ep)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(ep)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cirfil,1,nil,ep) then Duel.RegisterFlagEffect(ep,id,0,0,1) end
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_GRAVE then Duel.RegisterFlagEffect(ep,id,0,0,0) end
end
-- e1 Effect Code 
function s.cfilter(c)
	return c:IsReleasable() and c:IsMonster() and c:IsSetCard(SET_CIRGON)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)==0 end
	-- Cirgon lock
	aux.CirgonLock(c,tp)
	local g=Duel.Select(HINTMSG_RELEASE,false,tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_RELEASE)
end
function s.filter(c)
	return c:IsFaceup() and c:HasLevel() and c:IsSetCard(SET_CIRGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.Select(HINTMSG_LVRANK,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local val=Duel.AnnounceNumber(tp,1,2)
		local b1=true
		local b2=tc:IsLevelAbove(1+val)
		local opt=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)}, --Increase its Level by the Declared number
		{b2,aux.Stringid(id,2)}) --Decrease its Level by the Declared number
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if opt==1 then
			e1:SetValue(val)
		else
			e1:SetValue(-val)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		tc:RegisterEffect(e1)
	end
end