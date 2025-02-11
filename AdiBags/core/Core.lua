--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2021 Adirelle (adirelle@gmail.com)
All rights reserved.

This file is part of AdiBags.

AdiBags is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

AdiBags is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AdiBags.  If not, see <http://www.gnu.org/licenses/>.
--]]

local addonName = ...
---@class AdiBags: ABEvent-1.0
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)
---@cast addon +ABEvent-1.0|ABBucket-1.0|AceHook-3.0|AceConsole-3.0
local L = addon.L

--<GLOBALS
local _G = _G
local ADDON_LOAD_FAILED = _G.ADDON_LOAD_FAILED
local BANK_CONTAINER = _G.BANK_CONTAINER or ( Enum.BagIndex and Enum.BagIndex.Bank ) or -1
local REAGENTBAG_CONTAINER = ( Enum.BagIndex and Enum.BagIndex.REAGENTBAG_CONTAINER ) or 5
local CloseWindows = _G.CloseWindows
local CreateFrame = _G.CreateFrame
local format = _G.format
local GetCVarBool = _G.GetCVarBool
local geterrorhandler = _G.geterrorhandler
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory
local LoadAddOn = _G.LoadAddOn
local next = _G.next
local NUM_BANKGENERIC_SLOTS = _G.NUM_BANKGENERIC_SLOTS
local pairs = _G.pairs
local pcall = _G.pcall
local print = _G.print
local strmatch = _G.strmatch
local strsplit = _G.strsplit
local type = _G.type
---@diagnostic disable-next-line: deprecated
local unpack = _G.unpack
--GLOBALS>

--------------------------------------------------------------------------------
-- Addon initialization and enabling
--------------------------------------------------------------------------------

--[===[@debug@
local function DebugTable(t, prevKey)
	local k, v = next(t, prevKey)
	if k ~= nil then
		return k, v, DebugTable(t, k)
	end
end
--@end-debug@]===]

local bagKeys = {"backpack", "bank", "reagentBank"}
function addon:OnInitialize()
	-- Create the default font settings for each bag type.
	for _, name in ipairs(bagKeys) do
		local bfd = self:GetFontDefaults(GameFontHighlightLarge)
		bfd.r, bfd.g, bfd.b = 1, 1, 1
		self.DEFAULT_SETTINGS.profile.theme[name].bagFont = bfd
		self.DEFAULT_SETTINGS.profile.theme[name].sectionFont = self:GetFontDefaults(GameFontNormalLeft)
	end

	self.db = LibStub('AceDB-3.0'):New(addonName.."DB", self.DEFAULT_SETTINGS, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "Reconfigure")

	self:UpgradeProfile()

	-- Create the bag font objects.
	---@type table<string, table<string, AdiFont|Font>>
	self.fonts = {}
	for _, name in ipairs(bagKeys) do
		self.fonts[name] = {
			bagFont = self:CreateFont(addonName..name.."BagFont", GameFontHighlightLarge, function() return addon.db.profile.theme[name].bagFont end),
			sectionFont = self:CreateFont(addonName..name.."SectionFont", GameFontNormalLeft, function() return addon.db.profile.theme[name].sectionFont end)
		}
	end

	self.itemParentFrames = {}

	self:InitializeFilters()
	self:CreateBagAnchor()

	self:SetEnabledState(false)

	-- Persistant handlers
	self.RegisterBucketMessage(addonName, 'AdiBags_ConfigChanged', 0.2, function(...) addon:ConfigChanged(...) end)
	self.RegisterEvent(addonName, 'PLAYER_ENTERING_WORLD', function() if self.db.profile.enabled then self:Enable() end end)

	self:RegisterChatCommand("adibags", function(cmd)
		addon:OpenOptions(strsplit(' ', cmd or ""))
	end, true)

	if addon.isRetail then
		-- Disable the reagent bag tutorial
		C_CVar.SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, true)
		C_CVar.SetCVar("professionToolSlotsExampleShown", 1)
		C_CVar.SetCVar("professionAccessorySlotsExampleShown", 1)
	end

  self:Deprecation()
	self:Debug('Initialized')
