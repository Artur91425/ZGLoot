-- Author      : e-Will - design and idea
-- Create Date v1.0: 12/5/2012 3:46:29 AM
-- Author      : Shuraken - all modification
-- Create Date v1.5: 25/04/2015 15:28:55 AM

ZGLoot.Active = false
ZGLoot.LastMess = nil
ZGLoot.CurrentVers = 1.8
ZGLoot.Tier_one = {
16828, 16830,
16850, 16851, 
16799, 16802,
16857, 16858,
16817, 16819,
16825, 16827,
16838, 16840,
16804, 16806,
16861, 16864,
}

function ZGLoot.MinimapButtonOnClick()
	if (ZGLootMain:IsVisible()) then ZGLootMain:Hide(); return; end
	ZGLootMain:Show()
end

-- движение вокруг миникарты
function ZGLoot_MinimapButton_Reposition()
	ZGLoot_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(ZGLootItemList.Minimap)),(80*sin(ZGLootItemList.Minimap))-52)
end

function ZGLoot_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70
	ypos = ypos/UIParent:GetScale()-ymin-70

	ZGLootItemList.Minimap = math.deg(math.atan2(ypos,xpos))
	ZGLoot_MinimapButton_Reposition()
end

-- переключение вкладок
function ZGLoot.OnInsetClick()
	for key, value in pairs(ZGLoot.Insets) do
		value:SetChecked(false)
		if ZGLoot.Tabs[key] then
			ZGLoot.Tabs[key]:Hide()
		end
		if this:GetName() == value:GetName() then
			value:SetChecked(true)
			if ZGLoot.Tabs[key] then
				ZGLoot.Tabs[key]:Show()
			end
		end
	end
end

-- обработка клика на "галочку" ALL

