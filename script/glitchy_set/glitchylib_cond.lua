--CONDITIONS
-----------------------------------------------------------------------

--Event Group (eg) Check Condition
function Auxiliary.EventGroupCond(f,min,max,exc)
	if not min then min=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				return eg:IsExists(f,min,exc,e,tp,eg,ep,ev,re,r,rp) and (not max or not eg:IsExists(f,max,exc,e,tp,eg,ep,ev,re,r,rp))
			end
end
function Auxiliary.ExactEventGroupCond(f,ct,exc)
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				return eg:FilterCount(f,exc,e,tp,eg,ep,ev,re,r,rp)==ct
			end
end

--Turn/Phase Conditions
function Auxiliary.DrawPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsDrawPhase(tp)
			end
end
function Auxiliary.StandbyPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsStandbyPhase(tp)
			end
end
function Auxiliary.MainPhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsMainPhase(tp,ct)
			end
end
function Auxiliary.BattlePhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsBattlePhase(tp)
			end
end
function Auxiliary.MainOrBattlePhaseCond(tp,ct)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsMainPhase(tp,ct) or Duel.IsBattlePhase(tp)
			end
end
function Auxiliary.EndPhaseCond(tp)
	return	function(e,p)
				local tp = (tp==0) and p or (tp==1) and 1-p or nil
				return Duel.IsEndPhase(tp)
			end
end
function Auxiliary.ExceptOnDamageCalc()
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function Auxiliary.TurnPlayerCond(tp)
	return	function(e,p)
				local tp = (not tp or tp==0) and p or 1-p
				return Duel.GetTurnPlayer()==tp
			end
end

--Location Group Check Conditions
function Auxiliary.LocationGroupCond(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not min then min=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then
					tp=e:GetHandlerPlayer()
				end
				local exc=(not exc) and nil or e:GetHandler()
				local ct=Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
				return ct>=min and (not max or ct<=max)
			end
end
function Auxiliary.ExactLocationGroupCond(f,loc1,loc2,ct0,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then
					tp=e:GetHandlerPlayer()
				end
				local exc=(not exc) and nil or e:GetHandler()
				local ct=Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
				return ct==ct0
			end
end
function Auxiliary.CompareLocationGroupCond(res,f,loc,exc)
	if not f then f=aux.TRUE end
	if not loc then loc=LOCATION_MZONE end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then
					tp=e:GetHandlerPlayer()
				end
				local res = (res and res==1) and 1-tp or tp
				local exc = exc and exc or e:GetHandler()
				local ct1=Duel.GetMatchingGroupCount(f,tp,loc,0,exc,e,tp,eg,ep,ev,re,r,rp)
				local ct2=Duel.GetMatchingGroupCount(f,tp,0,loc,exc,e,tp,eg,ep,ev,re,r,rp)
				local winner
				if ct1>ct2 then
					winner=tp
				elseif ct1<ct2 then
					winner=1-tp
				else
					winner=PLAYER_NONE
				end
				return res==winner
			end
end

--When this card is X Summoned
function Auxiliary.FusionSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function Auxiliary.SynchroSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Auxiliary.XyzSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function Auxiliary.PendulumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Auxiliary.LinkSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function Auxiliary.PandemoniumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PANDEMONIUM)
end
function Auxiliary.BigbangSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function Auxiliary.TimeleapSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function Auxiliary.DriveSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE)
end
function Auxiliary.ProcSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

--Equip
function Auxiliary.IsEquippedCond(e)
	return e:GetHandler():GetEquipTarget()
end

--Reason and Reason Player
function Auxiliary.ByCardEffectCond(p,typ)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local p = (p==0) and tp or (p==1) and 1-tp or nil
				return c:IsReason(REASON_EFFECT) and (not p or rp==p)
					and (not typ or (re and re:IsActiveType(typ)))
			end
end
function Auxiliary.ByCardEffect(p,typ)
	return aux.ByCardEffectCond(p,typ)
end

function Auxiliary.ByPlayerCardCond(p)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local p = (not p or p==1) and 1-tp or (p==0) and tp
				return rp==p and c:IsPreviousControler(tp)
			end
end

--Xyz Related
function Auxiliary.HasXyzMaterialCond(e)
	return e:GetHandler():GetOverlayCount()>0
end

--Link Related
function Auxiliary.ThisCardPointsToCond(f,min)
	if not f then f=aux.TRUE end
	return	function(e)
				local tp=e:GetHandlerPlayer()
				return e:GetHandler():GetLinkedGroup():IsExists(f,min,nil,e,tp)
			end
end

-----------------------------------------------------------------------
--Summon Conditions
function Card.MustFirstBeSummoned(c,sumtype,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e:SetCode(EFFECT_SPSUMMON_CONDITION)
	e:SetValue(	function(eff,se,sp,st)
					return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sumtype and st&sumtype==sumtype)
				end
			  )
	c:RegisterEffect(e)
	return e
end
function Card.MustBeSSedByOwnProcedure(c,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e)
end