end

function addon:OnEnable()

	self.globalLock = false

	self:RegisterEvent('BAG_UPDATE')
	self:RegisterEvent('BAG_UPDATE_DELAYED')
	self:RegisterBucketEvent('PLAYERBANKSLOTS_CHANGED', 0.01, 'BankUpdated')
	if addon.isRetail then
		self:RegisterBucketEvent('PLAYERREAGENTBANKSLOTS_CHANGED', 0.01, 'ReagentBankUpdated')
	end

	self:RegisterEvent('PLAYER_LEAVING_WORLD', 'Disable')

	self:RegisterMessage('AdiBags_BagOpened', 'LayoutBags')
	self:RegisterMessage('AdiBags_BagClosed', 'LayoutBags')
	
	-- Track most windows involving items
	if addon.isRetail or addon.isWrath then
		self:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', 'UpdateInteractingFrame')
		self:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', 'UpdateInteractingFrame')
		-- TODO(lobato): This is a hack to fix a change in the timing of the interaction manager
		-- event. The interaction manager frame event is fired later than the bankframe opened
		-- event is, which causes a race somewhere else in our code. Without this, GetInteractingWindow
		-- will return a nil value when it shouldn't. We need to figure out where this race is
		-- happening and fix it properly.
		-- Note, this seems to only happen with the bankframe event, and no others.
		self:RegisterEvent('BANKFRAME_OPENED', 'UpdateInteractingWindow')
	else
		self:RegisterEvent('BANKFRAME_OPENED', 'UpdateInteractingWindow')
		self:RegisterEvent('BANKFRAME_CLOSED', 'UpdateInteractingWindow')
		self:RegisterEvent('MAIL_SHOW', 'UpdateInteractingWindow')
		self:RegisterEvent('MAIL_CLOSED', 'UpdateInteractingWindow')
		self:RegisterEvent('MERCHANT_SHOW', 'UpdateInteractingWindow')
		self:RegisterEvent('MERCHANT_CLOSED', 'UpdateInteractingWindow')
		self:RegisterEvent('AUCTION_HOUSE_SHOW', 'UpdateInteractingWindow')
		self:RegisterEvent('AUCTION_HOUSE_CLOSED', 'UpdateInteractingWindow')
		self:RegisterEvent('TRADE_SHOW', 'UpdateInteractingWindow')
		self:RegisterEvent('TRADE_CLOSED', 'UpdateInteractingWindow')
		self:RegisterEvent('GUILDBANKFRAME_OPENED', 'UpdateInteractingWindow')
		self:RegisterEvent('GUILDBANKFRAME_CLOSED', 'UpdateInteractingWindow')
		self:RegisterEvent('SOCKET_INFO_UPDATE', 'UpdateInteractingWindow')
		self:RegisterEvent('SOCKET_INFO_CLOSE', 'UpdateInteractingWindow')
	end
	self:SetSortingOrder(self.db.profile.sortingOrder)

	for name, module in self:IterateModules() do
		---@cast module +AceModule|FilterModule
		if module.isFilter then
			module:SetEnabledState(self.db.profile.filters[module.moduleName])
		elseif module.isBag then
			module:SetEnabledState(self.db.profile.bags[module.bagName])
		else
			module:SetEnabledState(self.db.profile.modules[module.moduleName])
		end
	end

	for _, name in ipairs(bagKeys) do
		self.fonts[name].bagFont:ApplySettings()
		self.fonts[name].sectionFont:ApplySettings()
	end

	self:UpdatePositionMode()

	self:Debug('Enabled')
end

function addon:OnDisable()
	self.anchor:Hide()
	self:CloseAllBags()
	self:Debug('Disabled')
end

