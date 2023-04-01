--Inumerization
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,s.fcfilter,nil,s.fextra,s.extraop,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
	--Banish 1 Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.condit)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operat)
	c:RegisterEffect(e2)
end
--e1 Effect Code
function s.fcfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
--e2 Effect Code
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.condit(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==Duel.GetMatchingGroupCount(Card.IsInExtraMZone,tp,LOCATION_MZONE,0,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end