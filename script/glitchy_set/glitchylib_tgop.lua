GFILTER_TABLE = {aux.dncheck}
GFILTER_DIFFERENT_NAMES = 1

ACTION_TABLE = {[CATEGORY_DESTROY]=function(g) Duel.Destroy(g,REASON_EFFECT) end}

CONJUNCTION_AND_IF_YOU_DO				=	0x1
CONJUNCTION_THEN						=	0x2
CONJUNCTION_ALSO						=	0x4
CONJUNCTION_ALSO_AFTER_THAT				=	0x8
CONJUNCTION_AND_IF_YOU_DO_YOU_CAN		=	0x1001
CONJUNCTION_THEN_YOU_CAN				=	0x1002
CONJUNCTION_ALSO_YOU_CAN				=	0x1004
CONJUNCTION_ALSO_AFTER_THAT_YOU_CAN		=	0x1008

--Complex Operation Builder
function Auxiliary.CreateOperation(...)
	local x={...}
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local res,rct,rchk
				for i,op in ipairs(x) do
					if type(op)=="function" then
						local conj = (i>2 and type(x[i-1])=="number") and x[i-1] or nil
						-- Debug.Message(conj)
						-- Debug.Message(res)
						-- Debug.Message(rct)
						-- Debug.Message(rchk)
						if i>2 and (conj==CONJUNCTION_AND_IF_YOU_DO or conj==CONJUNCTION_THEN)
							and ((type(rchk)~="nil" and not rchk) or (type(rct)=="nil" and type(rchk)=="nil" and not res)) then
							return
						end
						res,rct,rchk=op(e,tp,eg,ep,ev,re,r,rp,conj)
					end
				end
			end
end
function Auxiliary.CheckSequentiality(conj)
	if conj and (conj&CONJUNCTION_THEN==CONJUNCTION_THEN or conj&CONJUNCTION_ALSO_AFTER_THAT==CONJUNCTION_ALSO_AFTER_THAT) then
		Duel.BreakEffect()
	end
end

