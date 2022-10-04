--Hourglass of Rebirth
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
	--Revive Monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sftarg)
	e3:SetOperation(s.spoper)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetTarget(s.sftarg2)
	c:RegisterEffect(e4)
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
function s.sfilter(c,e,tp)
	return c:IsSetCard(0xc90) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,c)
end
function s.attfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.sftarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,g,e,tp)
	e:SetLabelObject(g2:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local tc=e:GetLabelObject()
	g:RemoveCard(tc)
	if #g>=3 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>=3 then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
			Duel.ChangePosition(c,POS_FACEDOWN)
			Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			Duel.BreakEffect()
			if tc:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_GRAVE,0,1,nil,e) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local at=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_GRAVE,0,1,1,nil,e)
				if at then
					Duel.Overlay(tc,at,true)
				end
			end
		end
	end
end
--e4 Effect Code
function s.rfilter1(c,e,tp)
	return c:IsSetCard(0xc90) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.rfilter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.vpf(c)
  return c:IsHasEffect(250820104) and c:IsFaceup()
end
function s.sftarg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local vp=Duel.GetMatchingGroup(s.vpf,tp,LOCATION_MZONE,0,nil)
  local xyzg=Group.CreateGroup()
  for tc in vp:Iter() do
  	if tc:GetOverlayGroup():IsExists(s.rfilter1,3,nil) then
      xyzg:AddCard(tc)
    end
  end
  local b1=Duel.IsExistingTarget(s.rfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
  local b2=#vp>0 and #xyzg>0
  if chk==0 then return b1 and b2 end
  if #xyzg==1 then
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  	local g=xyzg:GetFirst():GetOverlayGroup():FilterSelect(tp,s.rfilter1,3,3,nil)
  	Duel.SetTargetCard(g)
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectTarget(tp,s.rfilter2,tp,LOCATION_GRAVE,0,1,1,g,e,tp)
		e:SetLabelObject(g2:GetFirst())
  elseif #xyzg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local ch=xyzg:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=ch:GetOverlayGroup():FilterSelect(tp,s.rfilter1,3,3,nil)
		Duel.SetTargetCard(g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectTarget(tp,s.rfilter2,tp,LOCATION_GRAVE,0,1,1,g,e,tp)
		e:SetLabelObject(g2:GetFirst())
  end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end