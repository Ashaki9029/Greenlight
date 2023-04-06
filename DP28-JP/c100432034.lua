--ＢＫ プロモーター
--Battlin' Boxer Promoter
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.selfspcon)
	e1:SetCost(s.sumlimitcost)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Special Summon up to 2 "Battlin' Boxer" monsters from the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Increase or decrease the Level of all "Battlin' Boxer" monsters you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.lvcost)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.activityfilter)
end
s.listed_names={id}
s.listed_series={SET_BATTLIN_BOXER}
function s.activityfilter(c)
	return c:IsSetCard(SET_BATTLIN_BOXER)
end
function s.sumlimitcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon, except "Battlin' Boxer" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsSetCard(SET_BATTLIN_BOXER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.selfreleasecost(e,tp,eg,ep,ev,re,r,rp,0)
		and s.sumlimitcost(e,tp,eg,ep,ev,re,r,rp,0) end
	aux.selfreleasecost(e,tp,eg,ep,ev,re,r,rp,1)
	s.sumlimitcost(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_BATTLIN_BOXER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g<2 then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),#g,2)
	if ft<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and s.sumlimitcost(e,tp,eg,ep,ev,re,r,rp,0) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	s.sumlimitcost(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BATTLIN_BOXER) and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,#g,tp,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local decrease=g:FilterCount(Card.IsLevel,nil,1)<#g
	local value=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,4)}, --increase levels by 1
		{decrease,aux.Stringid(id,5)}) --decrease levels by 1
	if value==2 then value=-1 end
	local c=e:GetHandler()
	for tc in g:Iter() do
		---Increase or decrease the level of "Battlin' Boxer" monsters
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(value)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