--Target/Operation functions and filters
--Simple Target
function Auxiliary.Check(check,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return (not check or check(e,tp,eg,ep,ev,re,r,rp)) end
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.CostCheck(check,cost,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if e:GetLabel()~=1 then return false end
					e:SetLabel(0)
					return not check or check(e,tp,eg,ep,ev,re,r,rp)
				end
				e:SetLabel(0)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp)
				end
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.LabelCheck(labelcheck,check,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local l=e:GetLabel()
					local lchk = (l==1) or labelcheck(e,tp,eg,ep,ev,re,r,rp)
					e:SetLabel(0)
					return lchk and (not check or check(e,tp,eg,ep,ev,re,r,rp))
				end
				e:SetLabel(0)
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.Target(f,loc1,loc2,min,max,exc,check,info,prechk,necrovalley,...)
	local x={...}
	if not f then f=aux.TRUE end
	if not min then min=1 end
	if not max then max=min end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&LOCATION_GRAVE>0 and necrovalley then
		f=aux.NecroValleyFilter(f)
	end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local exc= (type(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				if chkc then
					local plchk=((loc1~=0 and loc2==0 and chkc:IsControler(tp) and chkc:IsLocation(loc1)) or (loc2~=0 and loc1==0 and chkc:IsControler(1-tp) and chkc:IsLocation(loc2)))
					return plchk and (not f or f(chkc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				if chk==0 then
					if prechk then prechk(e,tp,eg,ep,ev,re,r,rp) end
					return ((not check or check(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExistingTarget(f,tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
				local g=Duel.SelectTarget(tp,f,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp,chk)
				if info then
					if type(info)=="function" then
						info(g,e,tp,eg,ep,ev,re,r,rp)
					elseif type(info)=="table" then
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetCustomOperationInfo(0,info[1],g,#g,p,locs,info[2])
					else
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetOperationInfo(0,info,g,#g,p,locs)
					end
				end
				if #x>0 then
				
					for _,extrainfo in ipairs(x) do
						if type(extrainfo)=="function" then
							extrainfo(g,e,tp,eg,ep,ev,re,r,rp)
						elseif type(extrainfo)=="table" then
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetCustomOperationInfo(0,extrainfo[1],g,#g,p,locs,extrainfo[2])
						else
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetOperationInfo(0,extrainfo,g,#g,p,locs)
						end
					end
				end
				return g
			end
end
function Auxiliary.TargetUpToTheNumberOfCards(f,loc1,loc2,min,exc,gf,gloc1,gloc2,gexc,check,info,prechk,necrovalley,...)
	local x={...}
	if not f then f=aux.TRUE end
	if not min then min=1 end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&LOCATION_GRAVE>0 and necrovalley then
		f=aux.NecroValleyFilter(f)
	end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local exc= (type(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				if chkc then
					local plchk=((loc1~=0 and loc2==0 and chkc:IsControler(tp) and chkc:IsLocation(loc1)) or (loc2~=0 and loc1==0 and chkc:IsControler(1-tp) and chkc:IsLocation(loc2)))
					return plchk and (not f or f(chkc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				local sg=Duel.Group(gf,tp,gloc1,gloc2,gexc,e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if prechk then prechk(e,tp,eg,ep,ev,re,r,rp) end
					return (not check or check(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExistingTarget(f,tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp,chk)
						and #sg>=min
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
				local g=Duel.SelectTarget(tp,f,tp,loc1,loc2,min,#sg,exc,e,tp,eg,ep,ev,re,r,rp,chk)
				if info then
					if type(info)=="function" then
						info(g,e,tp,eg,ep,ev,re,r,rp)
					elseif type(info)=="table" then
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetCustomOperationInfo(0,info[1],g,#g,p,locs,info[2])
					else
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetOperationInfo(0,info,g,#g,p,locs)
					end
				end
				if #x>0 then
				
					for _,extrainfo in ipairs(x) do
						if type(extrainfo)=="function" then
							extrainfo(g,e,tp,eg,ep,ev,re,r,rp)
						elseif type(extrainfo)=="table" then
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetCustomOperationInfo(0,extrainfo[1],g,#g,p,locs,extrainfo[2])
						else
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetOperationInfo(0,extrainfo,g,#g,p,locs)
						end
					end
				end
				return g
			end
end

function Auxiliary.TargetOperation(op,f,hardchk,prechk,postchk)
	if type(op)=="number" then
		op=ACTION_TABLE[op]
	end
	if not hardchk then
		if type(f)=="function" then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if prechk and not prechk(e,tp,eg,ep,ev,re,r,rp) then return end
						local g=Duel.GetTargetCards():Filter(f,nil,e,tp,eg,ep,ev,re,r,rp)
						if #g>0 and (not postchk or postchk(g,e,tp,eg,ep,ev,re,r,rp)) then
							aux.CheckSequentiality(conj)
							local res,ct,chk=op(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,(ct>0 and chk)
						end
						return g,0,false
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if prechk and not prechk(e,tp,eg,ep,ev,re,r,rp) then return end
						local g=Duel.GetTargetCards()
						if #g>0 and (not postchk or postchk(g,e,tp,eg,ep,ev,re,r,rp)) then
							aux.CheckSequentiality(conj)
							local res,ct,chk=op(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,(ct>0 and chk)
						end
						return g,0,false
					end
		end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if prechk and not prechk(e,tp,eg,ep,ev,re,r,rp) then return end
						local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
						for tc in aux.Next(g) do
							if not tc:IsRelateToChain() or (f and not f(tc,e,tp,eg,ep,ev,re,r,rp)) then
								return
							end
						end	
						if #g>0 and (not postchk or postchk(g,e,tp,eg,ep,ev,re,r,rp)) then
							aux.CheckSequentiality(conj)
							local res,ct,chk=op(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,(ct==#g and chk)
						end
						return g,0,false
					end
	end
end

-----------------------------------------------------------------------
--Infos
function Auxiliary.Info(ctg,ct,p,v)
	return	function(_,e,tp)
				local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
				return Duel.SetOperationInfo(0,ctg,nil,ct,p,v)
			end
end
function Auxiliary.DamageInfo(p,v)
	return	function(_,e,tp)
				return Auxiliary.Info(CATEGORY_DAMAGE,0,p,v)
			end
end
function Auxiliary.DrawInfo(p,v)
	return	function(_,e,tp)
				return Auxiliary.Info(CATEGORY_DRAW,0,p,v)
			end
end
function Auxiliary.MillInfo(p,v)
	return	function(_,e,tp)
				return Auxiliary.Info(CATEGORY_DECKDES,0,p,v)
			end
end
function Auxiliary.RecoverInfo(p,v)
	return	function(_,e,tp)
				return Auxiliary.Info(CATEGORY_RECOVER,0,p,v)
			end
end

function Auxiliary.HandlerInfo(ctg,custom)
	if not custom then
		return	function(_,e,tp)
					local c=e:GetHandler()
					return Duel.SetOperationInfo(0,ctg,c,1,c:GetControler(),c:GetLocation())
				end
	else
		return	function(_,e,tp)
					local c=e:GetHandler()
					return Duel.SetCustomOperationInfo(0,ctg,c,1,c:GetControler(),c:GetLocation(),custom)
				end
	end
end
function Auxiliary.GroupInfo(ctg)
	return	function(g)
				return Duel.SetOperationInfo(0,ctg,g,#g,0,0)
			end
end
function Auxiliary.SelfInfo(ctg)
	return	function(_,e)
				return Duel.SetOperationInfo(0,ctg,e:GetHandler(),1,0,0)
			end
end

-----------------------------------------------------------------------
function Auxiliary.CardMovementOperationTemplate(fn,action_filter,loc,subject,loc1,loc2,min,max,exc,...)
	if type(subject)=="function" or type(subject)=="nil" then
		if action_filter then
			subject=action_filter(subject)
		end
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		if (loc1|loc2)&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
							Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED),true)
						end
						local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
						return g,ct,(ct>0 and aux.PLChk(g,nil,loc))
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local ct=fn(c,e,tp,eg,ep,ev,re,r,rp)
						return c,1,(ct>0 and aux.PLChk(c,nil,loc))
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g,e,tp,eg,ep,ev,re,r,rp)
							local chk=0
							local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,(ct>0 and aux.PLChk(g,nil,loc))
						end
			return aux.TargetOperation(op)
			
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g,e,tp,eg,ep,ev,re,r,rp)
							local chk=0
							local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,aux.PLChk(g,nil,loc)
						end
			return aux.TargetOperation(op,nil,hardchk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if action_filter then truesub=action_filter(truesub) end
			if not min then min=1 end
			if not max then max=min end
			if (loc1|loc2)&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							if sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
								Duel.HintSelection(sg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED),true)
							end
							local ct=fn(sg,e,tp,eg,ep,ev,re,r,rp)
							return sg,ct,(ct>0 and aux.PLChk(sg,nil,loc))
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g,e,tp,eg,ep,ev,re,r,rp)
							local chk=0
							local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,aux.PLChk(g,nil,loc,ct)
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end
function Auxiliary.CardsInteractionOperationTemplate(fn,action_filter,subject,loc1,loc2,min,max,exc,subject2,action_filter2,loc3,loc4,exc2)
	local check,sel
	if type(subject2)=="function" then
		subject2=action_filter2(subject2)
		check=	function(g,e,tp,eg,ep,ev,re,r,rp)
					local excg=type(g)=="Group" and g:Clone() or Group.FromCards(g)
					if exc2 then excg:AddCard(e:GetHandler()) end
					return Duel.IsExistingMatchingCard(subject2,tp,loc3,loc4,1,excg,e,tp,eg,ep,ev,re,r,rp)
				end
		sel=	function(g,e,tp,eg,ep,ev,re,r,rp)
					local excg=type(g)=="Group" and g:Clone() or Group.FromCards(g)
					if exc2 then excg:AddCard(e:GetHandler()) end
					return Duel.SelectMatchingCard(tp,subject2,tp,loc3,loc4,1,1,excg,e,tp,eg,ep,ev,re,r,rp)
				end
	elseif subject2==SUBJECT_THIS_CARD then
		check=	function(g,e)
					local cc=e:GetHandler()
					return not g:IsContains(cc) and cc:IsType(TYPE_XYZ)
				end
		sel=	function(g,e,tp,eg,ep,ev,re,r,rp)
					return Group.FromCards(e:GetHandler())
				end
	else
		check=	function(g,e,tp,eg,ep,ev,re,r,rp)
					local cc=Duel.GetFirstTarget()
					return not g:IsContains(cc) and cc:IsType(TYPE_XYZ)
				end
		sel=	function(g,e,tp,eg,ep,ev,re,r,rp)
					return Group.FromCards(Duel.GetFirstTarget())
				end
	end
	
	if type(subject)=="function" or type(subject)=="nil" then
		subject=action_filter(subject)
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		if (loc1|loc2)&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					local g0=Duel.GetMatchingGroup(subject,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,rp)
					if #g0<min then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=g0:SelectSubGroup(tp,check,false,min,max,e,tp,eg,ep,ev,re,rp)
					if #g>0 then
						if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
							Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED),true)
						end
						local g2=sel(g,e,tp,eg,ep,ev,re,r,rp)
						if #g2>0 then
							aux.CheckSequentiality(conj)
							local ct=fn(g,g2,e,tp,eg,ep,ev,re,r,rp)
							return g1,ct,ct>0,g2
						end
					end
					return g,0,false,g2
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						local g2=sel(c,e,tp,eg,ep,ev,re,r,rp)
						if #g2>0 then
							aux.CheckSequentiality(conj)
							local ct=fn(c,g2,e,tp,eg,ep,ev,re,r,rp)
							return c,ct,ct>0,g2
						end
						return c,0,false,g2
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g,e,tp,eg,ep,ev,re,r,rp)
							local g2=sel(g,e,tp,eg,ep,ev,re,r,rp)
							if #g2>0 then
								aux.CheckSequentiality(conj)
								local ct=fn(g,g2,e,tp,eg,ep,ev,re,r,rp)
								return g,ct,ct>0,g2
							end
							return g,0,false,g2
						end
			return aux.TargetOperation(op)
			
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g,e,tp,eg,ep,ev,re,r,rp)
							local chk=0
							local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,aux.PLChk(g,nil,loc)
						end
			return aux.TargetOperation(op,nil,hardchk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			truesub=action_filter(truesub)
			if not min then min=1 end
			if not max then max=min end
			if (loc1|loc2)&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=function(sg,...) return GFILTER_TABLE[subject[2]](sg,...) and check(sg,...) end
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g0=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g0<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g0:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							if sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
								Duel.HintSelection(sg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED),true)
							end
							local g2=sel(sg,e,tp,eg,ep,ev,re,r,rp)
							if #g2>0 then
								aux.CheckSequentiality(conj)
								local ct=fn(sg,g2,e,tp,eg,ep,ev,re,r,rp)
								return sg,ct,ct>0,g2
							end
						end
						return sg,0,false,g2
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g,e,tp,eg,ep,ev,re,r,rp)
							local g2=sel(g,e,tp,eg,ep,ev,re,r,rp)
							if #g2>0 then
								aux.CheckSequentiality(conj)
								local ct=fn(g,g2,e,tp,eg,ep,ev,re,r,rp)
								return g,ct,ct>0,g2
							end
							return g,0,false,g2
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end

function Auxiliary.NotConfirmed(f)
	return	function(c,...)
				return not c:IsPublic() or (not f or f(c,...))
			end
end

-----------------------------------------------------------------------
--Attach
function Auxiliary.AttachFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
			end
end
function Auxiliary.AttachFilter2(f)
	return	function(c,...)
				return (not f or f(c,e,...)) and c:IsType(TYPE_XYZ)
			end
end
function Auxiliary.AttachTarget(f,loc1,loc2,min,exc,f2,loc3,loc4,exc2,targeted)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	if not f2 then f2=SUBJECT_THIS_CARD end
	
	local check
	if type(f2)=="function" then
		f2=aux.AttachFilter2(f2)
		if targeted then
			check=	function(g,e,tp,eg,ep,ev,re,r,rp)
						local excg=type(g)=="Group" and g:Clone() or Group.FromCards(g)
						if exc2 then excg:AddCard(e:GetHandler()) end
						return Duel.IsExistingTarget(f2,tp,loc3,loc4,1,excg,e,tp,eg,ep,ev,re,r,rp)
					end
		else
			check=	function(g,e,tp,eg,ep,ev,re,r,rp)
						local excg=type(g)=="Group" and g:Clone() or Group.FromCards(g)
						if exc2 then excg:AddCard(e:GetHandler()) end
						return Duel.IsExistingMatchingCard(f2,tp,loc3,loc4,1,excg,e,tp,eg,ep,ev,re,r,rp)
					end
		end
	elseif f2==SUBJECT_THIS_CARD then
		check=	function(g,e)
					local cc=e:GetHandler()
					return not g:IsContains(cc) and cc:IsType(TYPE_XYZ)
				end
	end
	
	if type(f)=="function" or type(f)=="nil" then
		f=aux.AttachFilter(f)
		if locs&(LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_DECK+LOCATION_EXTRA)>0 then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,rp)
						if chk==0 then return #g>min and g:CheckSubGroup(check,min,max,e,tp,eg,ep,ev,re,r,rp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						if locs&LOCATION_ONFIELD>0 then
							if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,1,exc,e,tp,eg,ep,ev,re,rp) then
								Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,min,p,locs)
							else
								Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,min,p,locs)
							end
						else
							Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,min,p,locs)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,rp)
						if chk==0 then return #g>min and g:CheckSubGroup(check,min,max,e,tp,eg,ep,ev,re,r,rp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,min,p,locs)
					end
		end
	
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local c=e:GetHandler()
						if chk==0 then return not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e) end
						Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.AttachOperation(f,loc1,loc2,min,max,exc,f2,loc3,loc4,exc2)
	local op =	function(g1,g2)
					return Duel.Attach(g1,g2:GetFirst())
				end
	return aux.CardsInteractionOperationTemplate(op,aux.AttachFilter,f,loc1,loc2,min,max,exc,f2,aux.AttachFilter,loc3,loc4,exc2)
end

-----------------------------------------------------------------------
--Banish
function Auxiliary.BanishFilter(f,cost,spelimfilter,mustbefaceup,includemzone)
	return	function(c,...)
				return (not f or f(c,...))
					and (not cost and c:IsAbleToRemove() or cost and c:IsAbleToRemoveAsCost())
					and (not spelimfilter or aux.SpElimFilter(c,mustbefaceup,includemzone))
			end
end
function Auxiliary.BanishTarget(f,loc1,loc2,min,exc)
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
		loc2=LOCATION_ONFIELD
	elseif loc2&LOCATION_GRAVE>0 then
		if not spelimfilter then spelimfilter=true end
		if loc2&LOCATION_MZONE==0 then
			loc2=loc2|LOCATION_MZONE
		elseif not includemzone then
			includemzone=true
		end
	end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if type(f)=="function" or type(f)=="nil" then
		if not f or f==Card.IsMonster then
			mustbefaceup=true
		end
		f=aux.BanishFilter(f,false,spelimfilter,mustbefaceup,includemzone)
		if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						if locs&LOCATION_ONFIELD>0 then
							local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
							if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,1,exc,e,tp) then
								Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,min,p,locs)
							else
								Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,p,locs)
							end
						else
							Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,p,locs)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
						Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,min,p,locs)
					end
		end
	
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local c=e:GetHandler()
						if chk==0 then return c:IsAbleToRemove() end
						Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.BanishOperation(f,loc1,loc2,min,max,exc)
	local spelimfilter=false
	local mustbefaceup=false
	local includemzone=false
	
	if loc1 then
		if loc1&LOCATION_GRAVE>0 then
			spelimfilter=true
			if loc1&LOCATION_MZONE==0 then
				loc1=loc1|LOCATION_MZONE
			else
				includemzone=true
			end
		end
	end
	if loc2 then
		if loc2&LOCATION_GRAVE>0 then
			if not spelimfilter then spelimfilter=true end
			if loc2&LOCATION_MZONE==0 then
				loc2=loc2|LOCATION_MZONE
			elseif not includemzone then
				includemzone=true
			end
		end
	end
	
	if type(f)=="function" or type(f)=="nil" then
		if not f or f==Card.IsMonster then
			mustbefaceup=true
		end
	end
	local opfunc =	function(f)
						return aux.BanishFilter(f,false,spelimfilter,mustbefaceup,includemzone)
					end
	
	local op =	function(g)
					return Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
				end
	return aux.CardMovementOperationTemplate(op,opfunc,LOCATION_REMOVED,f,loc1,loc2,min,max,exc)
end

-----------------------------------------------------------------------
--Control
function Auxiliary.ControlFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsControlerCanBeChanged()
			end
end

-----------------------------------------------------------------------
--Add Counter
function Auxiliary.AddCounterFilter(ctype,ct,f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsCanAddCounter(ctype,ct)
			end
end
function Auxiliary.AddCounterFilterTemplate(ctype,ct)
	return	function(f)
				return	function(c,...)
							return (not f or f(c,...)) and c:IsCanAddCounter(ctype,ct)
						end
			end
end
function Auxiliary.AddCounterTarget(ctype,ct,f,loc1,loc2,min,exc)
	if not ct then ct=1 end
	
	if type(f)=="function" or type(f)=="nil" then
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if not min then min=1 end
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					local g=Duel.GetMatchingGroup(aux.AddCounterFilter(ctype,ct,f),tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
					if chk==0 then return #g>=min  end
					if loc1>0 and loc2>0 then
						Duel.SetCustomOperationInfo(0,CATEGORY_COUNTER|ctype,g,min,PLAYER_ALL,locs,ct)
					elseif loc1>0 then
						Duel.SetCustomOperationInfo(0,CATEGORY_COUNTER|ctype,g,min,tp,loc1,ct)
					elseif loc2>0 then
						Duel.SetCustomOperationInfo(0,CATEGORY_COUNTER|ctype,g,min,1-tp,loc2,ct)
					end
				end
				
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local c=e:GetHandler()
						if chk==0 then return c:IsCanAddCounter(ctype,ct) end
						Duel.SetCustomOperationInfo(0,CATEGORY_COUNTER|ctype,c,1,c:GetControler(),c:GetLocation(),ct)
					end
		end
	end
end
function Auxiliary.AddCounterOperation(ctype,ct,f,loc1,loc2,min,max,exc)
	local op =	function(g)
					local chk=0
					if type(g)=="Group" then
						for tc in aux.Next(g) do
							if tc:AddCounter(ctype,ct) then
								chk=chk+1
							end
						end
					elseif type(g)=="Card" then
						if g:AddCounter(ctype,ct) then
							chk=chk+1
						end
					end	
					return chk
				end
	return aux.CardMovementOperationTemplate(op,aux.AddCounterFilterTemplate(ctype,ct),nil,f,loc1,loc2,min,max,exc)
end

-----------------------------------------------------------------------
--Damage
function Auxiliary.DamageTarget(ct)
	if not ct then ct=1000 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				Duel.SetTargetPlayer(1-tp)
				Duel.SetTargetParam(ct)
				Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,min)
			end
end
function Auxiliary.DamageOperation()
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				return Duel.Damage(p,d,REASON_EFFECT)
			end
end

-----------------------------------------------------------------------
--Destroy
function Auxiliary.DestroyFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and (c:IsOnField() or c:IsDestructable(e))
			end
end
function Auxiliary.DestroyTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if not f or type(f)=="function" then
		if not f then f=aux.TRUE end
		if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
			f=aux.DestroyFilter(f)
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						if locs&LOCATION_ONFIELD>0 then
							local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
							if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,1,exc,e,tp) then
								Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,min,p,locs)
							else
								Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,min,p,locs)
							end
						else
							Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,min,p,locs)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,min,p,locs)
					end
		end
	
	
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local c=e:GetHandler()
						if chk==0 then return true end
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,c:GetControler(),c:GetLocation())
					end
		end

	elseif type(f)=="table" then
		local subject=f[1]
		if subject==SUBJECT_ALL then
			f=f[2]
			if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
				return	function (e,tp,eg,ep,ev,re,r,rp,chk)
							if exc then exc=e:GetHandler() end
							local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
							if chk==0 then return #g>0 and not g:IsExists(aux.NOT(aux.DestroyFilter(f)),1,nil) end
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							if locs&LOCATION_ONFIELD>0 then
								if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,1,exc,e,tp) then
									Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,p,locs)
								else
									Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,p,locs)
								end
							else
								Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,p,locs)
							end
						end
			else
				return	function (e,tp,eg,ep,ev,re,r,rp,chk)
							if exc then exc=e:GetHandler() end
							if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,1,exc,e,tp) end
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
							Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,p,locs)
						end
			end
		end
	end
