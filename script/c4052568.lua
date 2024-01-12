-- Fuelfire Titan - Blazjin, Blaze of Glory
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Fusion Summon 
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,4051924,s.matfil)
end
function s.matfil(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,fc,sumtype,tp) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
end