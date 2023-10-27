-- Eclipse, Revengeful Cirgon
-- Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Xyz.AddProcedure(c,nil,5,2,nil,nil,nil,nil,false,s.xyzcheck)
	-- Card in your other Pendulum Zone cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetTarget(s.indestg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Special Summon this card from your Pendulum Zone
	c:PhaseTrigger
	(
		nil,PHASE_STANDBY,aux.Stringid(id,0),CATEGORY_SPECIAL_SUMMON,nil,LOCATION_PZONE,nil,
		s.spcon,nil,s.sptg,s.spop
	)
	-- Negate 1 face-up Spell your opponent controls
	c:Quick
	(
		nil,aux.Stringid(id,1),CATEGORY_DISABLE,EFFECT_FLAG_CARD_TARGET,nil,LOCATION_MZONE,
		true,function() return Duel.IsMainPhase() end,nil,s.distg,s.disop,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END
	)
	-- Place this card in the Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.plcost)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.xyzcheck(g,tp,xyz)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function s.indestg(e,c)
	local rc=e:GetHandler()
	return c~=rc
end
function Card.IsNegatableSpell(c)
	return c:IsSpell() and c:IsNegatableSpellTrap()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsNegatableSpell() and chkc:IsControler(1-tp) end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.IsExistingTarget(Card.IsNegatableSpell,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatableSpell,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsNegatableSpell() and tc:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0 then
		tc:NegateEffects(c)
	end
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local og=e:GetHandler():GetOverlayGroup()
	Duel.SendtoGrave(og,REASON_COST)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsStandbyPhase(1-tp) and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end