function addon:EnableHooks()
	self:RawHook("OpenAllBags", true)
	self:SecureHook("CloseAllBags")
	self:RawHook("ToggleAllBags", true)
	self:RawHook("ToggleBackpack", true)
	self:RawHook("ToggleBag", true)
	self:RawHook("OpenBag", true)
	self:SecureHook("CloseBag")
	self:RawHook("OpenBackpack", true)
	self:SecureHook("CloseBackpack")
	self:SecureHook('CloseSpecialWindows')
end

function addon:DisableHooks()
	self:Unhook("OpenAllBags")
	self:Unhook("CloseAllBags")
	self:Unhook("ToggleAllBags")
	self:Unhook("ToggleBackpack")
	self:Unhook("ToggleBag")
	self:Unhook("OpenBag")
	self:Unhook("CloseBag")
	self:Unhook("OpenBackpack")
	self:Unhook("CloseBackpack")
	self:Unhook('CloseSpecialWindows')
end

function addon:Reconfigure()
	self.holdYourBreath = true -- prevent tons*$% of useless updates
	self:Disable()
	self:Enable()
	self.holdYourBreath = nil
	self:UpdateFilters()
end

function addon:OnProfileChanged()
	self:UpgradeProfile()
	return self:Reconfigure()
end

-- Thanks to Talyrius for this idea
-- TODO(lobato): Remove this update code in a future version
local prevSkinPreset = {
  BackpackColor = { 0, 0, 0, 1 },
  BankColor = { 0, 0, 0.5, 1 },
  ReagentBankColor = { 0, 0.5, 0, 1 },
}

function addon:UpgradeProfile()
	-- Copy over skin settings to the new theme format.
	local skin = addon.db.profile.skin
	if skin then
		for _, key in ipairs(bagKeys) do
			-- Update the basic theme data.
			addon.db.profile.theme[key].background = skin.background
			addon.db.profile.theme[key].border = skin.border
			addon.db.profile.theme[key].insets = skin.insets
			addon.db.profile.theme[key].borderWidth = skin.borderWidth

			-- Update font data, taking care not to create a new table as this breaks the font object.
			if addon.db.profile.bagFont then
				for k, v in pairs(addon.db.profile.bagFont) do
					addon.db.profile.theme[key].bagFont[k] = v
				end
			end
			if addon.db.profile.sectionFont then
				for k, v in pairs(addon.db.profile.sectionFont) do
					addon.db.profile.theme[key].sectionFont[k] = v
				end
			end

			-- Update the color data.
			if key == "backpack" and skin.BackpackColor then
				for i, v in ipairs(prevSkinPreset.BackpackColor) do
					v = skin.BackpackColor[i] or v
					addon.db.profile.theme[key].color[i] = v
				end
			elseif key == "bank" and skin.BankColor then
				for i, v in ipairs(prevSkinPreset.BankColor) do
					v = skin.BankColor[i] or v
					addon.db.profile.theme[key].color[i] = v
				end
			elseif key == "reagentBank" and skin.ReagentBankColor then
				for i, v in ipairs(prevSkinPreset.ReagentBankColor) do
					v = skin.ReagentBankColor[i] or v
					addon.db.profile.theme[key].color[i] = v
				end
			end
		end

		-- Delete the old skin and font profile data.
		addon.db.profile.skin = nil
		addon.db.profile.bagFont = nil
		addon.db.profile.sectionFont = nil
		addon.db.profile.theme.currentTheme = "legacy theme"
		addon:SaveTheme()
	end
end

--------------------------------------------------------------------------------
-- Option addon handling
--------------------------------------------------------------------------------

do
	local configAddonName = "AdiBags_Config"
	local why = '???'
	local function CouldNotLoad()
		print("|cffff0000AdiBags:", format(ADDON_LOAD_FAILED, configAddonName, why), "|r")
	end
	function addon:OpenOptions(...)
		self.OpenOptions = CouldNotLoad
		local loaded, reason = LoadAddOn(configAddonName)
		if not loaded then
			why = _G['ADDON_'..reason]
		end
		addon:OpenOptions(...)
	end
