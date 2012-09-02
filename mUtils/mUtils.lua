do
	-- Clean up Hotkey font.
	local Path, Height = NumberFontNormalSmall:GetFont();
	NumberFontNormalSmall:SetFont( Path, Height, 'OUTLINE' );
	
	
	-- Movable option frames
	InterfaceOptionsFrame:RegisterForDrag("LeftButton")
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:SetScript("OnDragStart", function()
		InterfaceOptionsFrame:StartMoving()
	end)
		
	InterfaceOptionsFrame:SetScript("OnDragStop", function()
		InterfaceOptionsFrame:StopMovingOrSizing()
	end)
	
	VideoOptionsFrame:RegisterForDrag("LeftButton")
	VideoOptionsFrame:SetMovable(true)
	VideoOptionsFrame:SetScript("OnDragStart", function()
		VideoOptionsFrame:StartMoving()
	end)
		
	VideoOptionsFrame:SetScript("OnDragStop", function()
		VideoOptionsFrame:StopMovingOrSizing()
	end)
	
	
end