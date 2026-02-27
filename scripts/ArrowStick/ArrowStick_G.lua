local _, world = pcall(require, "openmw.world")
local _, async = pcall(require, "openmw.async")
local util = require("openmw.util")

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
    async:newUnsavableSimulationTimer(0.1, function()
        local id = data.id
        local pos = data.position
        local rot = data.rotation
        local player = data.actor
        -- print(id, pos, rot)

        local temppos = util.vector3(pos.x, pos.y, pos.z - 1000)
        local newArrow = world.createObject(id)
        newArrow:teleport(player.cell.name, temppos, rot)

        xrot = rot
        xpos = util.vector3(pos.x, pos.y, pos.z)
    end)
end

return {
    engineHandlers = {
        onItemActive = onItemActive,
    },
    eventHandlers = {
        rotateArrow = rotateArrow,
        placeArrow = placeArrow,
    }
}
