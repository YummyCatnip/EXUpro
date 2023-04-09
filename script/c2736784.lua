-- The Manufactured Pumpkin Scarer
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_PUMPKINHEAD,2)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- Change name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cntarg)
	e1:SetOperation(s.cnoper)
	c:RegisterEffect(e1)
	-- Negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcond)
	e2:SetOperation(s.negoper)
	c:RegisterEffect(e2)
	-- Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtarg)
	e3:SetOperation(s.thoper)
	c:RegisterEffect(e3)
end
s.material_setcode=SET_PUMPKINHEAD
s.listed_names={CARD_PUMPKINHEAD}
-- e0 Effect Code
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- e1 Effect Code
function s.cntarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and aux.pupfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.pupfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local g=Duel.Select(HINTMSG_APPLYTO,true,tp,aux.pupfil,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
end
function s.cnoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(CARD_PUMPKINHEAD)
		tc:RegisterEffect(e1)
	end
end
-- e2 Effect Code
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) and c:IsFaceup() and c:IsCode(CARD_PUMPKINHEAD)
end
function s.negcond(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(id)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(s.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.negoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		Duel.NegateEffect(ev)
	end
end
-- e3 Effect Code
function s.thfilter(c)
	return c:ListsCode(CARD_PUMPKINHEAD) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
 end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		Duel.Search(sg,tp)
	end
end