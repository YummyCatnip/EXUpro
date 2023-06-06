-- Hope of the Conquerors
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- Activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Extra Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetCountLimit(1)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAbleToRemove))
	e1:SetOperation(s.banishmat)
	e1:SetValue(s.mtval)
	c:RegisterEffect(e1)
	-- Fusion Summon
	local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_CONQUEROR),extrafil=s.fextra,extratg=s.extratg}
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.sptarg(Fusion.SummonEffTG(params)))
	e2:SetOperation(s.spoper(Fusion.SummonEffOP(params)))
	c:RegisterEffect(e2)
end
s.listed_series={SET_CONQUEROR}
-- e1 Effect Code
function s.banishmat(e,tc,tp,sg)
	local bg,nbg=sg:Split(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.Remove(bg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	if #nbg>0 then
		Duel.SendtoGrave(nbg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	end
	sg:Clear()
end
function s.mtval(e,c)
	if not c then return false end
	return c:IsSetCard(SET_CONQUEROR) and c:IsControler(e:GetHandlerPlayer())
end
-- e2 Effect Code 
function s.sptarg(fusetg)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsAbleToGrave() and fusetg(e,tp,eg,ep,ev,re,r,rp,0) end
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.spoper(fusetg,fuseop)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and fusetg(e,tp,eg,ep,ev,re,r,rp,0) then
			fuseop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.dmcon(tp)
	return not Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,LOCATION_MZONE,0,1,nil,LOCATION_EXTRA)
		and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
function s.fextra(e,tp,mg)
	if s.dmcon(tp) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end