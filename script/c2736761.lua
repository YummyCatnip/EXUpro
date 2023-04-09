-- The Strider with a Pumpkin for a Head
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcond)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Change names
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cntarg)
	e2:SetOperation(s.cnoper)
	c:RegisterEffect(e2)
	-- Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtarg)
	e3:SetOperation(s.thoper)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_PUMPKINHEAD}
-- e1 Effect Code
function s.spfilter(c)
	return c:IsReleasable() and c:IsCode(CARD_PUMPKINHEAD)
end
function s.spcond(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and #rg>0
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local g=Duel.Select(HINTMSG_RELEASE,false,tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
-- e2 Effect Code
function s.cntarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and aux.pupfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local g=Duel.Select(HINTMSG_APPLYTO,true,tp,aux.pupfil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
end
function s.cnfilter(c,code)
	return c:IsOriginalCode(code) and not c:IsCode(CARD_PUMPKINHEAD)
end
function s.cnoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=Duel.GetFirstTarget()
	if sc and sc:IsRelateToEffect(e) and sc:IsFaceup() then
		local code=sc:GetOriginalCode()
		local g=Duel.GetMatchingGroup(s.cnfilter,tp,LOCATION_ALL,LOCATION_ALL,nil,code)
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(CARD_PUMPKINHEAD)
			tc:RegisterEffect(e1)
		end
	end
end
-- e3 Effect Code
function s.thfilter(c)
	return c:ListsCode(CARD_PUMPKINHEAD) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
 end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 then
		local sg=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		Duel.Search(sg,tp)
	end
end