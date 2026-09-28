--从dll直接执行代码
--Game.DoOptionalUCCode()

include ("IconSupport");
include ("MenuUtils");
include("InfoTooltipInclude");

-- Hide dialog by default.
ContextPtr:SetHide(true);
--==========================================================================================
-- Variables
--==========================================================================================

-- 修改这里即可改变可选 UC 的数量。
-- 不需要在游戏中动态修改，默认 4。
local OPTIONAL_UC_COUNT = 4;

local g_UCList = {};
local g_ChosenUCList = {};
local g_UCInstances = {};
local g_ViewOnly = false;

local UC_UNIT = 0;
local UC_BUILDING = 1;
local UC_IMPROVEMENT = 2;
local t_List = {};

-- 抽取所有 UC
for row in GameInfo.Civilization_UnitClassOverrides() do
	-- 不能建造的以及本身是默认单位的不要
	-- 海鹞 蛮族?
	if row.UnitType 
	and row.UnitType ~= "UNIT_BARBARIAN_WARRIOR"
	and row.UnitType ~= "UNIT_BARBARIAN_ARCHER"
	and row.UnitType ~= "UNIT_BARBARIAN_AXMAN"
	and row.UnitType ~= "UNIT_BARBARIAN_GALLEY"
	then
		table.insert(t_List, {row.UnitType, UC_UNIT, GameInfoTypes[row.UnitType], Locale.ConvertTextKey(GameInfo.Units[row.UnitType].Description)})
	end
end
table.sort(t_List, function(a , b) return Locale.Compare(a[4], b[4]) == -1 end);
g_UCList = t_List;
t_List = {};

for row in GameInfo.Civilization_BuildingClassOverrides() do
	-- 不能建造的不要
	-- 总督府 总督宫 宫殿允许(V5)
	if row.BuildingType 
	and (GameInfo.Buildings[row.BuildingType].Cost > 1 
		or row.BuildingType == "BUILDING_SATRAPS_COURT" 
		or row.BuildingType == "BUILDING_PUPPET_GOVERNEMENT_FULL"
		or GameInfo.Buildings[row.BuildingType].BuildingClass == "BUILDINGCLASS_PALACE") 
	then
		table.insert(t_List, {row.BuildingType, UC_BUILDING, GameInfoTypes[row.BuildingType], Locale.ConvertTextKey(GameInfo.Buildings[row.BuildingType].Description)})
	end
end
table.sort(t_List, function(a , b) return Locale.Compare(a[4], b[4]) == -1 end);
for k, v in pairs(t_List) do table.insert(g_UCList, v) end
t_List = {};

for row in GameInfo.Improvements() do
	if row.Type and row.CivilizationType then
		table.insert(t_List, {row.Type, UC_IMPROVEMENT, row.ID, Locale.ConvertTextKey(row.Description)})
	end
end
table.sort(t_List, function(a , b) return Locale.Compare(a[4], b[4]) == -1 end);
for k, v in pairs(t_List) do table.insert(g_UCList, v) end
t_List = {};

local activePlayerID = Game.GetActivePlayer()
local activePlayer = Players[activePlayerID]

--==========================================================================================
-- UC UI Functions
--==========================================================================================

-- 根据 UC 类型取得 GameInfo 项
local function GetUCInfo(UCID, UCType)
	if UCType == UC_UNIT then
		return GameInfo.Units[UCID]
	elseif UCType == UC_BUILDING then
		return GameInfo.Buildings[UCID]
	elseif UCType == UC_IMPROVEMENT then
		return GameInfo.Improvements[UCID]
	end
	return nil
end

-- 设置一个动态创建的 UC 选择项
local function SetUCSelected(index, UCID, UCType)
	local instance = g_UCInstances[index];
	if not instance then
		return;
	end

	local ucInfo = GetUCInfo(UCID, UCType);
	if not ucInfo then
		return;
	end

	instance.SelectList:GetButton():SetText(Locale.ConvertTextKey(ucInfo.Description or 0));

	if g_ViewOnly then
		instance.SelectList:SetDisabled(true);
		instance.IconButton:SetToolTipString("");
	else
		instance.SelectList:SetDisabled(false);

		if UCType == UC_UNIT then
			instance.IconButton:SetToolTipString(GetHelpTextForUnit(UCID));
		elseif UCType == UC_BUILDING then
			instance.IconButton:SetToolTipString(GetHelpTextForBuilding(UCID));
		elseif UCType == UC_IMPROVEMENT then
			instance.IconButton:SetToolTipString(GetHelpTextForImprovement(UCID));
		end
	end

	IconHookup(ucInfo.PortraitIndex, 256, ucInfo.IconAtlas, instance.Portrait);
	g_ChosenUCList[index] = {UCID, UCType};
end

-- 每个动态 PullDown 都使用同一个回调函数
local function OnUCSelected(index, UCID, UCType)
	if g_ViewOnly then
		return;
	end
	SetUCSelected(index, UCID, UCType);
