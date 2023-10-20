-- Gloom, Darkness Cirgon
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Cannot Remove
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
end