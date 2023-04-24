--Seekers of the Etherealm
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ETHEREALM}

-- e1 Effect Code
function s.cfilter(c,tp)
	return c:IsSetCard(SET_ETHEREALM) and c:IsMonster() and (c:IsControler(tp) or c:IsFaceup())
end
function s.check(sg,tp)
	return Duel.IsExistingTarget(s.nfilter,tp,0,LOCATION_MZONE,1,sg) or Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,sg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,2,false,s.check,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,2,2,false,s.check,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.nfilter(c)
	return c:IsFaceup() and c:IsReleasableByEffect()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.nfilter(chkc)
		else
			return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown()
		end
	end
	local b1=Duel.IsExistingTarget(s.nfilter,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingTarget(s.lkfil,tp,0,LOCATION_SZONE,1,nil)
	if chk==0 then
		local check = e:GetLabel()==1 or (b1 or b2)
		e:SetLabel(0)
		return check
	end
	e:SetLabel(0)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	Duel.SetTargetParam(op)
	if op==0 then
		e:SetCategory(CATEGORY_RELEASE)
		local g=Duel.Select(HINTMSG_RELEASE,true,tp,s.nfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	else
		e:SetCategory(0)
		Duel.Select(HINTMSG_APPLYTO,true,tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,2,nil)
	end	
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetTargetParam()
	if not op then return end
	if op==0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e1:SetTarget(s.distg)
			e1:SetLabel(tc:GetOriginalCodeRule())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(s.discon)
			e2:SetOperation(s.disop)
			e2:SetLabel(tc:GetOriginalCodeRule())
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	elseif op==1 then
		local fid=c:GetFieldID()
		local g=Duel.GetTargetCards(e)
		local fg=g:Filter(Card.IsFacedown,nil)
		if #fg<=0 then return end
		local effects={}
		for tc in fg:Iter() do
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
			--Prevent Activation
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			e1:SetValue(1)
			if tc:RegisterEffect(e1)>0 then
				table.insert(effects,e1)
			end
			--activate check
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetCode(EVENT_CHAINING)
			e4:SetLabel(fid)
			e4:SetLabelObject(tc)
			e4:SetOperation(s.rstop2)
			e4:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e4,tp)
		end
		--Reset Activation Preventers
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE|PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(effects)
		e2:SetCondition(s.rstcon)
		e2:SetOperation(s.rstop)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		--Shuffle into Deck
		fg:KeepAlive()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE|PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(fg)
		e3:SetCondition(s.agcon)
		e3:SetOperation(s.agop)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,1-tp)
	end
end

function s.distg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsActiveType(TYPE_MONSTER) and (code1==code or code2==code)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

function s.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=e:GetLabel()
	local etab=e:GetLabelObject()
	if type(etab)=="table" then
		for _,ce in ipairs(etab) do
			local tc=ce:GetHandler()
			if tc:GetFlagEffectLabel(id)==fid then
				return true
			end
		end
	end
	e:Reset()
	return false
end
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local etab=e:GetLabelObject()
	if type(etab)=="table" then
		for _,ce in ipairs(etab) do
			ce:Reset()
		end
	end
end
function s.agcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=e:GetLabel()
	local g=e:GetLabelObject()
	if g and g:IsExists(Card.HasFlagEffectLabel,1,nil,id,fid) then
		return true
	else
		if g then
			g:DeleteGroup()
		end
		e:Reset()
		return false
	end
end
function s.agop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject():Filter(Card.HasFlagEffectLabel,nil,id,fid)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.rstop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local fid=e:GetLabel()
	local c=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=fid or tc~=c then return end
	tc:ResetFlagEffect(id)
end