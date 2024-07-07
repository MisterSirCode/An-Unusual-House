function init()
    panel = FindShape('panel')
    lights = FindLights('electric', true)
    buttons = FindShapes('elcbtn', true)
    motors = FindShapes('motor', true)
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
        for i = 1, #buttons do
            local button = buttons[i]
            SetShapeEmissiveScale(button, 0)
            RemoveTag(button, 'interact')
        end
        for i = 1, #motors do
            local motor = motors[i]
            SetTag(motor, 'broken')
        end
    end
end