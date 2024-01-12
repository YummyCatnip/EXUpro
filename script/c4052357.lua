-- Fuelfire Titan - Infergrath
-- Scripted by Yummy Catnip
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Fusion Summon 
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,4051913,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE))
end