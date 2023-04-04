--Spearman of the Endless Sands
local s,id=GetID()
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
	--Recover from GY
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.escond)
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
end
s.listed_series={0xc89}
--e1 Effect Code
function s.chkfil(c)
	return c:IsFaceup() and c:IsSetCard(0xc89) and c:IsType(TYPE_TRAP+TYPE_CONTINUOUS)
end
function s.spcond(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.chkfil,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
--e2 Effect Code
function s.escond(e)
  return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return Duel.IsExistingMatchingCard(s.chkfil,tp,LOCATION_ONFIELD,0,1,nil) and c:IsAbleToHand() end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not Duel.IsExistingMatchingCard(s.chkfil,tp,LOCATION_ONFIELD,0,1,nil) then return false end
  if c and c:IsLocation(LOCATION_GRAVE) then
    Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
  end
end