end
function Auxiliary.DestroyOperation(subject,loc1,loc2,min,max,exc)
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then subject=aux.DestroyFilter(subject) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.HintSelection(g,true)
						local ct=Duel.Destroy(g,REASON_EFFECT)
						return g,ct,ct>0
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local ct=Duel.Destroy(c,REASON_EFFECT)
						return c,1,ct>0
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							local ct=Duel.Destroy(g,REASON_EFFECT)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op)
		
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							local ct=Duel.Destroy(g,REASON_EFFECT)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,hardchk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then truesub=aux.DestroyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg,true)
							local ct=Duel.Destroy(sg,REASON_EFFECT)
							return sg,ct,ct>0
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							local ct=Duel.Destroy(g,REASON_EFFECT)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk)
		
		elseif truesub==SUBJECT_ALL then
			local f=subject[2]
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then f=aux.DestroyFilter(f) end
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.Group(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
						if #g>0 then
							aux.CheckSequentiality(conj)
							local ct=Duel.Destroy(g,REASON_EFFECT)
							return g,ct,ct>0
						end
						return g,0
					end
		end
	end
end

-----------------------------------------------------------------------
--Disable
function Auxiliary.DisableFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsNegatable()
			end
end
function Auxiliary.DisableTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if type(f)=="function" or type(f)=="nil" then
		f=aux.DisableFilter(f)
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
					Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,min,p,locs)
				end
		
	end
