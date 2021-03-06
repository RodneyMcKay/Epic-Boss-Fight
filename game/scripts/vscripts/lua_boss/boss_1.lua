function vendetta_attack( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local modifierName = "modifier_vendetta_buff_datadriven"
		local abilityDamage = ability:GetLevelSpecialValueFor( "bonus_damage", ability:GetLevel() - 1 )
		local abilityDamageType = ability:GetAbilityDamageType()
	
		-- Deal damage and show VFX
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
		
		StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
		
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = abilityDamage,
			damage_type = abilityDamageType,
			ability = ability
		}
		ApplyDamage( damageTable )
		
		keys.caster:RemoveModifierByName( modifierName )
	end
end

function vendetta_particle( keys )
	local poof = ParticleManager:CreateParticle( keys.particle, PATTACH_WORLDORIGIN, keys.caster )
		ParticleManager:SetParticleControl( poof, 0, keys.caster:GetAbsOrigin() )
end