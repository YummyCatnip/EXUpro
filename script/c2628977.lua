--Mudafi Malady - Nizar
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	--use rank as level for Synchro Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_RANK_LEVEL_S)
	c:RegisterEffect(e0)
end
s.listed_series={0xc88}
--e1 Effect Code