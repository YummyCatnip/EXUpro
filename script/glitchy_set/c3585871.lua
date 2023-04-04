--Wicked Booster Callback
--Scripted by: XGlitchy30

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	--activate
	c:Activate(0,CATEGORY_TOHAND,EFFECT_FLAG_CARD_TARGET,nil,aux.HOPT(),
		nil,
		nil,
		aux.Target(s.filter,LOCATION_GB,0,1,1,nil,nil,CATEGORY_TOHAND),
		aux.SendToHandOperation(SUBJECT_IT)
	)
	--search
	c:Ignition(1,CATEGORIES_SEARCH,nil,LOCATION_GRAVE,aux.HOPT(),
		aux.exccon,
		s.cost,
		aux.SearchTarget(s.thfilter),
		aux.SearchOperation(s.thfilter)
	)
end
function s.filter(c)
	return c:IsSetCard(SET_WICKED_BOOSTER) and c:IsMonster() and c:NotBanishedOrFaceup() and c:IsAbleToHand()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,c) end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_WICKED_BOOSTER) and c:IsST() and not c:IsCode(id)
end