function ZGLoot.Click()
	local from, to, num = string.find(this:GetName(), "(%d+)")
	local str = strsub(this:GetName(), to + 1)
	if str == "CheckMyClass" then
		if this:GetChecked() then
			local localizedClass = UnitClass("player")
			for i = 1, getn(ZGLoot.Data[tonumber(num)]["items"]) do
				if string.find( ZGLoot.Data[tonumber(num)]["items"][i]["tooltip"][2], localizedClass ) then
					ZGLoot.CheckButtons[num..i.."Need"]:SetChecked(true)
					ZGLoot.CheckButtons[num..i.."Pass"]:SetChecked(false)
					ZGLoot.CheckButtons[num..i.."Greed"]:SetChecked(false)
					ZGLootItemList[num.."CheckMyClass"] = 1
					ZGLootItemList[num..i] = 1
				else
					ZGLoot.CheckButtons[num..i.."Need"]:SetChecked(false)
					ZGLoot.CheckButtons[num..i.."Pass"]:SetChecked(true)
					ZGLoot.CheckButtons[num..i.."Greed"]:SetChecked(false)
					ZGLootItemList[num.."CheckMyClass"] = 1
					ZGLootItemList[num..i] = 0
				end
			end
			ZGLoot.ConfirmCheckLine(num)
		else
			ZGLoot.CheckButtons[num.."CheckMyClass"]:SetChecked(true)
		end
	elseif string.find(str, "RollOption") then
		local roll_opt = tonumber(strsub(str, strlen(str)))
		local alloptions = {}
		for i = 1, 6 do
			alloptions[i] = ZGLoot.CheckButtons[num.."RollOption"..i]:GetChecked()
		end
		if (roll_opt == 1 or roll_opt == 2) and alloptions[roll_opt] then
			local flag = alloptions[roll_opt]
			for i = 1, 6 do
				alloptions[i] = not flag
			end
			alloptions[roll_opt] = flag
		elseif roll_opt == 1 and not alloptions[roll_opt] then
			alloptions[2] = true
			for i = 3, 6 do
				alloptions[i] = false
			end
		elseif roll_opt == 2 and not alloptions[roll_opt] then
			alloptions[1] = true
			for i = 3, 6 do
				alloptions[i] = false
			end
		else
			if alloptions[1] then
				alloptions[1] = false
			elseif alloptions[2] then
				alloptions[2] = false
			elseif alloptions[roll_opt] then
				if roll_opt == 3 then
					alloptions[4] = false
				elseif roll_opt == 4 then
					alloptions[3] = false
				elseif roll_opt == 5 then
					alloptions[6] = false
				elseif roll_opt == 6 then
					alloptions[5] = false
				end
			end
		end
		local globalfail = true
		for i = 1, 6 do
			if alloptions[i] then
				globalfail = false
			end
		end
		if globalfail then
			alloptions[1] = true
		end
		for i = 1, 6 do
			ZGLoot.CheckButtons[num.."RollOption"..i]:SetChecked(alloptions[i])
			if alloptions[i] then
				ZGLootItemList[num.."RollOption"..i] = 1
			else
				ZGLootItemList[num.."RollOption"..i] = 0
			end
		end
	elseif strlen(num) == 1 then
		local need, greed, pass
		if str == "Need" then
			need = this:GetChecked();
			pass = not need;
			ZGLoot.CheckButtons[num.."Greed"]:SetChecked(false)
			ZGLoot.CheckButtons[num.."Pass"]:SetChecked(pass)
		elseif str == "Greed" then
			greed = this:GetChecked();
			pass = not greed;
			ZGLoot.CheckButtons[num.."Need"]:SetChecked(false)
			ZGLoot.CheckButtons[num.."Pass"]:SetChecked(pass)
		elseif str == "Pass" then
			pass = true
			ZGLoot.CheckButtons[num.."Pass"]:SetChecked(true)
			ZGLoot.CheckButtons[num.."Need"]:SetChecked(false)
			ZGLoot.CheckButtons[num.."Greed"]:SetChecked(false)
		end
		local i = 1
		local name = num..i
		while ZGLoot.CheckButtons[name.."Need"] do
			ZGLoot.CheckButtons[name.."Need"]:SetChecked(need)
			ZGLoot.CheckButtons[name.."Greed"]:SetChecked(greed)
			ZGLoot.CheckButtons[name.."Pass"]:SetChecked(pass)
			if need then 
				ZGLootItemList[name] = 1
			elseif greed then 
				ZGLootItemList[name] = 2
			elseif pass then 
				ZGLootItemList[name] = 0
			end
			i = i + 1
			name = num..i
		end
		if ZGLoot.CheckButtons[num.."CheckMyClass"] then 
			ZGLootItemList[num.."CheckMyClass"] = 0
			ZGLoot.CheckButtons[num.."CheckMyClass"]:SetChecked(false)
		end
	else
		local need, greed, pass
		if str == "Need" then
			need = this:GetChecked()
			ZGLoot.CheckButtons[num.."Greed"]:SetChecked(false)
			ZGLoot.CheckButtons[num.."Pass"]:SetChecked(not need)
			ZGLootItemList[num] = need or 0
		elseif str == "Greed" then
			greed = this:GetChecked()
			ZGLoot.CheckButtons[num.."Need"]:SetChecked(false)
			ZGLoot.CheckButtons[num.."Pass"]:SetChecked(not greed)
			if greed then greed = 2 end
			ZGLootItemList[num] = greed or 0
		elseif str == "Pass" then
			pass = this:GetChecked()
			ZGLoot.CheckButtons[num.."Need"]:SetChecked(not pass)
			ZGLoot.CheckButtons[num.."Greed"]:SetChecked(false)
			if pass then pass = 0 end
			ZGLootItemList[num] = pass or 1
		end
		ZGLoot.ConfirmCheckLine(strsub(num, 1, 1))
		if ZGLoot.CheckButtons[floor(tonumber(num)/10).."CheckMyClass"] then 
			ZGLootItemList[floor(tonumber(num)/10).."CheckMyClass"] = 0
			ZGLoot.CheckButtons[floor(tonumber(num)/10).."CheckMyClass"]:SetChecked(false)
		end
	end
end

