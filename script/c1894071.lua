-- Legion Queltz
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,3,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	c:EnableReviveLimit()
	-- Cannot Special  monster from the Extra Deck
	aux.AddSSCounter(id,s.spcounter)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(s.spcond)
	e0:SetOperation(aux.PlayerCannotSSOperation(0,splimit,nil,1))
	c:RegisterEffect(e0)
	-- Attach 1 banished card to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atcond)
	e1:SetTarget(s.attarg)
	e1:SetOperation(s.atoper)
	c:RegisterEffect(e1)
	-- Search 1 "Queltz" Ritual monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}
-- Xyz Code
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and (c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsType(TYPE_RITUAL,lc,SUMMON_TYPE_XYZ,tp)) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.refil(c)
	return c:IsSetCard(SET_QUELTZ) and not c:IsPublic()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.refil,tp,LOCATION_HAND,0,1,nil) end
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.refil,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
-- e0 Effect Code
function s.spcounter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) and (c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_FIRE))
end
function s.spcond(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_FIRE))
end
-- e1 Effect Code
function s.atcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
function s.attarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	local g=Duel.Select(HINTMSG_ATTACH,true,tp,aux.TRUE,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
end
function s.atoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,tc)
	end
end
-- e2 Effect Code
function s.thfil(c)
	return c:IsAbleToHand() and c:IsSetCard(SET_QUELTZ) and c:IsRitualMonster()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end