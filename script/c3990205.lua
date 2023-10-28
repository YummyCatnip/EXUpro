-- Turbulence, Forest Cirgon Spirit
-- Scripted by Satellaa
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	-- Must be properly summoned before reviving
	c:EnableReviveLimit()
	-- Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_CIRGON),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_CIRGON),1,1)
	-- Fusion Summon 1 "Cirgon Spirit" Fusion Monster
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_CIRGON),matfilter=aux.FALSE,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratg}
	c:SummonedTrigger
	(
		false,false,true,false,aux.Stringid(id,0),CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON,
		EFFECT_FLAG_DELAY,true,function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end,
		s.cost,Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)
	)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_GRAVE) end)
	-- Gain effect for a Synchro Monster used this card as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.efcon)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CIRGON}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- Cannot Special Summon from the GY
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_GRAVE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsReleasableByEffect),tp,LOCATION_DECK,0,nil)
	if #g>0 then
		return g
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,2,tp,LOCATION_DECK)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #rg>0 then
		Duel.Sendto(rg,LOCATION_GRAVE,REASON_RELEASE|REASON_EFFECT|REASON_FUSION|REASON_MATERIAL)
		sg:Sub(rg)
	end
	sg:Clear()
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_SYNCHRO)>0 and e:GetHandler():GetReasonCard():IsSetCard(SET_CIRGON)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- Cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(1)
	rc:RegisterEffect(e1)
end