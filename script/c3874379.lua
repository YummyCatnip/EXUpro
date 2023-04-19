-- Aberration-214: We All Deserve Love
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Link Summon Procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	-- Cannot be targeted for attacks while you control another face-up monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.imval2)
	e1:SetCondition(s.econ)
	c:RegisterEffect(e1)
	-- Special Summon a monster when a monster is summoned to a zone this card points to
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.zptcon(nil))
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptarg)
	e2:SetOperation(s.spoper)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- Link Summon Code
function s.matfil(c,lc,sumtype,tp)
	return (c:IsCode(3876554) or c:IsCode(3874393))
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfil,1,nil,lc,sumtype,tp)
end
-- e1 Effect Code
function s.econ(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c)
end
-- e2 Effect Code
function s.spfilter(c,hc,e,tp)
	local zone1=hc:GetLinkedZone(tp)&~0x60
	local zone2=hc:GetLinkedZone(tp)&~0x60
	return c:ListsArchetype(SET_ABERRATION) and not c:IsType(TYPE_EXTRA) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)) and (Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone1)>0 or Duel.GetMZoneCount(1-tp,c,tp,LOCATION_REASON_TOFIELD,zone2)>0)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp):GetFirst()
	local zone1=c:GetLinkedZone(tp)&~0x60
	local zone2=c:GetLinkedZone(1-tp)&~0x60
	local s1=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone1)>0 and sg:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone2)>0 and sg:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else return end
	if op==0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP,zone1)
	else Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP,zone2) end
	sg:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetLabelObject(tc)
	e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	e1:SetCountLimit(1)
	Duel.RegisterEffect(e1,tp)
	if sg:IsControler(tp) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		sg:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		sg:RegisterEffect(e3)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp and tc:GetFlagEffectLabel(id)==e:GetLabel()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
end