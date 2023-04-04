function Card.FieldEffect(c,code,range,selfzones,oppozones,f,val,cond,reset,rc)
--CONTINUOUS EFFECTS (EFFECT_TYPE_FIELD)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not selfzones then selfzones=0 end
	if type(oppozones)=="boolean" and oppozones==true then
		oppozones=selfzones
	elseif not oppozones then
		oppozones=0
	end
	if not rc then rc=c end
	local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(range)
	e:SetCode(code)
	if cond then
		e:SetCondition(cond)
	end
	e:SetTargetRange(selfzones,oppozones)
	if f then
		e:SetTarget(f)
	end
	if val then
		e:SetValue(val)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
	end
	--c:RegisterEffect(e)
	return e
end

-----------------------------------------------------------------------
function Card.UpdateATKField(c,atk,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_UPDATE_ATTACK,range,selfzones,oppozones,f,atk,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateDEFField(c,def,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_UPDATE_DEFENSE,range,selfzones,oppozones,f,def,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateATKDEFField(c,atk,def,range,selfzones,oppozones,f,cond,reset,rc)
	local e1=c:FieldEffect(EFFECT_UPDATE_ATTACK,range,selfzones,oppozones,f,atk,cond,reset,rc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(def)
	c:RegisterEffect(e2)
	return e1,e2
end
function Card.ChangeATKField(c,atk,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_SET_ATTACK_FINAL,range,selfzones,oppozones,f,atk,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.ChangeDEFField(c,def,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_SET_DEFENSE_FINAL,range,selfzones,oppozones,f,def,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.AddTypeField(c,typ,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_ADD_TYPE,range,selfzones,oppozones,f,typ,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.ChangeAttributeField(c,attr,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CHANGE_ATTRIBUTE,range,selfzones,oppozones,f,attr,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.ChangeRaceField(c,race,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CHANGE_RACE,range,selfzones,oppozones,f,race,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.UpdateLevelField(c,lv,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_UPDATE_LEVEL,range,selfzones,oppozones,f,lv,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.ChangeLevelField(c,lv,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CHANGE_LEVEL,range,selfzones,oppozones,f,lv,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

--Battle Related
BATTLE_TIMING_FUNCTIONS_FIELD={
[BATTLE_TIMING_BATTLES]=	function(f1,f2)
								return	function(e)
											local a=Duel.GetAttacker()
											if not a then return false end
											local d=Duel.GetAttackTarget()
											if a:IsControler(1-e:GetHandlerPlayer()) then a,d=d,a end
											return a and (not f1 or f1(a,e,d)) and (not d or (not f2 or f2(d,e,a)))
										end
							end;
[BATTLE_TIMING_ATTACKS]=	function(f1,f2)
								return	function(e)
											local a=Duel.GetAttacker()
											if not a or a:IsControler(1-e:GetHandlerPlayer()) then return false end
											local d=Duel.GetAttackTarget()
											return (not f1 or f1(a,e,d)) and (not d or (not f2 or f2(d,e,c)))
										end
							end;
[BATTLE_TIMING_ATTACKS_DIRECTLY]=	function(f1)
										return	function(e)
													local a=Duel.GetAttacker()
													if not a or a:IsControler(1-e:GetHandlerPlayer()) then return false end
													local d=Duel.GetBattleTarget()
													return (not f1 or f1(a,e,d)) and not d
												end
									end;
[BATTLE_TIMING_IS_ATTACKED]=	function(f1,f2)
									return	function(e)
												local a=Duel.GetAttackTarget()
												if not a or a:IsControler(1-e:GetHandlerPlayer()) then return false end
												local d=Duel.GetAttacker()
												return (not f1 or f1(a,e,d)) and (not f2 or f2(d,e,c))
											end
								end;
}

function Card.CanAttackDirectlyField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_DIRECT_ATTACK,range,selfzones,oppozones,f,nil,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.CanAttackWhileInDefensePositionField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_DEFENSE_ATTACK,range,selfzones,oppozones,f,1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.MustAttackField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_MUST_ATTACK,range,selfzones,oppozones,f,nil,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.ArmadesEffectField(c,timing,protection,range,self,oppo,f1,cond,reset,rc)
	if not timing then timing=BATTLE_TIMING_BATTLES end
	if not self then self=0 end
	if not oppo then oppo=0 end
	local f2
	if type(timing)=="table" then
		f2=timing[2]
		timing=timing[1]
	end
	local battlecond=BATTLE_TIMING_FUNCTIONS_FIELD[timing](f1,f2)
	local condition =	function(e)
							return (not battlecond or battlecond(e)) and (not cond or cond(e))
						end

	local val
	if not protection then
		val=1
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=8 do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i*2
			end
			val =	function(eff,re,rp)
						for _,f in ipairs(list) do
							if not f(eff,re,rp) then
								return false
							end
						end
						return true
					end
		elseif type(protection)=="function" then
			val=protection
		else
			val=function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end
		end
	end
	local e=c:FieldEffect(EFFECT_CANNOT_ACTIVATE,LOCATION_MZONE,self,oppo,nil,val,condition,reset,rc)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	c:RegisterEffect(e)
	return e
end
function Card.SetMaximumNumberOfAttacksField(c,ct,range,selfzones,oppozones,f,cond,reset,rc)
	if not ct or type(ct)~="number" then ct=2 end
	local e=c:FieldEffect(EFFECT_EXTRA_ATTACK,range,selfzones,oppozones,f,ct-1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.SetMaximumNumberOfAttacksOnMonstersField(c,ct,range,selfzones,oppozones,f,cond,reset,rc)
	if not ct or type(ct)~="number" then ct=2 end
	local e=c:FieldEffect(EFFECT_EXTRA_ATTACK_MONSTER,range,selfzones,oppozones,f,ct-1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
--Protections
function Card.BattleProtectionField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_INDESTRUCTABLE_BATTLE,range,selfzones,oppozones,f,1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.EffectProtectionField(c,protection,range,selfzones,oppozones,f,cond,reset,rc)
	local val
	if not protection then
		val=1
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=8 do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i*2
			end
			val =	function(eff,re,rp)
						for _,f in ipairs(list) do
							if not f(eff,re,rp) then
								return false
							end
						end
						return true
					end
		elseif type(protection)=="function" then
			val=protection
		else
			val=function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end
		end
	end
	local e=c:FieldEffect(EFFECT_INDESTRUCTABLE_EFFECT,range,selfzones,oppozones,f,val,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.TargetProtectionField(c,protection,range,selfzones,oppozones,f,cond,reset,rc)
	local val
	if not protection then
		val=1
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=8 do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i*2
			end
			val =	function(eff,re,rp)
						for _,f in ipairs(list) do
							if not f(eff,re,rp) then
								return false
							end
						end
						return true
					end
		elseif type(protection)=="function" then
			val=protection
		else
			val=aux.tgoval
		end
	end
	local e=c:FieldEffect(EFFECT_CANNOT_BE_EFFECT_TARGET,range,selfzones,oppozones,f,val,cond,reset,rc)
	e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e)
	return e
end
function Card.UnaffectedProtectionField(c,protection,range,selfzones,oppozones,f,cond,reset,rc)
	local val
	if not protection then
		val=1
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=8 do
				if protection&i==i then
					table.insert(list,UNAFFECTED_PROTECTION_FUNCTIONS[i])
				end
				i=i*2
			end
			val =	function(eff,re)
						for _,f in ipairs(list) do
							if not f(eff,re) then
								return false
							end
						end
						return true
					end
		elseif type(protection)=="function" then
			val=protection
		else
			val=function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end
		end
	end
	local e=c:FieldEffect(EFFECT_IMMUNE_EFFECT,range,selfzones,oppozones,f,val,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.FirstTimeProtectionField(c,each_turn,battle,effect,protection,range,selfzones,oppozones,f,cond,reset,rc)
	local val
	if not protection then
		val=function (eff,re,r,rp)
				return (battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0)
			end
	else
		if type(protection)=="number" then
			local list={}
			local i=1
			while i<=8 do
				if protection&i==i then
					table.insert(list,PROTECTION_FUNCTIONS[i])
				end
				i=i*2
			end
			val =	function(eff,re,rp)
						if not ((battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0)) then return false end
						for _,f in ipairs(list) do
							if not f(eff,re,rp) then
								return false
							end
						end
						return true
					end
		elseif type(protection)=="function" then
			val=function (eff,re,r,rp)
					return (battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0 and protection(eff,re,r,rp))
				end
		else
			val=function (eff,re,r,rp)
					return (battle and r&REASON_BATTLE>0) or (effect and r&REASON_EFFECT>0 and rp~=eff:GetHandlerPlayer())
				end
		end
	end
	local e=c:FieldEffect(EFFECT_INDESTRUCTABLE_COUNT,range,selfzones,oppozones,f,val,cond,reset,rc)
	if not each_turn then
		e:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	end
	e:SetCountLimit(1)
	c:RegisterEffect(e)
	return e
end

--SS Procedures
function Card.SSProc(c,desc,prop,range,ctlim,cond,tg,op,pos,p,zone)
	local default_prop = (not pos1 and not p and not zone) and EFFECT_FLAG_UNCOPYABLE or EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM
	local prop = prop and prop or 0
	local range = range and range or (c:IsOriginalType(TYPE_EXTRA)) and LOCATION_EXTRA or LOCATION_HAND
	if p and p==PLAYER_ALL then
		tg=aux.SelectFieldForSSProc(tg,pos)
	end
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	e1:SetProperty(default_prop+prop)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="boolean" then
			e1:HOPT(true)
		elseif type(ctlim)=="table" then
			if type(ctlim[1])=="boolean" then
				local shopt=ctlim[2]
				local oath=ctlim[3]
				if shopt then
					e1:SHOPT(oath)
				else
					e1:HOPT(oath)
				end
			else
				local flag=#ctlim>2 and ctlim[3] or 0
				e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
			end
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if pos or p then
		if not pos then pos=POS_FACEUP end
		if not p then p=0 end
		e1:SetTargetRange(pos,p)
	end
	if zone then
		e1:SetValue(zone)
	end
	if cond then
		e1:SetCondition(function(e,c) if c==nil then return true end return cond(e,c,e:GetHandlerPlayer()) end)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.SelectFieldForSSProc(f,pos)
	if not f then f=aux.TRUE end
	if not pos then pos=POS_FACEUP end
	return	function(...)
				local outcome=f(...)
				local sel=Duel.SelectOption(tp,102,103)
				if sel==0 then
					e:SetTargetRange(pos,0)
				else
					e:SetTargetRange(pos,1)
				end
				return outcome
			end
end