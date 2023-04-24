-- Custom Archetypes
SET_ANIMATHOS    	= 0xc77
SET_ASTROMINI    	= 0xc78
SET_ABERRATION   	= 0xc79
SET_PUMPKINHEAD  	= 0xc80
SET_EVO          	= 0Xc81
SET_MUDAFI       	= 0xc88
SET_HOURGLASS    	= 0xc89
SET_ENDLESS_SANDS	= 0xc90
SET_DIGITAL_BUG  	= 0xc91
SET_ITERATOR     	= 0xc92
SET_ETHEREALM    	= 0xc93
SET_VULUTI       	= 0xc94
SET_AXYZ         	= 0xc95

-- Commonly used names
CARD_PUMPKINHEAD	= 2736751
CARD_ABE_56     	= 3788395
CARD_ABE_214    	= 3874379
CARD_BOUQUET    	= 3789163
TOKEN_ETHEREALM 	= 3311799

-- Auxiliary functions
function Auxiliary.pupfil(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and not c:IsCode(CARD_PUMPKINHEAD)
end

function Card.IsEvo(c)
	return (c:IsSetCard(SET_EVO) or c:IsCode(14154221,8632967,34026662,88760522,5338223,74100225,64815084,24362891))
end

function Auxiliary.rsnsynchro(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Custom Constants

TYPE_EXTRA = TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK