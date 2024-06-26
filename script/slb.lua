function init()
    hosts = FindShapes('host')
    light = FindLight('electric')
end

function tick()
    if IsLightActive(light) then -- Cull after light is broken
        for i=1, #hosts do
            local host = hosts[i]
            if IsShapeBroken(host) then
                SetLightEnabled(light, false)
            end
        end
    end
end