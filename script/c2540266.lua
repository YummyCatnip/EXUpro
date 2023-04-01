--Mudafi Masterpiece - Jadida
local s,id,o=GetID()
function s.initial_effect(c)
	--Synchro Procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Card from hand as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_IGNORE_RANGE)
  e1:SetCode(EFFECT_HAND_SYNCHRO)
  e1:SetRange(LOCATION_EXTRA)
  e1:SetLabel(id)
  e1:SetValue(s.synval)
  c:RegisterEffect(e1)
	--return materials from field to hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetCondition(function() return not Duel.IsBattlePhase() end)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--cannot remove
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function() return not Duel.IsBattlePhase() end)
	c:RegisterEffect(e4)
	--Special Summon 1 from GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operat)
	c:RegisterEffect(e5)
end
s.listed_series={0xc88}
--e1 Effect code
function s.synval(e,c,sc)
    if c:IsLocation(LOCATION_HAND) and c:IsSetCard(0xc88) and sc==e:GetHandler() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
        e1:SetLabel(id)
        e1:SetTarget(s.synchktg)
        c:RegisterEffect(e1)
        return true
    else return false end
end
function s.chk(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
    local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
    for i=1,#te do
        local e=te[i]
        if e:GetLabel()~=id then return false end
    end
    return true
end
function s.chk2(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
    local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i=1,#te do
        local e=te[i]
        if e:GetLabel()==id then return true end
    end
    return false
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
    if c then
        local res=true
        if sg:IsExists(s.chk,1,c) or (not tg:IsExists(s.chk2,1,c) and not ntg:IsExists(s.chk2,1,c) 
            and not sg:IsExists(s.chk2,1,c)) then return false end
        local trg=tg:Filter(s.chk,nil)
        local ntrg=ntg:Filter(s.chk,nil)
        return res,trg,ntrg
    else
        return true
    end
end
--e2 Effect Code
function s.gfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsAbleToHand() and c:IsSetCard(0xc88)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local sg=g:Filter(s.gfilter,nil)
	if #sg>0 then
		for tc in sg:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_HAND)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
--e5 Effect Code
function s.filter(c,e,tp)
	return c:IsSetCard(0xc88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsLevelBelow(6)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.operat(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
			local lv=tc:GetLevel()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(-lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end