end
function Auxiliary.DisableOperation(f,loc1,loc2,min,max,exc,reset)
	local op =	function(g,e)
					local ct=0
					if type(g)=="Group" then
						for tc in aux.Next(g) do
							local e1,e2=Duel.Negate(tc,e,reset)
							if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) then
								ct=ct+1
							end
						end
					else
						local e1,e2=Duel.Negate(g,e,reset)
						if not g:IsImmuneToEffect(e1) and not g:IsImmuneToEffect(e2) then
							ct=ct+1
						end
					end
					return ct
				end
	return aux.CardMovementOperationTemplate(op,aux.DisableFilter,nil,f,loc1,loc2,min,max,exc)
end
-----------------------------------------------------------------------
--Discard
function Auxiliary.DiscardFilter(f,cost)
	local r = (not cost) and REASON_EFFECT or REASON_COST
	return	function(c)
				return (not f or f(c)) and c:IsDiscardable(r)
			end
end
function Auxiliary.DiscardTarget(f,min,max,p)
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				local p = (not p or p==0) and tp or 1-tp
				if chk==0 then return Duel.IsExistingMatchingCard(aux.DiscardFilter(f),p,LOCATION_HAND,0,min,nil) end
				Duel.SetTargetPlayer(p)
				if not max then
					Duel.SetTargetParam(min)
				end
				Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,p,min)
			end
end
function Auxiliary.DiscardOperation(f,min,max,p)
	if not min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
					return Duel.DiscardHand(p,aux.DiscardFilter(f),d,d,REASON_EFFECT+REASON_DISCARD)
				end
	else
		if not max then max=min end
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
					return Duel.DiscardHand(p,aux.DiscardFilter(f),min,max,REASON_EFFECT+REASON_DISCARD)
				end
	end
end

--Draw
function Auxiliary.DrawTarget(min,p)
	if not min then min=1 end
	if not p or p<1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local p=(not p or p==0) and tp or 1-tp
					if chk==0 then return Duel.IsPlayerCanDraw(p,min) end
					Duel.SetTargetPlayer(p)
					Duel.SetTargetParam(min)
					Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,min)
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return Duel.IsPlayerCanDraw(tp,min) and Duel.IsPlayerCanDraw(1-tp,min) end
					Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,min)
				end
	end
end
function Auxiliary.DrawOperation(min,max,p)
	if not min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
					local ct=Duel.Draw(p,d,REASON_EFFECT)
					return nil,ct,ct>0
				end
	else
		if not max then max=min end
		if not p or p<1 then 
			return	function (e,tp,eg,ep,ev,re,r,rp)
						local p = (p==0 or not p) and tp or 1-tp 
						local ct=Duel.Draw(p,min,REASON_EFFECT)
						return nil,ct,ct>0
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp)
						local ct1=Duel.Draw(tp,min,REASON_EFFECT)
						local ct2=Duel.Draw(1-tp,min,REASON_EFFECT)
						local ct=ct1+ct2
						return nil,ct,ct>0
					end
		end
	end
