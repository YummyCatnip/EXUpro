-- Number 143: Shadow of the Mind Hunter
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	--Set ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- Negate 1 monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcond)
	e2:SetTarget(s.ngtarg)
	e2:SetOperation(s.ngoper)
	c:RegisterEffect(e2)
	-- Destroy negated monsters then draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.dscost)
	e3:SetTarget(s.dstarg)
	e3:SetOperation(s.dsoper)
	c:RegisterEffect(e3)
end
-- e1 Effect Code
function s.matcheck(e,c)
	local atk=c:GetMaterial():GetSum(Card.GetBaseAttack)
	local def=c:GetMaterial():GetSum(Card.GetBaseDefense)
	if atk==0 then return end
	--Increase ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(def)
	c:RegisterEffect(e2)
end
-- e2 Effect Code
function s.ngcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.ngfilter(c,atk,def)
	return c:IsNegatableMonster() and (c:GetAttack()<atk or c:GetDefense()<def)
end
function s.ngtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	local def=c:GetDefense()
	if chk==0 then return Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,atk,def) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function s.ngoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	local def=c:GetDefense()
	local g=Duel.GetMatchingGroup(s.ngfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,atk,def)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
-- e3 Effect Code
function s.cfilter(c)
	return c:IsDisabled() and c:IsFaceup() and c:IsMonster()
end
function s.dscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local tgc=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tmc=c:GetOverlayCount()
	local ct=math.min(tgc,tmc)
	c:RemoveOverlayCard(tp,1,ct,REASON_COST)
	local og=Duel.GetOperatedGroup()
	e:SetLabel(#og)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,ct,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,ct,ct,nil)
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			Duel.Draw(tp,#og,REASON_EFFECT)
		end
	end
end