--A Plethora of Pumpkins
--Scripted by: XGlitchy30
Duel.LoadScript("yummylib.lua")
Duel.LoadScript("glitchylib.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCost(s.cost)
	e1:SetTarget(s.FusionSummonTarget(nil,s.matfilter,s.extrafil,s.extraop,nil,nil,extratg))
	e1:SetOperation(s.FusionSummonOperation(nil,s.matfilter,s.extrafil,s.extraop,nil,nil))
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local temp1=Effect.CreateEffect(c)
		temp1:SetType(EFFECT_TYPE_FIELD)
		temp1:SetCode(EFFECT_CHANGE_CODE)
		temp1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
		temp1:SetCondition(s.tempcon)
		temp1:SetTarget(s.changecode_temp)
		temp1:SetValue(CARD_PUMPKINHEAD)
		Duel.RegisterEffect(temp1,0)
		local temp2=temp1:Clone()
		temp2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		temp2:SetTarget(s.extramat_temp)
		temp2:SetValue(aux.TRUE)
		Duel.RegisterEffect(temp2,0)
	end
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.temp_tg = nil
s.listed_names={CARD_PUMPKINHEAD}
s.listed_series={SET_PUMPKINHEAD}
function s.tempcon()
	return s.temp_tg~=nil
end
function s.changecode_temp(e,c)
	if not s.temp_tg then return false end
	return c:IsMonster() and c:IsControler(s.temp_tg)
end
function s.extramat_temp(e,c)
	return not c:IsMonster() and s.extrafilter(c,e:GetHandlerPlayer())
end

local function GetExtraMatEff(c,summon_card)
	local effs={c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
	for _,eff in ipairs(effs) do
		if eff~=geff then
			if not summon_card then
				return eff
			end
			local val=eff:GetValue()
			if (type(val)=="function" and val(eff,summon_card)) or val==1 then
				return eff
			end
		end
	end
end
local function ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
	local extra_feff_mg=mg1:Filter(GetExtraMatEff,nil)
	if #extra_feff_mg>0 then
		local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			local extra_feff_loc=extra_feff:GetTargetRange()
			if extrafil then
				local extrafil_g=extrafil(e,tp,mg1)
				if extrafil_g and #extrafil_g>0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff_loc) then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				elseif not extrafil_g then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				end
			else
				mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
				efmg:Clear()
			end
		end
	elseif #efmg>0 then
		local extra_feff=GetExtraMatEff(efmg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			efmg:Clear()
		end
	end
	return mg1,efmg
end

function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsType(TYPE_FUSION)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_FUSION)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end

function s.matfilter(c,e,tp,check_or_run)
	return c:IsSetCard(SET_PUMPKINHEAD) and c:IsAbleToRemove(tp,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION) and aux.SpElimFilter(c)
end
function s.extrafilter(c,tp)
	return c:IsSetCard(SET_PUMPKINHEAD) and c:IsAbleToRemove(tp,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
end
function s.extrafil(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(s.extrafilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp), s.fcheck
	end
	return nil, s.fcheck
end
function s.extraop(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL,fc,SUMMON_TYPE_FUSION)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.extramat(e,c)
	return not c:IsMonster() and s.extrafilter(c,e:GetHandlerPlayer())
end

function s.FusionSummonTarget(fusfilter,matfilter,extrafil,extraop,chkf,nosummoncheck,extratg)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if not chkf or ((chkf&PLAYER_NONE)~=PLAYER_NONE) then
					chkf=chkf and chkf|tp or tp
				end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				local value=MATERIAL_FUSION
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION
				end
				local gc=nil
				
				if chk==0 then
					s.temp_tg = tp
				
					local fmg_all=Duel.GetFusionMaterial(tp)
					local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
					local efmg=fmg_all:Filter(GetExtraMatEff,nil)
					local checkAddition=nil
					local repl_flag=false
					if #efmg>0 then
						local extra_feff=GetExtraMatEff(efmg:GetFirst())
						if extra_feff and extra_feff:GetLabelObject() then
							local repl_function=extra_feff:GetLabelObject()
							repl_flag=true
							local ret = {extrafil(e,tp,mg1)}
							local repl={repl_function[1](e,tp,mg1)}
							if ret[1] then
								repl[1]:Match(matfilter,nil)
								ret[1]:Merge(repl[1])
								Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							checkAddition=aux.AND(ret[2],repl[2])
						end
					end
					if not repl_flag then
						local ret = {extrafil(e,tp,mg1)}
						if ret[1] then
							Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					Fusion.CheckAdditional=checkAddition
					mg1:Match(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=nil
					Fusion.CheckMin=nil
					Fusion.CheckMax=nil
					mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
					local res=Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,LOCATION_EXTRA,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,POS_FACEUP,efmg)
					Fusion.CheckAdditional=nil
					Fusion.ExtraGroup=nil
					if not res and not notfusion then
						for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
							local fgroup=ce:GetTarget()
							local mg=fgroup(ce,e,tp,value)
							if #mg>0 and (not Fusion.CheckExact or #mg==Fusion.CheckExact) and (not Fusion.CheckMin or #mg>=Fusion.CheckMin) then
								local mf=ce:GetValue()
								local fcheck=nil
								if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
								Fusion.CheckAdditional=checkAddition
								if fcheck then
									if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
								end
								Fusion.ExtraGroup=mg
								if Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,LOCATION_EXTRA,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,POS_FACEUP) then
									res=true
									Fusion.CheckAdditional=nil
									Fusion.ExtraGroup=nil
									break
								end
								Fusion.CheckAdditional=nil
								Fusion.ExtraGroup=nil
							end
						end		
					end
					Fusion.CheckExact=nil
					Fusion.CheckMin=nil
					Fusion.CheckMax=nil
					s.temp_tg = nil
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
			end
end
function s.FusionSummonOperation(fusfilter,matfilter,extrafil,extraop,chkf,nosummoncheck)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				chkf = chkf and chkf|tp or tp
				chkf=chkf|FUSPROC_CANCELABLE
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				local value=0
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION|MATERIAL_FUSION
				end
				local gc=nil
				local checkAddition
				
				local cc=e:GetHandler()
				local e1=Effect.CreateEffect(cc)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CHANGE_CODE)
				e1:SetTargetRange(LOCATION_GRAVE,0)
				e1:SetTarget(aux.TargetBoolFunction(Card.IsMonster))
				e1:SetValue(CARD_PUMPKINHEAD)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
				e2:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
				e2:SetTarget(s.extramat)
				e2:SetValue(aux.TRUE)
				Duel.RegisterEffect(e2,tp)
				
				local fmg_all=Duel.GetFusionMaterial(tp)
				local mg1=fmg_all:Filter(matfilter,nil,e,tp,1)
				local efmg=fmg_all:Filter(GetExtraMatEff,nil)
				local extragroup=nil
				local repl_flag=false
				if #efmg>0 then
					local extra_feff=GetExtraMatEff(efmg:GetFirst())
					if extra_feff and extra_feff:GetLabelObject() then
						local repl_function=extra_feff:GetLabelObject()
						repl_flag=true
						local ret = {extrafil(e,tp,mg1)}
						local repl={repl_function[1](e,tp,mg1)}
						if ret[1] then
							repl[1]:Match(matfilter,nil)
							ret[1]:Merge(repl[1])
							Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=aux.AND(ret[2],repl[2])
					end
				end
				if not repl_flag then
					local ret = {extrafil(e,tp,mg1)}
					if ret[1] then
						Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1:Match(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
				Fusion.CheckExact=nil
				Fusion.CheckMin=nil
				Fusion.CheckMax=nil
				Fusion.CheckAdditional=checkAddition
				local effswithgroup={}

				mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,LOCATION_EXTRA,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,POS_FACEUP,efmg)
				if #sg1>0 then
					table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
				end
				Fusion.ExtraGroup=nil
				Fusion.CheckAdditional=nil
				if not notfusion then
					local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
					for _,ce in ipairs(extraeffs) do
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp,value)
						if #mg2>0 and (not Fusion.CheckExact or #mg2==Fusion.CheckExact) and (not Fusion.CheckMin or #mg2>=Fusion.CheckMin) then
							local mf=ce:GetValue()
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=mg2
							local sg2=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,LOCATION_EXTRA,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,POS_FACEUP)
							if #sg2 > 0 then
								table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
								sg1:Merge(sg2)
							end
							Fusion.CheckAdditional=nil
							Fusion.ExtraGroup=nil
						end
					end
				end
				if #sg1>0 then
					local sg=sg1:Clone()
					local mat1=Group.CreateGroup()
					local sel=nil
					local backupmat=nil
					local tc=nil
					local ce=nil
					while #mat1==0 do
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						tc=sg:Select(tp,1,1,nil):GetFirst()
						sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
						if sel[1]==e then
							Fusion.CheckAdditional=checkAddition
							Fusion.ExtraGroup=extragroup
							mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						else
							ce=sel[1]
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
							mat1=Duel.SelectFusionMaterial(tp,tc,Fusion.ExtraGroup,gc,chkf)
						end
					end
					if sel[1]==e then
						Fusion.ExtraGroup=nil
						backupmat=mat1:Clone()
						tc:SetMaterial(mat1)

						local extra_feff_mg=mat1:Filter(GetExtraMatEff,nil,tc)
						if #extra_feff_mg>0 then
							local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op and extraop~=extra_feff_op and extra_feff:CheckCountLimit(tp) then
									local flag=nil
									local extrafil_g=extrafil(e,tp,mg1)
									if #extrafil_g>=0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff:GetTargetRange()) then
										mat1:Sub(extra_feff_mg)
										extra_feff_op(e,tc,tp,extra_feff_mg)
										flag=true
									elseif #extrafil_g>=0 and Duel.SelectEffectYesNo(tp,extra_feff:GetHandler()) then
										Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)
										local g=extra_feff_mg:Select(tp,1,#extra_feff_mg,nil)
										if #g>0 then
											mat1:Sub(g)
											extra_feff_op(e,tc,tp,g)
											flag=true
										end
									end
									if flag and extra_feff:CheckCountLimit(tp) then
										extra_feff:UseCountLimit(tp,1)
									end
								end
							end
						end
						if extraop(e,tc,tp,mat1)==false then
							e2:Reset()
							return
						end
						if #mat1>0 then
							local extra_feff_mg,normal_mg=mat1:Split(GetExtraMatEff,nil,tc)
							local extra_feff
							if #extra_feff_mg>0 then extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
							if #normal_mg>0 then
								Duel.SendtoGrave(normal_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op then
									Duel.BreakEffect()
									extra_feff_op(e,tc,tp,extra_feff_mg)
								else
									Duel.BreakEffect()
									Duel.SendtoGrave(extra_feff_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
								end
								if extra_feff:CheckCountLimit(tp) then
									extra_feff:UseCountLimit(tp,1)
								end
							end
						end
						Duel.BreakEffect()
						Duel.SpecialSummonStep(tc,value,tp,tp,sumlimit,false,POS_FACEUP)
					else
						Fusion.CheckAdditional=nil
						Fusion.ExtraGroup=nil
						ce:GetOperation()(sel[1],e,tp,tc,mat1,value,nil,POS_FACEUP)
						backupmat=tc:GetMaterial():Clone()
					end
					Duel.SpecialSummonComplete()
					if (chkf&FUSPROC_NOTFUSION)==0 then
						tc:CompleteProcedure()
					end
				end
				Fusion.CheckMin=nil
				Fusion.CheckMax=nil
				Fusion.CheckExact=nil
				Fusion.CheckAdditional=nil
				e2:Reset()
			end
end