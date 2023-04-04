-- Venom Mist
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Place Venom Counters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cttarg)
	e1:SetOperation(s.ctoper)
	c:RegisterEffect(e1)
	-- Special 1 "Venom" monster from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcond)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- "Venom" monsters becomes unaffected
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_VENOM))
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetValue(s.unaval)
	c:RegisterEffect(e5)
	--Destroy replace
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.desreptg)
	e6:SetValue(s.desrepval)
	e6:SetOperation(s.desrepop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_VENOM}
s.counter_place_list={COUNTER_VENOM}
-- e1 Effect Code
function s.ctfilter(c)
	return (c:HasLevel() or c:IsRankAbove(1) or c:IsLinkAbove(1)) and c:IsCanAddCounter(COUNTER_VENOM,1)
end
function s.cttarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
function s.ctoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(COUNTER_VENOM,1) then
		local atk=tc:GetAttack()
		if tc:HasLevel() then
			local ct=tc:GetLevel()
			tc:AddCounter(COUNTER_VENOM,ct)
		elseif tc:IsRankAbove(1) then
			local ct=tc:GetRank()
			tc:AddCounter(COUNTER_VENOM,ct)
		elseif tc:IsLinkAbove(1) then
			local ct=tc:GetLink()
			tc:AddCounter(COUNTER_VENOM,ct)
		end
		if atk>0 and tc:GetAttack()==0 then
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
-- e2 Effect Code
function s.confil(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_VENOM) and c:IsControler(tp)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confil,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VENOM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- e5 Effect Code
function s.unaval(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER)
		and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() 
		and tc:GetCounter(COUNTER_VENOM)>0
end
-- e6 Effect Code
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(SET_VENOM) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_VENOM,2,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,1,1,COUNTER_VENOM,2,REASON_EFFECT+REASON_REPLACE)
end