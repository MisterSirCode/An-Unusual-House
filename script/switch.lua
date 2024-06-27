function init()
    cover = FindShape('interact')
    switch = FindShape('switch')
    branch = GetTagValue(switch, 'target')
    lightTag = 's'..branch
    lights = FindLights(lightTag, true)
    status = false
    if HasTag(switch, 'on') then
        status = true
    end
end

function tick()
    local shape = GetPlayerInteractShape()
    if shape ~= 0 and InputPressed("interact") and shape == cover then
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
                if not HasTag(light, 'broken') then
                    SetLightEnabled(light, true)
                end
            end
        end
	end
end