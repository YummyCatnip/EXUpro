--Astute Inu
local s,id,o=GetID()
local ROOFTOP_INU=1642313
local INVOKING_INU=2555628
function s.initial_effect(c)
	--fusion procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,{ROOFTOP_INU,INVOKING_INU},s.matfil)
	--Gain Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.dircon)
	c:RegisterEffect(e2)
	--Add to hand + send to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.hdcond)
	e3:SetTarget(s.hdtarg)
	e3:SetOperation(s.hdoper)
	c:RegisterEffect(e3)
	--Special Summon Rooftop Inu
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcond)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.sptarg)
	e4:SetOperation(s.spoper)
	c:RegisterEffect(e4)
end
s.material={ROOFTOP_INU,INVOKING_INU}
s.listed_names={ROOFTOP_INU}
--Fusion material
function s.matfil(c,fc,sumtype,tp)
	return c:IsRace(RACE_BEAST,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WIND,fc,sumtype,tp)
end
--e1 Effect Code
function s.filter(c)
	return c:IsMonster() and c:IsType(TYPE_LINK) or c:IsType(TYPE_TUNER)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.filter,1,nil) then
		--Your opponent cannot target with card effects.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
		--Cannot be destroyed by card effects.
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e2)
		--Halve damage
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e3)
	end
end
--e2 Effect Code
function s.cfilter(c,atk)
	return (c:GetAttack()>atk)
end
function s.dircon(e)
	local tp=e:GetHandler():GetControler()
	local atk=e:GetHandler():GetAttack()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,atk)
end
--e3 Effect Code
function s.hdfilter(c)
	return c:IsAbleToHand() and c:IsAbleToDeck()
end
function s.hdcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.hdtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(s.hdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.hdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.hdoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	-- the effect can resolve even if a target is missing, so long as "all but 1" and "1" remain (i.e., 1)
	if #g>=1 then
		local rest_count=#g-1
		Duel.ConfirmCards(1-tp,g)
        -- only prompt the opponent to remove cards if more than 1 remain
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
			local tg=g:Select(1-tp,rest_count,rest_count,nil)
			g:RemoveCard(tg)
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
		Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
	end
end
--e4 Effect Code
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and c:IsCode(ROOFTOP_INU)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
	end
end