-- инициализация массивов значениями по умолчанию
function ZGLoot.LoadingDefaults()
	-- все по умолчанию заполняем
	if ZGLootItemList and ZGLoot.CurrentVers == ZGLootItemList.CurrentVers then
		for key, value in pairs(ZGLootItemList) do
			if key == "Silver" or key == "Zulian" or key == "Ru" then
				ZGLootItemList = nil
				ZGLootItemList = {}
				break
			end
		end
	else
		ZGLootItemList = 
		{
			Minimap = 45,
			CurrentVers = ZGLoot.CurrentVers
		}
	end

	ZGLoot.InInstance = false;
end

-- инициализация массивов после загрузки
function ZGLoot.InitializeVariable()
	-- ставим галочки везде из сохранений
	for key, value in pairs(ZGLootItemList) do
		ZGLootItemList[key] = value or 1
	end
	ZGLootItemList.Minimap = ZGLootItemList.Minimap	or 45;

	ZGLoot_MinimapButton_Reposition();
	ZGLoot.InitializeButtons();
	ZGLoot.RollMas = {}
end

-- проверить если вся полоса с "галочкой", поставить в ALL "галочку"
function ZGLoot.ConfirmCheckLine(num)
	local need = true;
	local greed = true;
	local pass = true;
	local i = 1;
	name = num..i
	while ZGLoot.CheckButtons[name.."Need"] do
		if (need) then
			need = ZGLoot.CheckButtons[name.."Need"]:GetChecked();
		end
		if (greed) then
			greed = ZGLoot.CheckButtons[name.."Greed"]:GetChecked();
		end
		if (pass) then
			pass = ZGLoot.CheckButtons[name.."Pass"]:GetChecked();
		end
		i = i + 1
		name = num..i
	end
	ZGLoot.CheckButtons[num.."Need"]:SetChecked(nil);
	ZGLoot.CheckButtons[num.."Greed"]:SetChecked(nil);
	ZGLoot.CheckButtons[num.."Pass"]:SetChecked(nil);
	
	if (need) then 
		ZGLoot.CheckButtons[num.."Need"]:SetChecked(1);
	elseif (greed) then 
		ZGLoot.CheckButtons[num.."Greed"]:SetChecked(1);
	elseif (pass) then
		ZGLoot.CheckButtons[num.."Pass"]:SetChecked(1);
	end
end

-- раставление "галочек" после загрузки файла настроек
function ZGLoot.InitializeButtons()
	-- sets checks buttons
	local roll_flag = false
	for key, value in pairs(ZGLootItemList) do
		if strlen(key) == 2 then
			if (ZGLootItemList[key] == 1) then
				ZGLoot.CheckButtons[key.."Need"]:SetChecked(1);
			elseif (ZGLootItemList[key] == 2) then
				ZGLoot.CheckButtons[key.."Greed"]:SetChecked(1);
			elseif (ZGLootItemList[key] == 0) then
				ZGLoot.CheckButtons[key.."Pass"]:SetChecked(1);
			end
	    end
	    if string.find(key, "RollOption") and value == 1 then
	    	ZGLoot.CheckButtons[key]:SetChecked(1)
	    	roll_flag = true
	    end
	end
	for i = 1, getn(ZGLoot.Data) do
		ZGLoot.ConfirmCheckLine(i)
	end
	if not roll_flag then
		ZGLoot.CheckButtons["8RollOption1"]:Click()
	end
	for i = 1, 5 do
		if (ZGLootItemList[i.."CheckMyClass"] == 1) then
			ZGLoot.CheckButtons[i.."CheckMyClass"]:SetChecked(1);
		end
	end
end

function ZGLoot.FindInMas(val, mas)
	local result = false
	for i = 1, getn(mas) do
		if mas[i] == val then
			result = i
			break
		end
	end
	return result
end

