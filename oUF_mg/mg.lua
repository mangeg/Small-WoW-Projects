local _,  ns = ...

local C = ns.C
local E = ns.E

local oUF = oUF

local function PostHelath(health, unit, min, max)
	local r, g, b = health:GetStatusBarColor()

	--health:SetValue(max /2)
	--local newr, newg, newb = oUF.ColorGradient(min / max, 1, 0, 0, 1, 1, 0, r, g, b)
	--health:SetStatusBarColor(newr, newg, newb)
end

function E.AddSharpBorder(f)
	f:SetBackdrop({
	  bgFile = C.media.blank, 
	  edgeFile = C.media.blank, 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	f:SetBackdropColor(unpack(C.media.backdropColor))
	
	if not f.oborder and not f.iborder then
		local border = CreateFrame("Frame", nil, f)
		border:SetPoint("TOPLEFT", (1), -(1))
		border:SetPoint("BOTTOMRIGHT", -(1), (1))
		border:SetBackdrop({
			edgeFile = C.media.blank, 
			edgeSize = 1, 
			insets = { left = 1, right = 1, top = 1, bottom = 1 }
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		f.iborder = border
		
		if f.oborder then return end
		local border = CreateFrame("Frame", nil, f)
		border:SetPoint("TOPLEFT", -(1), (1))
		border:SetPoint("BOTTOMRIGHT", (1), -(1))
		border:SetFrameLevel(f:GetFrameLevel() + 1)
		border:SetBackdrop({
			edgeFile = C.media.blank, 
			edgeSize = 1, 
			insets = { left = 1, right = 1, top = 1, bottom = 1 }
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		f.oborder = border				
	end
	
	f:SetBackdropBorderColor(unpack(C.media.borderColor))
end

-- Player
do
	local BORDER = 2
	local PORTRAIT_WIDTH = C.unitframes.playerHeight + (C.unitframes.playerHeight / 2)

	local Shared = function(self, unit, isSingle, ...)
		-- Set Colors
		self.colors = C.ouf_colors
		
		-- Register Frames for Click
		self:RegisterForClicks("AnyUp")
		self:SetScript('OnEnter', UnitFrame_OnEnter)
		self:SetScript('OnLeave', UnitFrame_OnLeave)
		
		-- Setup Menu
		self.menu = function (self)
		local unit = self.unit:gsub("(.)", string.upper, 1)
			if self.unit == "targettarget" then return end
			if _G[unit.."FrameDropDown"] then
				ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
			elseif (self.unit:match("party")) then
				ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
			else
				FriendsDropDown.unit = self.unit
				FriendsDropDown.id = self.id
				FriendsDropDown.initialize = RaidFrameDropDown_Initialize
				ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
			end
		end
		
		-- Frame Level
		self:SetFrameLevel(5)
		
		if unit == "player" then
			
			local health = E.CreateHealthBar(self, true, true)
			health:SetPoint("TOPRIGHT", -(BORDER), BORDER)
			health:SetPoint("BOTTOMLEFT", (BORDER), (BORDER))
			
			local power = E.CreatePowerBar(self, true, true)
			power:SetPoint("RIGHT", self, "BOTTOMRIGHT", -(BORDER * 2 + 4), 0)
			power:SetWidth(C.unitframes.playerWidth / 2)
			power:SetHeight(6)
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
			
			local portrait = CreateFrame("PlayerModel", nil, self)
			portrait:SetFrameStrata("LOW")
			portrait.backdrop = CreateFrame("Frame", nil, portrait)
			health:SetPoint("TOPLEFT", PORTRAIT_WIDTH + BORDER, -BORDER)
			portrait.backdrop:SetPoint("TOPLEFT", self, "TOPLEFT", BORDER, 0)
			portrait.backdrop:SetPoint("BOTTOMRIGHT", health.backdrop, "BOTTOMLEFT", -1, -C.unitframes.playerHeight / 2)
			portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel() - 1)			
			portrait:SetPoint("BOTTOMLEFT", portrait.backdrop, "BOTTOMLEFT", BORDER, BORDER)		
			portrait:SetPoint("TOPRIGHT", portrait.backdrop, "TOPRIGHT", -BORDER, -BORDER)
			
			portrait.PostUpdate = E.PortraitUpdate
			
			E.AddSharpBorder(health.backdrop)
			E.AddSharpBorder(power.backdrop)
			E.AddSharpBorder(portrait.backdrop)
			
			self.Health = health
			self.Power = power
			self.Portrait = portrait
		
		elseif unit == "target" then
			
			local health = E.CreateHealthBar(self, true, true)
			health:SetPoint("TOPRIGHT", -(BORDER), BORDER)
			health:SetPoint("BOTTOMLEFT", (BORDER), (BORDER))
						
			local power = E.CreatePowerBar(self, true, true)
			power:SetPoint("LEFT", self, "BOTTOMLEFT", (BORDER * 2 + 4), 0)
			power:SetWidth(C.unitframes.playerWidth / 2)
			power:SetHeight(6)
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
			
			local portrait = CreateFrame("PlayerModel", nil, self)
			portrait:SetFrameStrata("LOW")
			portrait.backdrop = CreateFrame("Frame", nil, portrait)
			health:SetPoint("TOPRIGHT", -PORTRAIT_WIDTH + BORDER, -BORDER)
			portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", BORDER, 0)
			portrait.backdrop:SetPoint("BOTTOMLEFT", health.backdrop, "BOTTOMRIGHT", 1, -C.unitframes.playerHeight / 2)
			portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel() - 1)			
			portrait:SetPoint("BOTTOMLEFT", portrait.backdrop, "BOTTOMLEFT", BORDER, BORDER)		
			portrait:SetPoint("TOPRIGHT", portrait.backdrop, "TOPRIGHT", -BORDER, -BORDER)
			
			portrait.PostUpdate = E.PortraitUpdate
			
			E.AddSharpBorder(health.backdrop)
			E.AddSharpBorder(power.backdrop)
			E.AddSharpBorder(portrait.backdrop)
			
			self.Health = health
			self.Power = power
			self.Portrait = portrait
		end
	end
	
	oUF:RegisterStyle("mgPlayer", Shared)
end



oUF:Factory(function(self)
	self:SetActiveStyle("mgPlayer")	
	local player = self:Spawn("player")
	player:SetSize(C.unitframes.playerWidth, C.unitframes.playerHeight)
	player:SetPoint("CENTER", -220, -200)	
	
	local target = self:Spawn("target")
	target:SetSize(C.unitframes.playerWidth, C.unitframes.playerHeight)
	target:SetPoint("CENTER", 220, -200)	
end)