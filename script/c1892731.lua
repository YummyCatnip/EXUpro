-- Queltz Fright
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_QUELTZ}
-- e1 Effect Code
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_QUELTZ) and c:IsRitualMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter1(c,tp)
	local cg=c:GetColumnGroup()
	return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,c,cg,c)
end
function s.filter2(c,g,mc)
	return not (g:IsContains(c) or c==mc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	local g1=Duel.Select(HIMTMSG_DESTROY,true,tp,s.filter1,tp,0,LOCATION_ONFIELD,1,1,nil,tp):GetFirst()
	local cg=g1:GetColumnGroup()
	local g2=Duel.Select(HIMTMSG_DESTROY,true,tp,s.filter2,tp,0,LOCATION_ONFIELD,1,1,g1,cg,g1)
	g2:AddCard(g1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,2,0,0)
end
function s.desfilter(c,g)
	return g:IsContains(c)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local cg=Group.CreateGroup()
	local ct=Duel.IsTurnPlayer(1-tp) and 2 or 1
	for tc in g:Iter() do
		cg:Merge(tc:GetColumnGroup():Match(Card.IsControler,nil,1-tp))
	end
	cg:Merge(g:Filter(Card.IsControler,nil,1-tp))
	if #cg==0 or Duel.Destroy(cg,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	local seq=0
	for oc in og:Iter() do
		seq=seq|0x1<<oc:GetPreviousSequence()
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(seq*0x10000)
	e1:SetOperation(function(e) return e:GetLabel() end)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end