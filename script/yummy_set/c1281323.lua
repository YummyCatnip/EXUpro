-- Muto, Toxic Duo Kaiju
local s,id=GetID()
function s.initial_effect(c)
	local e1,e2=aux.AddKaijuProcedure(c)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.dmgcost)
	e3:SetTarget(s.dmgtarg)
	e3:SetOperation(s.dmgoper)
	c:RegisterEffect(e3)
end
s.listed_series={0xd3}
-- e3 Effect Code
function s.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x37,1,REASON_COST)
end
function s.dmgtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.dmgfilter(c)
	return c:IsSetCard(0xd3) and c:IsFaceup()
end
function s.dmgoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.GetMatchingGroup(s.dmgfilter,tp,LOCATION_MZONE,0,nil)
	if #g>1 then g=g:Select(tp,1,1,nil) end
	local tc=g:GetFirst()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end