end

-- 更新一个 PullDown
local function UpdateUCList(instance, index)
	local selectList = instance.SelectList;

	selectList:ClearEntries();

	for k, v in pairs(g_UCList) do
		local entry = {};
		selectList:BuildEntry("InstanceOne", entry);

		local UCPoint = GetUCInfo(v[3], v[2]);
		if UCPoint then
			-- RegisterSelectionCallback 会把 Void1/Void2 作为参数传给回调
			entry.Button:SetVoid1(v[3]);
			entry.Button:SetVoid2(v[2]);
			entry.Button:SetText(Locale.ConvertTextKey(UCPoint.Description));
		end
	end

	selectList:GetButton():LocalizeAndSetText("TXT_KEY_OPTIONAL_UC_CHOSE");
	selectList:CalculateInternals();
	selectList:RegisterSelectionCallback(function(UCID, UCType)
		OnUCSelected(index, UCID, UCType);
	end);
end

-- 创建 OPTIONAL_UC_COUNT 个选择项
local function BuildUCSelectionUI()
	Controls.UCSelectPanel:DestroyAllChildren();
	g_UCInstances = {};

	for i = 1, OPTIONAL_UC_COUNT do
		local instance = {};
		ContextPtr:BuildInstanceForControl("UCSelectInstance", instance, Controls.UCSelectPanel);
		g_UCInstances[i] = instance;

		-- 默认使用原来的占位图标
		IconHookup(11, 256, "EXPANSION2_PROMOTION_ATLAS", instance.Portrait);

		UpdateUCList(instance, i);
	end

	Controls.UCSelectPanel:CalculateSize();
	Controls.UCSelectPanel:ReprocessAnchoring();
	Controls.UCScrollPanel:CalculateInternalSize();
end

--==========================================================================================
-- Main Functions
--==========================================================================================

-- Initializes All Components.
function initializeDialog()
	local pPlayer = activePlayer;	
	local leader = GameInfo.Leaders[pPlayer:GetLeaderType()];
	local activeCivID = pPlayer:GetCivilizationType();
	local activeCiv = GameInfo.Civilizations[activeCivID];

	g_ChosenUCList = {};
	for i = 1, OPTIONAL_UC_COUNT do
		g_ChosenUCList[i] = {nil, nil};
	end

	if leader then
		print("initializeDialog: Leader Found: " .. Locale.ConvertTextKey(leader.Description))
		IconHookup(leader.PortraitIndex, 128, leader.IconAtlas, Controls.MercenaryUnitLeaderPortrait)
	else
		print("Leader not found")
	end

	BuildUCSelectionUI();
end

--==========================================================================================
-- Handle the Apply Button
--==========================================================================================

function onApplyButton()
	for k, v in pairs(g_ChosenUCList) do
		if v[1] and v[2] then
			if v[2] == UC_UNIT then
				local unit = GameInfo.Units[v[1]];
				--activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lChangeUUFromExtra", unit.ID)
				activePlayer:ChangeUUFromExtra(unit.ID);

				--禁用默认
				--if unit.Special ~= "SPECIALUNIT_PEOPLE" then end
				activePlayer:ChangeUUFromExtra(GameInfoTypes[GameInfo.UnitClasses[unit.Class].DefaultUnit]);

			elseif v[2] == UC_BUILDING then
				local building = GameInfo.Buildings[v[1]];
				--activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lChangeUBFromExtra", building.ID)
				activePlayer:ChangeUBFromExtra(building.ID);

				--禁用默认
				activePlayer:ChangeUBFromExtra(GameInfoTypes[GameInfo.BuildingClasses[building.BuildingClass].DefaultBuilding]);

			elseif v[2] == UC_IMPROVEMENT then
				local improvement = GameInfo.Improvements[v[1]];
				--activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lChangeUIFromExtra", improvement.ID)
				activePlayer:ChangeUIFromExtra(improvement.ID);
			end
		end
	end

	--activePlayer:SendAndExecuteLuaFunction("CvLuaPlayer::lSetLostUC", true)
	activePlayer:SetLostUC(true);
	addOptionalUCNotification();
	changeGreatWorkBuildings();
	hideDialog();
end

--==========================================================================================
-- Smaller Functions
--==========================================================================================