end

-----------------------------------------------------------------------
--Excavate
function Auxiliary.ExcavateTarget(min)
	if not min then min=1 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=min end
				Duel.SetTargetPlayer(tp)
				Duel.SetTargetParam(min)
			end
end
function Auxiliary.ExcavateOperation(conj1,f,min,op1,conj2,op2,id,desc1,desc2)
	if not conj1 then conj1=CONJUNCTION_ALSO end
	if not conj2 then conj2=CONJUNCTION_ALSO end
	if not min then min=1 end
	
	local hint
	if not op1 or op1==CATEGORY_TOHAND then
		f=aux.SearchFilter(f)
		hint=HINTMSG_ATOHAND
		op1=function(g,p) return Duel.Search(g,p) end
	end
	
	if not op2 or op2==SEQ_DECKSHUFFLE then
		op2=function(_,p) return Duel.ShuffleDeck(p) end
	elseif op2==SEQ_DECKTOP then
		op2=function(g,p)
			Duel.MoveToDeckTop(g,p)
			return Duel.SortDecktop(p,p,#g)
		end
	elseif op2==SEQ_DECKBOTTOM then
		op2=function(g,p)
				Duel.MoveToDeckBottom(g,p)
				return Duel.SortDeckbottom(p,p,g)
			end
	end
	
	local check1 = (conj1&0x1000==0x1000) and function(p) return Duel.SelectYesNo(p,aux.Stringid(id,desc1)) end or aux.TRUE
	local check2 = (conj2&0x1000==0x1000) and function(p) return Duel.SelectYesNo(p,aux.Stringid(id,desc2)) end or aux.TRUE
	
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				if Duel.GetFieldGroupCount(p,LOCATION_DECK,0)<d then return end
				Duel.ConfirmDecktop(p,d)
				local g=Duel.GetDecktopGroup(p,d)
				if #g>0 then
					Duel.DisableShuffleCheck()
					if g:IsExists(f,min,nil) and check1(p) then
						aux.CheckSequentiality(conj1)
						Duel.Hint(HINT_SELECTMSG,p,hint)
						local sg=g:FilterSelect(p,f,min,min,nil)
						if #sg>0 then
							op1(sg,p)
							Duel.ShuffleHand(p)
							g:Sub(sg)
						end
					end
					if check2(p) then
						aux.CheckSequentiality(conj2)
						op2(g,p)
					end
				end
			end
end

-----------------------------------------------------------------------
--Search
function Auxiliary.SearchFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsAbleToHand()
			end
end
function Auxiliary.SearchTarget(f,min,loc,max)
	if not min then min=1 end
	if not loc then loc=LOCATION_DECK end
	local gf
	if type(f)=="table" then
		if #f>1 then
			gf=GFILTER_TABLE[f[2]]
		end
		f=f[1]
	end
	local filter=aux.SearchFilter(f)
	
	if not gf or min==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,loc,0,min,nil,e,tp) end
					Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local g=Duel.GetMatchingGroup(filter,tp,loc,0,nil,e,tp)
					if chk==0 then return g:CheckSubGroup(filter,min,max,e,tp) end
					Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
				end
	end
end
function Auxiliary.SearchOperation(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_DECK end
	local op =	function(g,_,tp)
					return Duel.Search(g,tp)
				end
	return aux.CardMovementOperationTemplate(op,aux.SearchFilter,LOCATION_HAND+LOCATION_EXTRA,f,loc1,loc2,min,max,exc)
end

-----------------------------------------------------------------------
--Send To GY
function Auxiliary.ToGYFilter(f,cost)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToGrave() or (cost and c:IsAbleToGraveAsCost()))
			end
end
function Auxiliary.ToGraveFilter(f,cost)
	return aux.ToGYFilter(f,cost)
end
function Auxiliary.SendToGYTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if type(f)=="function" or type(f)=="nil" then
		f=aux.ToGYFilter(f)
		if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						if locs&LOCATION_ONFIELD>0 then
							local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
							if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,1,exc,e,tp) then
								Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,min,p,locs)
							else
								Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,min,p,locs)
							end
						else
							Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,min,p,locs)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
						Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,min,p,locs)
					end
		end
		
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local c=e:GetHandler()
						if chk==0 then return c:IsAbleToGrave() end
						Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.SendToGYOperation(f,loc1,loc2,min,max,exc)
	local op =	function(g)
					return Duel.SendtoGrave(g,REASON_EFFECT)
				end
	return aux.CardMovementOperationTemplate(op,aux.ToGYFilter,LOCATION_GRAVE,f,loc1,loc2,min,max,exc)
end

function Auxiliary.ReturnToGYTarget(f,loc1,loc2,min,exc)
	if not f then f=aux.TRUE end
	if loc1 then loc1=LOCATION_REMOVED else loc1=0 end
	if loc2 then loc2=LOCATION_REMOVED else loc2=0 end
	if not min then min=1 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if exc then exc=e:GetHandler() end
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
				local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
				local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
				Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,min,p,LOCATION_REMOVED)
		
	end
end
function Auxiliary.ReturnToGYOperation(f,loc1,loc2,min,max,exc)
	local op =	function(g)
					return Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
				end
	return aux.CardMovementOperationTemplate(op,nil,LOCATION_GRAVE,f,loc1,loc2,min,max,exc)
end

-----------------------------------------------------------------------
--Send To Hand
function Auxiliary.ToHandFilter(f,cost)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToHand() or (cost and c:IsAbleToHandAsCost()))
			end
end
function Auxiliary.SendToHandTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if type(f)=="function" or type(f)=="nil" then
		f=aux.SearchFilter(f)
		if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						if locs&LOCATION_ONFIELD>0 then
							local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
							if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,1,exc,e,tp) then
								Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,min,p,locs)
							else
								Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,p,locs)
							end
						else
							Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,p,locs)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
						Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,min,p,locs)
					end
		end
		
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local c=e:GetHandler()
						if chk==0 then return c:IsAbleToHand() end
						Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.SendToHandOperation(f,loc1,loc2,min,max,exc)
	local op =	function(g)
					return Duel.SendtoHand(g,nil,REASON_EFFECT)
				end
	return aux.CardMovementOperationTemplate(op,aux.SearchFilter,LOCATION_HAND,f,loc1,loc2,min,max,exc)
end


--To Deck
function Auxiliary.ToDeckFilter(f,cost,loc)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToDeck() or (cost and ((not loc and c:IsAbleToDeckOrExtraAsCost()) or (loc==LOCATION_DECK and c:IsAbleToDeckAsCost()) or (loc==LOCATION_EXTRA and c:IsAbleToExtraAsCost()))))
			end
end

-----------------------------------------------------------------------
--Negates
function Auxiliary.NegateCondition(monstercon,negateact,rplayer,rf,cond)
	local negatecheck = negateact and Duel.IsChainNegatable or Duel.IsChainDisablable
	if type(rf)=="boolean" and rf then
		rf=function(rc,re) return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE) end
	elseif type(rf)=="number" then
		local rtype=rf
		rf=function(rc,re) return re:IsActiveType(rtype) end
	end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return (not monstercon or not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED))
					and (not rplayer or (rplayer==0 and rp==tp) or rp==1-tp)
					and (not rf or rf(re:GetHandler(),re,e,tp,eg,ep,ev,r,rp))
					and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
					and negatecheck(ev)
			end
