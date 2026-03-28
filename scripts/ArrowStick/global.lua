local _, world = pcall(require, "openmw.world")
local _, async = pcall(require, "openmw.async")
local util = require("openmw.util")
local storage = require("openmw.storage")
local I = require("openmw.interfaces")

local IE = require("scripts.ArrowStick.utils.impactEffects")
local consts = require("scripts.ArrowStick.utils.consts")

local settings = storage.globalSection("SettingsArrowStick")
local settingsImpactEffects = storage.globalSection("SettingsArrowStick_impactEffects")
local arrowDespawnScript = "scripts/ArrowStick/customArrow.lua"

local shotArrows = {}
local xrot
local xpos

local function rotateArrow(data)
    local obj = data.obj
    data.obj:teleport(obj.cell, obj.position, data.rotation)
end

local function onItemActive(item)
    if xrot and xpos then
        async:newUnsavableSimulationTimer(0.1, function()
            item:teleport(item.cell.name, xpos, xrot)
            xrot = nil
        end)
    end
end

local function placeArrow(data)
    local id = data.id
    local pos = data.position
    local rot = data.rotation
    local player = data.actor
    local waterPos = data.waterPos
    local hitWater = player.cell.waterLevel and pos.z < player.cell.waterLevel

    if I.impactEffects then
        local mat = IE.getMaterial(data.hitObj, hitWater)

        if settingsImpactEffects:get("impactEffects") then
            local vfxPos = hitWater and waterPos or pos
            IE.addImpactEffects(data.weapon, vfxPos, mat, player.position)
        end

        if settingsImpactEffects:get("checkMaterial") then
            if consts.unstickableMaterials[mat] then return end
        end
    end

    if hitWater and not settings:get("stickUnderwater") then return end

    local temppos = util.vector3(pos.x, pos.y, pos.z - 1000)
    local newArrow = world.createObject(id)
    newArrow:teleport(player.cell.name, temppos, rot)

    xrot = rot
    xpos = util.vector3(pos.x, pos.y, pos.z)

    if settings:get("despawnArrows") then
        newArrow:addScript(arrowDespawnScript)
        shotArrows[newArrow.id] = newArrow
    end
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
        onItemActive = onItemActive,
        onActivate = onActivate,
        onSave = onSave,
        onLoad = onLoad,
    },
    eventHandlers = {
        rotateArrow = rotateArrow,
        placeArrow = placeArrow,
        arrowInactive = arrowInactive,
    }
}
