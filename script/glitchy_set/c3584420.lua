--Wicked Booster Breaker
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--summon with no tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetOperation(s.ntop)
	c:RegisterEffect(e1)
	--target banished
	c:SummonedTrigger(false,true,true,false,1,CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,{true,true},
		nil,
		nil,
		s.target,
		s.operation
	)
	--negate
	c:BanishedTrigger(false,4,CATEGORY_DISABLE,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,{true,true},
		s.tkcon,
		nil,
		aux.Target(aux.DisableFilter(Card.IsFaceup),0,LOCATION_ONFIELD,1,1,nil,nil,CATEGORY_DISABLE),
		aux.DisableOperation(SUBJECT_IT,nil,nil,nil,nil,nil,RESET_PHASE+PHASE_END)
	)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	local rct=(Duel.IsEndPhase(1-tp)) and 2 or 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD+RESET_PHASE+PHASE_END+RESET_TURN_OPPO,rct)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(0)
	c:RegisterEffect(e1)
end

function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_WICKED_BOOSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain(0) then return end
	local spchk = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=aux.Option(id,tp,2,true,spchk)
	if op==0 then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	elseif op==1 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WICKED_BOOSTER)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and r&(REASON_EFFECT|REASON_COST)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end