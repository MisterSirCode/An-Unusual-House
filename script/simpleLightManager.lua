function init()
    hosts = FindShapes('host')
    lights = FindLights('electric')
    debug = HasTag(light, 'debug')
end

function tick()
    for i = 1, #lights do
        local light = lights[i]
        if not HasTag(light, 'broken') then -- Cull after light is broken
            for i=1, #hosts do
                local host = hosts[i]
                if IsShapeBroken(host) then
                    SetLightEnabled(light, false)
                    if debug then DebugWatch('SLM_'..light, 'broken') end
                    SetTag(light, 'broken')
                end
            end
        end
    end
end