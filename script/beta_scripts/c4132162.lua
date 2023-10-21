-- Shudi, Faded Cirgon Core
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Cannot Remove
	aux.CannotbeRemoved(c,LOCATION_GRAVE)
	-- Global Check
	aux.CirgonGlobalCheck(s,c)
	-- Special Summon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcond)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptarg)
	e1:SetOperation(s.spoper)
	c:RegisterEffect(e1)
	-- Excavate 5
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtarg)
	e2:SetOperation(s.thoper)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_CIRGON}
-- e1 Effect Code
function s.spcfilter(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.cfilter(c,tp)
	return c:GetSequence()<5 and c:IsControler(tp) and c:IsFaceup()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g,exg=Duel.GetReleaseGroup(tp):Split(aux.ReleaseCostFilter,nil,tp)
	if chk==0 then return #g>0 and g:FilterCount(s.cfilter,nil,tp)+Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,3935780)==0 end
	if #(exg-g)>0 then
		g=g+(exg-g)
	end
	-- Cirgon lock
	aux.CirgonLock(c,tp)
	Duel.Release(g,REASON_COST)
end
function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- e2 Effect Code
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,3935780)==0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	g:KeepAlive()
	e:SetLabelObject(g)
	-- Cirgon lock
	aux.CirgonLock(c,tp)
end
function s.thtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.filter1(c)
	return c:IsMonster() and c:IsSetCard(SET_CIRGON) and c:IsAbleToHand()
end
function s.thoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	local tc=g:FilterSelect(tp,s.filter1,1,1,nil):GetFirst()
	g:RemoveCard(tc)
	Duel.DisableShuffleCheck()
	if tc then
		b1=true
		b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,c)
		local opt=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)}, -- Add it to your Hand
		{b2,aux.Stringid(id,3)}) -- Special Summon it
		if opt==1 then
			Duel.Search(tc,tp)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local tb=g:Filter(s.tbfil,nil)
	g:RemoveCard(tb)
	if #tb>0 then 
		Duel.SendtoGrave(tb,REASON_COST+REASON_RELEASE)
	end
	if #g>0 then Duel.ShuffleDeck(tp) end
end
function s.tbfil(c)
	return c:IsMonster() and c:IsReleasableByEffect()
end