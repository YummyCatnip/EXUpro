--Digital Bug Locathode
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,2,s.lcheck)
	--Card from hand as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	--Xyz summon disruption
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsMainPhase() and Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.syncsumtg)
	e2:SetOperation(s.syncsumop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc91}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_INSECT,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_LIGHT,lc,sumtype,tp)
end
function s.cfilter(c)
	return c:IsCode(68950538,19301729,94344242,83048208,32465539,85004150,58600555,12615446) or c:IsSetCard(0xc91)
end
function s.lcheck(g)
	return g:IsExists(s.cfilter,1,nil)
end
--e1 Effect code
s.curgroup=nil
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not s.curgroup or #(sg&s.curgroup)<2
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end
--e2 Effect code
function s.xyzfilter(c,forcedg,matg)
	return c:IsXyzSummonable(forcedg,matg) and c:IsRace(RACE_INSECT)
end
function s.filter(c,this,tp)
	if not c:IsFaceup() and not c:IsCanBeXyzMaterial() then return false end
	--Temporarily register EFFECT_XYZ_MATERIAL otherwise IsXyzSummonable will fail with opponent's monsters 
	local e1=Effect.CreateEffect(this)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_MATERIAL)
	c:RegisterEffect(e1,true)
	--Temporarily register EFFECT_XYZ_LEVEL 
	local e2=Effect.CreateEffect(this)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetValue(s.xyzlv)
	c:RegisterEffect(e2,true)
	local e2b=e2:Clone()
	this:RegisterEffect(e2b,true)
	--Temporarily register RACE_INSECT to the opponent's monster
	local e3=Effect.CreateEffect(this)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_INSECT)
	c:RegisterEffect(e3,true)
	--Temporarily register RACE_INSECT to itself
	local e3b=e2:Clone()
	this:RegisterEffect(e3b,true)
	--Temporarily register ATTRIBUTE_LIGHT  to the opponent's monster
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e4:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e4,true)
	--Temporarily register ATTRIBUTE_LIGHT to itself
	local e4b=e2:Clone()
	this:RegisterEffect(e4b,true)
	local mg=Group.FromCards(this,c)
	local res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg,nil)
	e1:Reset()
	e2:Reset()
	e2b:Reset()
	e3:Reset()
	e3b:Reset()
	e4:Reset()
	e4b:Reset()
	return res
end
function s.xyzlv(e,c,rc)
	return 3,e:GetHandler():GetLevel()
end
function s.syncsumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:s.filter(chkc,c,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,c,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
--Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,c,c,tp)
function s.syncsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tc then return end
	--Register EFFECT_XYZ_MATERIAL, temporarily, only if it's an opponent's monster
	local e1=Effect.CreateEffect(c) --don't declare e1 localy inside the if, so it outlives that scope (to be used in e2)
	if tc:IsControler(1-tp) then
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_MATERIAL)
		tc:RegisterEffect(e1,true)
	end
	--Temporarily register EFFECT_XYZ_LEVEL 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetValue(s.xyzlv)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2,true)
	local e2b=e2:Clone()
	c:RegisterEffect(e2b,true)
	--Temporarily register RACE_INSECT to the opponent's monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_INSECT)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3,true)
	--Temporarily register RACE_INSECT to itself
	local e3b=e2:Clone()
	c:RegisterEffect(e3b,true)
	--Temporarily register ATTRIBUTE_LIGHT  to the opponent's monster
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e4:SetValue(ATTRIBUTE_LIGHT)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e4,true)
	--Temporarily register ATTRIBUTE_LIGHT to itself
	local e4b=e3:Clone()
	c:RegisterEffect(e4b,true)
	--Xyz Summon:
	local mg=Group.FromCards(c,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg,nil)
	local sc=g:GetFirst()
	if sc then
		--Reset EFFECT_XYZ_MATERIAL at the suitable time
		if tc:IsControler(1-tp) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_SPSUMMON_SUCCESS)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			e2:SetOperation(s.regop)
			e2:SetLabelObject(e1)
			sc:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EVENT_SPSUMMON_NEGATED)
			sc:RegisterEffect(e3,true)
		end
		--Perform the Xyz Summon
		Duel.XyzSummon(tp,sc,mg,nil)
	end
	--Do not use the following reset (or the properties will be lost before the Xyz Summon):
	--[[
	e2:Reset()
	e2b:Reset()
	e3:Reset()
	e3b:Reset()
	e4:Reset()
	e4b:Reset()
	--]]
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end