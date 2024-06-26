function init()
    host = FindShape('host')
    light = FindLight('electric')
end

function tick()
    if IsShapeBroken(host) then
        SetLightEnabled(light, false)
    end
end