-- Lumino, Light Cirgon
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Cannot Remove
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	-- Global Check
	aux.CirgonGlobalCheck(s,c)
	-- Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CIRGON}
-- e1 Effect Code
function s.cfilter(c,tp)
	return c:IsReleasable() and c:IsMonster() and c:IsSetCard(SET_CIRGON)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetClassCount(Card.GetCode)==2 and Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_DECK,0,1,nil,e,tp,sg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) and aux.CirgonRestrictionCheck(tp) end
	aux.CirgonLock(c,tp)
	local sg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	Duel.Sendto(sg,LOCATION_GRAVE,REASON_COST+REASON_RELEASE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfil(c,e,tp,att)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(SET_CIRGON) and (not c:IsType(TYPE_TUNER) and not c:IsAttribute(ATTRIBUTE_LIGHT) and not att:IsExists(Card.IsAttribute,1,nil,c:GetAttribute()))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local att=e:GetLabelObject()
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp,att):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON+RACE_HIGHDRAGON)
end