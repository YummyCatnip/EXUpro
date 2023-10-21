-- Breez, Forest Crystal Cirgon
-- Scripted by Satellaa
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	aux.CirgonGlobalCheck(s,c)
	-- Special Summon itself from the hand
	c:SSProc
	(
		aux.Stringid(id,0),nil,LOCATION_HAND,true,
		s.spcon,nil,function(e,tp) aux.CirgonLock(e:GetHandler(),tp) end
	)
	-- Add 1 "Cirgon" Spell/Trap/Increase its Level by 1
	c:SummonedTrigger
	(
		false,false,true,false,nil,nil,
		true,nil,nil,s.effcost,s.efftg,s.effop
	)
end
s.listed_names={id}
s.listed_series={SET_CIRGON,SET_C_CIRGON}
function s.cfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:IsSetCard(SET_CIRGON)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	local cirgoncount=g:FilterCount(s.cfilter,nil)
	return aux.CirgonRestrictionCheck(tp) and cirgoncount>0 and cirgoncount==#g
end
function s.tbfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_C_CIRGON)
		and c:IsReleasable()
		and not c:IsCode(id)
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_CIRGON) and c:IsAbleToHand()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.CirgonRestrictionCheck(tp) end
	aux.CirgonLock(e:GetHandler(),tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tbfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=true
	if chk==0 then return (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b1 and b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op~=2 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.tbfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.Sendto(g,LOCATION_GRAVE,REASON_RELEASE|REASON_COST)
	end
	if op~=1 then
		e:SetCategory(CATEGORY_LVCHANGE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	local raf=c:IsRelateToEffect(e) and c:IsFaceup()
	if op~=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			Duel.Search(tc,tp)
		end
	end
	if raf and op~=1 then
		c:UpdateLV(1)
	end
end
		
