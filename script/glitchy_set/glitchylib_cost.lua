--COSTS
function Auxiliary.CreateCost(...)
	local x={...}
	if #x==0 then return end
	local f	=	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						for _,cost in ipairs(x) do
							if not cost(e,tp,eg,ep,ev,re,r,rp,chk) then
								return false
							end
						end
						return true
					end
					for _,cost in ipairs(x) do
						cost(e,tp,eg,ep,ev,re,r,rp,chk)
					end
				end
	return f
end

-----------------------------------------------------------------------
function Auxiliary.InfoCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function Auxiliary.LabelCost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function Auxiliary.CustomLabelCost(lab)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				e:SetLabel(lab)
				if chk==0 then return true end
			end
end

--Card Action Costs
function Auxiliary.DiscardCost(f,min,max,exc)
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.DiscardFilter(f,true),tp,LOCATION_HAND,0,min,exc) end
				Duel.DiscardHand(tp,aux.DiscardFilter(f,true),min,max,REASON_COST+REASON_DISCARD,exc)
			end
end
function Auxiliary.BanishCost(f,loc1,loc2,min,max,exc)
	local spelimfilter=false
	local mustbefaceup=false
	local includemzone=false
	
	if not loc1
		then loc1=LOCATION_ONFIELD
	elseif loc1&LOCATION_GRAVE>0 then
		spelimfilter=true
		if loc1&LOCATION_MZONE==0 then
			loc1=loc1|LOCATION_MZONE
		else
			includemzone=true
		end
	end
	if not loc2 then
		loc2=0
	elseif loc2&LOCATION_GRAVE>0 then
		if not spelimfilter then spelimfilter=true end
		if loc2&LOCATION_MZONE==0 then
			loc2=loc2|LOCATION_MZONE
		elseif not includemzone then
			includemzone=true
		end
	end
	if not f or f==Card.IsMonster then
		mustbefaceup=true
	end
	
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.BanishFilter(f,true,spelimfilter,mustbefaceup,includemzone),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local g=Duel.SelectMatchingCard(tp,aux.BanishFilter(f,true,spelimfilter,mustbefaceup,includemzone),tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
				if #g>0 then
					local ct=Duel.Remove(g,POS_FACEUP,REASON_COST)
					return g,ct
				end
				return g,0
			end
end
function Auxiliary.ToGraveCost(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.ToGraveFilter(f,true),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,aux.ToGraveFilter(f,true),tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
				if #g>0 then
					local ct=Duel.SendtoGrave(g,REASON_COST)
					return g,ct
				end
				return g,0
			end
end
function Auxiliary.ToHandCost(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.ToHandFilter(f,true),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
				local g=Duel.SelectMatchingCard(tp,aux.ToHandFilter(f,true),tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
				if #g>0 then
					Duel.HintSelection(g)
					local ct=Duel.SendtoHand(g,nil,REASON_COST)
					return g,ct
				end
				return g,0
			end
end
function Auxiliary.ToDeckCost(f,loc1,loc2,min,max,exc,main_or_extra)
	f=aux.ToDeckFilter(f,true,main_or_extra)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
				if #g>0 then
					local hg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
					if #hg>0 then
						Duel.HintSelection(hg)
					end
					local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
					return g,ct
				end
				return g,0
			end
end
function Auxiliary.TributeCost(f,min,max,exc)
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.CheckReleaseGroupCost(tp,f,min,max,false,nil,exc,e,tp,eg,ep,ev,re,r,rp) end
				local rg=Duel.SelectReleaseGroupCost(tp,f,min,max,false,nil,exc,e,tp,eg,ep,ev,re,r,rp)
				if #rg>0 then
					local ct=Duel.Release(rg,REASON_COST)
					return rg,ct
				end
				return g,0
			end
end
-----------------------------------------------------------------------
--Self as Cost
function Auxiliary.BanishFacedownSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost(POS_FACEDOWN) end
	Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_COST)
end
function Auxiliary.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function Auxiliary.DetachSelfCost(min,max)
	SCRIPT_REGISTER_FLAG = REGISTER_FLAG_DETACH_MAT
	if not min then min=1 end
	if not max or max<min then max=min end
	
	if min==max then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,min,REASON_COST) end
					e:GetHandler():RemoveOverlayCard(tp,min,min,REASON_COST)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then
						for i=min,max do
							if c:CheckRemoveOverlayCard(tp,i,REASON_COST) then
								return true
							end
						end
						return false
					end
					local list={}
					for i=min,max do
						if c:CheckRemoveOverlayCard(tp,i,REASON_COST) then
							table.insert(list,i)
						end
					end
					if #list==0 then return end
					if #list==max-min then
						c:RemoveOverlayCard(tp,min,max,REASON_COST)
					else
						local ct=Duel.AnnounceNumber(tp,table.unpack(list))
						c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
					end
				end
	end
end
function Auxiliary.RemoveCounterSelfCost(ctype,min,max)
	if not min then min=1 end
	if not max or max<min then max=min end
	
	if min==max then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then return c:IsCanRemoveCounter(tp,ctype,min,REASON_COST) end
					c:RemoveCounter(tp,ctype,min,REASON_COST)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then
						for i=min,max do
							if c:IsCanRemoveCounter(tp,ctype,i,REASON_COST) then
								return true
							end
						end
						return false
					end
					local list={}
					for i=min,max do
						if c:IsCanRemoveCounter(tp,ctype,i,REASON_COST) then
							table.insert(list,i)
						end
					end
					if #list==0 then return end
					local ct=Duel.AnnounceNumber(tp,table.unpack(list))
					c:RemoveCounter(tp,ctype,ct,REASON_COST)
				end
	end
end
function Auxiliary.ToDeckSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Auxiliary.ToExtraSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Auxiliary.ToGraveSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function Auxiliary.TributeSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function Auxiliary.TributeForSummonFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone)
	local reason
	if sumtype==SUMMON_TYPE_FUSION then
		reason = REASON_FUSION
	elseif sumtype==SUMMON_TYPE_SYNCHRO then
		reason = REASON_SYNCHRO
	elseif sumtype==SUMMON_TYPE_XYZ then
		reason = REASON_XYZ
	elseif sumtype==SUMMON_TYPE_LINK then
		reason = REASON_LINK
	end
	if reason then
		return	function(c,e,tp,...)
					local pg=aux.GetMustBeMaterialGroup(sump,Group.CreateGroup(),sump,c,nil,reason)
					return #pg<=0 and (not f or f(c,e,tp,...)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone)
						and ((not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>0)
						or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(recp,sump,e:GetHandler(),c,zone)>0))
				end
	else
		return	function(c,e,tp,...)
					return (not f or f(c,e,tp,...)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone)
						and ((not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>0)
						or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(recp,sump,e:GetHandler(),c,zone)>0))
				end
	end
