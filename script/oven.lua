function init()
    broken = false
    topState = false
    ovenState = false
    topHeat = 0
    ovenHeat = 0
    topButton = FindShape('topButton')
    topElements = FindShapes('topElement')
    ovenButton = FindShape('ovenButton')
    topTrigger = FindTrigger('topBurner')
    SetTag(topButton, 'interact', 'Stove Top')
    SetTag(ovenButton, 'interact', 'Oven')
    -- Destruction Detection Stuff
    ovenBits = FindShapes('host')
    statusLoc = FindLocation('ovenStatus')
end

function checkVal(val)
    if val >= 1 then return 1
    elseif val <= 0 then return 0
    else return val end
end

function adjustVal(val, adder, state)
    if state then return checkVal(val + adder)
    else return checkVal(val - adder) end
end

function active(val)
    if val < 1 or val > 0 then return true
    else return false end
end

function round(num)
    if math.abs(num) > 2^52 then
      return num
    end
    return num < 0 and num - 2^52 + 2^52 or num + 2^52 - 2^52
end  

function tick(dt)
    -- Destruction Stuff
    if not broken then
        if HasTag(statusLoc, 'broken') then
            broken = true
        end
        for i = 0, #ovenBits do
            local elm = ovenBits[i]
            if IsShapeBroken(elm) then
                broken = true
                SetTag(statusLoc, 'broken')  
            end
        end
    else
        topState = false
        ovenState = false
        RemoveTag(topButton, 'interact')
        RemoveTag(ovenButton, 'interact')
    end
    -- Oven Code
    local ishape = GetPlayerInteractShape()
    local interacted = ishape ~= 0 and InputPressed('interact')
    if interacted and ishape == topButton then
        topState = not topState
    elseif interacted and ishape == ovenButton then
        ovenState = not ovenState
    end
    topHeat = adjustVal(topHeat, 1 / 10 * dt, topState)
    ovenHeat = adjustVal(ovenHeat, 1 / 10 * dt, ovenState)

    if active(topHeat) then
        for i = 0, #topElements do
            local element = topElements[i]
            SetShapeEmissiveScale(element, topHeat)
        end
    end
    if topHeat > 0 then
        local min, max = GetTriggerBounds(topTrigger)
        local shapes = QueryAabbShapes(min, max)
        for i = 0, #shapes do
            local shape = shapes[i]
            local pos = GetShapeWorldTransform(shape).pos
            AddHeat(shape, pos, topHeat * 2 * dt)
        end
    end
end