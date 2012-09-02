local _, ns = ...

local C = ns.C

local oUF = oUF

C.media = {
	blank = [[Interface\BUTTONS\WHITE8X8]],
	borderTexture = [[Interface\AddOns\oUF_mg\media\borders\3pxBorder]],	
	statusBarTexture = [[Interface\TargetingFrame\UI-StatusBar]],
	borderColor = {0.23, 0.23, 0.23},
	backdropColor = {0.07, 0.07, 0.07},
}

C.unitframes = {
	showPlayer = true,
	showTarget = true,
	showTargetTarget = true,
	showFocus = true,
	showFocusTarget = true,
	
	healthBackdrop = false,
	classColor = false,
	classcolorpower = true,

	playerWidth = 275,
	playerHeight = 45,
	smallWidth = 100,
	smallHeight = 20,
}

C.ouf_colors = setmetatable({
	tapped = {1, 0, 0},
	power = setmetatable({
		["MANA"] 		=	{0.31, 0.45, 0.63},
		["RAGE"] 		=	{0.78, 0.25, 0.25},
		["FOCUS"] 		=	{0.71, 0.43, 0.27},
		["ENERGY"] 		=	{0.65, 0.63, 0.35},
		["RUNIC_POWER"] =	{0.00, 0.82, 1.00},
	}, {__index = oUF.colors.power}),
	class = setmetatable({
		["DEATHKNIGHT"] = {0, 1, 1},
	}, {__index = oUF.colors.class}),
	smooth = setmetatable({
		1, 0, 0,
		1, 1, 0,
		unpack(C.media.borderColor)
	}, {__index = oUF.colors.smooth}),
}, {__index = oUF.colors})