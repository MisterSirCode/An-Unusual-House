function init()
    cover = FindShape('interact')
    switchon = FindShape('switchon')
    switchoff = FindShape('switchoff')
    branch = GetTagValue(cover, 'target')
    lights = FindLights('s'..branch, true)
    lightHosts = FindShapes('lh'..branch, true)
    status = false
    -- Initialize lights and switches
    if HasTag(cover, 'on') then
        status = true
    else
        for i=1, #lights do
            local light = lights[i]
            SetLightEnabled(light, false)
        end
        SetTag(switchon, 'invisible')
        RemoveTag(switchoff, 'invisible')
    end
    prevtickbroken = false
end

function tick()
    local shape = GetPlayerInteractShape()
    -- prevtickbroken protects against excessive for loops and checks after switch is broken
    if not prevtickbroken then
        dynamic = IsBodyDynamic(GetShapeBody(cover))
        broken = IsShapeBroken(cover) or IsShapeBroken(switchon) or IsShapeBroken(switchoff)
    end
    -- If switch broken or disconnected, cut off switchable devices
    if not prevtickbroken and (broken or dynamic) then
        for i=1, #lights do
            local light = lights[i]
            SetLightEnabled(light, false)
        end
    end
    -- If switch actually damaged, disable interaction
    if broken then
        if HasTag(cover, 'interact') then
            RemoveTag(cover, 'interact')
        end
    end
    -- Interaction / Switch Flipping
    if shape ~= 0 and InputPressed('interact') and shape == cover then
        if status then
            SetTag(switchon, 'invisible')
            RemoveTag(switchoff, 'invisible')
            status = not status
            for i=1, #lights do
                local light = lights[i]
                SetLightEnabled(light, false)
            end
        elseif not status then
            SetTag(switchoff, 'invisible')
            RemoveTag(switchon, 'invisible')
            status = not status
            for i=1, #lights do
                local light = lights[i]
                local debug = HasTag(light, 'debug')
                -- Enable light as long as nothing is broken
                if not HasTag(light, 'broken') and not (broken or dynamic) then
                    if debug then DebugWatch(light, HasTag(light, 'broken')) end
                    SetLightEnabled(light, true)
                end
            end
        end
	end
    -- Protection against excessive for loops after switch is broken
    if broken or dynamic then
        prevtickbroken = true
    end
end