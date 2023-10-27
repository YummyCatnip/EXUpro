-- Gloom, Darkness Cirgon
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
	e1:SetCategory(CATEGORIES_SEARCH)
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
s.listed_names={id}
s.listed_series={SET_CIRGON}
-- e1 Effect Code
function s.cfilter(c,tp)
	return c:IsReleasable() and c:IsSetCard(SET_CIRGON) and c:IsMonster() and Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetFlagEffect(tp,3935780)==0 end
	-- Cirgon lock
	aux.CirgonLock(c,tp)
	local g=Duel.Select(HINTMSG_RELEASE,false,tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	Duel.Sendto(g,LOCATION_GRAVE,REASON_COST+REASON_RELEASE)
	e:SetLabel(Duel.GetOperatedGroup():GetFirst():GetAttribute())
end
function s.thfil(c,att)
	return c:IsAbleToHand() and c:IsMonster() and not c:IsCode(id) and not c:IsAttribute(att) and c:IsSetCard(SET_CIRGON)
end
function s.filter2(c)
	return c:IsSetCard(SET_CIRGON) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel()):GetFirst()
	if tc then
		Duel.Search(tc,tp)
	end
end