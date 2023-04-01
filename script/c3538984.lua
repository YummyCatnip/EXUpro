-- Number 143: Shadow of the Mind Hunter
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
end