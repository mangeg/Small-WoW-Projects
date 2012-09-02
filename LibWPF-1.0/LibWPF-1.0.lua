local name, addon_table = ...

local LIBWPF_MAJOR, LIBWPF_MINOR = "LibWPF-1.0", 1
local LibWPF = LibStub:NewLibrary(LIBWPF_MAJOR, LIBWPF_MINOR)
if not LibWPF then return end

local lib = LibWPF

local DependencyObjectMT = {}

local DependencyObject = {}
DependencyObject.Values = {}


function DependencyObject:SetValue(dp, value)
	if DEBUG then
		expect(dp, "typeof", "table")
		expect(value, "typeof", "number;boolean")
		expect(value, "typeof", dp.PropertyType)
	end	
	self.Values[dp] = value
	DependencyObject:RaisePropertyChanged(dp, value)
end
function DependencyObject:GetValue(dp)
	return self.Values[dp]
end
function DependencyObject:RaisePropertyChanged(dp, value)
	self.Callbacks:Fire("PropertyChanged", dp, value)
end

local DependencyPropertyMT = {
	PropertyType = nil,
	Name = nil
}


local DependencyProperty = {}
local PropertiesByName = setmetatable({}, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end})

function DependencyProperty:Register(name, propertyType, ownerType)	
	if DEBUG then
		expect(name, "typeof", "string")
		expect(propertyType, "typeof", "string")
		expect(ownerType, "typeof", "table")
		expect(getmetatable(ownerType), "==", FromNameKey)
		expect(ownerType:GetID(), "~=" -1)
	end
	
	local ownerKey = ownerType:GetID()
	
	if PropertiesByName[ownerKey][name] ~= nil then
	end
	
	-- Create new property
	local prop = setmetatable({}, {
		__index = DependencyPropertyMT,
		PropertyType = propertyType,
	})	
	PropertiesByName[ownerKey][name] = prop	
	
	return prop
end

function DependencyProperty:FromName(name, ownerType)
	if DEBUG then
		expect(name, "typeof", "string")
		expect(ownerType, "typeof", "table")
		expect(getmetatable(ownerType), "==", FromNameKey)
		expect(ownerType:GetID(), "~=" -1)
		expect(PropertiesByName[ownerType:GetID()], "~=", nil)
	end
	return PropertiesByName[ownerType:GetID()][name]
end

local FromNameKeyIndex = 0
local FromNameKey = {
	Name = "not set",
	Meta = nil,
	Key = -1,
}
function FromNameKey:GetID()
	return self.Key
end

function Lib:CreateDependencyObject()
	local res = setmetatable({}, {
		__index = DependencyObjectMT,		
	})
	res.Callbacks = LibStub("CallbackHandler-1.0"):New(res)
	
	return res
end

function lib:CreateFromeNameKey(name, meta)
	local ret = setmetatable({}, {
		__index = FromNameKey
	})
	ret.Name = name
	ret.Meta = meta	
	ret.Index = FromNameKeyIndex 
	
	FromNameKeyIndex = FromNameKeyIndex + 1
	
	return ret
end