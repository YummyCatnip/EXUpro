--Scorpion of the Endless Sands
local s,id,o=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcond)
	c:RegisterEffect(e1)
	--Destroy (Battled)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetTarget(s.bttarg)
	e2:SetOperation(s.btoper)
	c:RegisterEffect(e2)
	--Destroy (Targeted)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.escond)
	e3:SetTarget(s.dstarg)
	e3:SetOperation(s.dsoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc90}
s.listed_names={id}
--e1 Effect Code
function s.spfilter(c)
	return c:IsSetCard(0xc90) and c:IsMonster()
end
function s.spcond(e,c)
	if c==nil then return true end
local g=Duel.GetMatchingGroup(s.spfilter,c:GetControler(),LOCATION_GRAVE,0,2,nil)
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and #g>0 and g:GetClassCount(Card.GetCode)>=2
end
--e2 Effect Code
function s.bttarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.btoper(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
--e3 Effect Code
function s.dsfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.escond(e)
  return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.dsfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dsfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.dsfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end