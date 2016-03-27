
--[[
	SaySapped: Says "Sapped!" when you get sapped allowing you to notify nearby players about it.
	Also works for many other CCs.
	Author: Coax  - Nostalrius PvP
	Original idea: Bitbyte of Icecrown
--]]

--[[	
 version 1.1: Rogue on me option and 10 sec cd for it.
 version 1.0: release
--]]

local SaySapped_timer = 0;
local measureTime = false;
local SaySapped_UpdateInterval = 5.0; -- How often the OnUpdate code will run (in seconds)
local Sapped_TimeSinceLastUpdate = 0;

-- Turn the message into a table.
local function stringToTable(str)
	str = string.sub(str, 1, string.len(str) - 1)
	local args = {}
	for word in string.gfind(str, "[^%s]+") do
		table.insert(args, word)
	end
	return args
end

local function SaySapped_OnUpdate(self, elapsed)
	local time = GetTime()
  if (Sapped_TimeSinceLastUpdate < time) then
		if (SaySapped_timer < 2) then 
			--DEFAULT_CHAT_FRAME:AddMessage(SaySapped_timer)
			SaySapped_timer = SaySapped_timer + 1
		else
			SaySapped_timer = 0
			measureTime = false
			--DEFAULT_CHAT_FRAME:AddMessage("reset")
		end
		Sapped_TimeSinceLastUpdate = time + SaySapped_UpdateInterval
  end
end

local f = CreateFrame("frame")
f:SetScript("OnUpdate", SaySapped_OnUpdate)

-- Extract the spell name and check if it contains the name of a cc.
-- If found and the reporting of that cc is enabled, report in chat frame and say.
function SaySapped_FilterDebuffs(msg)
		local t = stringToTable(msg)
		local spell = t[5]
		local i = 6
		while t[i] do
			spell = spell..t[i]
			i = i + 1
		end
		if string.find(spell, "Sap") and SaySappedConfig["Sap"] then
			SendChatMessage("Sapped!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Sapped!")
		elseif string.find(spell, "FreezingTrap") and SaySappedConfig["Freezing Trap"] then
			SendChatMessage("Trapped!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Trapped!")
		elseif string.find(spell, "Blind") and SaySappedConfig["Blind"] then
			SendChatMessage("Blinded!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Blinded!")	
		elseif string.find(spell, "Polymorph") and SaySappedConfig["Polymorph"] then
			SendChatMessage("Polymorphed!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Polymorphed!")
		elseif ( string.find(spell, "Fear") or string.find(spell, "IntimidatingShout") or string.find(spell, "PsychicScream") ) and SaySappedConfig["Fear"] then
			SendChatMessage("Feared!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Feared")
		elseif string.find(spell, "Hibernate") and SaySappedConfig["Hibernate"] then
			SendChatMessage("Hibernated!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Hibernated!")
		elseif string.find(spell, "RecklessCharge") and SaySappedConfig["Reckless Charge"] then
			SendChatMessage("Reckless Charged!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Reckless Charged!")
		elseif string.find(spell, "Silence") and SaySappedConfig["Silence"] then
			SendChatMessage("Silenced!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Silenced!")
		elseif string.find(spell, "MindControl") and SaySappedConfig["Mind Control"] then
			SendChatMessage("Mindcontrolled!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Mindcontrolled!")
		elseif string.find(spell, "Seduce") and SaySappedConfig["Seduce"] then
			SendChatMessage("Seduced!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Seduced!")	
		elseif (string.find(spell, "CheapShot") or string.find(spell, "KidneyShot")) and SaySappedConfig["Rogue on me"] and not measureTime then
			SendChatMessage("Rogue on me!","SAY")
			DEFAULT_CHAT_FRAME:AddMessage("Rogue on you!")	
			measureTime = true
			SaySapped_timer = 0
		--elseif (string.find(spell, "Hamstring") or string.find(spell, "Frostbolt")) and not measureTime then -- for testing
		--	DEFAULT_CHAT_FRAME:AddMessage("Hamstring!")	
		--	measureTime = true
		--	SaySapped_timer = 0
		--DEFAULT_CHAT_FRAME:AddMessage("Hamstring")	
		end
end

-- Check if the player is entering the world and create the config file if it is not yet created.
-- if the event is a debuff on you, filter it.
function SaySapped_OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then
		this:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if not SaySappedConfig then
			SaySappedConfig = {
				["Sap"] = true,
				["Fear"] = false,
				["Freezing Trap"] = false,
				["Blind"] = false,
				["Reckless Charge"] = false,
				["Silence"] = false,
				["Polymorph"] = false,
				["Hibernate"] = false,
				["Seduce"] = false,
				["Rogue on me"] = false,
				["Mind Control"] = true
--				["Hamstring"] = false  -- for testing
			}
		end
	elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
		if string.find(arg1, "You are") then
			SaySapped_FilterDebuffs(arg1)
		end
	end
end

-- Make the menu visible or invisible.
function SaySappedMenu_Toggle()
	if SaySapped:IsVisible() then
		SaySapped:Hide()
	else
		SaySapped:Show()
	end
end

-- Slash Command
SlashCmdList["SAYSAPPED"] = SaySapped_SlashCmdHandler
SLASH_SAYSAPPED1 = "/saysapped"

function SaySapped_SlashCmdHandler(msg)
	SaySappedMenu_Toggle()
end

-- Change the config file when a click happens.
function SaySapped_CheckButton_OnClick()
	local t = this:GetText();
	if this:GetChecked() then
		SaySappedConfig[t] = true
	else
		SaySappedConfig[t] = false
	end
end

-- Load the check button setting on show.
function SaySapped_ButtonInitialize()
	local name = this:GetText()
	if SaySappedConfig then
		if SaySappedConfig[name] then
			this:SetChecked(true);
		end
	end
end

-- Start registering events and print the loading message.
function SaySapped_OnLoad()
	SaySapped:RegisterEvent("PLAYER_ENTERING_WORLD")
	SaySapped:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
	DEFAULT_CHAT_FRAME:AddMessage("SaySapped loaded, type /saysapped for options.")
end


