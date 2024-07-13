include ("IconSupport");
include ("MenuUtils");
print("UC Selection Loaded")

-- Hide dialog by default.
ContextPtr:SetHide(true);
--==========================================================================================
-- Variables
--==========================================================================================
local g_UCList = {}
local g_ChosenUCList = {{nil, nil}, {nil, nil}, {nil, nil}, {nil, nil}}
local UC_UNIT = 0;
local UC_BUILDING = 1;
local UC_IMPROVEMENT = 2;

-- 抽取所有UC
for row in GameInfo.Civilization_UnitClassOverrides() do
	if row.UnitType then
		table.insert(g_UCList,{row.UnitType, UC_UNIT, GameInfoTypes[row.UnitType]})
	end
	
end
for row in GameInfo.Civilization_BuildingClassOverrides() do
	if row.BuildingType then
		table.insert(g_UCList,{row.BuildingType, UC_BUILDING, GameInfoTypes[row.BuildingType]})
	end
end
for row in GameInfo.Improvements() do
	if row.Type and row.CivilizationType then
		table.insert(g_UCList,{row.Type, UC_IMPROVEMENT, row.ID})
	end
end

local activePlayerID = Game.GetActivePlayer()
local activePlayer = Players[activePlayerID]

--==========================================================================================
-- Main Functions
--==========================================================================================
-- Initializes All Components.
function initializeDialog()

	local pPlayer = activePlayer;	
	local leader = GameInfo.Leaders[pPlayer:GetLeaderType()];
	local activeCivID = pPlayer:GetCivilizationType();
	local activeCiv = GameInfo.Civilizations[activeCivID];
	g_ChosenUCList = {{nil, nil}, {nil, nil}, {nil, nil}, {nil, nil}}

	if leader then
		print("initializeDialog: Leader Found: " .. Locale.ConvertTextKey(leader.Description))
		-- Build CIV LEADER Potrair
		IconHookup(leader.PortraitIndex, 128, leader.IconAtlas, Controls.MercenaryUnitLeaderPortrait)
	else
		print("Leader not found")
	end

	IconHookup(11, 256, "EXPANSION2_PROMOTION_ATLAS", Controls.UCPPortrait1)
	IconHookup(11, 256, "EXPANSION2_PROMOTION_ATLAS", Controls.UCPPortrait2)
	IconHookup(11, 256, "EXPANSION2_PROMOTION_ATLAS", Controls.UCPPortrait3)
	IconHookup(11, 256, "EXPANSION2_PROMOTION_ATLAS", Controls.UCPPortrait4)
	
	Controls.UCSelectList1:GetButton():LocalizeAndSetText("TXT_KEY_OPTIONAL_UC_CHOSE")
	Controls.UCSelectList2:GetButton():LocalizeAndSetText("TXT_KEY_OPTIONAL_UC_CHOSE")
	Controls.UCSelectList3:GetButton():LocalizeAndSetText("TXT_KEY_OPTIONAL_UC_CHOSE")
	Controls.UCSelectList4:GetButton():LocalizeAndSetText("TXT_KEY_OPTIONAL_UC_CHOSE")
end

function OnUCSelected1(UCID, UCType)
	if UCType == UC_UNIT then
		local unit = GameInfo.Units[UCID]
		Controls.UCSelectList1:GetButton():SetText(Locale.ConvertTextKey(unit.Description or 0))
		Controls.UCIconButton1:SetToolTipString(Locale.ConvertTextKey(unit.Help or 0))
		IconHookup(unit.PortraitIndex, 256, unit.IconAtlas, Controls.UCPPortrait1);
	elseif UCType == UC_BUILDING then
		local building = GameInfo.Buildings[UCID]
		Controls.UCSelectList1:GetButton():SetText(Locale.ConvertTextKey(building.Description or 0))
		Controls.UCIconButton1:SetToolTipString(Locale.ConvertTextKey(building.Help or 0))
		IconHookup(building.PortraitIndex, 256, building.IconAtlas, Controls.UCPPortrait1);
	elseif UCType == UC_IMPROVEMENT then
		local improvement = GameInfo.Improvements[UCID]
		Controls.UCSelectList1:GetButton():SetText(Locale.ConvertTextKey(improvement.Description or 0))
		Controls.UCIconButton1:SetToolTipString(Locale.ConvertTextKey(improvement.Help or 0))
		IconHookup(improvement.PortraitIndex, 256, improvement.IconAtlas, Controls.UCPPortrait1);
	end
	g_ChosenUCList[1] = {UCID, UCType}
