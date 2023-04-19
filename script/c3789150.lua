-- Those Thorny Stems
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Change its name to "Bouquet of Black Roses"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	e1:SetValue(CARD_BOUQUET)
	c:RegisterEffect(e1)
	-- Cannot be used as Material, except for a "Aberration-" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetValue(s.matlimit)
	c:RegisterEffect(e2)
	-- Banish 1 card from either GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_COST) and e:GetHandler():IsReason(REASON_RELEASE) end)
	e3:SetTarget(s.rmtarg)
	e3:SetOperation(s.rmoper)
	c:RegisterEffect(e3)
	-- Give Effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.effcon)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_ABE_56,CARD_BOUQUET}
s.listed_series={SET_ABERRATION}
-- e2 Effect Code
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(SET_ABERRATION)
end
-- e3 Effect Code
function s.rmcond(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and r&REASON_COST>0
end
function s.rmtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToBeRemove() end
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_GRAVE)
end
function s.rmoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- e4 Effect Code
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local spc=c:GetReasonCard()
	return spc:GetSummonLocation()==LOCATION_EXTRA
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local spc=c:GetReasonCard()
	--Your Effect starts from here
		local e1=Effect.CreateEffect(spc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetCondition(s.negcon)
		spc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		spc:RegisterEffect(e2)
	--target 1 faceup monster your opponent controls change it Face-down
	local e3=Effect.CreateEffect(spc)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.rmtarg)
	e3:SetOperation(s.rmoper)
	spc:RegisterEffect(e3)
end
function s.negfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_ABE_56)
end
function s.negcon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_ONFIELD,0,1,nil)
end