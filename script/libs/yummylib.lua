-- Custom Archetypes
SET_FUELFIRE			= 0xc76
SET_FUELFIRE_T		= 0x1c76
SET_ANIMATHOS    	= 0xc77
SET_ASTROMINI    	= 0xc78
SET_ABERRATION   	= 0xc79
SET_PUMPKINHEAD  	= 0xc80
SET_EVO          	= 0Xc81
SET_SIMULACRA			= 0xc82
SET_SIMULACRUM		= 0xc83
SET_CIRGON       	= 0xc84
SET_C_CIRGON    	= 0x1c84
SET_CONQUEROR     = 0xc85
SET_CARCHARRACK  	= 0xc86
SET_QUELTZ       	= 0xc87
SET_MUDAFI       	= 0xc88
SET_HOURGLASS    	= 0xc89
SET_FIRESOUL			= 0xc8f
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
CARD_S_CORE				= 1205136

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

function Auxiliary.mnphase()
	return Duel.IsMainPhase()
end

-- Hint Messages
HINTMSG_RITUAL	=	10000

Duel.LoadScript("extra_functions.lua")