end
function Auxiliary.NegateTarget(negateact,negatedop,tg)
	local negcategory = negateact and CATEGORY_NEGATE or CATEGORY_DISABLE
	
	if type(negatedop)=="function" or negatedop==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
				end
	elseif negatedop==CATEGORY_DESTROY then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local rc=re:GetHandler()
					local relation=rc:IsRelateToChain(ev)
					if chk==0 then
						return not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
					if relation then
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,rc:GetControler(),rc:GetLocation())
					else
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,rc:GetPreviousControler(),rc:GetPreviousLocation())
					end
				end
	else
		local chktab = {
			[CATEGORY_REMOVE]	={Card.IsAbleToRemove,Duel.IsPlayerCanRemove};
			[CATEGORY_TOHAND]	={function(c) return c:IsAbleToHand() end,Duel.IsPlayerCanSendtoHand};
			[CATEGORY_TOGRAVE]	={function(c) return c:IsAbleToGrave() end,Duel.IsPlayerCanSendtoGrave};
			[CATEGORY_TODECK]	={function(c) return c:IsAbleToDeck() end,Duel.IsPlayerCanSendtoDeck};
		}
		local rcchk,pchk=chktab[negatedop][1],chktab[negatedop][2]
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local rc=re:GetHandler()
					local relation=rc:IsRelateToChain(ev)
					if chk==0 then
						return (rcchk(rc,tp) or (not relation and pchk(tp)))
							and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk))
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
					if relation then
						Duel.SetOperationInfo(0,negatedop,rc,1,rc:GetControler(),rc:GetLocation())
					else
						Duel.SetOperationInfo(0,negatedop,nil,0,rc:GetPreviousControler(),rc:GetPreviousLocation())
					end
				end
	end
end
function Auxiliary.NegateOperation(negateact,negatedop)
	local negtype = negateact and Duel.NegateActivation or Duel.NegateEffect
	if type(negatedop)=="function" then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if negtype(ev) then
						return negatedop(e,tp,eg,ep,ev,re,r,rp,1)
					end
				end
	else
		if negatedop==0 then
			return	function (e,tp,eg,ep,ev,re,r,rp)
						return negtype(ev)
					end
		else
			local actiontab = {
				[CATEGORY_DESTROY]	=Duel.Destroy;
				[CATEGORY_REMOVE]	=function(c,r) return Duel.Remove(c,POS_FACEUP,r) end;
				[CATEGORY_TOHAND]	=function(c,r) return Duel.SendtoHand(c,nil,r) end;
				[CATEGORY_TOGRAVE]	=Duel.SendtoGrave;
				[CATEGORY_TODECK]	=function(c,r) return Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,r) end;
			}
			local chktab = {
				[CATEGORY_DESTROY]	=function(g) return #g>0 end;
				[CATEGORY_REMOVE]	=function(g) return aux.PLChk(g,nil,LOCATION_REMOVED) end;
				[CATEGORY_TOHAND]	=function(g) return aux.PLChk(g,nil,LOCATION_HAND+LOCATION_EXTRA) end;
				[CATEGORY_TOGRAVE]	=function(g) return aux.PLChk(g,nil,LOCATION_GRAVE) end;
				[CATEGORY_TODECK]	=function(g) return aux.PLChk(g,nil,LOCATION_DECK+LOCATION_EXTRA) end;
			}
			local action=actiontab[negatedop]
			local check=chktab[negatedop]
			return	function (e,tp,eg,ep,ev,re,r,rp)
						if negtype(ev) and re:GetHandler():IsRelateToChain(ev) then
							local ct=action(eg,REASON_EFFECT)
							return eg,ct,check
						end
						return false
					end
		end
	end
end

function Auxiliary.NegateAttackOperation()
	local res=Duel.NegateAttack()
	return res
end

-----------------------------------------------------------------------
--Normal Summons
function Auxiliary.NSFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsSummonable(true,nil)
			end
end
function Auxiliary.NSTarget(f,loc1)
	if not loc1 then loc1=LOCATION_HAND+LOCATION_MZONE else loc1=loc1&(LOCATION_HAND+LOCATION_MZONE) end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(aux.NSFilter(f),tp,loc1,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
				Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,loc1)
			end
end
function Auxiliary.NSOperation(subject,loc1)
	if type(subject)=="function" or type(subject)=="nil" then
		if not loc1 then loc1=LOCATION_HAND+LOCATION_MZONE else loc1=loc1&(LOCATION_HAND+LOCATION_MZONE) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.NSFilter(subject),tp,loc1,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.Summon(tp,g:GetFirst(),true,nil)
						return g,1,true
					end
					return g,1
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				if not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				Duel.Summon(tp,c,true,nil)
				return c,1,true
			end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							Duel.Summon(tp,g:GetFirst(),true,nil)
							return g,1,true
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if truesub==SUBJECT_THAT_TARGET then
			local f=subject[2]
			local op =	function(g)
							Duel.Summon(tp,g:GetFirst(),true,nil)
							return g,1,true
						end
			return aux.TargetOperation(op,f)
		end
	end
end

-----------------------------------------------------------------------
--Restrictions

function Auxiliary.PlayerCannotSSOperation(p,excf,reset,desc)
	local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	if not reset then reset=RESET_PHASE+PHASE_END end
	
	local s,o=0,0
	if not p or p==0 then
		s=s+1	
	elseif p==1 then
		o=o+1
	elseif p==PLAYER_ALL then
		s=s+1
		o=o+1
	end
	
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(s,o)
				e1:SetTarget(aux.PlayerCannotSSFilter(excf))
				e1:SetReset(reset,rct)
				Duel.RegisterEffect(e1,tp)
				if desc then
					local id=c:GetOriginalCode()
					aux.RegisterClientHint(c,nil,tp,s,o,aux.Stringid(id,desc),reset,rct)
				end
				return true
			end
end
function Auxiliary.PlayerCannotSSFilter(f)
	return	function(e,c,sump,sumtype,sumpos,targetp,se)
				return not f or not f(c,e,sump,sumtype,sumpos,targetp,se)
			end
end

-----------------------------------------------------------------------
--Special Summons
SPSUM_MOD_NEGATE   		= 0x1
SPSUM_MOD_REDIRECT 		= 0x2
SPSUM_MOD_CHANGE_ATKDEF	=	0x4

function Auxiliary.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone)
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone)
			end
end
function Auxiliary.SSFromExtraDeckFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone)
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone)
					and Duel.GetLocationCountFromEx(recp,sump,nil,c,zone)>0
			end
end
function Auxiliary.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2)
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...))
					and (c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2))
			end
end

