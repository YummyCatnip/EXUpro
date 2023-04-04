--Wicked Booster MP
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
	--draw
	c:SummonedTrigger(false,true,true,false,1,CATEGORY_DRAW,EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY,{true,true},
		nil,
		aux.BanishCost(aux.MonsterFilter(Card.IsSetCard,SET_WICKED_BOOSTER),LOCATION_HAND),
		aux.DrawTarget(),
		aux.DrawOperation()
	)
	--search
	c:BanishedTrigger(false,2,CATEGORIES_SEARCH,true,{true,true},
		s.tkcon,
		nil,
		aux.SearchTarget(s.thfilter),
		aux.SearchOperation(s.thfilter)
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

function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and r&(REASON_EFFECT|REASON_COST)>0
end
function s.thfilter(c)
	return c:IsSetCard(SET_WICKED_BOOSTER) and c:IsMonster() and not c:IsCode(id)
end

-- function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return true end
	-- Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
-- end
-- function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- local c=e:GetHandler()
	-- local ct=Duel.GetMatchingGroupCount(Card.IsInMMZ,tp,LOCATION_MZONE,0,nil)
	-- if ct<2 and Duel.GetMZoneCount(tp)>=(2-ct)
		-- and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		-- and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_WICKED_BOOSTER,TYPES_TOKEN,2000,2000,7,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then
		-- for i=1,2-ct do
			-- local token=Duel.CreateToken(tp,id+1)
			-- if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				-- token:CannotBeTributedForATributeSummon(true,true,c)
			-- end
		-- end
		-- Duel.SpecialSummonComplete()
	-- end
	-- local e0=aux.createTempLizardCheck(c)
	-- e0:SetCondition(s.spcon)
	-- Duel.RegisterEffect(e0,tp)
	-- --
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetDescription(aux.Stringid(id,3))
	-- e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	-- e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- e2:SetReset(RESET_PHASE+PHASE_END)
	-- e2:SetOwnerPlayer(tp)
	-- e2:SetCondition(s.spcon)
	-- e2:SetTargetRange(1,0)
	-- Duel.RegisterEffect(e2,tp)
	-- local e2x=e2:Clone()
	-- e2x:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- Duel.RegisterEffect(e2x,tp)
	-- local e2y=e2:Clone()
	-- e2y:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- Duel.RegisterEffect(e2y,tp)
	-- --
	-- local e3=Effect.CreateEffect(c)
	-- e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	-- e3:SetCode(EVENT_SUMMON_SUCCESS)
	-- e3:SetOperation(s.checkop)
	-- e3:SetReset(RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(e3,tp)
	-- local e3x=e3:Clone()
	-- e3x:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- Duel.RegisterEffect(e3x,tp)
	-- local e3y=e3:Clone()
	-- e3y:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- Duel.RegisterEffect(e3y,tp)
-- end
-- function s.spcon(e)
	-- return Duel.GetFlagEffect(e:GetOwnerPlayer(),id)>0
-- end
-- function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- e:Reset()
-- end