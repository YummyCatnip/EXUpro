-- Aberration-51: Hunter in Wolf's Clothing
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_BEAST),6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	-- Pop 1 Beast monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(aux.mnphase)
	e1:SetTarget(s.dstarg)
	e1:SetOperation(s.dsoper)
	c:RegisterEffect(e1)
	-- Attach a Beast monster(s) that would be sent to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
	-- If Destroyed Special Summon Level 4 or lower Beast Monster(s) from your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcond)
	e3:SetTarget(s.sptarg)
	e3:SetOperation(s.spoper)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ABERRATION}
-- Xyz Summon Code
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRace(RACE_BEAST,lc,SUMMON_TYPE_XYZ,tp) and c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
-- e1 Effect Code
function s.dsfil(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function s.dstarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.dsfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dsfil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,s.dsfil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.dsoper(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- e2 Effect Code
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetDestination()==LOCATION_GRAVE and c:IsMonster() and c:IsRace(RACE_BEAST)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		local g=eg:Filter(s.repfilter,c,e,tp)
		for tc in g:Iter() do
			tc:CancelToGrave()
		end
		if #g>0 then
			Duel.Overlay(c,g)
		end
		return true
	else return false end
end
function s.repval(e,c)
	return true
end
-- e3 Effect Code
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()-1
	e:SetLabel(ct)
	return c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and ct>0
end
function s.spfil(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>ft then ct=ft end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,0,ct,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ct>ft then ct=ft end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfil,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- Cannot Special Summon monsters, except Beast and "Aberration-" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(function(_,c) return not (c:IsRace(RACE_BEAST) or c:IsSetCard(SET_ABERRATION)) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end