-- Custom Archetypes
SET_ANIMATHOS	= 0xc77
SET_ASTROMINI	= 0xc78
SET_ABERRATION	= 0xc79
SET_PUMPKINHEAD	= 0xc80
SET_MUDAFI	= 0xc88
SET_HOURGLASS	= 0xc89
SET_ENDLESS_SANDS	= 0xc90
SET_DIGITAL_BUG	= 0xc91
SET_ITERATOR	= 0xc92
SET_VULUTI	= 0xc94
SET_AXYZ	= 0xc95

-- Commonly used names
CARD_PUMPKINHEAD	= 2736751
-- Auxiliary functions
function Auxiliary.pupfil(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and not c:IsCode(CARD_PUMPKINHEAD)
end