-- Ideal, Chaotic Technique Dragon Caller
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.ffilter1,s.ffilter2,s.ffilter3)
	--atk limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	-- Banish 1 card to apply effect
	-- Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rvcond)
	e2:SetTarget(s.rmtarg)
	e2:SetOperation(s.rmoper)
	c:RegisterEffect(e2)
	-- Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.rvcond)
	e3:SetTarget(s.rstarg)
	e3:SetOperation(s.rsoper)
	c:RegisterEffect(e3)
	-- Trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.rvcond)
	e4:SetTarget(s.rttarg)
	e4:SetOperation(s.rtoper)
	c:RegisterEffect(e4)
end
-- Fusion Code
function s.ffilter1(c,fc,sumtype,tp,sub,mg,sg)
	return not c:IsNonEffectMonster() and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.ffilter2(c,fc,sumtype,tp,sub,mg,sg)
	return not c:IsNonEffectMonster() and c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.ffilter3(c,fc,sumtype,tp,sub,mg,sg)
	return not c:IsNonEffectMonster() and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,tp)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) and not c:IsHasEffect(511002961)
end
-- e1 Effect Code
function s.atkfil(c)
	return c:IsST() and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end
function s.atkcon(e)
	return not Duel.IsExistingMatchingCard(s.atkfil,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- e2 Effect Code
function s.rvcond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.rmfil(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.rmtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.rmoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g<=0 then return end
	local sg=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local tc=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- e3 Effect Code
function s.rsfil(c)
	return c:IsSpell() and c:IsAbleToRemove()
end
function s.rstarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rsfil,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
end
function s.rsoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if #g<=0 then return end
	local sg=Duel.Select(HINTMSG_REMOVE,false,tp,s.rsfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local tc=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- e4 Effect Code
function s.rtfil(c)
	return c:IsTrap() and c:IsAbleToRemove()
end
function s.rttarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(1-tp,3)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfil,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) and rg:FilterCount(Card.IsAbleToRemove,nil)==3 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,0,0)
end
function s.rtoper(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if #g<=0 then return end
	local sg=Duel.Select(HINTMSG_REMOVE,false,tp,s.rtfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end