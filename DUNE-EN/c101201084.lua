--Japanese name
--Storagepod
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Destroy 1 card you control and 1 card your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descond)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.matfilter1(c)
	return c:IsCode(12275533,99733359)
end
function s.matfilter2(c)
	return c:IsRace(RACE_MACHINE|RACE_DINOSAUR)
end
function s.indescon(e)
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil,LOCATION_GRAVE)
end
function s.filter(c)
	return c:IsPreviousLocation(LOCATION_HAND)
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end