-- обработка вызова мастер лута и автоматическое нажатие
function ZGLoot.WatchLoot(id)
	local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(id)
	local fail = true
	local link = GetLootRollItemLink(id)
	local _, _, item_id = string.find(link, "[^:]*:?(%d*)")
	if item_id then
		item_id = tonumber(item_id)
	end
	for i = 1, getn(ZGLoot.Data) do
		for j = 1, getn(ZGLoot.Data[i]["items"]) do
			if (name == ZGLoot.Data[i]["items"][j]["name"]) and ZGLootItemList[i..j] then
				local rollType = ZGLootItemList[i..j];
				RollOnLoot(id, rollType)
				fail = false
				if not ZGLoot.RollMas[link] then
					ZGLoot.RollMas[link] = {}
					ZGLoot.RollMas[link]["count"] = 1
					ZGLoot.RollMas[link][ZGLoot.RollNames["Need"]] = {}
					ZGLoot.RollMas[link][ZGLoot.RollNames["Greed"]] = {}
				else
					ZGLoot.RollMas[link]["count"] = ZGLoot.RollMas[link]["count"] + 1
				end
			end
		end
	end
	if fail and quality >= 2 and quality <= 4 and not bindOnPickUp then
		local rollType = ZGLootItemList["7"..(5 - quality)];
		if ZGLoot.FindInMas(item_id, ZGLoot.Tier_one) then
			rollType = ZGLootItemList["64"];
		end
		RollOnLoot(id, rollType)			
		if not ZGLoot.RollMas[link] then
			ZGLoot.RollMas[link] = {}
			ZGLoot.RollMas[link]["count"] = 1
			ZGLoot.RollMas[link][ZGLoot.RollNames["Need"]] = {}
			ZGLoot.RollMas[link][ZGLoot.RollNames["Greed"]] = {}
		else
			ZGLoot.RollMas[link]["count"] = ZGLoot.RollMas[link]["count"] + 1
		end
	end
end

local ChatFrame_OnEvent_OldZGLoot;

ZGLoot.CurrentChatFrame = {}

function ChatFrame_OnEvent_NewZGLoot(event)
	if (event == "CHAT_MSG_LOOT" and not ZGLoot.Active) or event ~= "CHAT_MSG_LOOT" then
		ChatFrame_OnEvent_OldZGLoot(event)
	else
		local n = getn(ZGLoot.CurrentChatFrame)
		if not ZGLoot.FindInMas(this:GetName(), ZGLoot.CurrentChatFrame) then
			ZGLoot.CurrentChatFrame[n+1] = this:GetName()
		end
	end
end

--обработка ролловых сообщений

