function init()
	door_fl = FindShape("door_fl")
	door_fr = FindShape("door_fr")
	door_bl = FindShape("door_bl")
	door_br = FindShape("door_br")
	door_slide_r = FindShape("door_slide_r")
	door_slide_l = FindShape("door_slide_l")
	trunk = FindShape("trunk")

	vehicle = FindVehicle("vehicle")
	vehBody = FindBody("vehBody")
	--vehShape = FindShape("vehShape")

	joint_fl = FindJoint("joint_fl")
	joint_fr = FindJoint("joint_fr")
	joint_bl = FindJoint("joint_bl")
	joint_br = FindJoint("joint_br")
	joint_slide_l = FindJoint("joint_slide_l")
	joint_slide_r = FindJoint("joint_slide_r")
	joint_trunk = FindJoint("joint_trunk")

	DoorClosedFl = true
	DoorClosedFr = true
	DoorClosedBl = true
	DoorClosedBr = true
	DoorClosedSlideL = true
	DoorClosedSlideR = true
	DoorClosedTrunk = true
	angle = 3
	MaxSlidingDoorDeviation = 0.05
end

OpenedDoorSndChime = GetStringParam("OpenedDoorSndChimeFile", "MOD/snd/Door Sounds/OpenedDoorSnd.ogg")
DoorOpeningSndFile = GetStringParam("DoorOpeningSndFile", "MOD/snd/Door Sounds/DoorOpeningSnd.ogg")
DoorClosingSnd = GetStringParam("DoorClosingSndFile", "MOD/snd/Door Sounds/DoorClosingSnd.ogg")

OpenedDoorSnd = LoadLoop(OpenedDoorSndChime)
DoorOpeningSnd = LoadSound(DoorOpeningSndFile)
DoorClosingSnd = LoadSound(DoorClosingSnd)
OpenedDoorSignalization = GetBoolParam("OpenedDoorSignalization", false)

