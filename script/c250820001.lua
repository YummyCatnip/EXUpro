--Gladiator Beast Antony
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.cond1)
	e1:SetTarget(s.targ1)
	e1:SetOperation(s.oper1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(aux.gbspcon)
	e3:SetTarget(s.targ2)
	e3:SetOperation(s.oper2)
	c:RegisterEffect(e3)
end
s.listed_series={0x19}
--e1 Effect Code
function s.setcfilter(c,tp,lg)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x19) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():IsPreviousLocation(LOCATION_HAND)
	return eg:IsExists(s.setcfilter,1,nil,tp,lg)
end
function s.targ1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.oper1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,113,tp,tp,false,false,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(c:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
	end
end
--e3 Effect Code
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and (c:IsSetCard(0x19) or c:IsCode(52394047,97234686,76384284,16990348)) and c:IsSSetable(true)
end
function s.targ2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAINING)
		e2:SetLabel(Duel.GetCurrentChain())
		e2:SetLabelObject(tc)
		e2:SetCondition(s.regcon)
		e2:SetOperation(s.regop)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==e:GetLabel() then return false end
	local ceff=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_EFFECT)
	local res = ceff:IsHasType(EFFECT_TYPE_ACTIVATE) and ceff:GetHandler()==e:GetLabelObject()
	if not res then
		e:Reset()
		return false
	end
	return true
end
function s.regop(e,tp)
	e:GetOwner():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.oper2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		if e:GetHandler():GetFlagEffect(id)>0 then
			if Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
				if g then
					Duel.SSet(tp,g)
				end
			end
		elseif tc:IsFacedown() and tc:IsRelateToChain(0) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end
