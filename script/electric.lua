function init()
    panel = FindShape('panel')
    lights = FindLights('electric', true)
end

function tick()
    if IsShapeBroken(panel) then
        for i = 1, #lights do
            local light = lights[i]
            SetLightEnabled(light, false)
            if not HasTag(light, 'broken') then
                SetTag(light, 'broken')
            end
        end
    end
end