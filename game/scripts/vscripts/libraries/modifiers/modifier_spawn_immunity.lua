modifier_spawn_immunity = class({})

function modifier_spawn_immunity:IsHidden()
	return true
end

function modifier_spawn_immunity:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true}
end

