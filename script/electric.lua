function init()
    panel = FindShape('panel')
    lights = FindLights('electric', true)
end

function tick()
    if IsShapeBroken(panel) then
        for i = 1, #lights do
            SetLightEnabled(lights[i], false)
        end
    end
end