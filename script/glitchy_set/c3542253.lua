--Bestia Riciclo Spina Specchio
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--summon proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--to gy and draw
	c:SummonedTrigger(false,true,true,false,1,CATEGORY_TOGRAVE+CATEGORY_DRAW,true,true,
		nil,
		nil,
		s.tgtg,
		s.tgop
	)
	--tohand
	c:SentToHandTrigger(false,2,CATEGORY_TOHAND,true,true,
		s.thcon,
		nil,
		aux.SearchTarget(s.thfilter,1,LOCATION_GRAVE),
		aux.SearchOperation(s.thfilter,LOCATION_GRAVE)
	)
end
function s.filter(c)
	return c:IsFacedown() or not c:IsRace(RACE_MACHINE)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_RECYCLE_BEAST) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousControler(1-tp)) and (c:GetReasonCard() or (re and re:GetHandler()))
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_RECYCLE_BEAST)
end