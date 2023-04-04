--Vuluti Light-Maker
local s,id,o=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,2,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop,false,s.xyzcheck)
	--Banish this card, Special previous material, reduce dmg by 500
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtarg)
	e1:SetOperation(s.rmoper)
	c:RegisterEffect(e1)
	--Revive from banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
end
s.listed_series={0xc94}
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0xc94) and (c:GetSequence()>4) and c:IsType(TYPE_LINK)
end
function s.xyzfilter(c,xyz,tp)
	return c:IsSetCard(0xc94,xyz,SUMMON_TYPE_XYZ,tp)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:IsExists(s.xyzfilter,1,nil,xyz,tp)
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and
	Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,mc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,mc):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if tc then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.SendtoGrave(tc,REASON_COST)
		return true
	else return false end
end
--e1 Effect Code
function s.filter(c,e,tp,ovr)
	return ovr:IsContains(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) and c:IsAbleToRemoveAsCost() end
	local oldg=e:GetLabelObject()
	if oldg then oldg:DeleteGroup() end
	local ovr=c:GetOverlayGroup()
	ovr:KeepAlive()
	e:SetLabelObject(ovr)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.rmtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,ovr) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	local ovr=e:GetLabelObject()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ovr)
	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ovr)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
	end
	ovr:DeleteGroup()
	e:SetLabelObject(nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.rmoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- halve battle damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.damval(e,re,val,r,rp,rc)
	return math.max(val-500,0)
end
--e2 Effect Code
function s.spfilter(c)
	return c:IsSetCard(0xc94) and c:IsType(TYPE_MONSTER)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsRelateToEffect(e) and s.spfilter(tc) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end