end
function Auxiliary.TributeForSummonSelfCost(f,loc1,loc2,sumtype,sump,ign1,ign2,pos,recp,zone)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				e:SetLabel(1)
				if chk==0 then
					return e:GetHandler():IsReleasable() and Duel.IsExistingMatchingCard(aux.TributeForSummonFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,1,nil,e,tp,eg,ep,ev,re,r,rp)
				end
				Duel.Release(e:GetHandler(),REASON_COST)
			end
end

-----------------------------------------------------------------------
--LP Payment Costs
function Auxiliary.PayLPCost(lp)
	if not lp then lp=1000 end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.CheckLPCost(tp,lp) end
				Duel.PayLPCost(tp,lp)
			end
end

-----------------------------------------------------------------------
--Restrictions (Limits)
function Auxiliary.AttackRestrictionCost(oath,reset,desc)
	local prop=EFFECT_FLAG_CANNOT_DISABLE
	if oath then prop=prop|EFFECT_FLAG_OATH end
	if desc then prop=prop|EFFECT_FLAG_CLIENT_HINT end
	if not reset then reset=RESET_PHASE+PHASE_END end
	
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:GetAttackAnnouncedCount()==0 end
				local e1=Effect.CreateEffect(c)
				if desc then e1:Desc(desc) end
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(prop)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
				c:RegisterEffect(e1)
			end
end
function Auxiliary.SSRestrictionCost(f,oath,reset,id,cf,desc)
	if id then
		if not cf then
			aux.AddSSCounter(id,f)
			Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,f)
		else
			aux.AddSSCounter(id,cf)
			Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cf)
		end
	end
	local prop=EFFECT_FLAG_PLAYER_TARGET
	if oath then prop=prop|EFFECT_FLAG_OATH end
	if desc then prop=prop|EFFECT_FLAG_CLIENT_HINT end
	if not reset then reset=RESET_PHASE+PHASE_END end
	
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
				local e1=Effect.CreateEffect(e:GetHandler())
				if desc then e1:Desc(desc) end
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(prop)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetReset(reset)
				e1:SetTargetRange(1,0)
				e1:SetTarget(	function(eff,c,sump,sumtype,sumpos,targetp,se)
									return not f(c,eff,sump,sumtype,sumpos,targetp,se)
								end
							)
				Duel.RegisterEffect(e1,tp)
			end
end

function Auxiliary.AddActivationCounter(id,f)
	return Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,f)
end
function Auxiliary.AddSSCounter(id,f)
	return Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,f)
end

--old names
function Auxiliary.SSLimit(f,desc,oath,reset,id,cf)
	return Auxiliary.SSRestrictionCost(f,oath,reset,id,cf,desc)
end