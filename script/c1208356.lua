-- Ancient Deity of the Carcharracks 
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Evenly Matched at home
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.tgcond)
	e1:SetTarget(s.tgtarg)
	e1:SetOperation(s.tgoper)
	c:RegisterEffect(e1)
	-- Set 1 banished "Carcharrack" Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sttarg)
	e2:SetOperation(s.stoper)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CARCHARRACK}
-- e1 Effect Code
function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,SET_CARCHARRACK)
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if chk==0 then return ct>0 and g:IsExists(Card.IsAbleToGrave,1,nil,1-tp,REASON_RULE) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,ct,0,0)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToGrave,ct,ct,nil,1-tp,REASON_RULE)
		Duel.SendtoGrave(sg,REASON_RULE,PLAYER_NONE,1-tp)
	end
end
-- e2 Effect Code
function s.stfil(c)
	return c:IsST() and c:IsSetCard(SET_CARCHARRACK) and c:IsSSetable()
end
function s.sttarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and s.stfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.stfil,tp,LOCATION_REMOVED,0,1,nil) end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.stfil,tp,LOCATION_REMOVED,0,1,1,nil)
end
function s.stoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
		--Send it to the Deck if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		tc:RegisterEffect(e1)
	end
end