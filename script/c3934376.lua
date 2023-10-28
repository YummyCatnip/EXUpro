-- Cirgon Arrival
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CIRGON}
-- e1 Effect Code
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.cfilter(c)
	return c:IsReleasable() and c:IsMonster() and c:IsSetCard(SET_CIRGON)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==2 and Duel.IsExistingMatchingCard(s.thfil1,tp,LOCATION_DECK,0,1,nil,sg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	e:SetLabel(1)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	Duel.Sendto(sg,LOCATION_GRAVE,REASON_COST+REASON_RELEASE)
end
function s.thfil1(c,att)
	return c:IsMonster() and c:IsSetCard(SET_CIRGON) and c:IsAbleToHand() and not att:IsExists(Card.IsAttribute,1,nil,c:GetAttribute())
end
function s.thfil2(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(SET_CIRGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res and Duel.IsExistingMatchingCard(s.thfil2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Group.CreateGroup()
	local code=0
	local att=e:GetLabelObject()
	local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil1,tp,LOCATION_DECK,0,1,1,nil,att):GetFirst()
	if g1 then
		code=g1:GetCode()
		g:Merge(g1)
	end
	local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil2,tp,LOCATION_DECK,0,1,1,nil)
	g:Merge(g2)
	if #g>0 then
		Duel.Search(g,tp)
		--Cannot Special Summon monsters with the same name
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsCode(e:GetLabel()) end)
		e1:SetLabel(code)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	aux.CirgonLock(c,tp)
end