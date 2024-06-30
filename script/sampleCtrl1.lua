
-- This is a sample script demostrating how to control garage door with external scripts.
-- You may modify this script as your wish.

function init()
	openShape = FindShape("open")
	closeShape = FindShape("close")
	stopShape = FindShape("stop")
	checkTriggers = FindTriggers("enterCheck")
	SetTag(openShape, "interact", "Open")
	SetTag(closeShape, "interact", "Close")
	SetTag(stopShape, "interact", "Stop")
	toggle = GetBoolParam("open", false)
	triggerToggle = toggle
	inTimer = 0
	maxTimer = 2
	overflow = false
	showInfo = false

	ctrlUnit = FindShape("gateCtrl") -- this is the control unit for garage door, setting tag values would open/close door
	SetTag(ctrlUnit, "gateCtrl", toggle and "open" or toggle == false and "close" or 0) -- "open" for open, "close" for close, all other values for stopped
end

function tick(dt)
	showInfo = false
	if InputPressed("interact") then
		if GetPlayerInteractShape() == closeShape then toggle = false end
		if GetPlayerInteractShape() == openShape then toggle = true end
		if GetPlayerInteractShape() == stopShape then toggle = nil end
		if toggle ~= nil then triggerToggle = toggle end

		SetTag(ctrlUnit, "gateCtrl", toggle and "open" or toggle == false and "close" or 0)
	end
	local cond1 = false
	local cond2 = InputDown("handbrake")
	for i=1, #checkTriggers do
		cond1 = cond1 or IsVehicleInTrigger(checkTriggers[i], GetPlayerVehicle())
	end
	if cond1 and cond2 then
		showInfo = not overflow
		inTimer = inTimer+dt
		if inTimer > maxTimer and not overflow then
			triggerToggle = not triggerToggle
			toggle = triggerToggle
			overflow = true

			SetTag(ctrlUnit, "gateCtrl", toggle and "open" or toggle == false and "close" or 0)
		end
	elseif cond1 or cond2 then
		inTimer = 0
	else
		inTimer = 0
		overflow = false
	end
	SetShapeEmissiveScale(openShape, toggle and 1 or 0)
	SetShapeEmissiveScale(closeShape, toggle == false and 1 or 0)
	SetShapeEmissiveScale(stopShape, toggle == nil and 1 or 0)
	local tagValue = GetTagValue(ctrlUnit, "gateCtrl")
	if tagValue == "open" then toggle = true
	elseif tagValue == "close" then toggle = false
	else toggle = nil end
	if toggle ~= nil then triggerToggle = toggle end
end

function draw()
	if not showInfo then return end
	UiPush()
		UiFont("bold.ttf", 22)
		UiTranslate(UiCenter(), UiHeight()-90)
		UiTranslate(-100, 0)
		progressBar(200, 20, inTimer/maxTimer)
		UiColor(1,1,1)
		UiTranslate(100, -12)
		UiAlign("center middle")
		UiTextOutline(0.2, 0.2, 0.2, 0.75, 0.5)
		UiText(triggerToggle and "Close Gate" or "Open Gate")
	UiPop()
end

function progressBar(w, h, t)
	UiPush()
		UiAlign("left top")
		UiColor(0, 0, 0, 0.5)
		UiImageBox("ui/common/box-solid-10.png", w, h, 6, 6)
		if t > 0 then
			UiTranslate(2, 2)
			w = (w-4)*t
			if w < 12 then w = 12 end
			h = h-4
			UiColor(1,1,1,1)
			UiImageBox("ui/common/box-solid-6.png", w, h, 6, 6)
		end
	UiPop()
end