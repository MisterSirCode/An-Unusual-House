function init()
    cover = FindShape('interact')
    switch = FindShape('switch')
    branch = GetTagValue(switch, 'target')
    lightTag = 's'..branch
    lights = FindLights(lightTag, true)
    status = false
    -- Initialize lights and switches
    if HasTag(switch, 'on') then
        status = true
    else
        for i=1, #lights do
            local light = lights[i]
            SetLightEnabled(light, false)
        end
    end
    prevtickbroken = false
end

function tick()
    local shape = GetPlayerInteractShape()
    local dynamic = IsBodyDynamic(GetShapeBody(cover))
    local broken = IsShapeBroken(cover) or IsShapeBroken(switch)
    -- If switch broken or disconnected, cut off switchable devices
    -- not prevtickbroken protects against excessive for loops after switch is broken
    if not prevtickbroken and (broken or dynamic) then
        for i=1, #lights do
            local light = lights[i]
            SetLightEnabled(light, false)
        end
    end
    -- If switch actually damaged, disable interaction
    if broken then
        if HasTag(switch, 'interact') then
            RemoveTag(switch, 'interact')
        end
    end
    -- Interaction / Switch Flipping
    if shape ~= 0 and InputPressed('interact') and shape == cover then
        local stf = GetShapeLocalTransform(switch)
        if status then
            SetShapeLocalTransform(switch, Transform(VecAdd(stf.pos, Vec(0.1, 0, 0)), QuatEuler(40, 180, 0)))
            status = not status
            for i=1, #lights do
                local light = lights[i]
                SetLightEnabled(light, false)
            end
        elseif not status then
            SetShapeLocalTransform(switch, Transform(VecSub(stf.pos, Vec(0.1, 0, 0)), QuatEuler(40, 180, 180)))
            status = not status
            for i=1, #lights do
                local light = lights[i]
                -- Enable light as long as nothing is broken
                if not HasTag(light, 'broken') and not (broken or dynamic) then
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