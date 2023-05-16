-- Tragic Defeat of the Carcharracks
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Send 1 "Carcharrack" monster or card from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtarg)
	e1:SetOperation(s.tgoper)
	c:RegisterEffect(e1)
	-- Set on the Field 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.stcost)
	e2:SetTarget(s.sttarg)
	e2:SetOperation(s.stoper)
	c:RegisterEffect(e2)
	-- Count activated Carcharrack S/T effects in the GY
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.actfilter)
end
s.listed_series={SET_CARCHARRACK}
s.listed_names={787258}
-- e1 Effect Code
function s.tgfil(c)
	return c:IsMonster() and c:IsAbleToGrave() and c:IsSetCard(SET_CARCHARRACK)
end
function s.chkfil(c)
	return c:IsFaceup() and c:IsCode(787258)
end
function s.tgfil1(c,tp)
	return c:IsAbleToGrave() and c:IsSetCard(SET_CARCHARRACK) and Duel.IsExistingMatchingCard(s.chkfil,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.tgfil,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tgfil1,tp,LOCATION_DECK,0,1,nil,tp)
	if chk==0 then return (b1 or b2) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.tgfil,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tgfil1,tp,LOCATION_DECK,0,1,nil,tp)
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfil1,tp,LOCATION_DECK,0,1,1,nil,tp)
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif b1 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfil,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif b2 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfil1,tp,LOCATION_DECK,0,1,1,nil,tp)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- e2 Effect Code
function s.actfilter(re)
	local rc=re:GetHandler()
	return not (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rc:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(SET_CARCHARRACK))
end
function s.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	-- Cannot activate effects in the GY of other Carcharrack Spell/Traps
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(_,re) return not s.actfilter(e,re) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sttarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.stoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end