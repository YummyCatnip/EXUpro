--Tin Soldier
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,s.matfil,2,2,s.lcheck)
	c:EnableReviveLimit()
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destarg)
	e1:SetOperation(s.desoper)
	c:RegisterEffect(e1)
end
function s.matfil(c)
	return c:IsType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
--e1 Effect Code
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function s.trfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function s.tgrescon(clv)
	return function(sg)
		local sum=sg:GetSum(Card.GetLevel)
		return sum==clv,sum>clv
	end
end
function s.destarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(s.trfilter,tp,LOCATION_DECK,0,nil)
		local rescon=s.tgrescon(tc:GetLevel())
		local mg=aux.SelectUnselectGroup(g,e,tp,1,#g,rescon,1,tp,HINTMSG_TOGRAVE,rescon)
		if #mg>0 and Duel.SendtoGrave(mg,REASON_EFFECT)>0 and mg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end