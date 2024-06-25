function init()
    panel = FindBody('panel')
    lights = FindLights('electric', true)
end

function tick()
    if IsBodyBroken(panel) then
        for i = 1, #lights do
            SetLightEnabled(lights[i], false)
        end
    end
end