function tick()
	com = GetBodyCenterOfMass(vehBody)
	BodyCenterPos = TransformToParentPoint(GetBodyTransform(vehBody), com)
	vehPos = VecAdd(BodyCenterPos, Vec(0,1,0))
	--DebugCross(vehPos)

	door_flPos = GetShapeWorldTransform(door_fl).pos
	door_frPos = GetShapeWorldTransform(door_fr).pos
	door_blPos = GetShapeWorldTransform(door_bl).pos
	door_brPos = GetShapeWorldTransform(door_br).pos
	door_slide_rPos = GetShapeWorldTransform(door_slide_r).pos
	door_slide_lPos = GetShapeWorldTransform(door_slide_l).pos
	door_trunkPos = GetShapeWorldTransform(trunk).pos


	currentAngleFl = GetJointMovement(joint_fl)
	currentAngleFr = GetJointMovement(joint_fr)
	currentAngleBl = GetJointMovement(joint_bl)
	currentAngleBr = GetJointMovement(joint_br)
	currentAngleSlideL = GetJointMovement(joint_slide_l)
	currentAngleSlideR = GetJointMovement(joint_slide_r)
	currentAngleTrunk = GetJointMovement(joint_trunk)

	function chime()
		if OpenedDoorSignalization == true and GetPlayerVehicle() == vehicle and GetVehicleHealth(vehicle) > 0.2 then
			PlayLoop(OpenedDoorSnd, vehPos, 0.7)
		end
	end

	if IsShapeBroken(door_slide_r) == false then
        if GetPlayerGrabShape() == door_slide_r then
            SetJointMotor(joint_slide_r, 0, 0)
        else
            if currentAngleSlideR < MaxSlidingDoorDeviation then
                SetJointMotor(joint_slide_r, 1)
            else
                SetJointMotor(joint_slide_r, 0, 0)
            end
        end
    else
		SetJointMotor(joint_slide_r, 0, 0)
    end
	if currentAngleSlideR < MaxSlidingDoorDeviation then
		if DoorClosedSlideR == false then
			PlaySound(DoorClosingSnd, door_slide_rPos, 1)
			DoorClosedSlideR = true
		end
	else
		if DoorClosedSlideR == true and currentAngleSlideR > 0.05 and IsShapeBroken(door_slide_r) == false then
			PlaySound(DoorOpeningSnd, door_slide_rPos, 1)
			DoorClosedSlideR = false
		end
	end


	if IsShapeBroken(door_slide_l) == false then
		if GetPlayerGrabShape() == door_slide_l then
			SetJointMotor(joint_slide_l, 0, 0)
		else
			if currentAngleSlideL < MaxSlidingDoorDeviation then
				SetJointMotor(joint_slide_l, 1)
			else
				SetJointMotor(joint_slide_l, 0, 0)
			end
		end
	else
		SetJointMotor(joint_slide_l, 0, 0)
    end
	if currentAngleSlideL < MaxSlidingDoorDeviation then
		if DoorClosedSlideL == false then
			PlaySound(DoorClosingSnd, door_slide_lPos, 1)
			DoorClosedSlideL = true
		end
	else
		if DoorClosedSlideL == true and currentAngleSlideL > 0.05 and IsShapeBroken(door_slide_l) == false then
			PlaySound(DoorOpeningSnd, door_slide_lPos, 1)
			DoorClosedSlideL = false
		end
	end






	if IsShapeBroken(door_fl) == false then
        if GetPlayerGrabShape() == door_fl then
            SetJointMotor(joint_fl, 0, 0)
        else
            if currentAngleFl < angle then
                SetJointMotor(joint_fl, 1)
            else
                SetJointMotor(joint_fl, 0, 0)
            end
        end
    else
        SetJointMotor(joint_fl, 0, 0)
    end
	if currentAngleFl < angle then
		if DoorClosedFl == false then
			PlaySound(DoorClosingSnd, door_flPos, 1)
			DoorClosedFl = true
		end
	else
		if DoorClosedFl == true and currentAngleFl > 0.7 and IsShapeBroken(door_fl) == false then
			PlaySound(DoorOpeningSnd, door_flPos, 1)
			DoorClosedFl = false
		end
	end

	if IsShapeBroken(door_fr) == false then
        if GetPlayerGrabShape() == door_fr then
            SetJointMotor(joint_fr, 0, 0)
        else
            if currentAngleFr < angle then
                SetJointMotor(joint_fr, 1)
            else
                SetJointMotor(joint_fr, 0, 0)
            end
        end
    else
        SetJointMotor(joint_fr, 0, 0)
    end
	if currentAngleFr < angle then
		if DoorClosedFr == false then
			PlaySound(DoorClosingSnd, door_frPos, 1)
			DoorClosedFr = true
		end
	else
		if DoorClosedFr == true and currentAngleFr > 0.7 and IsShapeBroken(door_fr) == false then
			PlaySound(DoorOpeningSnd, door_frPos, 1)
			DoorClosedFr = false
		end
	end

	if IsShapeBroken(door_bl) == false then
        if GetPlayerGrabShape() == door_bl then
            SetJointMotor(joint_bl, 0, 0)
        else
            if currentAngleBl < angle then
                SetJointMotor(joint_bl, 1)
            else
                SetJointMotor(joint_bl, 0, 0)
            end
        end
    else
        SetJointMotor(joint_bl, 0, 0)
    end
	if currentAngleBl < angle then
		if DoorClosedBl == false then
			PlaySound(DoorClosingSnd, door_blPos, 1)
			DoorClosedBl = true
		end
	else
		if DoorClosedBl == true and currentAngleBl > 0.7 and IsShapeBroken(door_bl) == false then
			PlaySound(DoorOpeningSnd, door_blPos, 1)
			DoorClosedBl = false
		end
	end

	if IsShapeBroken(door_br) == false then
        if GetPlayerGrabShape() == door_br then
            SetJointMotor(joint_br, 0, 0)
        else
            if currentAngleBr < angle then
                SetJointMotor(joint_br, 1)
            else
                SetJointMotor(joint_br, 0, 0)
            end
        end
    else
        SetJointMotor(joint_br, 0, 0)
    end
	if currentAngleBr < angle then
		if DoorClosedBr == false then
			PlaySound(DoorClosingSnd, door_brPos, 1)
			DoorClosedBr = true
		end
	else
		if DoorClosedBr == true and currentAngleBr > 0.7 and IsShapeBroken(door_br) == false then
			PlaySound(DoorOpeningSnd, door_brPos, 1)
			DoorClosedBr = false
		end
	end

	if IsShapeBroken(trunk) == false then
        if GetPlayerGrabShape() == trunk then
            SetJointMotor(joint_trunk, 0, 0)
        else
            if currentAngleTrunk < angle then
                SetJointMotor(joint_trunk, 1)
            else
                SetJointMotor(joint_trunk, 0, 0)
            end
        end
    else
        SetJointMotor(joint_trunk, 0, 0)
    end
	if currentAngleTrunk < angle then
		if DoorClosedTrunk == false then
			PlaySound(DoorClosingSnd, door_trunkPos, 1)
			DoorClosedTrunk = true
		end
	else
		if DoorClosedTrunk == true and currentAngleTrunk > 0.7 and IsShapeBroken(trunk) == false then
			PlaySound(DoorOpeningSnd, door_trunkPos, 1)
			DoorClosedTrunk = false
		end
	end

	if currentAngleFr > angle and IsJointBroken(joint_fr) == false or IsJointBroken(joint_fl) == false and currentAngleFl > angle then
        chime()
    end
end


