-- Cirgon Chaos Fusion
-- Scripted by Satellaa
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff{handler=c,extraop=s.extraop,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON|RACE_HIGHDRAGON),matfilter=s.matfilter,extrafil=s.fextra,extratg=s.extratg}
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_RELEASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CIRGON}
function s.matfilter(c,e,tp,chk,loc)
	return c:IsLocation(loc and loc or LOCATION_HAND|LOCATION_ONFIELD) and c:IsReleasableByEffect() and not c:IsImmuneToEffect(e)
end
function s.matdeckcheck(c,fc)
	if fc.material then
		return not c:IsCode(table.unpack(fc.material))
	end
	return true
end
function s.fcheck(tp,sg,fc)
	if not sg:CheckDifferentProperty(Card.GetAttribute,fc,SUMMON_TYPE_FUSION,tp) then return false end
	local matdeck=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if fc:IsSetCard(SET_CIRGON) then
		return #matdeck==0 or #matdeck==1 and matdeck:IsExists(s.matdeckcheck,1,nil,fc)
	else
		return #matdeck==0
	end
end
function s.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		return g,s.fcheck
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND|LOCATION_ONFIELD
	local rg=Duel.GetFusionMaterial(tp):Filter(s.matfilter,nil,e,tp,0,loc)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,rg,2,tp,loc)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RELEASE,nil,0,tp,LOCATION_DECK)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #rg>0 then
		Duel.Sendto(rg,LOCATION_GRAVE,REASON_RELEASE|REASON_EFFECT|REASON_FUSION|REASON_MATERIAL)
		sg:Sub(rg)
	end
	Duel.Release(sg,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end