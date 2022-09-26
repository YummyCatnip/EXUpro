--Vuluti Potion-Brawler
local s,id,o=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,2,2,nil,nil,99,nil,false,s.xyzcheck)
	--Gamble Effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_REMOVE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
--Xyz Code
function s.xyzfilter(c,xyz,tp)
	return c:IsSetCard(0xc94,xyz,SUMMON_TYPE_XYZ,tp)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:IsExists(s.xyzfilter,1,nil,xyz,tp)
end
--e1 Effect Code
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d1=0
	local d2=0
	d1,d2=Duel.TossDice(tp,1,1)
	if d1==1 or d1==2 then
		Duel.Recover(tp,1000,REASON_EFFECT)
	elseif d1==3 or d1==4 then
			if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)==0 then return end
			local g=Duel.GetDecktopGroup(1-tp,3)
			if #g>0 then
				Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
			end
	elseif d1==5 or d1==6 then
		Duel.Damage(1-tp,750,REASON_EFFECT)
	end
	if d2==1 or d2==2 then
		Duel.Recover(tp,1000,REASON_EFFECT)
	elseif d2==3 or d2==4 then
			if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)==0 then return end
			local g=Duel.GetDecktopGroup(1-tp,3)
			if #g>0 then
				Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
			end
	elseif d2==5 or d2==6 then
		Duel.Damage(1-tp,750,REASON_EFFECT)
	end
end