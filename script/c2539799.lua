--Mudafi Master - Hakeem
local s,id,o=GetID()
function s.initial_effect(c)
	--Link procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
	--atk change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Unaffected by Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.unaffectedval)
	c:RegisterEffect(e2)
	--Set Spell/Trap from Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.condit)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={0xc88}
function s.lcheck(g,lc,sumtype,tp)
	return (g:CheckDifferentProperty(Card.GetRace,lc,sumtype,tp) or g:CheckDifferentProperty(Card.GetLevel,lc,sumtype,tp))
end
--e1 Effect Code
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*500
end
--e2 Effect Code
function s.unaffectedval(e,te)
	return (te:IsActiveType(TYPE_SPELL) or te:IsActiveType(TYPE_TRAP)) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--e3 Effect Code
function s.cfilter(c)
	return c:IsSetCard(0xc88) and c:IsMonster()
end
function s.condit(e,tp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(0xc88)  and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end