function Auxiliary.SSTarget(f,loc1,loc2,min,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	loc1 = loc1&(~LOCATION_EXTRA)
	loc2 = loc2&(~LOCATION_EXTRA)
	local locs = (loc1&(~loc2))|loc2
	if not min then min=1 end
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(f)=="function" or type(f)=="nil" then
		if min==1 then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						if chk==0 then
							local check = (e:GetLabel()==1) or (Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=min and Duel.IsExistingMatchingCard(aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp))
							e:SetLabel(0)
							return check
						end
						e:SetLabel(0)
						if loc1>0 and loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
						elseif loc1>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
						elseif loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						if chk==0 then
							local check = (e:GetLabel()==1) or (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=min and Duel.IsExistingMatchingCard(aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp))
							e:SetLabel(0)
							return check
						end
						e:SetLabel(0)
						if loc1>0 and loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
						elseif loc1>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
						elseif loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
						end
					end
		end
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						local c=e:GetHandler()
						if exc then exc=c end
						if chk==0 then
							local check = (e:GetLabel()==1) or (Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=min and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone))
							e:SetLabel(0)
							return check
						end
						e:SetLabel(0)
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.SSOperationTemplate(f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	end
end
function Auxiliary.SSOperation(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone,complete_proc)
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSOperationTemplate(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local ct=Duel.SpecialSummon(c,sumtype,sump,recp,ign1,ign2,pos,zone)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,hardchk,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
						local g=Duel.GetMatchingGroup(aux.SSFilter(truesub,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						
						if ft>max then ft=max end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg,true)
							local ct=Duel.SpecialSummon(sg,sumtype,sump,recp,ign1,ign2,pos,zone)
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end

function Auxiliary.SSFromExtraDeckTarget(f,loc1,loc2,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
	local loc1 = loc1 and LOCATION_EXTRA or 0
	local loc2 = loc2 and LOCATION_EXTRA or 0
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(f)=="function" or type(f)=="nil" then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if exc then exc=e:GetHandler() end
					if chk==0 then
						local check = (e:GetLabel()==1) or Duel.IsExistingMatchingCard(aux.SSFromExtraDeckFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,1,exc,e,tp,eg,ep,ev,re,r,rp)
						e:SetLabel(0)
						return check
					end
					e:SetLabel(0)
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_EXTRA)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_EXTRA)
					end
				end
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						local c=e:GetHandler()
						if exc then exc=c end
						if chk==0 then
							local check = (e:GetLabel()==1) or (Duel.GetLocationCountFromEx(recp,sump,nil,e:GetHandler(),zone)>0 and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone))
							e:SetLabel(0)
							return check
						end
						e:SetLabel(0)
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.SSFromExtraDeckOperation(subject,loc1,loc2,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
	local loc1 = loc1 and LOCATION_EXTRA or 0
	local loc2 = loc2 and LOCATION_EXTRA or 0
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	local complete_proc=false
	if sumtype==SUMMON_TYPE_FUSION or sumtype==SUMMON_TYPE_SYNCHRO or sumtype==SUMMON_TYPE_XYZ or sumtype==SUMMON_TYPE_LINK then
		complete_proc=true
	end	
	
	if type(subject)=="function" or type(subject)=="nil" then
		return aux.SSFromExtraDeckOperationTemplate(subject,loc1,loc2,exc,sumtype,sump,ign1,ign2,pos,recp,zone,complete_proc)
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				if Duel.GetLocationCountFromEx(recp,sump,nil,e:GetHandler(),zone)<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local ct=Duel.SpecialSummon(c,sumtype,sump,recp,ign1,ign2,pos,zone)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCountFromEx(recp,sump,nil,g:GetFirst(),zone)>0
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							if ct>0 and complete_proc then
								g:GetFirst():CompleteProcedure()
							end
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		
		elseif subject==SUBJECT_THAT_TARGET then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCountFromEx(recp,sump,nil,g:GetFirst(),zone)>0
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							if ct>0 and complete_proc then
								g:GetFirst():CompleteProcedure()
							end
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,false,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if truesub==SUBJECT_THAT_TARGET then
			local f=subject[2]
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCountFromEx(recp,sump,nil,g:GetFirst(),zone)>0
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							if ct>0 and complete_proc then
								g:GetFirst():CompleteProcedure()
							end
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,false,nil,chk)
		end
	end
end
function Auxiliary.SSFromExtraDeckOperationTemplate(f,loc1,loc2,exc,sumtype,sump,ign1,ign2,pos,recp,zone,complete_proc)
	return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				if exc then exc=e:GetHandler() end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,aux.SSFromExtraDeckFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,1,1,exc,e,tp,eg,ep,ev,re,r,rp)
				if #g>0 then
					aux.CheckSequentiality(conj)
					local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
					if ct>0 and complete_proc then
						g:GetFirst():CompleteProcedure()
					end
					return Duel.GetOperatedGroup(),ct,ct>0
				end
				return g,0
			end
end

