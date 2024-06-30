function init()
	speed = GetFloatParam("speed", 1)
	initOpen = GetBoolParam("open", false)
	noMotor = GetBoolParam("noMotor", false)
	motorSndStr = GetStringParam("motorSound", "")
	gateSndStr = GetStringParam("gateSound", "")
	haveMotorSnd = #motorSndStr ~= 0
	haveGateSnd = #gateSndStr ~= 0
	local pattern = "([^:]+):?([%d%.]*):?([%d%.]*)"
	if haveMotorSnd then
		motorSndPath = motorSndStr:gsub(pattern, "%1", 1)
		local digitStr = motorSndStr:gsub(pattern, "%2", 1)
		local sndDist = motorSndStr:gsub(pattern, "%3", 1)
		motorSndVolume = tonumber(digitStr) or 1
		motorSnd = LoadLoop(motorSndPath, tonumber(sndDist))
	end
	if haveGateSnd then
		gateSndPath = gateSndStr:gsub(pattern, "%1", 1)
		local digitStr = gateSndStr:gsub(pattern, "%2", 1)
		local sndDist = gateSndStr:gsub(pattern, "%3", 1)
		gateSndVolume = tonumber(digitStr) or 1
		gateSnd = LoadLoop(gateSndPath, tonumber(sndDist))
	end
	tracks = FindShapes("gateTrack")
	topGate = FindBody("gateTop")
	gateShapes = FindShapes("gateDoor")
	startShape = tracks[#tracks]
	endShape = tracks[#tracks-1]
	if not noMotor then
		gateCtrl = FindShape("gateCtrl")
		ctrlBody = GetShapeBody(gateCtrl)
		jointLocPos = GetLocationTransform(FindLocation("gateJoint")).pos
		startPos = GetShapeLocalTransform(startShape).pos
		endPos = GetShapeLocalTransform(endShape).pos
		moveVal = initOpen and 1 or 0
		moveShape = initOpen and endShape or startShape
		SetShapeCollisionFilter(moveShape, 8, 255-8)
		Delete(initOpen and startShape or endShape)
		trackBody = GetShapeBody(moveShape)
		shapePos = TransformToLocalPoint(GetShapeWorldTransform(moveShape), jointLocPos)
		doorPos = TransformToLocalPoint(GetBodyTransform(topGate), jointLocPos)
	end
	gateData = {}
	for i=1, #gateShapes do
		SetShapeCollisionFilter(gateShapes[i], 8, 255-8)
		local sx, sy = GetShapeSize(gateShapes[i])
		local shapeBody = GetShapeBody(gateShapes[i])
		gateData[#gateData+1] = {shapeBody, Vec(sx/20, 0, 0), Vec(-sx/20, 0, 0)}
		if shapeBody == topGate and noMotor then
			gateData[#gateData+1] = {shapeBody, Vec(sx/20, sy/10, 0), Vec(-sx/20, sy/10, 0)}
		end
	end
	leftTrack = {}
	rightTrack = {}
	for i=1, 4 do rightTrack[i] = {tracks[i], GetShapeBody(tracks[i])} SetShapeCollisionFilter(tracks[i], 8, 255-8) end
	for i=1, 4 do leftTrack[i] = {tracks[i+4], GetShapeBody(tracks[i+4])} SetShapeCollisionFilter(tracks[i+4], 8, 255-8) end
	hold = false
	holdVal = 0
	motorBroken = false
	gateBroken = false
	ctrlBroken = false
	soundVelThres = 0.15*speed
end

function tick()
	if not haveMotorSnd then return end
	if noMotor or ctrlBroken then return end
	local tagValue = GetTagValue(gateCtrl, "gateCtrl")
	if (tagValue ~= "open") or (tagValue ~= "close") then return end
	if (moveVal < 1) and (moveVal > 0) then
		local min, max = GetShapeBounds(gateCtrl)
		local shapeCentre = VecLerp(min, max, 0.5)
		PlayLoop(motorSnd, shapeCentre, motorSndVolume)
	end
end

function update()
	if motorBroken and gateBroken and ctrlBroken then return end

	ctrlBroken = ctrlBroken or IsShapeBroken(gateCtrl) or not IsHandleValid(gateCtrl) or ctrlBody ~= GetShapeBody(gateCtrl)
	if not (noMotor or ctrlBroken) then
		local tagValue = GetTagValue(gateCtrl, "gateCtrl")
		if tagValue == "open" then
			if moveVal < 1 then moveVal = moveVal + speed/600 else moveVal = 1 SetTag(gateCtrl, "gateCtrl", "") end
		elseif tagValue == "close" then
			if moveVal > 0 then moveVal = moveVal - speed/600 else moveVal = 0 SetTag(gateCtrl, "gateCtrl", "") end
		end
	end

	motorBroken = motorBroken or IsShapeBroken(moveShape) or not IsHandleValid(moveShape) or trackBody ~= GetShapeBody(moveShape)
	if not (motorBroken or noMotor) then
		local shapeRot = GetShapeLocalTransform(moveShape).rot
		SetShapeLocalTransform(moveShape, Transform(VecLerp(startPos, endPos, moveVal), shapeRot))

		local pointA = TransformToParentPoint(GetShapeWorldTransform(moveShape), shapePos)
		local pointB = TransformToParentPoint(GetBodyTransform(topGate), doorPos)
		local _, ckMotorPos = GetBodyClosestPoint(topGate, pointB)
		if VecDist(ckMotorPos, pointB) <= 0.2 then
			ConstrainPosition(trackBody, topGate, pointA, pointB)
		else
			motorBroken = true
		end
	end

	gateBroken = #gateData == 0
	if gateBroken then return end

	for i=1, #gateData do
		local locData = gateData[i]
		local locBody = locData[1]
		local bodyTrans = GetBodyTransform(locBody)
		if not gateData[i][4] then
			local pointL = TransformToParentPoint(bodyTrans, locData[2])
			local _, ckPointL = GetBodyClosestPoint(locBody, pointL)
			if VecDist(ckPointL, pointL) <= 0.2 then
				local worldVel = GetBodyVelocityAtPos(locBody, pointL)
				local locVel = TransformToLocalVec(bodyTrans, worldVel)
				local pointVel = VecLength(Vec(0, locVel[2], 0))
				if haveGateSnd and pointVel > soundVelThres then PlayLoop(gateSnd, pointL, gateSndVolume*pointVel) end
				local checkL = ConstrainTrack(leftTrack, locBody, pointL, Vec(0.05, 0, 0.1))
				gateData[i][4] = checkL or gateData[i][4]
			else
				gateData[i][4] = true
			end
		end
		if not gateData[i][5] then
			local pointR = TransformToParentPoint(bodyTrans, locData[3])
			local _, ckPointR = GetBodyClosestPoint(locBody, pointR)
			if VecDist(ckPointR, pointR) <= 0.2 then
				local worldVel = GetBodyVelocityAtPos(locBody, pointR)
				local locVel = TransformToLocalVec(bodyTrans, worldVel)
				local pointVel = VecLength(Vec(0, locVel[2], 0))
				if haveGateSnd and pointVel > soundVelThres then PlayLoop(gateSnd, pointR, gateSndVolume*pointVel) end
				local checkR = ConstrainTrack(rightTrack, locBody, pointR, Vec(0.05, 0, 0.1))
				gateData[i][5] = checkR or gateData[i][5]
			else
				gateData[i][5] = true
			end
		end
	end
	for i=#gateData, 1, -1 do
		if gateData[i][4] and gateData[i][5] then table.remove(gateData, i) end
	end
end

function ConstrainTrack(list, body, bPoint, offset)
	local minDist = 0
	local minPoint = {}
	local shape = 0
	for l=1, 4 do
		if IsHandleValid(list[l][1]) and GetShapeBody(list[l][1]) == list[l][2] then
			local testShape = list[l][1]
			local _, point = GetShapeClosestPoint(testShape, bPoint)
			local dist = VecDist(bPoint, point)
			if minDist ~= 0 then
				if minDist > dist then
					minDist = dist
					minPoint = point
					shape = testShape
				end
			else
				minDist = dist
				minPoint = point
				shape = testShape
			end
		end
	end
	local shapeTrans = GetShapeWorldTransform(shape)
	local shapeLocPos = TransformToLocalPoint(shapeTrans, bPoint)
	local perpPoint = VecAdd(Vec(0, shapeLocPos[2], 0), offset)
	local worldPerpPoint = TransformToParentPoint(shapeTrans, perpPoint)
	if VecDist(worldPerpPoint, minPoint) > 0.2 then return true end
	local worldPerpDir = VecSub(bPoint, worldPerpPoint)
	local dirLeng = VecLength(worldPerpDir)*20
	local unitDir = VecNormalize(worldPerpDir)
	local trackBody = GetShapeBody(shape)
	ConstrainVelocity(trackBody, body, bPoint, unitDir, dirLeng)
end

function VecDist(a, b)
	return VecLength(VecSub(a, b))
end