-- Show function
function showDialog()
	g_ViewOnly = false;
	ContextPtr:SetHide(false);
	Controls.OKButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_OK_TOOLTIP"));
	Controls.OKButton:SetText(Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_OK"))
	initializeDialog();
end

-- 显示已经选择的 UC，只用于查看
function showChosenUCDialog()
	activePlayerID = Game.GetActivePlayer();
	activePlayer = Players[activePlayerID];

	g_ViewOnly = true;
	g_ChosenUCList = GetChosenUCList();

	ContextPtr:SetHide(false);

	local leader = GameInfo.Leaders[activePlayer:GetLeaderType()];
	if leader then
		IconHookup(leader.PortraitIndex, 128, leader.IconAtlas, Controls.MercenaryUnitLeaderPortrait);
	end

	Controls.UCSelectPanel:DestroyAllChildren();
	g_UCInstances = {};

	for i, v in ipairs(g_ChosenUCList) do
		local instance = {};
		ContextPtr:BuildInstanceForControl("UCSelectInstance", instance, Controls.UCSelectPanel);
		g_UCInstances[i] = instance;

		SetUCSelected(i, v[1], v[2]);
	end

	Controls.UCSelectPanel:CalculateSize();
	Controls.UCSelectPanel:ReprocessAnchoring();
	Controls.UCScrollPanel:CalculateInternalSize();

	Controls.OKButton:SetToolTipString("");
	Controls.OKButton:SetText(Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_CLOSE"))
end

-- Hide function
function hideDialog()
	ContextPtr:SetHide(true);
end

--==========================================================================================
-- Game Procession Functions
--==========================================================================================

-- 获取当前玩家已经选择的 UC
function GetChosenUCList()
	local result = {};

	for row in GameInfo.Civilization_UnitClassOverrides() do
		if row.UnitType and (activePlayer:GetUUFromExtra(GameInfoTypes[row.UnitType]) > 0) then
			table.insert(result, {GameInfoTypes[row.UnitType], UC_UNIT});
		end
	end

	for row in GameInfo.Civilization_BuildingClassOverrides() do
		if row.BuildingType and (activePlayer:GetUBFromExtra(GameInfoTypes[row.BuildingType]) > 0) then
			table.insert(result, {GameInfoTypes[row.BuildingType], UC_BUILDING});
		end
	end

	for row in GameInfo.Improvements() do
		if row.Type and (activePlayer:GetUIFromExtra(GameInfoTypes[row.Type]) > 0) then
			table.insert(result, {GameInfoTypes[row.Type], UC_IMPROVEMENT});
		end
	end

	return result;
end

function updateChosenUCList()
	g_ChosenUCList = GetChosenUCList();
end

--==========================================================================================
-- OK Button
--==========================================================================================

Controls.OKButton:RegisterCallback(Mouse.eLClick, function()
	if g_ViewOnly then
		hideDialog();
	else
		onApplyButton();
	end
end);

function addOptionalUCNotification()
	local heading = Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_NOTIFICATION_HEAD");
	local text = "";
	local UCDescript = "";

	for k, v in pairs(g_ChosenUCList) do
		if v[1] and v[2] then
			if v[2] == UC_UNIT then
				text = text .. "[NEWLINE]" .. Locale.ConvertTextKey(GameInfo.Units[v[1]].Description);
			elseif v[2] == UC_BUILDING then
				text = text .. "[NEWLINE]" .. Locale.ConvertTextKey(GameInfo.Buildings[v[1]].Description);
			elseif v[2] == UC_IMPROVEMENT then
				text = text .. "[NEWLINE]" .. Locale.ConvertTextKey(GameInfo.Improvements[v[1]].Description);
			end
		end
	end

	if text ~= "" then
		text = Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_NOTIFICATION_TEXT") .. text;
	else
		text = Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_NOTIFICATION_TEXT2");
	end

	activePlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading, -1, -1);
end

function changeGreatWorkBuildings()
	if activePlayer:IsLostUC() then
		for row in GameInfo.Civilization_BuildingClassOverrides() do
			if row.BuildingType
			and row.CivilizationType == GameInfo.Civilizations[activePlayer:GetCivilizationType()].Type 
			then
				LuaEvents.GreatWorkBuildingsChanges(GameInfo.BuildingClasses[GameInfo.Buildings[row.BuildingType].BuildingClass].DefaultBuilding);
				print(GameInfo.BuildingClasses[GameInfo.Buildings[row.BuildingType].BuildingClass].DefaultBuilding);
			end
		end
	end

	for k, v in pairs(g_ChosenUCList) do
		if v[1] and v[2] then
			if v[2] == UC_BUILDING then
				LuaEvents.GreatWorkBuildingsChanges(activePlayer:GetCivBuilding(GameInfoTypes[GameInfo.Buildings[v[1]].BuildingClass]));
				print(GameInfo.Buildings[activePlayer:GetCivBuilding(GameInfoTypes[GameInfo.Buildings[v[1]].BuildingClass])].Type);
			end
		end
	end
end

function showDialogOnGameStart()
	activePlayerID = Game.GetActivePlayer();
	activePlayer = Players[activePlayerID];

	if not activePlayer:IsLostUC() then
		showDialog();
	else
		updateChosenUCList();
		addOptionalUCNotification();
		changeGreatWorkBuildings();
	end
end
Events.SequenceGameInitComplete.Add(showDialogOnGameStart);

function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
    table.insert(additionalEntries, {
        text = Locale.ConvertTextKey("TXT_KEY_OPTIONAL_UC_NOTIFICATION_HEAD"),
        call = showChosenUCDialog
    })
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

print("UC Selection Loaded");