end

do
	-- Create the Blizzard addon option frame
	local panel = CreateFrame("Frame", addonName.."BlizzOptions")
	panel.name = addonName
	InterfaceOptions_AddCategory(panel)

	local fs = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	fs:SetPoint("TOPLEFT", 10, -15)
	fs:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", 10, -45)
	fs:SetJustifyH("LEFT")
	fs:SetJustifyV("TOP")
	fs:SetText(addonName)

	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetText(L['Configure'])
	button:SetWidth(128)
	button:SetPoint("TOPLEFT", 10, -48)
	button:SetScript('OnClick', function()
		while CloseWindows() do end
		return addon:OpenOptions()
	end)

end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------

local updatedBags = {}
local updatedBank = { [BANK_CONTAINER] = true }
local updatedReagentBank = {}
if addon.isRetail then
	updatedReagentBank = { [REAGENTBANK_CONTAINER] = true }
end

function addon:BAG_UPDATE(event, bag)
	updatedBags[bag] = true
	if addon.isWrath or addon.isRetail then
		self:SendMessage('AdiBags_BagUpdated', updatedBags)
		wipe(updatedBags)
	end
end

function addon:BAG_UPDATE_DELAYED(event)
	self:SendMessage('AdiBags_BagUpdated', updatedBags)
	wipe(updatedBags)
end

function addon:BankUpdated(slots)
	-- Wrap several PLAYERBANKSLOTS_CHANGED into one AdiBags_BagUpdated message
	for slot in pairs(slots) do
		if slot > 0 and slot <= NUM_BANKGENERIC_SLOTS then
			return self:SendMessage('AdiBags_BagUpdated', updatedBank)
		end
	end
end

function addon:ReagentBankUpdated(slots)
	-- Wrap several PLAYERREAGANBANKSLOTS_CHANGED into one AdiBags_BagUpdated message
	for slot in pairs(slots) do
		if slot > 0 and slot <= 98 then
			return self:SendMessage('AdiBags_BagUpdated', updatedReagentBank)
		end
	end
end

function addon:ConfigChanged(vars)
	--[===[@debug@
	self:Debug('ConfigChanged', DebugTable(vars))
	--@end-debug@]===]
	if vars.enabled then
		if self.db.profile.enabled then
			self:Enable()
		else
			self:Disable()
		end
		return
	elseif not self:IsEnabled() then
		return
	elseif vars.filter then
		return self:SendMessage('AdiBags_FiltersChanged')
	else
		for name in pairs(vars) do
			if strmatch(name, 'virtualStacks') then
				return self:SendMessage('AdiBags_FiltersChanged')
			elseif strmatch(name, 'bags%.') then
				local _, bagName = strsplit('.', name)
				local bag = self:GetModule(bagName)
				local enabled = self.db.profile.bags[bagName]
				if enabled and not bag:IsEnabled() then
					bag:Enable()
				elseif not enabled and bag:IsEnabled() then
					bag:Disable()
				end
			elseif strmatch(name, 'columnWidth') then
				return self:SendMessage('AdiBags_LayoutChanged')
			end
		end
	end
	if vars.sortingOrder then
		return self:SetSortingOrder(self.db.profile.sortingOrder)
	elseif vars.maxHeight then
		return self:SendMessage('AdiBags_LayoutChanged')
	elseif vars.scale then
		return self:LayoutBags()
	elseif vars.positionMode then
		return self:UpdatePositionMode()
	else
		self:SendMessage('AdiBags_UpdateAllButtons')
	end
end

function addon:SetGlobalLock(locked)
	locked = not not locked
	if locked ~= self.globalLock then
		self.globalLock = locked
		self:SendMessage('AdiBags_GlobalLockChanged', locked)
		if not locked then
			self:SendMessage('AdiBags_LayoutChanged')
		end
		return true
	end
end

