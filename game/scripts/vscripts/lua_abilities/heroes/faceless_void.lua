function BacktrackHealth( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

--[[Author: Pizzalol
	Date: 14.02.2016.
	Negates incoming damage]]
function BacktrackHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:SetHealth(ability.caster_hp_old)
	if caster:IsIllusion() then
		if not caster:HasModifier("modifier_illusion") then
			caster:ForceKill(true)
		end
	end
end

function CooldownReduction(keys)
	local reduction = 1.0
	if keys.reduction ~= nil then
		reduction = keys.reduction
	end
	local caster = keys.caster
	for i=0,caster:GetAbilityCount()-1 do 
		if caster:GetAbilityByIndex(i) ~= nil then
			local skill = caster:GetAbilityByIndex(i)
			if not skill:IsCooldownReady() and skill and skill ~= keys.ability then
				local timeleft = skill:GetCooldownTimeRemaining()
				skill:EndCooldown()
				if timeleft > reduction then
					skill:StartCooldown(timeleft-reduction)
				end
			end
		end
	end
end

function LockDamage(keys)
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.ability:GetTalentSpecialValueFor("bonus_damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability})
end

function TimeWalk( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local modifier = keys.modifier

	-- Distance calculations
	local speed = ability:GetTalentSpecialValueFor("speed")
	local max_distance = ability:GetTalentSpecialValueFor("range")
	print(max_distance)
	
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local duration = distance/speed
	
	if distance > max_distance then distance = max_distance end

	-- Saving the data in the ability
	ability.time_walk_distance = distance
	ability.time_walk_speed = speed * 1/30 -- 1/30 is how often the motion controller ticks
	ability.time_walk_direction = direction
	ability.time_walk_traveled_distance = 0

	-- Apply the invlunerability modifier to the caster
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end

--[[Author: Pizzalol
	Date: 21.09.2015.
	Moves the target until it has traveled the distance to the chosen point]]
function TimeWalkMotion( keys )
	local caster = keys.target
	local ability = keys.ability

	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.time_walk_traveled_distance < ability.time_walk_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.time_walk_direction * ability.time_walk_speed)
		ability.time_walk_traveled_distance = ability.time_walk_traveled_distance + ability.time_walk_speed
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 7, 2016
	Adds up all the damage the caster takes every two seconds and stores it in an array]]
function CalculateDamage( keys )
	local ability = keys.ability
	local damage_taken = keys.DamageTaken
	local backtrack_time = keys.BacktrackTime
	
	-- Temporary damage array and index
	local temp = {}
	local temp_index = 0
	
	-- Global damage array and index
	local caster_index = 0
	if ability.caster_damage == nil then
		ability.caster_damage = {}
	end
	
	-- Sets the damage and game time values in the tempororary array, if void was attacked within 2 seconds of current time
	while ability.caster_damage do
		if ability.caster_damage[caster_index] == nil then
		break
		elseif Time() - ability.caster_damage[caster_index+1] <= backtrack_time then
			temp[temp_index] = ability.caster_damage[caster_index]
			temp[temp_index+1] = ability.caster_damage[caster_index+1]
			temp_index = temp_index + 2
		end
		caster_index = caster_index + 2
	end
	
	-- Places most recent damage and current time in the temporary array
	temp[temp_index] = damage_taken
	temp[temp_index+1] = Time()
	
	-- Sets the global array as the temporary array
	ability.caster_damage = temp
end

--[[Author: YOLOSPAGHETTI
	Date: February 7, 2016
	Moves the target until it has traveled the distance to the chosen point]]
function RemoveDamage ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local backtrack_time = keys.BacktrackTime
	local damage_sum = 0
	local caster_index = 0
	
	-- Sums damage over the last 2 seconds
	while ability.caster_damage do
		if ability.caster_damage[caster_index] == nil then
		break
		elseif Time() - ability.caster_damage[caster_index+1] <= backtrack_time then
			damage_sum = damage_sum + ability.caster_damage[caster_index]
		end
		caster_index = caster_index + 2
	end
	
	-- Adds damage to caster's current health
	caster:SetHealth(caster:GetHealth() + damage_sum)
end