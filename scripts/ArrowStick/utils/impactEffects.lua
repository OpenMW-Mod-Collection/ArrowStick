local time = require("openmw_aux.time")
local core = require("openmw.core")
local types = require("openmw.types")
local I = require("openmw.interfaces")

local IE = {}

IE.getMaterial = function(hitObj, hitWater)
    if hitWater then
        return "Water"
    elseif hitObj then
        return I.impactEffects.getMaterialByObject(hitObj)
    else
        return "Dirt"
    end
end

local delayedImpactEffect = time.registerTimerCallback(
    "ArrowStick_ImpactEffect",
    function(params)
        I.impactEffects.spawnEffect(params)
    end
)

IE.addImpactEffects = function(weapon, hitPos, mat, playerPos)
    local weaponType = weapon.type.record(weapon).type
    local isThrown = weaponType == types.Weapon.TYPE.MarksmanThrown
    local projectileSpeed = isThrown
        and core.getGMST("fThrownWeaponMaxSpeed")
        or core.getGMST("fProjectileMaxSpeed")

    local delta = playerPos - hitPos
    local distance = delta:length()

    time.newSimulationTimer(
        distance / projectileSpeed,
        delayedImpactEffect,
        { material = mat, hitPos = hitPos }
    )
end

return IE