--------------------------------------------------------------------------------
-- Track windows related to item interaction (merchant, mail, bank, ...)
--------------------------------------------------------------------------------

do
	local current
	function addon:UpdateInteractingWindow(event, ...)
		local new = strmatch(event, '^([_%w]+)_OPEN') or strmatch(event, '^([_%w]+)_SHOW$') or strmatch(event, '^([_%w]+)_UPDATE$')
		self:Debug('UpdateInteractingWindow', event, current, '=>', new, '|', ...)
		if new ~= current then
			local old = current
			current = new
			self.atBank = (current == "BANKFRAME")
			if self.db.profile.virtualStacks.notWhenTrading ~= 0 then
				self:SendMessage('AdiBags_FiltersChanged', true)
			end
			self:SendMessage('AdiBags_InteractingWindowChanged', new, old)
		end
	end

	function addon:UpdateInteractingFrame(event, kind)
		local new
		if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
			if kind == Enum.PlayerInteractionType.Banker then
				new = "BANKFRAME"
			elseif kind == Enum.PlayerInteractionType.Merchant or
			kind == Enum.PlayerInteractionType.Auctioneer or
			kind == Enum.PlayerInteractionType.BlackMarketAuctioneer or
			kind == Enum.PlayerInteractionType.TradePartner or
			kind == Enum.PlayerInteractionType.MailInfo then
				new = "MERCHANT"
			end
		end
		self:Debug('UpdateInteractingFrame', event, current, '=>', new, '|', kind)
		if new ~= current then
			local old = current
			current = new
			self.atBank = (current == "BANKFRAME")
			if self.db.profile.virtualStacks.notWhenTrading ~= 0 then
				self:SendMessage('AdiBags_FiltersChanged', true)
			end
			self:SendMessage('AdiBags_InteractingWindowChanged', new, old)
		end
	end

	function addon:GetInteractingWindow()
		return current
	end
end

--------------------------------------------------------------------------------
-- Virtual stacks
--------------------------------------------------------------------------------

function addon:ShouldStack(slotData)
	local conf = self.db.profile.virtualStacks
	local hintSuffix = '#'..tostring(slotData.bagFamily)
	if not slotData.link then
		return conf.freeSpace, "*Free*"..hintSuffix
	end
	if not self.db.profile.showBagType then
		hintSuffix = ''
	end
	local window, unstack = self:GetInteractingWindow(), 0
	if window then
		unstack = conf.notWhenTrading
		if unstack >= 4 and window ~= "BANKFRAME" then
			return
		end
	end
	local maxStack = slotData.maxStack or 1
	if maxStack > 1 then
		if conf.stackable then
			if (slotData.count or 1) == maxStack then
				return true, tostring(slotData.itemId)..hintSuffix
			elseif unstack < 3 then
				return conf.incomplete, tostring(slotData.itemId)..hintSuffix
			end
		end
	elseif conf.others and unstack < 2 then
		return true, tostring(self.GetDistinctItemID(slotData.link))..hintSuffix
	end
end

--------------------------------------------------------------------------------
-- Skin-related methods
--------------------------------------------------------------------------------

local LSM = LibStub('LibSharedMedia-3.0')

function addon:GetContainerSkin(containerName, isReagentBank)
	local skin
	if isReagentBank then
		skin = addon.db.profile.theme.reagentBank
	else
		skin = addon.db.profile.theme[string.lower(containerName)]
	end

	local r, g, b, a = unpack(skin.color, 1, 4)
	local backdrop = addon.BACKDROP
	backdrop.bgFile = LSM:Fetch(LSM.MediaType.BACKGROUND, skin.background)
	backdrop.edgeFile = LSM:Fetch(LSM.MediaType.BORDER, skin.border)
	backdrop.edgeSize = skin.borderWidth
	backdrop.insets.left = skin.insets
	backdrop.insets.right = skin.insets
	backdrop.insets.top = skin.insets
	backdrop.insets.bottom = skin.insets
	return backdrop, r, g, b, a
end
