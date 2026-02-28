local core = require("openmw.core")
local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local util = require('openmw.util')
local I = require("openmw.interfaces")
local async = require("openmw.async")

local rotOffset = 0
local arrowId
local equipment = types.Actor.getEquipment(self)
local weapon = equipment[types.Actor.EQUIPMENT_SLOT.CarriedRight]
local arrow = equipment[types.Actor.EQUIPMENT_SLOT.Ammunition]

local function anglesToV(pitch, yaw)
    local xzLen = math.cos(pitch)
    return util.vector3(
        xzLen * math.sin(yaw), -- x
        xzLen * math.cos(yaw), -- y
        math.sin(pitch)        -- z
    )
end

local function getRotation(rot, angle)
    local z, y, x = rot:getAnglesZYX()
    return { x = x, y = y, z = z }
end

local function getCameraDirData(sourcePos)
    local pos = sourcePos
    local pitch, yaw

    pitch = -(camera.getPitch() + camera.getExtraPitch())
    yaw = (camera.getYaw() + camera.getExtraYaw())

    return pos, anglesToV(pitch, yaw)
end

local function getObjInCrosshairs(ignoredObj, mdist, alwaysPost, sourcePos)
    if not sourcePos then
        sourcePos = camera.getPosition()
    end
    local pos, v = getCameraDirData(sourcePos)

    local dist = 8500
    if (mdist ~= nil) then dist = mdist end

    local ret = nearby.castRenderingRay(pos, pos + v * dist, { ignore = ignoredObj })
    local ret2 = nearby.castRay(pos, pos + v * dist, { ignore = ignoredObj })
    local destPos = (pos + v * dist)

    return ret, ret2, destPos
end

local function createRotation(x, y, z)
    if (core.API_REVISION < 40) then
        return util.vector3(x, y, z)
    else
        local rotate = util.transform.rotateZ(z)
        local rotateX = util.transform.rotateX(x)
        local rotateY = util.transform.rotateY(y)
        ---@diagnostic disable-next-line: undefined-field
        rotate = rotate:__mul(rotateY)
        rotate = rotate:__mul(rotateX)
        return rotate
    end
end

local function placeNewArrow()
    local xRot = camera.getPitch() - math.rad(rotOffset)
    local zRot = getRotation(self.rotation).z -- math.rad(rotOffset2)
    local cast, cast2 = getObjInCrosshairs(self, nil, false, nil)

    -- Fired arrows will go through solid items, so need to check if it would have hit an NPC,
    -- otherwise you can get it stuck in a bottle, but still hit someone.
    if not cast.hitPos
        or (cast.hitObject and (cast.hitObject.type == types.NPC or cast.hitObject.type == types.Creature))
        or (cast2.hitObject and (cast2.hitObject.type == types.NPC or cast2.hitObject.type == types.Creature))
    then
        return
    end

    local newRot = createRotation(xRot, 0, zRot)
    local newPos = cast.hitPos
    core.sendGlobalEvent("placeArrow", {
        rotation = newRot,
        id = arrowId,
        position = newPos,
        actor = self.object
    })
end

local function attackMade(groupName, key)
    if key == "shoot start" then
        -- gotta get them in advance
        -- otherwise last arrow won't stick
        equipment = types.Actor.getEquipment(self)
        weapon    = equipment[types.Actor.EQUIPMENT_SLOT.CarriedRight]
        arrow     = equipment[types.Actor.EQUIPMENT_SLOT.Ammunition]
    elseif key == "shoot release" then
        if not (weapon and weapon.type == types.Weapon) then return end

        local weaponType = weapon.type.record(weapon).type
        local isBow      = weaponType == types.Weapon.TYPE.MarksmanBow
        local isCrossbow = weaponType == types.Weapon.TYPE.MarksmanCrossbow
        local isThrown   = weaponType == types.Weapon.TYPE.MarksmanThrown

        if isBow or isCrossbow then
            rotOffset = 0
        elseif isThrown then
            rotOffset = 180
            arrow = weapon
        else
            return
        end

        if not arrow then return end
        arrowId = arrow.recordId
    end
end

local function onFrame()
    if arrowId then
        placeNewArrow()
        arrowId = nil
    end
end

I.AnimationController.addTextKeyHandler("bowandarrow", attackMade)
I.AnimationController.addTextKeyHandler("crossbow", attackMade)
I.AnimationController.addTextKeyHandler("throwweapon", attackMade)

return {
    engineHandlers = {
        onFrame = onFrame
    }
}
