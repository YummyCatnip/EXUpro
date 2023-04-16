-- Florence, Baptista Colore
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Change Types
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- e1 Effect Code
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.Select(HINTMSG_RELEASE,false,tp,Card.IsReleasable,tp,LOCATION_ONFIELD,0,1,1,nil)
	local typ=g:GetFirst():GetType()&0x7
	e:SetLabel(typ)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.True,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	Debug.Message(typ)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.True,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(typ)
			tc:RegisterEffect(e1)
		end
	end
end