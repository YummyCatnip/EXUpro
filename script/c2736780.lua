-- The Lost Little Girl and the Pumpkins
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_PUMPKINHEAD}
-- e1 Effect Code
function s.filter(c)
	return c:IsType(TYPE_FUSION) and c:ListsCode(CARD_PUMPKINHEAD) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil)
	if #g<=0 then return end
	local sg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if Duel.SendtoGrave(sg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local cn=Duel.Select(HINTMSG_APPLYTO,false,tp,aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil):GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(CARD_PUMPKINHEAD)
		cn:RegisterEffect(e1)
	end
end