function ZGLoot.ChatMessageChange(message)
	local _, _, start, Roll, link, finish
	local type = strsub("CHAT_MSG_LOOT", 10) 
	local info = ChatTypeInfo[type]
	if GetLocale() == "enUS" then
		_, _, start, link, finish = string.find(message, "([^|]+)(|?c?f?f?%x|?H?[^:]*:?%d*:?%d*:?%d*:%d*|?h?%[.+%]|h|r)(.*)")
	else
		_, _, start, Color, Roll, middle, link, finish = string.find(message, "([^|]+)(|?c?f?f?%x%x%x%x%x%x)(%d+)|r([^|]+)(|?c?f?f?%x|?H?[^:]*:?%d*:?%d*:?%d*:%d*|?h?%[.+%]|h|r)(.*)")
		if not Roll then
			_, _, start, link, finish = string.find(message, "([^|]+)(|?c?f?f?%x*|?H?[^:]*:?%d*:?%d*:?%d*:%d*|?h?%[.+%]|h|r)(.*)")
		end
	end
	if not link or ZGLootItemList["8RollOption1"] == 1 or not ZGLoot.RollMas[link] or not ZGLoot.RollMas[link]["count"] or ZGLoot.RollMas[link]["count"] == 0 then
		for i = 1, getn(ZGLoot.CurrentChatFrame) do
			getglobal(ZGLoot.CurrentChatFrame[i]):AddMessage(message, info.r, info.g, info.b, info.id)
		end
		for i = 1, getn(ZGLoot.CurrentChatFrame) do
			ZGLoot.CurrentChatFrame[i] = nil
		end
	elseif ZGLootItemList["8RollOption2"] == 1 and ZGLoot.RollMas[link] then
	else
		if string.find(start, ZGLoot.RollNames["Roll"]) then
			local _, _, RollType = string.find(start, "^(%a+)")
			if GetLocale() ~= "enUS" then
				_, _, RollType = string.find(start, "(%b\"\")")
			end
			if not Roll then
				_, _, Roll = string.find(start, "(%d+)")
			end
			local _, _, Character = string.find(finish, "(%a+)$")
			if Character == UnitName("player") then
				Character = ZGLoot.RollNames["You"]
			end
			ZGLoot.RollMas[link][RollType][Character] = tonumber(Roll)
		elseif string.find(start, ZGLoot.RollNames["won"]) or string.find(start, ZGLoot.RollNames["won1"]) then
			local _, _, Winner = string.find(start, "([^%s]+)")
			local prevBestRoll, BestRoll = -1, 0
			local RollType = ZGLoot.RollNames["Need"]
			local fail = true
			for key, value in pairs(ZGLoot.RollMas[link][RollType]) do
				fail = false
				break
			end
			if fail then
				RollType = ZGLoot.RollNames["Greed"]
			end
			for key, value in pairs(ZGLoot.RollMas[link][RollType]) do
				if value >= BestRoll then
					prevBestRoll = BestRoll
					BestRoll = value
				end
			end
			local NearestConcurents = ZGLoot.RollNames[", Nearest:"]
			if ZGLootItemList["8RollOption4"] == 1 then
				for key, value in pairs(ZGLoot.RollMas[link][RollType]) do
					if value == prevBestRoll and key ~= Winner then
						NearestConcurents = NearestConcurents.." "..key
					end
				end
			end
			if NearestConcurents ~= ZGLoot.RollNames[", Nearest:"] then
				NearestConcurents = NearestConcurents..ZGLoot.RollNames[" with roll "]..prevBestRoll
			else
				NearestConcurents = ""
			end 
			if Winner == ZGLoot.RollNames["You"] and (ZGLootItemList["8RollOption3"] == 1 or ZGLootItemList["8RollOption4"] == 1 or ZGLootItemList["8RollOption5"] == 1) then
				totalmes = ZGLoot.RollNames["You"].." "..ZGLoot.RollNames["won1"].." "..link..ZGLoot.RollNames[" with "]..RollType.." "..ZGLoot.RollNames["Roll"].." "..ZGLoot.RollMas[link][RollType][ZGLoot.RollNames["You"]]..NearestConcurents
			else
				NearestConcurents = ""
				if ZGLootItemList["8RollOption6"] == 1 then
					if ZGLoot.RollMas[link][RollType][ZGLoot.RollNames["You"]] then
						NearestConcurents = ZGLoot.RollNames[", You rolled "]..ZGLoot.RollMas[link][RollType][ZGLoot.RollNames["You"]]
					end 
				end
				if ZGLootItemList["8RollOption5"] == 1 or ZGLootItemList["8RollOption6"] == 1 then
					totalmes = Winner.." "..ZGLoot.RollNames["won"].." "..link..ZGLoot.RollNames[" with roll "]..ZGLoot.RollMas[link][RollType][Winner]..NearestConcurents
				end
			end
			ZGLoot.RollMas[link]["count"] = ZGLoot.RollMas[link]["count"] - 1
			for key, value in pairs(ZGLoot.RollMas[link][ZGLoot.RollNames["Need"]]) do
				ZGLoot.RollMas[link][ZGLoot.RollNames["Need"]][key] = nil
			end
			for key, value in pairs(ZGLoot.RollMas[link][ZGLoot.RollNames["Greed"]]) do
				ZGLoot.RollMas[link][ZGLoot.RollNames["Greed"]][key] = nil
			end
			if totalmes and totalmes ~= ZGLoot.LastMess then
				for i = 1, getn(ZGLoot.CurrentChatFrame) do
					getglobal(ZGLoot.CurrentChatFrame[i]):AddMessage(totalmes, info.r, info.g, info.b, info.id)
				end
				for i = 1, getn(ZGLoot.CurrentChatFrame) do
					ZGLoot.CurrentChatFrame[i] = nil
				end
				ZGLoot.LastMess = totalmes
			end
		elseif string.find(message, ZGLoot.RollNames["Everyone pass"]) then
			ZGLoot.RollMas[link]["count"] = ZGLoot.RollMas[link]["count"] - 1
		end
	end
