-- Simulacrum Hypnotic Mirage
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
local TOKEN_MIRAGE=id+1
s.listed_names={TOKEN_MIRAGE,CARD_S_CORE}
s.listed_series={SET_SIMULACRA}
-- check
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- e1 Effect Code 
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_FUSION)
end 
function s.attcheck(tp,att,targ_p)
	return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_MIRAGE,0,TYPES_TOKEN,1500,1500,4,RACE_FIEND,att,POS_FACEUP_DEFENSE,targ_p)
end
function s.getvalidatts(tp)
	local res=ATTRIBUTE_ALL
	local att=ATTRIBUTE_EARTH
	while att<ATTRIBUTE_ALL do
		if not s.attcheck(tp,att,tp) or not s.attcheck(tp,att,1-tp) then
			res=res&~att
		end
		att=att<<1
	end
	return res
end
function s.tgfil(c)
	return c:IsSetCard(SET_SIMULACRA) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local valid_atts=s.getvalidatts(tp)
	if chk==0 then return valid_atts>0 and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.tgfil,tp,LOCATION_EXTRA,0,1,nil) end
	local att=Duel.AnnounceAttribute(tp,1,valid_atts)
	Duel.SetTargetParam(att)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local handler=e:GetHandler()
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if not (att and att>0 and s.attcheck(tp,att,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfil,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if not g then return end
	att2=g:GetAttribute()
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsLocation(LOCATION_GRAVE) then
		local token=Duel.CreateToken(tp,TOKEN_MIRAGE)
		token:Attribute(att)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		--Cannot be tributed
		local e1=Effect.CreateEffect(handler)
		e1:SetDescription(3303)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e2,true)
		--Cannot be used as link material
		local e3=e2:Clone()
		e3:SetDescription(3312)
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		token:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
	local params={
		fusfilter=function(c) return c:IsSetCard(SET_SIMULACRA) and c:IsAttributeExcept(att2) end,
		matfilter=function(c) return c:IsLocation(LOCATION_MZONE) end,
		gc=token,extrafil=s.fextra,extraop=s.extraop
	}
	if Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end