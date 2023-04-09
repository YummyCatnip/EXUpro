-- Animathos Strength
local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ANIMATHOS),aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION))
	-- Cannot be Special Summoned from the Extra Deck
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--Special summon procedure from graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.spcond)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- ATK change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- Negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.ngcond)
	e3:SetCost(s.ngcost)
	e3:SetTarget(s.ngtarg)
	e3:SetOperation(s.ngoper)
	c:RegisterEffect(e3)
	-- Return Fusion monsters to Extra Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_REMOVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.rttarg)
	e4:SetOperation(s.rtoper)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ANIMATHOS}
s.listed_names={id}
s.material_setcode=SET_ANIMATHOS
-- e1 Effect Code
function s.spfilter1(c)
	return c:IsSetCard(SET_ANIMATHOS) and c:IsReleasable()
end
function s.spfilter2(c)
	return c:IsType(TYPE_FUSION) and c:IsReleasable()
end
function s.spcond(e,c)
	if c==nil then return true end
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
	local rg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-2 and #rg1>0 and #rg2>0 and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.matfilter(c)
	return c:IsReleasable() and (s.spfilter1 or s.spfilter2)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.matchk,1,nil,sg)
end
function s.matchk(c,sg)
	return c:IsType(TYPE_FUSION) and sg:FilterCount(Card.IsSetCard,c,SET_ANIMATHOS)==1
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3300)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	c:RegisterEffect(e1,true)
end
-- e2 Effect Code
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,TYPE_FUSION)*200
end
-- e3 Effect Code
function s.ngcond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.ngfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
end
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.ngfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.ngtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.ngoper(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- e4 Effect Code
function s.rtfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToExtra() and not c:IsCode(id)
end
function s.rttarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.rtfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	local ct=Duel.GetMatchingGroupCount(s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,#g,0,LOCATION_REMOVED)
end
function s.rtoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if tc then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end