--Custom arches
SET_WICKED_BOOSTER 	= 0xa00
SET_RECYCLE_BEAST	= 0xa01

--Modified Functions
local _GetTargetCards, _IsRelateToChain = Duel.GetTargetCards, Card.IsRelateToChain
Card.IsMonster = function(c,typ)
	return c:IsType(TYPE_MONSTER) and (not typ or c:IsType(typ))
end
Duel.GetTargetCards = function(e)
	if type(e)=="Effect" then
		return _GetTargetCards(e)
	else
		return Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil,0)
	end
end
Card.IsRelateToChain = function(c,ct)
	if not ct then ct=0 end
	return _IsRelateToChain(c,ct)
end

--KPRO Imports
--filter for "negate the effects of a face-up monster" (無限泡影/Infinite Impermanence)
function Auxiliary.NegateMonsterFilter(c)
	return c:IsFaceup() and not c:IsDisabled() and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
--filter for "negate the effects of an Effect Monster" (エフェクト・ヴェーラー/Effect Veiler)
function Auxiliary.NegateEffectMonsterFilter(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
--filter for "negate the effects of a face-up card"
function Auxiliary.NegateAnyFilter(c)
	if c:IsType(TYPE_TRAPMONSTER) then
		return c:IsFaceup()
	elseif c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsFaceup() and not c:IsDisabled()
	else
		return aux.NegateMonsterFilter(c)
	end
end

Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_single.lua")
Duel.LoadScript("glitchylib_field.lua")
Duel.LoadScript("glitchylib_trigger.lua")
Duel.LoadScript("glitchylib_cond.lua")
Duel.LoadScript("glitchylib_cost.lua")
Duel.LoadScript("glitchylib_tgop.lua")