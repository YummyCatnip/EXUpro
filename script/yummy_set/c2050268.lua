--Naturia Carnation
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
end
s.listed_series={SET_NATURIA}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_NATURIA,lc,sumtype,tp) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_TOKEN,lc,sumtype,tp)
end