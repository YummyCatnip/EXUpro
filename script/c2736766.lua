-- Pumpkin Rolling into the Night
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_PUMPKINHEAD,3)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	-- Change name + Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cntarg)
	e2:SetOperation(s.cnoper)
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
s.listed_series={SET_PUMPKINHEAD}
-- e0 Effect Code
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- e1 Effect Code
function s.indval(e,c)
	return c:IsSetCard(SET_PUMPKINHEAD)
end
-- e2 Effect Code
function s.cntarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and aux.pupfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.pupfil,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	Duel.Select(HINTMSG_APPLYTO,true,tp,aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	local g=Duel.GetMatchingGroup(s.nfilter,tp,0,LOCATION_ALL,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g+1,0,0)
end
function s.nfilter(c,e)
	return c:IsCode(CARD_PUMPKINHEAD) and c:IsCanBeDisabledByEffect(e)
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
		local g=Duel.GetMatchingGroup(s.nfilter,tp,0,LOCATION_ALL,nil,e)
		for nf in g:Iter() do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nf:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nf:RegisterEffect(e3)
			if nf:IsType(TYPE_TRAPMONSTER) then
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				nf:RegisterEffect(e4)
			end
		end
	end
end
-- e3 Effect Code
function s.thfilter(c)
	return c:ListsCode(CARD_PUMPKINHEAD) and c:GetType()==TYPE_SPELL and c:IsAbleToHand()
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