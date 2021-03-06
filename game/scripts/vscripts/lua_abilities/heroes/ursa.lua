LinkLuaModifier( "modifier_fury_swipes_bonus_damage", "scripts/vscripts/lua_abilities/heroes/ursa.lua", LUA_MODIFIER_MOTION_NONE )

function fury_swipes_check_stacks( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target"
	local modifierNameB = "modifier_fury_swipes_bonus_damage"
	
	target.stacks = target:GetModifierStackCount( modifierName, ability )
	ability:ApplyDataDrivenModifier( caster, caster, modifierNameB, {} )
end

function fury_swipes_attack( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target"
	local damageType = ability:GetAbilityDamageType()
	
	if target:IsBuilding() then return end
	if caster:IsIllusion() then return end

	-- Necessary value from KV
	local duration = ability:GetTalentSpecialValueFor( "duration")

	local current_stack = target.stacks or 1

	-- Check if unit already have stack
	-- Apply modifier to target
	ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
	target:SetModifierStackCount( modifierName, ability, current_stack )
	
	if caster:HasModifier("modifier_ursa_claw") and caster:HasScepter() then
        local ability_claw = caster:FindAbilityByName("ursa_claw")
		local damage = ( target.stacks ) * (ability:GetTalentSpecialValueFor("bonus_damage_per_stack"))
        local percent = ability_claw:GetTalentSpecialValueFor("Pierce_percent_fury")*0.01
        local multiplier = ability_claw:GetTalentSpecialValueFor("physical_fury_damage_mult")*0.01
        local damageTable_fury = {victim = target,
                        attacker = caster,
                        damage = damage*percent*multiplier,
                        ability = keys.ability,
                        damage_type = DAMAGE_TYPE_PURE,
						damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
                        }
        ApplyDamage(damageTable_fury)
    end
	

end

-- FURY SWIPES DAMAGE MODIFIERS
if modifier_fury_swipes_bonus_damage == nil then
	modifier_fury_swipes_bonus_damage = class({})
end

function modifier_fury_swipes_bonus_damage:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end

function modifier_fury_swipes_bonus_damage:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_fury_swipes_bonus_damage:IsHidden()
	return true
end

function modifier_fury_swipes_bonus_damage:GetModifierProcAttack_BonusDamage_Physical(params)
    local caster = params.attacker
    local target = params.target
	local multiplier = 1
	local adder = 1
    if caster:IsIllusion() then return 0 end
	if caster:HasModifier( "modifier_ursa_claw" ) then
        local ability_claw = caster:FindAbilityByName("ursa_claw")
		multiplier = ability_claw:GetTalentSpecialValueFor("physical_fury_damage_mult")*0.01
	end
	if caster:HasModifier( "modifier_overpower_buff_datadriven" ) and caster:HasScepter() then
		adder = caster:FindAbilityByName("ursa_overpower_ebf"):GetTalentSpecialValueFor("fury_swipes_per_hit_scepter")
	end
	local nFurySwipes = ( target.stacks + adder) * (self:GetAbility():GetTalentSpecialValueFor("bonus_damage_per_stack")) * multiplier
    
    target.stacks = target.stacks + adder
    return nFurySwipes
end

function Pierce_skill(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local percent = ability:GetTalentSpecialValueFor("Pierce_percent", ability:GetLevel()-1)
    local damage = keys.damage_on_hit*percent*0.01
    local damageTable = {victim = target,
                attacker = caster,
                damage = damage/get_aether_multiplier(caster),
                ability = keys.ability,
                damage_type = DAMAGE_TYPE_PURE,
                }
    ApplyDamage(damageTable)
end

function overpower_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_overpower_buff_datadriven"
	local duration = ability:GetTalentSpecialValueFor( "duration_tooltip")
	local max_stack = ability:GetTalentSpecialValueFor( "max_attacks")
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { } )
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_overpower_attackspeed", {duration = duration} )
	caster:SetModifierStackCount( modifierName, ability, max_stack )
end

function overpower_decrease_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local max_stack = ability:GetTalentSpecialValueFor( "max_attacks")
	local armorreduc = ability:GetTalentSpecialValueFor( "debuff_minus_armor")
	local armorreducperc = ability:GetTalentSpecialValueFor( "debuff_altminus_armor") / 100
	local armor = target:GetPhysicalArmorBaseValue()
	
	local modifierName = "modifier_overpower_buff_datadriven"
	local demodifierName = "modifier_overpower_debuff_datadriven"
	if math.abs(max_stack*armorreduc) < math.abs(max_stack*armorreducperc*armor) then
		demodifierName = "modifier_overpower_altdebuff_datadriven"
	end
	local current_stack = caster:GetModifierStackCount( modifierName, ability )
	local current_destack = target:GetModifierStackCount( demodifierName, ability )
	local duration = ability:GetTalentSpecialValueFor("debuff_duration")
	if demodifierName == "modifier_overpower_altdebuff_datadriven" then
		local stackmodifier = "modifier_overpower_altdebuff_datadriven_stacks"
		local sunder = armorreducperc*armor
		target:RemoveModifierByName(stackmodifier)
		ability:ApplyDataDrivenModifier( caster, target, stackmodifier, {duration = duration} )
		target:SetModifierStackCount( stackmodifier, ability, (current_destack + 1 ) * sunder)
	end
	
	
	
	-- PLACE AND REFRESH DEBUFF --
	target:RemoveModifierByName(demodifierName)
	ability:ApplyDataDrivenModifier( caster, target, demodifierName, {duration = duration} )
	target:SetModifierStackCount( demodifierName, ability, current_destack + 1)
	
	if current_stack > 1 then
		caster:SetModifierStackCount( modifierName, ability, current_stack - 1 )
	else
		caster:RemoveModifierByName( modifierName )
	end
end


ursa_claw = class({})

function ursa_claw:GetBehavior()
	local val = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	if self:GetCaster():HasScepter() then val = val + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE end
	return val
end

function ursa_claw:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Ursa.Enrage", caster)
	if caster:HasScepter() then
		caster:Dispel(caster, true)
	end
	caster:AddNewModifier(caster, self, "modifier_ursa_claw", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_ursa_claw = class({})
LinkLuaModifier("modifier_ursa_claw", "lua_abilities/heroes/ursa", LUA_MODIFIER_MOTION_NONE)

function modifier_ursa_claw:OnCreated()
	self.pierce = self:GetTalentSpecialValueFor("Pierce_percent") / 100
	self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_ursa_claw:OnRefresh()
	self.pierce = self:GetTalentSpecialValueFor("Pierce_percent") / 100
	self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_ursa_claw:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_ursa_claw:GetModifierIncomingDamage_Percentage()
	return self.reduction
end

function modifier_ursa_claw:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage(self:GetParent(), params.target, params.damage * self.pierce)
	end
end

function modifier_ursa_claw:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_ursa_claw:GetHeroEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_hero_effect.vpcf"
end

function modifier_ursa_claw:HeroEffectPriority()
	return 10
end
