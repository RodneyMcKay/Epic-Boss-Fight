vengefulspirit_magic_missile_ebf = class({})

if IsServer() then
	function vengefulspirit_magic_missile_ebf:OnSpellStart()
		local distance = self:GetTrueCastRange()
		print(distance)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, distance, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for _,enemy in pairs(enemies) do
			local projectile = {
				Target = enemy,
				Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
				bDodgable = true,
				bProvidesVision = false,
				iMoveSpeed = self:GetTalentSpecialValueFor("magic_missile_speed"),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
			ProjectileManager:CreateTrackingProjectile(projectile)
		end
		EmitSoundOn("Hero_VengefulSpirit.MagicMissile", self:GetCaster())
	end

	function vengefulspirit_magic_missile_ebf:OnProjectileHit(target, position)
		if not target then return end
		EmitSoundOn("Hero_VengefulSpirit.MagicMissile", target)
		target:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetTalentSpecialValueFor("magic_missile_stun")})
		ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetTalentSpecialValueFor("magic_missile_damage"), damage_type = self:GetAbilityDamageType(), ability = self})
	end
end

vengefulspirit_nether_furor = class({})

if IsServer() then
	function vengefulspirit_nether_furor:OnSpellStart()
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()
		if target:GetTeam() == caster:GetTeam() then
			target:AddNewModifier(self:GetCaster(), self, "modifier_vengefulspirit_nether_furor_buff", {duration = self:GetSpecialValueFor("duration")})
			EmitSoundOn("Hero_VengefulSpirit.Attack", target)
		else
			target:AddNewModifier(self:GetCaster(), self, "modifier_vengefulspirit_nether_furor_debuff", {duration = self:GetSpecialValueFor("duration")})
			EmitSoundOn("Hero_VengefulSpirit.ProjectileImpact", target)
		end
		EmitSoundOn("Hero_VengefulSpirit.NetherSwap", caster)
	end
end

function vengefulspirit_nether_furor:GetCooldown(nLevel)
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	if self:GetCaster():HasScepter() then cooldown = self:GetSpecialValueFor("scepter_cooldown") end
	return cooldown
end

LinkLuaModifier( "modifier_vengefulspirit_nether_furor_buff", "lua_abilities/heroes/vengefulspirit.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_vengefulspirit_nether_furor_buff = class({})

function modifier_vengefulspirit_nether_furor_buff:OnCreated()
	self.dmgReduction = self:GetAbility():GetSpecialValueFor("allied_resist")
	self.dmgIncrease = self:GetAbility():GetSpecialValueFor("allied_damage")
end

function modifier_vengefulspirit_nether_furor_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
	return funcs
end

function modifier_vengefulspirit_nether_furor_buff:GetModifierDamageOutgoing_Percentage()
	return self.dmgIncrease
end

function modifier_vengefulspirit_nether_furor_buff:GetModifierIncomingDamage_Percentage()
	return self.dmgReduction
end

function modifier_vengefulspirit_nether_furor_buff:GetEffectName()
	return "particles/vengefulspirit_nether_furor_debuff.vpcf"
end

LinkLuaModifier( "modifier_vengefulspirit_nether_furor_debuff", "lua_abilities/heroes/vengefulspirit.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_vengefulspirit_nether_furor_debuff = class({})

function modifier_vengefulspirit_nether_furor_debuff:OnCreated()
	self.dmgReduction = self:GetAbility():GetSpecialValueFor("enemy_damage")
	self.dmgIncrease = self:GetAbility():GetSpecialValueFor("enemy_amp")
end

function modifier_vengefulspirit_nether_furor_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
	return funcs
end

function modifier_vengefulspirit_nether_furor_debuff:GetModifierDamageOutgoing_Percentage()
	return self.dmgReduction
end

function modifier_vengefulspirit_nether_furor_debuff:GetModifierIncomingDamage_Percentage()
	return self.dmgIncrease
end

function modifier_vengefulspirit_nether_furor_debuff:GetEffectName()
	return "particles/vengefulspirit_nether_furor_debuff.vpcf"
end