end

-- обработка событий

function ZGLoot.OnEvent()
	if (event == "PLAYER_LOGIN") then
		ZGLoot.LoadingDefaults();
		ZGLoot.BuildGraphic();
		ZGLoot.InitializeVariable();
		ZGLoot.Insets[1]:Click()
		this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		for i = 1, getn(ZGLoot.Zones) do
			if (GetRealZoneText() == ZGLoot.Zones[i]) then
				this:RegisterEvent("START_LOOT_ROLL");
				this:RegisterEvent("CHAT_MSG_LOOT");
				ZGLoot.Active = true
			end
		end
	elseif strsub(event, 1, 16) == "VARIABLES_LOADED" then
		if ChatFrame_OnEvent_OldZGLoot == nil then
			ChatFrame_OnEvent_OldZGLoot = ChatFrame_OnEvent;
			ChatFrame_OnEvent = ChatFrame_OnEvent_NewZGLoot;
		end
	elseif (event=="ZONE_CHANGED_NEW_AREA") then
		local fail = true
		for i = 1, getn(ZGLoot.Zones) do
			if (GetRealZoneText() == ZGLoot.Zones[i]) then
				this:RegisterEvent("START_LOOT_ROLL");
				this:RegisterEvent("CHAT_MSG_LOOT");
				ZGLoot.Active = true
				fail = false
			end
		end
		if fail then
			this:UnregisterEvent("START_LOOT_ROLL");
			this:UnregisterEvent("CHAT_MSG_LOOT");
			ZGLoot.Active = false
		end
	elseif (event == "START_LOOT_ROLL") then
		ZGLoot.WatchLoot(arg1);
	elseif (event == "CHAT_MSG_LOOT") then
		ZGLoot.ChatMessageChange(arg1);
	end
end

-- первый вход в "программу"
function ZGLoot.OnLoad()
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("VARIABLES_LOADED");
end

-- для перемещения окна
function ZGLoot.OnDragStart()
	this:StartMoving();
end

-- для перемещения окна
function ZGLoot.OnDragStop()
	this:StopMovingOrSizing(); 
end

ZGLoot.ItemButtons = {}

function ZGLoot.CreateTitle(name, x, y, parent, point, text)
	local f = parent:CreateFontString(name, "ARTWORK","GameFontNormal")
	f:SetPoint(point, parent, x, -y)
	f:SetText(text)
end

function ZGLoot.CreateItemButtons(name, x, y, texture, parent, tooltip)
	local f = CreateFrame("Button" , name, parent, "ButtonItemTemplate")
	f:SetPoint("TOPLEFT", parent, x, -y)
	if tooltip then
		f:SetScript("OnEnter", 
			function()
		        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
		        if type(tooltip) == "table" then
		        	for i = 1, getn(tooltip) do
		        		GameTooltip:AddLine(tooltip[i]);
		        	end
		        else
		        	GameTooltip:AddLine(tooltip);
		        end
		        GameTooltip:Show();
		    end
		)
	end
	f:SetScript("OnLeave", 
		function()
	        GameTooltip:Hide();
	    end
	)
	f:SetNormalTexture(texture)
	ZGLoot.ItemButtons[name] = f
	if not ZGLootItemList[name] then
		ZGLootItemList[name] = 1
	end
end

ZGLoot.CheckButtons = {}

function ZGLoot.CreateCheckButton(name, x, y, point, parent, tooltip)
	local f = CreateFrame("CheckButton" , name, parent, "CheckButtonZgTemplate")
	f:EnableMouse(true)
	f:SetPoint(point, parent, x, -y)
	f:SetScript("OnClick", ZGLoot.OnTabClick)
	if tooltip then
		f:SetScript("OnEnter", 
			function()
		        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
		        if type(tooltip) == "table" then
		        	for i = 1, getn(tooltip) do
		        		GameTooltip:AddLine(tooltip[i]);
		        	end
		        else
		        	GameTooltip:AddLine(tooltip);
		        end
		        GameTooltip:Show();
		    end
		)
	end
	f:SetScript("OnLeave", 
		function()
	        GameTooltip:Hide();
	    end
	)
	f:SetScript("OnClick", 
		function()
	        ZGLoot.Click()
	    end
	)
	ZGLoot.CheckButtons[name] = f
