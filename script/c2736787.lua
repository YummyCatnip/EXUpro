-- Gathering of Pumpkins Underneath the Full Moon
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--change code
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(CARD_PUMPKINHEAD)
	c:RegisterEffect(e2)
	-- Special Summon a Token or Send 1 Normal monster from your Deck to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORIES_TOKEN+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sgtarg)
	e3:SetOperation(s.sgoper)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_PUMPKINHEAD,2736788}
-- e1 Effect Code
function s.thfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_PUMPKINHEAD) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.Search(sg,tp)
	end
end
-- e3 Effect Code
function s.tgfilter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.sgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_PUMPKINHEAD,TYPES_TOKEN,0,0,2,RACE_PLANT,ATTRIBUTE_FIRE)
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return ((b1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or b2) end
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	Duel.SetTargetParam(opt)
	if opt==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
	if opt==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function s.sgoper(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if opt==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_PUMPKINHEAD,TYPES_TOKEN,0,0,2,RACE_PLANT,ATTRIBUTE_FIRE) then
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	if opt==1 and #g>0 then
		local sg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end