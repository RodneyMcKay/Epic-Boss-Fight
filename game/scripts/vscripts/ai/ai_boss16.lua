--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash")
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash_h") end
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_ogres")
	thisEntity.internalClock = GameRules:GetGameTime()
end


function AIThink()
	if thisEntity.internalClock + 15 < GameRules:GetGameTime() then
		CreateUnitByName( "npc_dota_mini_boss2_he" ,thisEntity:GetAbsOrigin() + RandomVector(RandomInt(250,500)), true, nil, nil, DOTA_TEAM_BADGUYS )
		thisEntity.internalClock = GameRules:GetGameTime()
	end
	if not thisEntity:IsDominated() then
		local radius = thisEntity.smash:GetCastRange()
		if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
		and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
		and thisEntity.smash:IsFullyCastable() then
			local smashRadius = thisEntity.smash:GetSpecialValueFor("impact_radius")
			local position = AICore:OptimalHitPosition(thisEntity, radius, smashRadius)
			if position then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = position,
					AbilityIndex = thisEntity.smash:entindex()
				})
				return 0.25
			end
		end
		if thisEntity.summon:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive(thisEntity, "npc_dota_mini_boss2") < 6 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.summon:entindex()
			})
			return 0.25
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end