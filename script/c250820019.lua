--Astromini Nibbling
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--e1 Effect Code
function s.filter(c)
	return c:GetOriginalRace()==(RACE_PSYCHIC) and c:GetOriginalType()==(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM)
end
function s.syxfilter(c)
	return c:GetOriginalType()&(TYPE_SYNCHRO|TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil)
	and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	if Duel.IsExistingMatchingCard(s.syxfilter,tp,LOCATION_PZONE,0,1,nil) 
	and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil)
	and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil)
		local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
		g1:Merge(g2)
	else
		local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil)
		local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		g1:Merge(g2)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if g then
		Duel.Destroy(g,REASON_EFFECT)
	end
end