-- Queltz Crowning
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtarg)
	e1:SetOperation(s.thoper)
	c:RegisterEffect(e1)
	-- Give ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.attarg)
	e2:SetOperation(s.atoper)
	c:RegisterEffect(e2)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.thfil(c,tp)
	return c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfil2,tp,LOCATION_DECK,0,1,c,c:GetLevel())
end
function s.thfil2(c,lv)
	return c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ) and c:IsAbleToHand() and not c:IsLevel(lv)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>1 and Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local th=Duel.GetMatchingGroup(s.thfil,tp,LOCATION_DECK,0,nil,tp)
	if #g<1 or #th<1 then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local tc=g:RandomSelect(1-tp,1,1,nil)
	Duel.BreakEffect()
	if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT,nil,1-tp)>0 then
		local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil,tp,LOCATION_DECK,0,1,1,nil,tp)
		local lv=g1:GetFirst():GetLevel()
		local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfil2,tp,LOCATION_DECK,0,1,1,nil,lv)
		g1:Merge(g2)
		Duel.Search(g1,tp)
	end
end
-- e2 Effect Code
function s.atfil(c)
	return c:IsFaceup() and c:IsSetCard(SET_QUELTZ)
end
function s.attarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and s.atfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atfil,tp,LOCATION_MZONE,0,1,nil) and c:IsAbleToRemove() and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,s.atfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,LOCATION_GRAVE)
end
function s.atoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end