end

function OnUCSelected2(UCID, UCType)
	if UCType == UC_UNIT then
		local unit = GameInfo.Units[UCID]
		Controls.UCSelectList2:GetButton():SetText(Locale.ConvertTextKey(unit.Description or 0))
		Controls.UCIconButton2:SetToolTipString(Locale.ConvertTextKey(unit.Help or 0))
		IconHookup(unit.PortraitIndex, 256, unit.IconAtlas, Controls.UCPPortrait2);
	elseif UCType == UC_BUILDING then
		local building = GameInfo.Buildings[UCID]
		Controls.UCSelectList2:GetButton():SetText(Locale.ConvertTextKey(building.Description or 0))
		Controls.UCIconButton2:SetToolTipString(Locale.ConvertTextKey(building.Help or 0))
		IconHookup(building.PortraitIndex, 256, building.IconAtlas, Controls.UCPPortrait2);
	elseif UCType == UC_IMPROVEMENT then
		local improvement = GameInfo.Improvements[UCID]
		Controls.UCSelectList2:GetButton():SetText(Locale.ConvertTextKey(improvement.Description or 0))
		Controls.UCIconButton2:SetToolTipString(Locale.ConvertTextKey(improvement.Help or 0))
		IconHookup(improvement.PortraitIndex, 256, improvement.IconAtlas, Controls.UCPPortrait2);
	end
	g_ChosenUCList[2] = {UCID, UCType}
end

function OnUCSelected3(UCID, UCType)
	if UCType == UC_UNIT then
		local unit = GameInfo.Units[UCID]
		Controls.UCSelectList3:GetButton():SetText(Locale.ConvertTextKey(unit.Description or 0))
		Controls.UCIconButton3:SetToolTipString(Locale.ConvertTextKey(unit.Help or 0))
		IconHookup(unit.PortraitIndex, 256, unit.IconAtlas, Controls.UCPPortrait3);
	elseif UCType == UC_BUILDING then
		local building = GameInfo.Buildings[UCID]
		Controls.UCSelectList3:GetButton():SetText(Locale.ConvertTextKey(building.Description or 0))
		Controls.UCIconButton3:SetToolTipString(Locale.ConvertTextKey(building.Help or 0))
		IconHookup(building.PortraitIndex, 256, building.IconAtlas, Controls.UCPPortrait3);
	elseif UCType == UC_IMPROVEMENT then
		local improvement = GameInfo.Improvements[UCID]
		Controls.UCSelectList3:GetButton():SetText(Locale.ConvertTextKey(improvement.Description or 0))
		Controls.UCIconButton3:SetToolTipString(Locale.ConvertTextKey(improvement.Help or 0))
		IconHookup(improvement.PortraitIndex, 256, improvement.IconAtlas, Controls.UCPPortrait3);
	end
	g_ChosenUCList[3] = {UCID, UCType}
end

