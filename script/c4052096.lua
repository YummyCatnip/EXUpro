-- Fuelfire Iltscar
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Basic "Fuelfire" Effects 
	aux.AddFuelfireMDEffects(c,id)
	-- Set 1 "Fuelfire" Spell/Trap from the Deck or GY 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FUELFIRE,SET_FUELFIRE_T}
-- e1 Effect Code 
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) or e:GetHandler():IsPreviousLocation(LOCATION_DECK)) and e:GetHandler():IsReason(REASON_EFFECT)
end
function s.filter(c)
	return c:IsSetCard(SET_FUELFIRE) and c:IsSSetable() and not c:IsForbidden() and c:IsType(TYPE_ST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not g then return end
	if Duel.SSet(tp,g)==0 then return end
	if g:GetPreviousLocation()==LOCATION_DECK then
		-- Cannot be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_CANNOT_ACT|RESET_PHASE|PHASE_END)
		g:RegisterEffect(e1)
	end
end