end

ZGLoot.Insets = {}

function ZGLoot.CreateInset(name, x, y, texture, tooltip)
	local f = CreateFrame("CheckButton" , name, ZGLootMain, "TabPanelTemplate")
	f:SetPoint("TOPRIGHT", ZGLootMain, "TOPRIGHT", x, -y)
	f:SetScript("OnClick", ZGLoot.OnInsetClick)
	if tooltip then
		f:SetScript("OnEnter", 
			function()
		        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
		        if type(tooltip) == "table" then
		        	for i = 1, getn(tooltip) do
		        		GameTooltip:AddLine(tooltip[i]);
		        	end
		        else
		        	GameTooltip:AddLine(tooltip);
		        end
		        GameTooltip:Show();
		    end
		)
	end
	f:SetScript("OnLeave", 
		function()
	        GameTooltip:Hide();
	    end
	)
	f:SetNormalTexture(texture)
	ZGLoot.Insets[name] = f
	ZGLoot.CreateTab(name)
end

ZGLoot.Tabs = {}

function ZGLoot.CreateTab(name)
	local f = CreateFrame("Frame" , name, ZGLootMain)
	f:EnableMouse(true)
	f:SetFrameStrata("MEDIUM")
	f:SetWidth(580)
	f:SetHeight(450)
	f:SetPoint("TOPLEFT", ZGLootMain, "TOPLEFT", 5, -25)
	ZGLoot.Tabs[name] = f
	ZGLoot.CreateTitle(name.."Pass", 20, 15, f, "TOP", ZGLoot.Data[name]["tooltip"])
	ZGLoot.CreateCheckButton(name.."Pass", -40, 50, "TOPRIGHT",f)
	ZGLoot.CreateTitle(name.."Pass", -25, 33, f, "TOPRIGHT", ZGLoot.TitleNames["All Pass"])
	ZGLoot.CreateCheckButton(name.."Greed", -90 - 40, 50, "TOPRIGHT", f)
	ZGLoot.CreateTitle(name.."Greed", -115, 33, f, "TOPRIGHT", ZGLoot.TitleNames["All Greed"])
	ZGLoot.CreateCheckButton(name.."Need", -180 - 40, 50, "TOPRIGHT", f)
	ZGLoot.CreateTitle(name.."Need", -205, 33, f, "TOPRIGHT", ZGLoot.TitleNames["All Need"])
	for i = 1, getn(ZGLoot.Data[name]["items"]) do
		ZGLoot.CreateItemButtons(name..i, 20, 90 + (i-1) * 40, ZGLoot.Data[name]["items"][i]["texture"], f, ZGLoot.Data[name]["items"][i]["tooltip"])
		ZGLoot.CreateTitle(name..i.."Title", 60, 100 + (i-1) * 40, ZGLoot.Tabs[name], "TOPLEFT", ZGLoot.Data[name]["items"][i]["name"])
		ZGLoot.CreateCheckButton(name..i.."Need", -180 - 40, 90 + (i-1) * 40, "TOPRIGHT", f)
		ZGLoot.CreateCheckButton(name..i.."Greed", -90 - 40, 90 + (i-1) * 40, "TOPRIGHT", f)
		ZGLoot.CreateCheckButton(name..i.."Pass", 0 - 40, 90 + (i-1) * 40, "TOPRIGHT",f)
	end

end

