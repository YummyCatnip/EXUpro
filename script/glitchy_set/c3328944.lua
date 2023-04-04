--Wicked Booster Metal Maestro
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
	--search
	c:SummonedTrigger(false,true,true,false,1,CATEGORIES_SEARCH,true,{true,true},
		nil,
		nil,
		aux.SearchTarget(s.tgfilter),
		aux.SearchOperation(s.tgfilter)
	)
	--control
	c:BanishedTrigger(false,2,CATEGORY_CONTROL,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,{true,true},
		s.tkcon,
		nil,
		aux.Target(aux.ControlFilter(),0,LOCATION_MZONE,1,1,nil,nil,CATEGORY_CONTROL),
		s.ctop
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

function s.tgfilter(c)
	return c:IsST() and c:IsSetCard(SET_WICKED_BOOSTER)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WICKED_BOOSTER) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and r&(REASON_EFFECT|REASON_COST)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain(0) and Duel.GetControl(tc,tp) then
		local c=e:GetHandler()
		local reset=RESET_EVENT+RESETS_STANDARD
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(reset)
		tc:RegisterEffect(e1)		
		local e2=e1:Clone()
		e2:SetDescription(3302)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:Desc(3)
		e3:SetCode(EFFECT_ADD_SETCODE)
		e3:SetValue(SET_WICKED_BOOSTER)
		tc:RegisterEffect(e3)
	end
end