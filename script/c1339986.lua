--Amalgunmation Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,s.matfil,2)
	c:EnableReviveLimit()
	--Indes
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.indval)
	c:RegisterEffect(e0)
	--Gamble
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_DAMAGE+CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.gbtarg)
	e1:SetOperation(s.gboper)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.matfil(c,lc,sumtype,tp)
	return c:IsRace(RACE_MACHINE,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp)
end
--e0 Effect Code 
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
--e1 Effect Code
function s.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(5) and c:IsAtrribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.gbtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
function s.gboper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT) then
		if c1+c2+c3==0 then
			local df=tc:GetBaseDefense()
			local at=tc:GetBaseAttack()
			Duel.Damage(tp,(df+at),REASON_EFFECT)
		elseif c1+c2+c3==1 then
			if Duel.Draw(tp,1,REASON_EFFECT) then
				Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)
			end
		elseif c1+c2+c3==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		elseif c1+c2+c3==3 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_HAND,0,1,1,nil)
		end
	end
end