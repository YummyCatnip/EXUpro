-- Card has multiple Races
function Card.HasMultipleRaces(c)
	if not c:IsMonster() then return false end
	local races=c:GetRace()
	return races>0 and races&(races-1)~=0
end