function OnUCSelected4(UCID, UCType)
	if UCType == UC_UNIT then
		local unit = GameInfo.Units[UCID]
		Controls.UCSelectList4:GetButton():SetText(Locale.ConvertTextKey(unit.Description or 0))
		Controls.UCIconButton4:SetToolTipString(Locale.ConvertTextKey(unit.Help or 0))
		IconHookup(unit.PortraitIndex, 256, unit.IconAtlas, Controls.UCPPortrait4);
	elseif UCType == UC_BUILDING then
		local building = GameInfo.Buildings[UCID]
		Controls.UCSelectList4:GetButton():SetText(Locale.ConvertTextKey(building.Description or 0))
		Controls.UCIconButton4:SetToolTipString(Locale.ConvertTextKey(building.Help or 0))
		IconHookup(building.PortraitIndex, 256, building.IconAtlas, Controls.UCPPortrait4);
	elseif UCType == UC_IMPROVEMENT then
		local improvement = GameInfo.Improvements[UCID]
		Controls.UCSelectList4:GetButton():SetText(Locale.ConvertTextKey(improvement.Description or 0))
		Controls.UCIconButton4:SetToolTipString(Locale.ConvertTextKey(improvement.Help or 0))
		IconHookup(improvement.PortraitIndex, 256, improvement.IconAtlas, Controls.UCPPortrait4);
	end
	g_ChosenUCList[4] = {UCID, UCType}
end

-- Left pulldown list update.
function UpdateUCList(ConUCSelectList, OnUCSelectedFuc)
	ConUCSelectList:ClearEntries()
	for k, v in pairs(g_UCList) do
		local entry = {}
		ConUCSelectList:BuildEntry("InstanceOne", entry)
		local UCPoint = nil;
		if v[2] == UC_UNIT then
			UCPoint = GameInfo.Units[v[3]]
		elseif v[2] == UC_BUILDING then
			UCPoint = GameInfo.Buildings[v[3]]
		elseif v[2] == UC_IMPROVEMENT then
			UCPoint = GameInfo.Improvements[v[3]]
		end
		-- RegisterSelectionCallback 传参 ID UCType 
		entry.Button:SetVoid1(v[3])
		entry.Button:SetVoid2(v[2])
		entry.Button:SetText(Locale.ConvertTextKey(UCPoint.Description))
	end

	ConUCSelectList:GetButton():LocalizeAndSetText("TXT_KEY_OPTIONAL_UC_CHOSE")	
	ConUCSelectList:CalculateInternals()
	ConUCSelectList:RegisterSelectionCallback(OnUCSelectedFuc)
end


-- Handle the Apply Button
function onApplyButton()
	for k, v in pairs(g_ChosenUCList) do
		if v[1] and v[2] then
			if v[2] == UC_UNIT then
				local unit = GameInfo.Units[v[1]]
				activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lChangeUUFromExtra", unit.ID)
			elseif v[2] == UC_BUILDING then
				local building = GameInfo.Buildings[v[1]]
				activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lChangeUBFromExtra", building.ID)
			elseif v[2] == UC_IMPROVEMENT then
				local improvement = GameInfo.Improvements[v[1]]
				activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lChangeUIFromExtra", improvement.ID)
			end
		end
		print(v[1])
	end
	activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lSetLostUC", true)
	hideDialog()
end
Controls.OKButton:RegisterCallback(Mouse.eLClick, onApplyButton)
--==========================================================================================
-- Smaller Functions
--==========================================================================================

-- Show function
function showDialog()
	-- Show panel
	ContextPtr:SetHide(false)
	-- Initialize
	initializeDialog()
	UpdateUCList(Controls.UCSelectList1, OnUCSelected1)
	UpdateUCList(Controls.UCSelectList2, OnUCSelected2)
	UpdateUCList(Controls.UCSelectList3, OnUCSelected3)
	UpdateUCList(Controls.UCSelectList4, OnUCSelected4)
end

-- Hide function
function hideDialog()
	ContextPtr:SetHide(true)
end
--==========================================================================================
-- Game Procession Functions
--==========================================================================================
function showDialogOnGameStart()
	if not activePlayer:IsLostUC() then
		showDialog()
	end
end
Events.SequenceGameInitComplete.Add(showDialogOnGameStart)