function ZGLoot.BuildGraphic()
	for i = 1, getn(ZGLoot.Data) do
		ZGLoot.CreateInset(i, 30, 30 + (i - 1) * 50, ZGLoot.Data[i]["texture"], ZGLoot.Data[i]["tooltip"])
	end
	ZGLoot.CreateCheckButton(ZGLoot.Tabs[4]:GetName().."CheckMyClass", 15, 50, "TOPLEFT",ZGLoot.Tabs[4], ZGLoot.TitleNames["Check My Class Tooltip"])
	ZGLoot.CreateTitle("CheckMyClass", 40, 53, ZGLoot.Tabs[4], "TOPLEFT", ZGLoot.TitleNames["Check My Class"])
	ZGLoot.CreateCheckButton(ZGLoot.Tabs[5]:GetName().."CheckMyClass", 15, 50, "TOPLEFT",ZGLoot.Tabs[5], ZGLoot.TitleNames["Check My Class Tooltip"])
	ZGLoot.CreateTitle("CheckMyClass", 40, 53, ZGLoot.Tabs[5], "TOPLEFT", ZGLoot.TitleNames["Check My Class"])
	local f = CreateFrame("CheckButton" , 8, ZGLootMain, "TabPanelTemplate")
	f:SetPoint("TOPRIGHT", ZGLootMain, "TOPRIGHT", 30, -380)
	f:SetScript("OnClick", ZGLoot.OnInsetClick)
	f:SetScript("OnEnter", 
		function()
	        GameTooltip:SetOwner(f, "ANCHOR_RIGHT");
	        GameTooltip:AddLine(ZGLoot.TitleNames["Roll"]);
	        GameTooltip:Show();
	    end
	)
	f:SetScript("OnLeave", 
		function()
	        GameTooltip:Hide();
	    end
	)
	f:SetNormalTexture([[Interface\Icons\Trade_Engineering]])
	ZGLoot.Insets[8] = f
	local f = CreateFrame("Frame" , 8, ZGLootMain)
	f:EnableMouse(true)
	f:SetFrameStrata("MEDIUM")
	f:SetWidth(580)
	f:SetHeight(450)
	f:SetPoint("TOPLEFT", ZGLootMain, "TOPLEFT", 5, -25)
	ZGLoot.Tabs[8] = f
	ZGLoot.CreateCheckButton("8RollOption1", 20, 90 + (1-1) * 40, "TOPLEFT", f, ZGLoot.TitleNames["Roll option 1 Tooltip"])
	ZGLoot.CreateTitle("81", 40, 90 + (1-1) * 40 + 3, f, "TOPLEFT", ZGLoot.TitleNames["Roll option 1"])
	ZGLoot.CreateCheckButton("8RollOption2", 20, 90 + (2-1) * 40, "TOPLEFT", f, ZGLoot.TitleNames["Roll option 2 Tooltip"])
	ZGLoot.CreateTitle("82", 40, 90 + (2-1) * 40 + 3, f, "TOPLEFT", ZGLoot.TitleNames["Roll option 2"])
	ZGLoot.CreateCheckButton("8RollOption3", 20, 90 + (3-1) * 40, "TOPLEFT", f, ZGLoot.TitleNames["Roll option 3 Tooltip"])
	ZGLoot.CreateTitle("83", 40, 90 + (3-1) * 40 + 3, f, "TOPLEFT", ZGLoot.TitleNames["Roll option 3"])
	ZGLoot.CreateCheckButton("8RollOption4", 20, 90 + (4-1) * 40, "TOPLEFT", f, ZGLoot.TitleNames["Roll option 4 Tooltip"])
	ZGLoot.CreateTitle("84", 40, 90 + (4-1) * 40 + 3, f, "TOPLEFT", ZGLoot.TitleNames["Roll option 4"])
	ZGLoot.CreateCheckButton("8RollOption5", 20, 90 + (5-1) * 40, "TOPLEFT", f, ZGLoot.TitleNames["Roll option 5 Tooltip"])
	ZGLoot.CreateTitle("85", 40, 90 + (5-1) * 40 + 3, f, "TOPLEFT", ZGLoot.TitleNames["Roll option 5"])
	ZGLoot.CreateCheckButton("8RollOption6", 20, 90 + (6-1) * 40, "TOPLEFT", f, ZGLoot.TitleNames["Roll option 6 Tooltip"])
	ZGLoot.CreateTitle("86", 40, 90 + (6-1) * 40 + 3, f, "TOPLEFT", ZGLoot.TitleNames["Roll option 6"])
	
end	