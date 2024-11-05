function init()
	vehicle = FindVehicle("vehicle") 
	joint = FindJoint("joint")
	SteeringWheel = FindShape("SteeringWheel")
	disableSteering = GetBoolParam("disableSteering", false)
	enableHorn = GetBoolParam("enableHorn", false)
	vehBody = FindBody("vehBody")
	if enableHorn == true then
		hornSound = GetStringParam("hornSound", "none")
		horn = LoadLoop(hornSound)
		--DebugPrint(hornSound)
	end

	TextPostion = 905
	CurrentSpeed = 0
end

function tick()
	com = GetBodyCenterOfMass(vehBody)
	BodyCenterPos = TransformToParentPoint(GetBodyTransform(vehBody), com)
	sndHornPos = VecAdd(BodyCenterPos, Vec(0,0.5,0))
	--DebugCross(sndHornPos)
	if IsJointBroken(joint) == false then
		if GetPlayerVehicle() == vehicle then
			if InputDown("d") then
				SetJointMotorTarget(joint, -100, 3.8)
			else
				SetJointMotorTarget(joint, 0, 3.8)
			end
			if InputDown("a") then
				SetJointMotorTarget(joint, 100, 3.8)
			end
			if InputDown("d") and InputDown("a") then
				SetJointMotorTarget(joint, 0, 3.8)
			end
		else
			SetJointMotorTarget(joint, 0, 3.8)
		end
	else
		if disableSteering == true then
			if GetPlayerVehicle() == vehicle then
				if InputDown("d") and InputDown("a") == false then
					DriveVehicle(vehicle, 0, 1, false)
				elseif InputDown("a") and InputDown("d") == false then
					DriveVehicle(vehicle, 0, -1, false)
				end
			end
		end
	end
	if enableHorn == true then
		if GetPlayerVehicle() == vehicle then
			if IsJointBroken(joint) == false and IsShapeBroken(SteeringWheel) == false then
				if InputDown("g") then
					PlayLoop(horn, sndHornPos, 1)
				end
			end
		end
	end
	health = GetFloat("game.player.health")
	BoxPosition = TextPostion - 7
	if health < 1 then
		if TextPostion > 856 then
			TextPostion = TextPostion - CurrentSpeed
			if CurrentSpeed < 10 then
				CurrentSpeed = CurrentSpeed + 1
			end
		else
			CurrentSpeed = 0
		end
	else
		if TextPostion < 905 then
			TextPostion = TextPostion + CurrentSpeed
			if CurrentSpeed < 30 then
				CurrentSpeed = CurrentSpeed + 1
			end
		else
			CurrentSpeed = 0
		end
	end
end

function draw()
	if enableHorn == true then
		if GetPlayerVehicle() == vehicle then
			UiPush()
				UiColor(0,0,0,0.5)
				UiTranslate(1685, BoxPosition)
				UiAlign("middle left")
				UiImageBox("ui/common/box-solid-6.png", 214, 35, 6, 6)
			UiPop()
			UiPush()
				UiTranslate(1753, TextPostion)
				UiFont("bold.ttf", 24)
				UiText("G")
			UiPop()
			UiPush()
				UiTranslate(1782, TextPostion)
				UiFont("regular.ttf", 24)
				UiText("Horn")
			UiPop()
		end
	end
end
