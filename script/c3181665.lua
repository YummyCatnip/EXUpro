-- Animathos Justice
local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ANIMATHOS),aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER))
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
	--atk change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- Send 2 cards to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tgtarg)
	e3:SetOperation(s.tgoper)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ANIMATHOS}
s.material_setcode=SET_ANIMATHOS
-- e1 Effect Code
function s.spfilter1(c)
	return c:IsSetCard(SET_ANIMATHOS) and c:IsReleasable()
end
function s.spfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsReleasable()
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
	return c:IsRace(RACE_SPELLCASTER) and sg:FilterCount(Card.IsSetCard,c,SET_ANIMATHOS)==1
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
function s.tgffil(c)
	return c:IsAbleToGrave()
end
function s.tgefil(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_FUSION)
end
function s.tgtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tgffil,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(s.tgffil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,s.tgffil,tp,LOCATION_ONFIELD,0,1,1,nil)
	local g2=Duel.SelectTarget(tp,s.tgffil,tp,0,LOCATION_ONFIELD,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,LOCATION_EXTRA)
end
function s.tgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sp=Duel.GetTargetCards(e)
	local op=e:GetLabelObject()
	sp:RemoveCard(op)
	if not (sp or op) then return false end
	local spe=Duel.GetMatchingGroup(s.tgefil,tp,LOCATION_EXTRA,0,nil)
	local ope=Duel.GetMatchingGroup(s.tgefil,tp,0,LOCATION_EXTRA,nil)
	if #spe>0 and Duel.SelectYesNo(aux.Stringid(id,1)) then
		local sf=spe:Select(tp,1,1,nil)
		Duel.SendtoGrave(sf,REASON_EFFECT)
	else
		Duel.SendtoGrave(sp,REASON_EFFECT)
	end
	if #ope>0 and Duel.SelectYesNo(aux.Stringid(id,1)) then
		local of=ope:Select(1-tp,1,1,nil)
		Duel.SendtoGrave(of,REASON_EFFECT)
	else
		Duel.SendtoGrave(op,REASON_EFFECT)
	end
end