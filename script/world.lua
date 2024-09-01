function init()
    activeList = FindBodies("activebodies", true)
    DebugWatch("Activebodies = ", #activeList)
end

function tick()
    for tag,handle in pairs(activeList) do
        SetBodyActive(handle, true)
        DrawBodyOutline(handle, 0, 1, 0, 1)
        DebugWatch(tag, handle)
    end
end

-- Thanks to lociee on discord for figuring out height-adjustment
-- TODO: Fix grab position
-- function tick()
--     local cameraTransform = GetPlayerCameraTransform()
--     local worldOffset = VecAdd(cameraTransform.pos, Vec(0, 0.4, 0))
--     local cameraOffsetTransform = TransformToLocalTransform(cameraTransform, Transform(worldOffset, cameraTransform.rot))
    
--     SetCameraOffsetTransform(cameraOffsetTransform)
-- end