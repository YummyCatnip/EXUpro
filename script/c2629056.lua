--Mudafi Mustira - Oualid
local s,id,o=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	--able to use original attack while battling
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operat)
	c:RegisterEffect(e1)
	--monsters' effects cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--Send to Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtarg)
	e3:SetOperation(s.tdoper)
	c:RegisterEffect(e3)
	--Revive
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.spcond)
	e4:SetTarget(s.sptarg)
	e4:SetOperation(s.spoper)
	c:RegisterEffect(e4)
end
s.listed_series={0xc88}
--Fusion Procedure
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
    return c:IsSetCard(0xc88,fc,sumtype,tp) and c:HasLevel() and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetLevel(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,lvl,fc,sumtype,tp)
    return c:IsLevel(lvl) and not c:IsHasEffect(511002961)
end
--e1 Effect Code
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		local oa=bc:GetTextAttack()
		local od=bc:GetTextDefense()
		local ca=bc:GetAttack()
		local cd=bc:GetDefense()
		if bc:IsImmuneToEffect(e) then
			oa=bc:GetBaseAttack()
			od=bc:GetBaseDefense() end
		if oa<0 then oa=0 end
		if od<0 then od=0 end
		local fa=math.min(oa,ca)
		local fd=math.min(od,cd)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e1:SetValue(fa)
		bc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e2:SetValue(fd)
		bc:RegisterEffect(e2,true)
	end
end
--e2 Effect Code
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
--e3 Effect Code
function s.filter(c)
	return c:IsSetCard(0xc88) and c:IsAbleToDeck()
end
function s.tdtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	g:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function s.tdoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if tc then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
--e4 Effect Code
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_GRAVE)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end