-- Cotezus, Coil of Crushing Claws
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	-- Special Summon itself 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcond)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Attack twice
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- Send a copy of itself to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.tgcond)
	e3:SetTarget(s.tgtarg)
	e3:SetOperation(s.tgoper)
	c:RegisterEffect(e3)
	-- Search 1 Reptile on Destruction
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
-- e1 Effect Code
function s.thfilter1(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand() and c:IsLevel(1)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==tp
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter1),tp,LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- e3 Effect Code
function s.tgfilter(c)
	return c:IsAbleToGrave() and c:IsCode(3433692)
end
function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,0)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- e4 Effect Code
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
function s.thfilter(c,lv)
	return c:IsMonster() and c:IsRace(RACE_REPTILE) and c:IsAbleToHand() and c:IsLevelBelow(lv)
end
function s.ctfilter(c)
	return c:IsCode(id) and c:IsFaceup()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_ALL,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_ALL,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end