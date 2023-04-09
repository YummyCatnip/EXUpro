--Wicked Booster Shred Motor
--Scripted by: XGlitchy30

local s,id = GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--alternative proc
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--banish
	c:SummonedTrigger(false,false,true,false,1,CATEGORY_REMOVE,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,true,
		nil,
		nil,
		aux.Target(aux.BanishFilter(nil,false,true,false,false),0,LOCATION_GRAVE,1,1,nil,nil,CATEGORY_REMOVE),
		aux.BanishOperation(SUBJECT_IT)
	)
	--pseudo fusion summon
	c:Quick(false,2,CATEGORIES_FUSION_SUMMON,nil,EVENT_CHAINING,LOCATION_MZONE,true,
		s.spcon,
		aux.TributeForSummonSelfCost(s.fusfilter,LOCATION_EXTRA,0,SUMMON_TYPE_FUSION),
		aux.SSFromExtraDeckTarget(s.fusfilter,true,false,nil,SUMMON_TYPE_FUSION),
		aux.SSFromExtraDeckOperation(s.fusfilter,true,false,nil,SUMMON_TYPE_FUSION)
	)
end
function s.matfilter(c,fc,sumtype,sp)
	return c:IsSetCard(SET_WICKED_BOOSTER,fc,sumtype,sp)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end

function s.dcfilter(c,tp,sc)
	return c:IsSetCard(SET_WICKED_BOOSTER) and c:IsDiscardable(REASON_COST+REASON_MATERIAL)
		and Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,sc,tp,nil,nil,c,tp,sc)
end
function s.hspfilter(c,tp,sc)
	return c:IsSetCard(SET_WICKED_BOOSTER) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_EXTRA)
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local dg=Duel.Select(HINTMSG_DISCARD,false,tp,s.dcfilter,tp,LOCATION_HAND,0,0,1,nil,tp,c)
	if dg and #dg>0 then
		dg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,tp,nil,false,dg,tp,c)
		if g and #g>0 then
			dg:Merge(g)
			dg:KeepAlive()
			e:SetLabelObject(dg)
			return true
		else
			dg:GetFirst():ResetFlagEffect(id)
		end
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g~=2 then return end
	local dc=g:GetFirst()
	local rc=g:GetNext()
	if not dc:HasFlagEffect(id) then
		dc,rc=rc,dc
	end
	dc:ResetFlagEffect(id)
	Duel.SendtoGrave(dc,REASON_COST+REASON_MATERIAL+REASON_DISCARD)
	if rc then
		Duel.BreakEffect()
		Duel.Release(rc,REASON_COST+REASON_MATERIAL)
	end
	g:DeleteGroup()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.fusfilter(c)
	return c:IsMonster(TYPE_FUSION) and c:IsSetCard(SET_WICKED_BOOSTER)
end