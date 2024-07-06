brushFile = GetString("brush", "", "object vox")
width = GetInt("width", 40)
height = GetInt("height", 24)
offset = GetInt("offset", 1)
gateCount = GetInt("gates", 4)
noMotorStr = GetString("noMotor", "")
noMotor = noMotorStr ~= ""
constc = 0.732

function init()
	local Mfloor = math.floor
	local Mceil = math.ceil
	local Mabs = math.abs

	width = Mabs(width-1)
	height = Mabs(height)
	offset = Mabs(offset)
	gateCount = gateCount ~= 0 and Mabs(gateCount) or 1
	gateH = Mceil(height/gateCount)
	height = gateH*gateCount

	trackOff = offset-1
	gateMid = Mceil(width/2)-width%2
	motorWidth = 2+width%2
	curveL = Mceil(constc*gateH)+1

	trackBR = brushFile..":track"
	-- gatesBR = brushFile..":gates"

	track = CreateBrush(trackBR, true)
	-- gates = CreateBrush(gatesBR, true)

	-- for i=1, gateCount do
	-- 	Vox(0, gateH*(i-1), 0)
	-- 	Material(gates)
	-- 	Box(0, 0, 0, width, gateH, offset)
	-- end

	Vox(0, 0, 0)
	Material(track)
	Box(0, 0, trackOff, -1, height-gateH, offset)
	Vox(0, height, gateH+offset, 90, 0, 0)
	Material(track)
	Box(0, 0, 0, -1, height+1, -1)
	Vox(0, height-gateH, offset-1, 30, 0, 0)
	Material(track)
	Box(0, 0, 0, -1, curveL, 1)
	Vox(0, height+1, gateH+trackOff+1, 60, 0, 0)
	Material(track)
	Box(0, 0, 0, -1, -curveL, 1)

	Vox(width, 0, 0)
	Material(track)
	Box(0, 0, trackOff, 1, height-gateH, offset)
	Vox(width, height, gateH+offset, 90, 0, 0)
	Material(track)
	Box(0, 0, 0, 1, height+1, -1)
	Vox(width, height-gateH, offset-1, 30, 0, 0)
	Material(track)
	Box(0, 0, 0, 1, curveL, 1)
	Vox(width, height+1, gateH+trackOff+1, 60, 0, 0)
	Material(track)
	Box(0, 0, 0, 1, -curveL, 1)
	
	Vox(0, height, height+offset+gateH+2)
	Material(track)
	Box(-1, 0, 0, width+1, 1, -1)

	if not noMotor then
		Vox(gateMid, height+offset+1, 0)
		Material(track)
		Box(-1, 0, 0, motorWidth-1, 1, height+gateH*2+offset)
		Vox(gateMid, height+1, offset+height+gateH)
		Material(track)
		Box(-1, -2, 0, motorWidth-1, offset, 1)
		Vox(gateMid, height+1, offset)
		Material(track)
		Box(-1, -2, 0, motorWidth-1, offset, 1)
	end
end
