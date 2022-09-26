--Empyrodraco Protector, Shuilong
local s,id,o=GetID()
function s.initial_effect(c)
	--Synchro limit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(s.synlimit)
	c:RegisterEffect(e0)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.setarg)
	e1:SetOperation(s.seoper)
	c:RegisterEffect(e1)
	--Revive and Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcond)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
	--Equip effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.eqcond)
	e3:SetTarget(s.eqtarg)
	e3:SetOperation(s.eqoper)
	c:RegisterEffect(e3)
	--Effect to copy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(250821000)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
s.listed_series={0xc93}
s.listed_names={id}
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_DRAGON)
end
--e1 Effect Code
function s.sfilter(c)
	return c:IsSetCard(0xc93) and c:IsAbleToHand() and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
end
function s.setarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.seoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--e2 Effect Code
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSetCard(0xc93) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonLocation(LOCATION_EXTRA) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) 
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,c)
end
function s.eqfilter(c)
	return c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TARGET)
	local tc=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 
		and not tc:IsFacedown() then
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		local et=g:GetFirst()
		if et then
			Duel.Equip(tp,et,tc)
			--Add Equip limit
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			et:RegisterEffect(e1)
		end
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
--e3 Effect Code
function s.eqcond(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsSetCard(0xc93)
end
function s.eqfilter1(c)
	return c:IsSetCard(0xc93) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.etfilter(c,tp)
	return c:IsSetCard(0xc93) and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.eqfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
end
function s.tgfilter(c)
	return c:IsSetCard(0xc93) and c:IsAbleToGrave()
end
function s.eqtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
		Duel.IsExistingTarget(s.etfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_MESSAGE,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.etfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.eqoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local g=Duel.SelectMatchingCard(tp,s.eqfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
		local et=g:GetFirst()
		if et then
			Duel.Equip(tp,et,tc)
			--Add Equip limit
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			et:RegisterEffect(e1)
			local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
			if tg then
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
	end
end