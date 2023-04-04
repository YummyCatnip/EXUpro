--Wicked Booster Proto Motor
--Scripted by: XGlitchy30

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	Link.AddProcedure(c,s.matfilter,1,1)
	--splimit
	aux.AddSSCounter(id,aux.RaceFilter(RACE_MACHINE))
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetCost(s.splimit)
	e1:SetOperation(aux.PlayerCannotSSOperation(0,aux.RaceFilter(RACE_MACHINE),nil,0))
	c:RegisterEffect(e1)
	--change name
	c:Ignition(1,nil,nil,LOCATION_MZONE,true,
		nil,
		aux.LabelCost,
		s.nmtg,
		s.nmop
	)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_WICKED_BOOSTER,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end

function s.splimit(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.filter(c)
	return c:IsMonster() and c:IsSetCard(SET_WICKED_BOOSTER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.nmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,c)
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,c)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_COST)>0 and g:GetFirst():IsBanished() then
		Duel.SetTargetParam(g:GetFirst():GetOriginalCodeRule())
	end
end
function s.nmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local name=Duel.GetTargetParam()
	if not name or not c:IsRelateToChain(0) or not c:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(name)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end