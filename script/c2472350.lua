-- Lavuna, Rosenn-Magia Le Chorus
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfil,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- Shuffle cards into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tdcond)
	e2:SetTarget(s.tdtarg)
	e2:SetOperation(s.tdoper)
	c:RegisterEffect(e2)
end
-- Fusion Code
function s.matfil(c,fc,sumtype,tp,sub,mg,sg)
	return (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL,fc,sumtype,tp)) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- e1 Effect Code
function s.efilter(e,re,rp)
	local tp=e:GetHandlerPlayer()
	return re:IsActiveType(TYPE_MONSTER) and rp~=tp
end
-- e2 Effect Code
function s.tdcond(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:GetActivateLocation()&LOCATION_ONFIELD>0
end
function s.tdtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,aux.FaceupFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	local g2=Duel.Select(HINTMSG_TODECK,true,tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	g:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
end
function s.tdoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	local c=e:GetHandler()
	if tc and c:IsLocation(LOCATION_MZONE) then
		tc:AddCard(c)
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end