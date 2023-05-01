-- Queltz Parnoia
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ANNOUNCE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.qfilter(c)
	return c:IsFaceup() and c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil) end
	local ct=Duel.GetMatchingGroupCount(s.qfilter,tp,LOCATION_MZONE,0,nil)*2
	local rpt=ct
	local t={}
	for i=1,ct do
		local code=Duel.AnnounceCard(tp)
		table.insert(t,code)
		i=i+1
		rpt=rpt-1
		if rpt>0 and not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then break end
	end
	e:SetLabel(t)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.rmvfil(c,name)
	return c:IsAbleToRemove() and c:IsCode(name)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local t={e:GetLabel(t)}
	local g=Group.CreateGroup()
	for i,name in ipairs(t) do
		if Duel.IsExistingMatchingCard(s.rmvfil,tp,0,LOCATION_DECK,1,nil,name) then
			local tc=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmvfil,tp,0,LOCATION_DECK,1,1,nil,name)
			g:AddCard(tc)
		end
	end
	Duel.ConfirmCards(tp,g)
	local rm=Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT,nil,1-tp)
	local ct=#t - rm
	if ct>0 then
		local sg=Duel.GetDecktopGroup(tp,3*ct)
		Duel.DisableShuffleCheck()
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
end