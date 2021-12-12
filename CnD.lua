SmallDeckCount = {7,8,9,10,"Jack", "Queen","King","Ace"}
BigDeckCount = {2,3,4,5,6}
CardColors = {"Spades", "Clubs", "Diamonds", "Hearts"}
Hand = {}
Cup = {}
CupValues = {}
TableTop = {}
TableTopValues = {}
Players = {}
OppoTable = {}
CupDicePosX = {0,40,-20,20,60,0,40}
CupDicePosY = {20,20,60,60,60,100,100}
TableDicePosX = {-100,-60,-20,20,60,100,140}
PlayersPosition = {15, -50, 15, -230, 760, -50, 760, -230}

Lis = CreateFrame("FRAME", "ListenerFrame")
Lis:RegisterEvent("CHAT_MSG_ADDON")

local Watch = CreateFrame("Frame")
Watch:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Watch:RegisterEvent("PARTY_MEMBERS_CHANGED")
Watch:SetScript("OnEvent", function() 
	Players = {}
	for i=1,4 do
		local f
		f = _G["PartyMemberFrame"..i]
		f:SetParent(CnD)
		f:SetPoint("TOPLEFT", CnD, "TOPLEFT", PlayersPosition[2 * i - 1], PlayersPosition[2 * i])
		f:SetAttribute("unit", UnitName("party" .. i))
		f:SetFrameStrata("MEDIUM")
		if UnitExists("party"..i) then
			table.insert(Players, f)
			f:Show();
		end
	
	end   
end)

local function AddonMsgHandler(self, event, prefix, msg, channel, source)
	if prefix == "CnDCD" then
		_, one = string.gsub(msg, "1", "1")
		_, two = string.gsub(msg, "2", "2")
		_, three = string.gsub(msg, "3", "3")
		_, four = string.gsub(msg, "4", "4")
		_, five = string.gsub(msg, "5", "5")
		_, six = string.gsub(msg, "6", "6")
		ThrowSum = one .. two .. three .. four .. five .. six
		local c = 1
		local k = 1
		SendChatMessage(source .. ":" .. msg .. " > " .. ThrowSum .. " / ".. #msg .. " in " .. #Players)
		for i = 1, #Players do
			PName = Players[i]:GetAttribute("unit")
			if PName == source then
				SendChatMessage(PName .. " shows the dice!")
				for c = 1, 6 do
					if string.sub(ThrowSum, c, c) == "0" then
					else
						for j = 1, string.sub(ThrowSum, c, c) do
							NewOppoDice = CreateFrame("Frame", "OppoDice" .. k, Players[i], "SmallDiceTemplate")
							NewOppoDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
							-- NOD:ClearAllPoints()
							--Players[i]:GetCenter()
							NewOppoDice:SetPoint("BOTTOM", k * 20, -20)  ----PlayersPosition[2 * i - 1] + k * 22, PlayersPosition[2 * i] - 50)
							k = k + 1
						end
					end
				end
			end
		end


--NewOppoDice:SetPoint("LEFT", k*22, 0)
--NewOppoDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
--table.insert(OppoTable, NewOppoDice)
--				end
--			end
--		end
--	elseif prefix == "CnDCD" then
--		SendChatMessage(msg)
	end
end

Lis:SetScript("OnEvent", AddonMsgHandler)

function CreateSmallDeck()
	CardsDeck = {}
	SendChatMessage("Creating small deck")
	local c = 1
	while c < 5 do
		local i = 1
		while i < 9 do
			local NewCard = SmallDeckCount[i] .. " of " .. CardColors[c]
			table.insert(CardsDeck, NewCard)
			i = i + 1
		end
		c = c + 1
	end
end

function CreateBigDeck()
	CardsDeck = {}
	SendChatMessage("Creating regular deck")
	local c = 1
	while c < 5 do
		local i = 1
		while i < 9 do
			local NewCard = SmallDeckCount[i] .. " of " .. CardColors[c]
			table.insert(CardsDeck, NewCard)
			i = i + 1
		end
--while j < 6 do
--local NewCard = BigDeckCount[j] .. " of " .. CardColors[c]
--table.insert(CardsDeck, NewCard)
--j = j + 1
		c = c + 1
	end
	SendChatMessage(CardsDeck[25])
end

function CreateCups()
	local c = 1
	while c < 8 do
		NewDice = CreateFrame("Frame", "Dice" .. c, CnD, "DiceTemplate")
		NewDice:SetPoint("BOTTOM", CupDicePosX[c], CupDicePosY[c])
		NewDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice6.tga"})
		table.insert(Cup, NewDice)
		table.insert(CupValues, 6)
		c = c + 1
	end
end

function CreateOneCup()
	local c = 1
	while c < 7 do
		NewDice = CreateFrame("Frame", "Dice" .. c, CnD, "DiceTemplate")
		NewDice:SetPoint("BOTTOM", CupDicePosX[c], CupDicePosY[c])
		NewDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice6.tga"})
		table.insert(Cup, NewDice)
		table.insert(CupValues, 6)
		c = c + 1
	end
end

function ShuffleDice()
	for i = 1, #Cup do
		local r = math.random(6)
		local NewFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. r .. ".tga"
		CupValues[i] = r
		Cup[i]:SetBackdrop({bgFile = NewFile})		
	end
end

function ShowDice()
	for i = 1, #Cup do
		Cup[i]:ClearAllPoints()
		Cup[i]:SetPoint("BOTTOM", TableDicePosX[i], 300)
		table.insert(TableTop, Cup[i])
		table.insert(TableTopValues, CupValues[i])
	end
	Cup = {}
	CupValues = {}
	local s = ""
	for i = 1, #TableTop do
		s = s .. TableTopValues[i]
	end
	SendAddonMessage("CnDCD", s, "RAID")
end


function CollectDice()
	for i = 1, #TableTop do
		TableTop[i]:ClearAllPoints()
		TableTop[i]:SetPoint("BOTTOM", CupDicePosX[i], CupDicePosY[i])
		table.insert(Cup, TableTop[i])
		table.insert(CupValues, TableTopValues[i])
	end
	TableTop = {}
	TableTopValues = {}
end

function ClearValues()
	TableTopValues = {}
	CupValues = {}
end

function RegisterElement()
	local x, y = GetCursorPosition()
	for i = 1, #TableTop do
--		if TableTop[i]:IsMouseOver() then ActiveElement = TableTop[i] end
	end
	for i = 1, #Cup do
--		if Cup[i]:IsMouseOver() then ActiveElement = Cup[i] end
	end
	for i = 1, #Hand do
--		if Hand[i]:IsMouseOver() then ActiveElement = Hand[i] end
	end
end

function Trade()
	local x, y = GetCursorPosition()
	local receiver = ""
	SendChatMessage("P " .. math.floor(x) .. " - " .. math.floor(y))

	if x > 320 and x < 525 then			--left side
 		if y > 340 and y < 460 and Players[2] then
			receiver = Players[1]
		elseif y > 500 and y < 640 and Players[1] then
			receiver = Players[1]
		end

	elseif x > 990 and x < 1200 then
		if y > 340 and y < 460 and Players[4] then
			receiver = Players[4]
		elseif y > 500 and y < 640 and Players[3] then
			receiver = Players[3]
		end

	elseif x > 545 and x < 970 then
		if y > 340 and y < 640 then		-- Table
			receiver = "TableTop"
		elseif y > 120 and y < 320 then
			receiver = "Player"
		end
	end
end
