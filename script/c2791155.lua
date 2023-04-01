-- Naturia Viper
local s,id=GetID()
function s.initial_effect(c)
	-- pendulum summon
	Pendulum.AddProcedure(c)
	-- Send 1 to GY deal 300 damage per "Naturia"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.dmgcost)
	e1:SetTarget(s.dmgtarg)
	e1:SetOperation(s.dmgoper)
	c:RegisterEffect(e1)
	-- Special Summon from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	-- from face-up Extra Deck
	local e3=e2:Clone()
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.espcon)
	c:RegisterEffect(e3)
	-- Recover
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.thtarg)
	e4:SetOperation(s.thoper)
	c:RegisterEffect(e4)
end
s.listed_series={0x2a}
-- e1 Effect Code
function s.dmgfil(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
function s.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
end
function s.dmgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.dmgfil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct~=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.dmgoper(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
-- e2 Effect Code
function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),Card.IsSetCard,1,false,1,true,c,c:GetControler(),nil,false,nil,SET_NATURIA)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,false,true,true,c,nil,nil,false,nil,SET_NATURIA)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
-- e3 Effect Code
function s.espcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.CheckReleaseGroup(c:GetControler(),Card.IsSetCard,1,false,1,true,c,c:GetControler(),nil,false,nil,SET_NATURIA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- e4 Effect Code
function s.thfilter(c)
	return c:IsSetCard(SET_NATURIA) and c:IsAbleToHand()
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c) and not c:IsForbidden() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,g)
			Duel.SendtoExtraP(c,tp,REASON_EFFECT)
		end
	end
end