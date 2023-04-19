-- Pink Shoes
local s,id,o=GetID()
Duel.LoadScript("glitchylib.lua")
Duel.LoadScript("yummylib.lua")
function s.initial_effect(c)
	-- Cannot be used as Fusion, Synchro, Xyz material or Tributed if you don't own this SSummoned card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1:SetCondition(s.limitcon)
	e1:SetValue(s.matlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3304)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCondition(s.limitcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- If used for a Link Summon, except "Aberration-", the opponent of the player who controlled this card draws 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.drcond)
	e3:SetTarget(s.drtarg)
	e3:SetOperation(s.droper)
	c:RegisterEffect(e3)
	-- Change Level if you own this SSummoned card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_LVCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.lvcond)
	e4:SetTarget(s.lvtarg)
	e4:SetOperation(s.lvoper)
	c:RegisterEffect(e4)
	-- SS "Aberration-Love Token" if you own this SSummoned card, then you can Link Summon "Abe-214"
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORIES_TOKEN)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.tkcond)
	e5:SetTarget(s.tktarg)
	e5:SetOperation(s.tkoper)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_ABE_214,3876554}
s.listed_series={SET_ABERRATION}
-- e2 Effect Code
function s.limitcon(e)
	return e:GetHandler():GetControler()~=e:GetHandler():GetOwner()
end
function s.matlimit(e,c)
	if not c then return false end
	return c:IsSummonType(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ)
end
-- e3 Effect Code
function s.drcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return not rc:IsSetCard(SET_ABERRATION) and r==REASON_LINK
end
function s.drtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local po=e:GetHandler():GetPreviousControler()
	local dp=0
	if po==tp then
		dp=1-tp
	elseif po==1-tp then
		dp=tp
	end
	Duel.SetTargetPlayer(dp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,dp,1)
end
function s.droper(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
-- e4 Effect Code
function s.lvcond(e)
	return e:GetHandler():GetControler()==e:GetHandler():GetOwner() and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.lvtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.AnnounceNumberRange(tp,1,3)
	e:SetLabel(g)
end
function s.lvoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- e5 Effect Code
function s.tkcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetControler()==e:GetHandler():GetOwner() and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,3876554),tp,LOCATION_MZONE,0,1,nil)
end
function s.tktarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_ABERRATION,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORIES_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.abefil(c)
	return c:IsCode(CARD_ABE_214) and c:IsLinkSummonable()
end
function s.tkoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.abefil,tp,LOCATION_EXTRA,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,id+1)
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
			local g=Duel.GetMatchingGroup(s.abefil,tp,LOCATION_EXTRA,0,nil,e,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:Select(tp,1,1,nil)
				Duel.LinkSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
end