--Hourglass of Distortion
local s,id,o=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Excavate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.excond)
	e1:SetTarget(s.extarg)
	e1:SetOperation(s.exoper)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcond)
	c:RegisterEffect(e2)
	--Send to Hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sftarg)
	e3:SetOperation(s.sfoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xc90}
--e1 Effect Code 
function s.excond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.extarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
end
function s.exoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsSetCard(0xc90) and tc:IsType(TYPE_MONSTER) and tc:IsAbleToGrave() then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end
--e2 Effect Code
function s.handcond(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
--e3 Effect Code
function s.sfilter(c)
    return c:IsSetCard(0xc90) and c:IsMonster() and c:IsAbleToDeck()
end
function s.vpf(c)
    return c:IsHasEffect(250820104) and c:IsFaceup()
end
function s.sftarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  local vp=Duel.GetMatchingGroup(s.vpf,tp,LOCATION_MZONE,0,nil)
  local xyzg=Group.CreateGroup()
  for tc in vp:Iter() do
    if tc:GetOverlayGroup():IsExists(s.sfilter,4,nil) then
      xyzg:AddCard(tc)
  	end
  end
  local b1=Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,nil)
  local b2=#vp>0 and #xyzg>0
  if chk==0 then return (b1 or b2) and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
    if #xyzg==1 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
      local g=xyzg:GetFirst():GetOverlayGroup():FilterSelect(tp,s.sfilter,4,4,nil)
      Duel.SetTargetCard(g)
    elseif #xyzg>1 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
      local ch=xyzg:Select(tp,1,1,nik)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
      local g=ch:GetOverlayGroup():FilterSelect(tp,s.sfilter,4,4,nil)
      Duel.SetTargetCard(g)
  	end
  else
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,4,nil)
  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	e:SetLabelObject(g2:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,4,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
function s.sfoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetedCards(e)
	local tc=e:GetLabelObject()
	g:RemoveCard(tc)
	if #g==4 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==4 then
		Duel.BreakEffect()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT) then
			Duel.ChangePosition(c,POS_FACEDOWN)
			Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		end
	end
end