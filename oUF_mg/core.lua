local _, ns = ...

ns.C = {}
ns.E = {}

local C = ns.C
local E = ns.E

local mult = 768 / string.match(GetCVar("gxResolution"), "%d+x(%d+)") / 0.711111111111111

local function Scale(x)
	return mult * math.floor(x / mult + .5)
end

local function CreateHealthBar(self, bg, text)
	local health = CreateFrame('StatusBar', nil, self)
	health:SetStatusBarTexture(C.media.statusBarTexture)
	health:SetFrameStrata("LOW")
	health.frequentUpdates = 0.2
	
	--if C["unitframes"].showsmooth == true then
	--	health.Smooth = true
	--end	
	
	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(C.media.blank)
		
		if C.unitframes.healthBackdrop ~= true then
			health.bg.multiplier = 0.25
		end
	end
	
	if text then
		--E.FontString(health, "value", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
		--health.value:SetShadowColor(0, 0, 0, 0)
		--health.value:SetParent(self)
	end
	
	if C.unitframes.classcolor ~= true then
		health.colorTapping = true		
		health.colorSmooth = true
	else
		health.colorTapping = true	
		health.colorClass = true
		health.colorReaction = true
	end
	health.colorTapping = true
	health.colorDisconnected = true
	
	health.backdrop = CreateFrame('Frame', nil, health)
	health.backdrop:SetPoint("TOPRIGHT", health, "TOPRIGHT", (2), (2))
	health.backdrop:SetPoint("BOTTOMLEFT", health, "BOTTOMLEFT", -(2), -(2))
	health.backdrop:SetFrameLevel(health:GetFrameLevel() - 1)		
	
	return health
end

local function CreatePowerBar(self, bg, text)
	local power = CreateFrame('StatusBar', nil, self)
	power:SetStatusBarTexture(C.media.statusBarTexture)
	power:SetFrameStrata("LOW")
	power.frequentUpdates = 0.2
	
	--if C["unitframes"].showsmooth == true then
	--	power.Smooth = true
	--end	
	
	if bg then
		power.bg = power:CreateTexture(nil, 'BORDER')
		power.bg:SetAllPoints()
		power.bg:SetTexture(C.media.blank)
		
		if C.unitframes.healthBackdrop ~= true then
			power.bg.multiplier = 0.2
		end
	end
	
	if text then
		--E.FontString(power, "value", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
		--power.value:SetShadowColor(0, 0, 0, 0)
		--power.value:SetParent(self)
	end
	
	if C.unitframes.classcolor == true then
		power.colorClass = true
		power.colorReaction = true
	else
		power.colorPower = true
	end
	
	power.colorDisconnected = true
	power.colorTapping = false
	
	power.backdrop = CreateFrame('Frame', nil, power)
	power.backdrop:SetPoint("TOPRIGHT", power, "TOPRIGHT", (2), (2))
	power.backdrop:SetPoint("BOTTOMLEFT", power, "BOTTOMLEFT", -(2), -(2))
	power.backdrop:SetFrameLevel(power:GetFrameLevel() - 1)		
	
	return power
end

local function PortraitUpdate(self, unit)		
	if self:GetModel() and self:GetModel().find and self:GetModel():find("worgenmale") then
		self:SetCamera(1)
	end	
end	

local function FontString(parent, name, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0, 0.4)
	fs:SetShadowOffset(1, 1)
	
	if not name then
		parent.text = fs
	else
		parent[name] = fs
	end
	
	return fs
end

E.FontString = FontString
E.CreateHealthBar = CreateHealthBar
E.CreatePowerBar = CreatePowerBar
E.PortraitUpdate = PortraitUpdate