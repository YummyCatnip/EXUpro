-- Venom Hatchling
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 venom counter on 1 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- Special Summon 1 "Venom" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
end
s.counter_place_list={0x1009}
s.listed_series={SET_VENOM}
-- e1 Effect Code
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3206)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1009,1) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,1) then
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:GetAttack()==0 then
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
-- e2 Effect Code
function s.cfilter(c,lv)
	return c:GetLevel()==lv
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VENOM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetLevel())
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsCanRemoveCounter(tp,1,1,0x1009,2,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
		Duel.RemoveCounter(tp,1,1,0x1009,2,REASON_COST)
	else
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		local att=sc:GetAttribute()
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			if (att==ATTRIBUTE_EARTH) then
				--Increase ATK/DEF
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(1000)
				sc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				sc:RegisterEffect(e2)
				--Cannot be destroyed by card effects
				local e3=e1:Clone()
				e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
				e3:SetDescription(3001)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e3:SetRange(LOCATION_MZONE)
				e3:SetValue(1)
				sc:RegisterEffect(e3)
			else
				--Cannot be destroyed by battle
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3000)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				--Cannot be targeted by card effects
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetDescription(3002)
				e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e2:SetValue(1)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
			Duel.SpecialSummonComplete()
		end
	end
end