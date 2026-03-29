local world = require("openmw.world")
local storage = require("openmw.storage")
local I = require("openmw.interfaces")
local core = require("openmw.core")

local IE = require("scripts.ArrowStick.utils.impactEffects")
local consts = require("scripts.ArrowStick.utils.consts")

local settings = storage.globalSection("SettingsArrowStick")
local settingsImpactEffects = storage.globalSection("SettingsArrowStick_impactEffects")
local arrowDespawnScript = "scripts/ArrowStick/customArrow.lua"

local shotArrows = {}

local function placeNewArrow(data)
    local id = data.id
    local pos = data.position
    local rot = data.rotation
    local player = data.actor
    local waterPos = data.waterPos
    local hitWater = player.cell.waterLevel and pos.z < player.cell.waterLevel

    if I.impactEffects then
        local mat = IE.getMaterial(data.hitObj, hitWater)

        if settingsImpactEffects:get("impactEffects") then
            I.impactEffects.spawnEffect({
                material = mat,
                hitPos = hitWater and waterPos or pos,
            })
        end

        if settingsImpactEffects:get("checkMaterial")
            and consts.unstickableMaterials[mat]
        then
            return
        end
    end

    if hitWater and not settings:get("stickUnderwater") then return end

    local newArrow = world.createObject(id)
    newArrow:teleport(player.cell.name, pos, rot)

    if settings:get("despawnArrows") then
        newArrow:addScript(arrowDespawnScript)
        shotArrows[newArrow.id] = newArrow
    end

    core.sendGlobalEvent("ArrowStick_ArrowPlaced", {
        item = newArrow,
        position = pos,
    })
end

local function onSave()
    return {
        shotArrows = shotArrows
    }
end

local function onLoad(saveData)
    shotArrows = saveData.shotArrows or {}
end

local function onActivate(obj, actor)
    if shotArrows[obj.id] then
        shotArrows[obj.id] = nil
    end
end

local function arrowInactive(id)
    local arrow = shotArrows[id]
    shotArrows[id] = nil
    if not arrow or not arrow:isValid() then return end
    arrow:remove()
    arrow:removeScript(arrowDespawnScript)
end

return {
    engineHandlers = {
        onActivate = onActivate,
        onSave = onSave,
        onLoad = onLoad,
    },
    eventHandlers = {
        ArrowStick_PlaceNewArrow = placeNewArrow,
        ArrowStick_ArrowInactive = arrowInactive,
    }
}
