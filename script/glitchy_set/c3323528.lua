--Wicked Booster Crush Motor
--Scripted by: XGlitchy30

local s,id = GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_DESTROY,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,true,
		nil,
		nil,
		aux.Target(nil,0,LOCATION_MZONE,1,1,nil,nil,CATEGORY_DESTROY),
		aux.DestroyOperation(SUBJECT_IT)
	)
	--negate
	c:Quick(false,1,CATEGORY_NEGATE+CATEGORY_REMOVE,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,EVENT_CHAINING,LOCATION_MZONE,true,
		s.negcon,
		aux.BanishCost(aux.MonsterFilter(Card.IsSetCard,SET_WICKED_BOOSTER),LOCATION_GRAVE,0,1,1,true),
		s.negtg,
		s.negop
	)
	--ss
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_REMOVED)
	e5:HOPT()
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
function s.matfilter(c,fc,sumtype,sp)
	return c:IsSetCard(SET_WICKED_BOOSTER,fc,sumtype,sp)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain(0) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED) then
		local check=Duel.IsStandbyPhase()
		local ct = check and 2 or 1
		local lab = check and Duel.GetTurnCount() or -1
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,ct,lab)
		if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToChain(ev) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:HasFlagEffect(id) then return false end
	for _,lab in ipairs({c:GetFlagEffectLabel(id)}) do
		if Duel.GetTurnCount()~=lab then
			return true
		end
	end
	return false
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToChain(0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end