function Auxiliary.SSOperationMod(mod,subject,loc1,loc2,min,max,exc,modvals,sumtype,sump,ign1,ign2,pos,recp,zone,complete_proc)
	if type(modvals)~="table" then
		modvals={modvals}
	end
	if not mod then mod=SPSUM_MOD_NEGATE end
	local spsum
	if type(mod)=="table" then
		spsum=Duel.SpecialSummonMod
	else
		if mod==SPSUM_MOD_NEGATE then
			spsum=Duel.SpecialSummonNegate
		elseif mod==SPSUM_MOD_REDIRECT then
			spsum=Duel.SpecialSummonRedirect
		elseif mod==SPSUM_MOD_CHANGE_ATKDEF then
			spsum=Duel.SpecialSummonATKDEF
		end	
	end
	
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSOperationModTemplate(spsum,subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone,table.unpack(modvals))
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<=0 or not c:IsRelateToChain() then return end

				aux.CheckSequentiality(conj)
				local ct=spsum(e,c,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
			
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,hardchk,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
						local g=Duel.GetMatchingGroup(aux.SSFilter(truesub,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						if ft>max then ft=max end

						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg,true)
							local ct=spsum(e,sg,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end
function Auxiliary.SSOperationModTemplate(spsum,f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone,...)
	local modvals={...}
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min then return end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	end
end

function Auxiliary.SSToEitherFieldTarget(f,loc1,loc2,min,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	loc1 = loc1&(~LOCATION_EXTRA)
	loc2 = loc2&(~LOCATION_EXTRA)
	local locs = (loc1&(~loc2))|loc2
	if not min then min=1 end
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone1 then zone1=0xff end
	if not zone2 then zone2=0xff end
	
	if min==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					if exc then exc=e:GetHandler() end
					if chk==0 then
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						return (ft1>=min or ft2>=min)
						and Duel.IsExistingMatchingCard(aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
					end
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					if exc then exc=e:GetHandler() end
					if chk==0 then
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
						and ft1+ft2>=min
						and Duel.IsExistingMatchingCard(aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp)
					end
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
					end
				end
	end
end
function Auxiliary.SSToEitherFieldOperation(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2,complete_proc)
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone1 then zone1=0xff end
	if not zone2 then zone2=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		loc1 = loc1&(~LOCATION_EXTRA)
		loc2 = loc2&(~LOCATION_EXTRA)
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSToEitherFieldOperationTemplate(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2)
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
				local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
				local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
				if ft1+ft2<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local recp,finalzone=tp,zone1
				if c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
					recp,finalzone=1-tp,zone2
				end
				local ct=Duel.SpecialSummon(c,sumtype,sump,recp,ign1,ign2,pos,finalzone)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=0
							for tc in aux.Next(g) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=0
							for tc in aux.Next(g) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,hardchk,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
						local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						if exc then exc=e:GetHandler() end
						local ft=ft1+ft2
						local g=Duel.GetMatchingGroup(aux.SSToEitherFieldFilter(truesub,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						
						if ft>max then ft=max end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							local ct=0
							for tc in aux.Next(sg) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=0
							for tc in aux.Next(g) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end
function Auxiliary.SSToEitherFieldOperationTemplate(f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2)
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if ft1+ft2<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local tc=g:GetFirst()
						local recp,finalzone=tp,zone1
						if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
							recp,finalzone=1-tp,zone2
						end
						local ct=Duel.SpecialSummon(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=0
						for tc in aux.Next(g) do
							local recp,finalzone=tp,zone1
							if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
								recp,finalzone=1-tp,zone2
							end
							if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if ft1+ft2<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=0
						for tc in aux.Next(g) do
							local recp,finalzone=tp,zone1
							if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
								recp,finalzone=1-tp,zone2
							end
							if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=0
						for tc in aux.Next(g) do
							local recp,finalzone=tp,zone1
							if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
								recp,finalzone=1-tp,zone2
							end
							if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	end
end

function Auxiliary.SSToEitherFieldOperationMod(mod,subject,loc1,loc2,min,max,exc,modvals,sumtype,sump,ign1,ign2,pos,zone1,zone2,complete_proc)
	if type(modvals)~="table" then
		modvals={modvals}
	end
	if not mod then mod=SPSUM_MOD_NEGATE end
	local spsum
	if mod==SPSUM_MOD_NEGATE then
		spsum=Duel.SpecialSummonNegate
	elseif mod==SPSUM_MOD_REDIRECT then
		spsum=Duel.SpecialSummonRedirect
	end
	
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone1 then zone1=0xff end
	if not zone2 then zone2=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		loc1 = loc1&(~LOCATION_EXTRA)
		loc2 = loc2&(~LOCATION_EXTRA)
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSOperationModTemplate(spsum,subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2,table.unpack(modvals))
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
				local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
				local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
				if ft1+ft2<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local recp,finalzone=tp,zone1
				if c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
					recp,finalzone=1-tp,zone2
				end
				local ct=spsum(e,c,sumtype,sump,recp,ign1,ign2,pos,finalzone,table.unpack(modvals))
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		
		elseif subject==SUBJECT_THAT_TARGET or subject==SUBJECT_ALL_THOSE_TARGETS then
			local hardchk=(subject==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,hardchk,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
						local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						if exc then exc=e:GetHandler() end
						local ft=ft1+ft2
						local g=Duel.GetMatchingGroup(aux.SSToEitherFieldFilter(truesub,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						if ft>max then ft=max end

						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg,true)
							local ct=spsum(e,sg,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end
function Auxiliary.SSToEitherFieldOperationModTemplate(mod,f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2,...)
	local modvals={...}
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if ft1+ft2<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or ft1+ft2<min then return end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	end
end

function Auxiliary.ZoneThisCardPointsTo(p)
	return	function(e,tp)
				local p = (p and p==0) and tp or (p and p==1) and 1-tp or nil
				return e:GetHandler():GetLinkedZone(p)
			end
end
function Auxiliary.ZoneThisCardDoesNotPointTo(p)
	return	function(e,tp)
				local p = (p and p==0) and tp or (p and p==1) and 1-tp or nil
				local field = (p and (p==0 or p==1)) and 0x1f or 0xff
				return (~(e:GetHandler():GetLinkedZone(p)))&field
			end
end

-----------------------------------------------
--SPECIAL SUMMON MODS
function Duel.SpecialSummonMod(e,g,styp,sump,tp,ign1,ign2,pos,zone,...)
	local mods={...}
	for i,mod in ipairs(mods) do
		local obj=type(mod)=="table" and mod[1] or mod
		if obj==SPSUM_MOD_NEGATE then
			mods[i][1]={EFFECT_DISABLE,EFFECT_DISABLE_EFFECT}
		elseif obj==SPSUM_MOD_REDIRECT then
			mods[i][1]=EFFECT_LEAVE_FIELD_REDIRECT
		elseif obj==SPSUM_MOD_CHANGE_ATKDEF then
			mods[i][1]={EFFECT_SET_ATTACK,EFFECT_SET_DEFENSE}
		end
	end
	
	if not zone then zone=0xff end
	if type(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			for i,mod in ipairs(mods) do
				local code=(type(mod)=="table") and mod[1] or mod
				local val=(type(mod)=="table" and #mod>1) and mod[2] or nil
				local reset=(type(mod)=="table" and #mod>2) and mod[3] or 0
				local rc=(type(mod)=="table" and #mod>3) and mod[4] or e:GetHandler()
				if #g==1 and g:GetFirst()==e:GetHandler() and rc==e:GetHandler() then
					reset=reset|RESET_DISABLE
				end
				
				if type(code)=="table" then
					for j,cd in ipairs(code) do
						local e1=Effect.CreateEffect(rc)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(cd)
						if cd==EFFECT_LEAVE_FIELD_REDIRECT then
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						elseif cd==EFFECT_SET_ATTACK or cd==EFFECT_SET_DEFENSE then
							e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
						end
						if val then
							e1:SetValue(val)
						end
						e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
						dg:RegisterEffect(e1)
					end
				else
					local e1=Effect.CreateEffect(rc)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(code)
					if code==EFFECT_LEAVE_FIELD_REDIRECT then
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					elseif code==EFFECT_SET_ATTACK or code==EFFECT_SET_DEFENSE then
						e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					end
					if val then
						e1:SetValue(val)
					end
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
					dg:RegisterEffect(e1)
				end
			end
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end

function Duel.SpecialSummonATK(e,g,styp,sump,tp,ign1,ign2,pos,zone,atk,reset,rc)
	if not zone then zone=0xff end
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if type(g)=="Card" then
		if g==e:GetHandler() and rc==e:GetHandler() then reset=reset|RESET_DISABLE end
		g=Group.FromCards(g)
	end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e1=Effect.CreateEffect(rc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonNegate(e,g,styp,sump,tp,ign1,ign2,pos,zone,reset,rc)
	if not zone then zone=0xff end
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if type(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e1=Effect.CreateEffect(rc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(rc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonRedirect(e,g,styp,sump,tp,ign1,ign2,pos,zone,loc,desc)
	if not zone then zone=0xff end
	if not loc then loc=LOCATION_REMOVED end
	if type(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e=Effect.CreateEffect(e:GetHandler())
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			if desc then
				e:SetDescription(desc)
				e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			else
				e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			end
			e:SetValue(loc)
			e:SetReset(RESET_EVENT+RESETS_REDIRECT_FIELD)
			dg:RegisterEffect(e,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonATKDEF(e,g,styp,sump,tp,ign1,ign2,pos,zone,atk,def,reset,rc)
	if not zone then zone=0xff end
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if type(g)=="Card" then
		if g==e:GetHandler() and rc==e:GetHandler() then reset=reset|RESET_DISABLE end
		g=Group.FromCards(g)
	end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e=Effect.CreateEffect(rc)
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			if atk then
				e:SetCode(EFFECT_SET_ATTACK)
				e:SetValue(atk)
				dg:RegisterEffect(e,true)
			end
			if def then
				local e=e:Clone()
				e:SetCode(EFFECT_SET_DEFENSE)
				e:SetValue(def)
				dg:RegisterEffect(e,true)
			end
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end