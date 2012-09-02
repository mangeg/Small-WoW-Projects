local name, t = ...

local addon = LibStub("AceAddon-3.0"):NewAddon(t, "mRepsperience", "AceEvent-3.0")

mRepsperience = addon

-- Libs
local LSM 		= LibStub("LibSharedMedia-3.0")
local BD		= LibStub("LibBackdrop-1.0")
local AceGUI 	= LibStub("AceGUI-3.0")
local FA		= LibStub("LibFrameAnchorRegistry-1.0")
local UIF

-- Frame
local Container
local Boubles = {}

local NrBoubles = 10

-- Other
local db

local Backdrop = {     
	tile = false, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local DisableXP, DisableRep = false, false

-- Code from Pibtull 4 LuaText script env.
local t = {}
local function SepNumber(num)
	local int = math.floor(num)
	local rest = num % 1
	if int == 0 then
		t[#t+1] = 0
	else
		local digits = math.log10(int)
		local segments = math.floor(digits / 3)
		t[#t+1] = math.floor(int / 1000^segments)
		for i = segments-1, 0, -1 do
			t[#t+1] = ","
			t[#t+1] = ("%03d"):format(math.floor(int / 1000^i) % 1000)
		end
	end
	if rest ~= 0 then
		t[#t+1] = "."
		rest = math.floor(rest * 10^6)
		while rest % 10 == 0 do
			rest = rest / 10
		end
		t[#t+1] = rest
	end
	local s = table.concat(t)
	wipe(t)
	
	return s
end
-- Code from Pibtull 4 LuaText script env end.

local function ShortNumber(num)
	if num >= 1000000 then
		return string.format("%.3fm", SepNumber(num / 1000000))
	elseif num >= 1000 then
		return string.format("%.1fk", SepNumber(num / 1000))
	else
		return num
	end
end

local defaults = {
	profile = {
		Enabled = true,

		RepMode = UnitLevel("player") == MAX_PLAYER_LEVEL,
	
		Anchor = "",
		Point = "CENTER",
		RelPoint = "CENTER",
		x = 0,
		y = 0,
			
		Stretch = true,
		Width = 400,
		WidthOfset = 0,
		Height = 40,
		
		Padding = 4,
		BorderWidth = 16,
		BorderInset = 4,
		BorderTexture = "Blizzard Tooltip",
		BorderColor = {1, 1, 1, 1},
		
		BackgroundTexture = "Solid",
		BackgroudColor = {0.16, 0.16, 0.16, 1},
			
		FontSettings = {
			Font = "Prototype",
			Size = 12,
			Flags = "Outline",
			Color = {1, 1, 1, 1},
		},
		
		Texture = "HalK",
		
		BarColor = {0.4, 0.4, 0.4, 1},
		BoubleColor = {0.4, 0.4, 0.4, 1},
		ExtraBarColor = {0.6, 0.6, 0.6, 1},
		
		BarColorDiff = 0.3,
		BoubleColorDiff = 0.3,
		
		BoubleSpace = 0,
		MiddleSpace = 0,
		
		BoubleHeight = 1,
		BarHeight = 1,
	}
}

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("mRepsperienceDB", defaults, true)
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
	self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
	self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")
	
	db = self.db.profile
	
	self:SetEnabledState(db.Enabled)
		
	-- LDB
	local LDB = LibStub("LibDataBroker-1.1")
	if LDB then
	
		local l = LDB:NewDataObject("mRepsperience")
		l.type = "data source"
		l.icon = [[Interface\ICONS\Item_icecrownringD]]
		l.OnClick = function(self, button)
			addon:ToggleOptions()
		end
		l.OnTooltipShow = function(tt)
			tt:AddLine("mRepsperience")
			tt:AddLine("Click to toggle configuration")
		end
		
		self.LDB = l
	end
	
	LSM.RegisterCallback(self, "LibSharedMedia_Registered", "MediaUpdated")
	UIF = LibStub("LibGUIFactory-1.0"):GetFactory("mRepsperience", {})
	self:SetOptionLook()
	
	self:CreateContainer()
end

function addon:OnEnable()	
	FA.RegisterCallback(self, "FrameRegistered", "ApplySettings")
	FA.RegisterCallback(self, "FrameModified", "ApplySettings")
	self:ApplySettings()
end

function addon:OnDisable()
	LSM.UnregisterAllCallbacks(self)
end

-- Apply all settings
function addon:ApplySettings(event, ...)
	if db.Enabled and not self:IsEnabled() then self:Enable()
	elseif not db.Enabled and self:IsEnabled() then
		self:Disable() 
		return
	end
	
	Backdrop.edgeFile = LSM:Fetch("border", db.BorderTexture)
	Backdrop.bgFile = LSM:Fetch("background", db.BackgroundTexture)
	Backdrop.edgeSize = db.BorderWidth
	Backdrop.insets.top = db.BorderInset
	Backdrop.insets.bottom = db.BorderInset
	Backdrop.insets.left = db.BorderInset
	Backdrop.insets.right = db.BorderInset
	Container:SetBackdrop(Backdrop)
	Container:SetBackdropColor(unpack(db.BackgroudColor))
	Container:SetBackdropBorderColor(unpack(db.BorderColor))
	
	Container.Marker:SetWidth(5)
	Container.Marker.Texture:SetTexture(unpack(db.ExtraBarColor))
	
	local anchor = FA:GetAnchor(db.Anchor)
	Container:ClearAllPoints()
	Container:SetPoint(db.Point, anchor, db.RelPoint, db.x, db.y)	
	Container:SetHeight(db.Height)
	
	if db.Stretch then
		Container:SetWidth(anchor:GetWidth() + db.WidthOfset)
	else
		Container:SetWidth(db.Width + db.WidthOfset)
	end	
	
	local Bar = Container.Bar
	local TotalInset = db.Padding + db.BorderInset
	Bar:ClearAllPoints()
	Bar:SetPoint("BOTTOMLEFT", TotalInset, TotalInset)
	Bar:SetPoint("BOTTOMRIGHT", -TotalInset, TotalInset)
	
	local HeightTotal = db.BoubleHeight + db.BarHeight
	Bar:SetHeight(Container:GetHeight() / HeightTotal * db.BarHeight - db.MiddleSpace / 2 - TotalInset)
	
	Bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.Texture))
	Bar.Background:SetStatusBarTexture(LSM:Fetch("statusbar", db.Texture))
	
	local r, g, b, a = unpack(db.BarColor)
	Bar:SetStatusBarColor(r, g, b, a)
	Bar.Background:SetStatusBarColor(r - db.BarColorDiff, g - db.BarColorDiff, b - db.BarColorDiff, a)
	
	Bar.Text:SetFont(LSM:Fetch("font", db.FontSettings.Font), db.FontSettings.Size, db.FontSettings.Flags)
	Bar.Text:SetTextColor(unpack(db.FontSettings.Color))
	
	self:ApplyBoubles()
	
	self:UnregisterAllEvents()
	if db.RepMode then
		self:RegisterEvent("UPDATE_FACTION")
		self:UPDATE_FACTION("UPDATE_FACTION")
	else
		self:RegisterEvent("UPDATE_EXHAUSTION", "PLAYER_XP_UPDATE")
		self:RegisterEvent("PLAYER_XP_UPDATE", "PLAYER_XP_UPDATE")
		self:RegisterEvent("PLAYER_LEVEL_UP", "PLAYER_XP_UPDATE")
		self:PLAYER_XP_UPDATE("UPDATE_EXHAUSTION")
	end
end

function addon:ApplyBoubles()
	local TotalInset = db.Padding + db.BorderInset
	for i, bouble in pairs(Boubles) do
		bouble:ClearAllPoints()
		if i == 1 then
			bouble:SetPoint("TOPLEFT", TotalInset, -TotalInset)
		else
			bouble:SetPoint("TOPLEFT", Boubles[i-1], "TOPRIGHT", db.BoubleSpace, 0)
		end
		local HeightTotal = db.BoubleHeight + db.BarHeight
		bouble:SetHeight(Container:GetHeight() / HeightTotal * db.BoubleHeight - TotalInset - db.MiddleSpace / 2)
		bouble:SetWidth(Container:GetWidth() / NrBoubles - db.BoubleSpace + (db.BoubleSpace / 10) - (TotalInset / 5))
		
		bouble:SetStatusBarTexture(LSM:Fetch("statusbar", db.Texture))
		bouble.Background:SetStatusBarTexture(LSM:Fetch("statusbar", db.Texture))
		
		local r, g, b, a = unpack(db.BoubleColor)
		bouble:SetStatusBarColor(r, g, b, a)
		bouble.Background:SetStatusBarColor(r - db.BoubleColorDiff, g - db.BoubleColorDiff, b - db.BoubleColorDiff, a)
		
		bouble.Text:SetFont(LSM:Fetch("font", db.FontSettings.Font), db.FontSettings.Size, db.FontSettings.Flags)
		bouble.Text:SetTextColor(unpack(db.FontSettings.Color))
	end
end

-- Some new media was loaded to LSM
function addon:MediaUpdated(event, MediaType, key)	
	self:ApplySettings()
	self:SetOptionLook()
end

function addon:CreateContainer()
	local f = CreateFrame("Frame", "mRepsperienceContainer", UIParent)
	
	Container = f
	Container:SetScript("OnSizeChanged", function() addon:ApplyBoubles() end)
	
	for i = 1, NrBoubles do
		local bouble = CreateFrame("StatusBar", "mRepsperienceBouble"..i, Container)
		bouble:SetMinMaxValues(0, 1)
		
		local boubleBackground = CreateFrame("StatusBar", "mRepsperienceBoubleBackground"..i, Container)
		boubleBackground:SetAllPoints(bouble)
		bouble.Background = boubleBackground
		bouble:SetFrameLevel(boubleBackground:GetFrameLevel() + 10)
		
		local str = bouble:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		str:SetAllPoints()
		--str:SetFormattedText("%d%%", i / NrBoubles * 100)
		
		bouble.Text = str
		
		tinsert(Boubles, bouble)
	end
	
	local bar = CreateFrame("StatusBar", "mRepsperienceBar", Container)
	bar:SetMinMaxValues(0, 1)	
	local str = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	str:SetAllPoints()	
	bar.Text = str	
	local backgroudBar = CreateFrame("StatusBar", "mRepsperienceBackgroundBar", Container)
	backgroudBar:SetAllPoints(bar)
	bar.Background = backgroudBar	
	bar:SetFrameLevel(backgroudBar:GetFrameLevel() + 10)	
	Container.Bar = bar
	
	local marker = CreateFrame("Frame", "mRepsperienceMarker", Container)
	marker:SetFrameLevel(Container:GetFrameLevel() + 20)
	local t = marker:CreateTexture(nil, "OVERLAY")
	t:SetAllPoints()
	t:SetTexture(1, 1, 1, 0.7)
	marker.Texture = t
	Container.Marker = marker
end

-- Events
----------------------------------
function addon:UPDATE_FACTION(event)
	local Faction, RepLevel, Min, Max, Current = GetWatchedFactionInfo()
	if Faction then
		local Bar = Container.Bar
		local c = Max - Min
		local p = (Current - Min) / c
		Bar:SetValue((p * 100) % (100 / NrBoubles) / (100 / NrBoubles))
		
		for i, Bouble in pairs(Boubles) do
			local pp = i / NrBoubles
			if pp <= p then
				Bouble:SetValue(1)
			else
				Bouble:SetValue(0)
			end
		end
		
		Bar.Text:SetFormattedText("%s (%s) - %s / %s (%d%%)", Faction, _G["FACTION_STANDING_LABEL"..RepLevel], SepNumber(Current - Min), SepNumber(Max - Min), p * 100)
	end
	
	Container.Marker:Hide()
end

function addon:PLAYER_XP_UPDATE(event, ...)
	
	local level = UnitLevel("player")	
	
	local current, max, rested = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion() or 0
	local p = current / max
	if rested == nil then rested = 0 end
	
	local remain = max - current
	local restRemain = remain - rested
	
	local restP
	if restRemain < 0 then
		restP = 1
	else
		restP = remain + rested / max
	end
	
	for i, Bouble in pairs(Boubles) do
		local pp = i / NrBoubles
		if pp < p then
			Bouble:SetValue(1)
		else
			Bouble:SetValue(0)
		end
	end
	
	local Bar = Container.Bar
	Bar:SetValue((p * 100) % (100 / NrBoubles) / (100 / NrBoubles))
	Bar.Text:SetFormattedText("%d - %s / %s (%.3f%%) - %s Rested", level, SepNumber(current), ShortNumber(max), p * 100, SepNumber(rested))
	
	Container.Marker:ClearAllPoints()
	Container.Marker:SetPoint("TOP", 0, -db.BorderInset - db.Padding)
	Container.Marker:SetPoint("BOTTOM", Bar, "TOP", 0, db.MiddleSpace)
	Container.Marker:SetPoint("LEFT", Container, "LEFT", (Container:GetWidth() - (db.BorderInset - db.Padding) * 2) * restP, 0)
	
	if rested > 0 then
		Container.Marker:Show()
	else
		Container.Marker:Hide()
	end
end


-- Options
-------------------------------
do
	function addon:SetOptionLook()
		UIF.s.font = LSM:Fetch("font", "Prototype")
	end
	
	local function Callback(...)
		addon:ApplySettings()
	end
	
	local OptionsStatus = {}
	local LastSelected, TreeStatus = nil, {}
	
	local FontVerticalAlign = {
		TOP = "Top",
		MIDDLE = "Middle",
		BOTTOM = "Bottom",
	}
	
	local FontHorizontalAlign = {
		LEFT = "Left",
		CENTER = "Center",
		RIGHT = "Right",
	}
	
	local options
	function addon:ToggleOptions()
		if options then
			options:Hide()
			options:Release()
			options = nil
		else
			options = UIF:Frame(addon:GetName())
			options:Show()
			options:SetLayout("Fill")
			options:SetCallback("OnClose", function()
				addon:ToggleOptions()
			end)
			options:SetStatusTable(OptionsStatus)
						
			local tree = UIF:TreeGroup()
			options:AddChild(tree)
			tree:SetLayout("Fill")
			tree:SetCallback("OnGroupSelected", function(self, event, group) LastSelected = group end)
			
			tree:AddGroup({{text = "Main", value = "Main"}}, function(self)
				
				local g = AceGUI:Create("SimpleGroup")
				g:SetLayout("Flow")
				g:SetFullWidth(true)
				
				g:AddChild(UIF:CheckBox("Stretch", db, "Stretch", Callback))
				g:AddChild(UIF:CheckBox("Rep Mode", db, "RepMode", Callback))
				g:AddChild(UIF:LSMDropdown("border", "Border", db, "BorderTexture", Callback))
				g:AddChild(UIF:Slider("Width", db, "BorderWidth", 1, 30, 1, Callback))
				g:AddChild(UIF:ColorSelect("Color", db, "BorderColor", Callback, true))
				g:AddChild(UIF:FrameAnchorDropdown("Anchor", db, "Anchor", Container, Callback, 0.5))
				g:AddChild(UIF:GridSelect("Point", db, "Point", "Anchor", 3, Callback, 0.5, 75))
				g:AddChild(UIF:GridSelect("Relative Point", db, "RelPoint", "Anchor", 3, Callback, 0.5, 75))
				g:AddChild(UIF:Slider("Padding", db, "Padding", 0, 30, 1, Callback))
				g:AddChild(UIF:Slider("Insets", db, "BorderInset", 0, 30, 1, Callback))
				g:AddChild(UIF:Slider("Height", db, "Height", 0, 300, 1, Callback))
				g:AddChild(UIF:Slider("Wdith", db, "Width", 0, 1000, 1, Callback))
				g:AddChild(UIF:Slider("X", db, "x", -1000, 1000, 1, Callback))
				g:AddChild(UIF:Slider("Y", db, "y", -1000, 10000, 1, Callback))
				g:AddChild(UIF:Slider("Bouble Space", db, "BoubleSpace", 0, 10, 1, Callback))
				g:AddChild(UIF:Slider("Middle Space", db, "MiddleSpace", 0, 10, 1, Callback))
				
				g:AddChild(UIF:StatusbarSelect("Texture", db, "Texture", Callback, 0.5))
				g:AddChild(UIF:ColorSelect("Bar Color", db, "BarColor", Callback, true))
				g:AddChild(UIF:ColorSelect("Bouble Color", db, "BoubleColor", Callback, true))
				g:AddChild(UIF:ColorSelect("Extrabar Color", db, "ExtraBarColor", Callback, true))
				g:AddChild(UIF:ColorSelect("Background Color", db, "BackgroudColor", Callback, true))
				g:AddChild(UIF:FontSettings("Font", db.FontSettings, true, Callback, 1))
				
				g:AddChild(UIF:Slider("Bar height", db, "BarHeight", 1, 10, 1, Callback))
				g:AddChild(UIF:Slider("Bouble height", db, "BoubleHeight", 1, 10, 1, Callback))
				
				g:AddChild(UIF:Slider("Bar Colordiff", db, "BarColorDiff", 0, 1, 0.01, Callback))
				g:AddChild(UIF:Slider("Bouble Colordiff", db, "BoubleColorDiff", 0, 1, 0.01, Callback))
				g:AddChild(UIF:Slider("Width Offset", db, "WidthOfset", 0, 300, 1, Callback))
				
				return g
			end)
			
			tree:SetSelected(LastSelected or "Main")
			tree:SetStatusTable(TreeStatus)
		end
	end
end