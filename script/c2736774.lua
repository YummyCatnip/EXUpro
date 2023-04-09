-- Many-Winged Pumpkin Reaper
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_PUMPKINHEAD,4)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--ATK/DEF Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Unaffected by the effects of "Pumpkinhead" cards your opponent posses
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.ufilter)
	c:RegisterEffect(e3)
	-- Change the names of all cards on the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.cntarg)
	e4:SetOperation(s.cnoper)
	c:RegisterEffect(e4)
	-- Search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.thtarg)
	e5:SetOperation(s.thoper)
	c:RegisterEffect(e5)
end
s.material_setcode=SET_PUMPKINHEAD
s.listed_names={CARD_PUMPKINHEAD}
-- e0 Effect Code
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- e1/e2 Effect Code
function s.atkfilter(c)
	return c:IsCode(CARD_PUMPKINHEAD) and c:IsFaceup()
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*1000
end
-- e3 Effect Code
function s.ufilter(e,te)
	local rc=te:GetOwner()
	return rc:IsSetCard(SET_PUMPKINHEAD) and rc:IsControler(1-e:GetHandlerPlayer())
end
-- e4 Effect Code
function s.cntarg(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.pupfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.cnoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.pupfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(CARD_PUMPKINHEAD)
			tc:RegisterEffect(e1)
		end
	end
end
-- e5 Effect Code
function s.thfilter(c)
	return c:ListsCode(CARD_PUMPKINHEAD) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
 end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.Search(sg,tp)
	end
end