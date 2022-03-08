SmallDeckCount = {7,8,9, 0,"J", "Q","K","A"}
BigDeckCount = {2,3,4,5,6}
CardColors = {"A", "H", "L", "S"}
Hand = {}
Cup = {}
CupValues = {}
TableTop = {}
TableTopValues = {}
Players = {}
ShowPos = {}
ShowPosValues = {}
DeckPosition = {x = 160, y = 250}

Trading = {}
SimTrading = {}

OppoShow = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
OppoTable = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
OppoHand = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
TableCards = {}
DisplayCards = {}

ShowPosX = {-180, -140,-100,-60,-20,20,60,100,140,180,220}
CupDicePosX = {-40,0,40,-60,-20,20,60,-40,0,40}
CupDicePosY = {20,20, 20,60, 60,60,60,100, 100,100}
TableDicePosX = {-180, -140,-100,-60,-20,20,60,100,140,180,220}
PlayersPosition = {15, -50, 15, -230, 760, -50, 760, -230}

Lis = CreateFrame("FRAME", "ListenerFrame")
Lis:RegisterEvent("CHAT_MSG_ADDON")

local Watch = CreateFrame("Frame")
Watch:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Watch:RegisterEvent("PARTY_MEMBERS_CHANGED")
Watch:SetScript("OnEvent", function() 
	Players = {}
	for i=1,4 do
		local s		--delete me?
		f = getglobal("P" .. i .. "ScreenDisplayLabel")
		f:SetText(UnitName("party" .. i))
		if UnitExists("party"..i) then
			table.insert(Players, GetUnitName("party" .. i))
		end
	
	end   
end)

local function AddonMsgHandler(self, event, prefix, msg, channel, source)
	if prefix == "CnDCDShow" then
		_, one = string.gsub(msg, "1", "1")
		_, two = string.gsub(msg, "2", "2")
		_, three = string.gsub(msg, "3", "3")
		_, four = string.gsub(msg, "4", "4")
		_, five = string.gsub(msg, "5", "5")
		_, six = string.gsub(msg, "6", "6")
		ThrowSum = one .. two .. three .. four .. five .. six
		local c = 1
		local k = 1
		local NewOppoDice
		for i = 1, #Players do
			PName = getglobal("P" .. i .. "ScreenDisplayLabel"):GetText()
			if PName == source then
				SendChatMessage(PName .. " zeigt seine Würfel!", "Party")
				for c = 1, 6 do
					if string.sub(ThrowSum, c, c) == "0" then
					else
						for j = 1, string.sub(ThrowSum, c, c) do
							if OppoShow["Player" .. i][j]  then
								OppoShow["Player" .. i][j]:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
								OppoShow["Player" .. i][j]:SetPoint("BOTTOM", k * 20, -20)  
								OppoShow["Player" .. i][j]:Show()
							else
								NewOppoDice = CreateFrame("Frame", "OppoDice" .. k, getglobal("P" .. i .. "Screen"), "SmallDiceTemplate")
								NewOppoDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
								NewOppoDice:SetPoint("LEFT", k * 20, -20)  
								NewOppoDice:Show()
								table.insert(OppoHand, NewOppoDice)
							end
							k = k + 1
						end
					end
				end
			OppoShow["Player" .. i] = OppoHand
			end
		end
	elseif prefix == "CnDCDTake" then
		SendChatMessage(source .. "Taking")
	elseif prefix == "CnDCDLose" then
		for i = 1, #Players do
			PName = getglobal("P" .. i .. "ScreenDisplayLabel"):GetText()
			if PName == source then
				SendChatMessage(PName .. "Losing")
				local j = 1
				local c = 3
				local k = 1
				if OppoTable["Player" .. i][j]  then
					OppoTable["Player" .. i][j]:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
					OppoTable["Player" .. i][j]:SetPoint("BOTTOM", k * 20, -20)  
					OppoTable["Player" .. i][j]:Show()
				else
					NewOppoTDice = CreateFrame("Frame", "OppoTDice" .. k, getglobal("P" .. i .. "Screen"), "DiceTemplate")
					NewOppoTDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
					NewOppoTDice:SetPoint("BOTTOM", k * 20, 10)  
					NewOppoTDice:Show()
					table.insert(OppoTable, NewOppoTDice)
				end
			end
		end
	elseif prefix == "CnDCDHide" then
		for i = 1, #Players do
			PName = Players[i]
			if PName == source then
				--SendChatMessage("collecting " .. PName .. "'s dice")
				for M = 1, #OppoShow["Player" .. i] do
					OppoShow["Player" .. i][M]:Hide()
				end
			end
		OppoShow["Player" .. i] = {}
		end
	elseif prefix == "CnDCTrade" then
		if GetUnitName("player") ~= source then
			SendChatMessage(msg .. " sent from " .. source)
			local p = 1
			local TradedCards = {}
			_, TarPos = string.find(msg, ":")
			Target = string.sub(msg, TarPos + 1)
			local CardCount = (TarPos - 1)/6
			for i = 1, CardCount do
				local CardID = string.sub(msg, i*6 -1, i*6)
				local NewCard = getglobal("Card" .. CardID)
				table.insert(SimTrading, NewCard)
			end
			SimTradeCards(Target)
			SimTrading = {}
		end		
	end
end

Lis:SetScript("OnEvent", AddonMsgHandler)


function Shuffle(Deck)
	local NewDeck = {}
	local Max = #Deck
	for i = 1, Max do
		j = math.random(#Deck)
		table.insert(NewDeck, Deck[j])
		table.remove(Deck, j)
	end
	return NewDeck
end

function CreateSmallDeck()
-- delete all dice
--	for k = 1, #Dice
	CardsDeck = {}
	local c = 1
	while c < 5 do
		local i = 1
		while i < 9 do
--		todo	if getglobal("Card" .. c .. i) then local card = getglobal("Card" .. c .. i) else 
			local card = CreateFrame("Frame", "Card" .. c .. i, CnD, "CardTemplate")
			card:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\" .. CardColors[c] .. SmallDeckCount[i] .. ".tga"})
			local FL = getglobal(card:GetName() .. "TexLabel")  	--delete me
			FL:SetText(CardColors[c] .. SmallDeckCount[i] .. "1")	--delete me
			card:ClearAllPoints()
			card:SetPoint("CENTER", DeckPosition.x + i, DeckPosition.y)
			TurnCard(card)
			table.insert(CardsDeck, card)
			i = i + 1
		end
		c = c + 1
	end
	CardsDeck = Shuffle(CardsDeck)
	for i = 1, #CardsDeck do
		CardsDeck[i]:Hide()
		CardsDeck[i]:ClearAllPoints()
		CardsDeck[i]:SetPoint("CENTER", DeckPosition.x + i, DeckPosition.y)
		CardsDeck[i]:Show()
	end
end

function CreateBigDeck()
	CardsDeck = {}
	SendChatMessage("Creating regular deck")
	CreateSmallDeck()
	local c = 1
	while c < 5 do
		local i = 1
		while i < 9 do
			local f = CreateFrame("Frame", "Card" .. c .. i, CnD, "CardTemplate")

			f:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\" .. CardColors[c] .. BigDeckCount[i] .. ".tga"})
			local FL = getglobal(f:GetName() .. "TexLabel")
			FL:SetText(CardColors[c] .. BigDeckCount[i] .. "1")
			NewCard = {Color = c, Value = i, Frame = f}
			f:ClearAllPoints()
			f:SetPoint("CENTER", DeckPosition.x + i, DeckPosition.y)
			TurnCard(f)
			table.insert(CardsDeck, NewCard)
			i = i + 1
		end
		c = c + 1
	end
	CardsDeck = Shuffle(CardsDeck)
	for i = 1, #CardsDeck do
		CardsDeck[i]:Hide()
		CardsDeck[i]:ClearAllPoints()
		CardsDeck[i]:SetPoint("CENTER", DeckPosition.x + i, DeckPosition.y)
		CardsDeck[i]:Show()
	end
end

function TurnCard(that)
	local CardID = getglobal(that:GetName() .. "TexLabel"):GetText()
	local a = string.sub(CardID, 1, 1)
	local b = string.sub(CardID, 2, 2)
	local c = string.sub(CardID, 3, 3)
	if c == "0" then
		c = 1
		getglobal(that:GetName() .. "TexLabel"):SetText(a .. b .. c)
		that:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\" .. a .. b .. ".tga"})
	else
		c = 0
		getglobal(that:GetName() .. "TexLabel"):SetText(a .. b .. c)
		that:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\Back.tga"})
	end
end

function CreateCup()
	for i = 1, #Cup do
		Cup[i]:Hide()
	end
	for i = 1, #TableTop do
		TableTop[i]:Hide()
	end
	for i = 1, #ShowPos do
		ShowPos[i]:Hide()
	end
	local c = 1
	local Number = StartingDiceBox:GetText()
	while c < tonumber(Number) + 1 do
		if Cup[c] then
			Cup[c]:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice6.tga"})
			CupValues[c] = 6
			Cup[c]:Show()
		else
			local NewDice = CreateFrame("Frame", "Dice" .. c, CnD, "DiceTemplate")
			NewDice:SetPoint("BOTTOM", CupDicePosX[c], CupDicePosY[c])
			NewDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice6.tga"})
			table.insert(Cup, NewDice)
			table.insert(CupValues, 6)
		end
		c = c + 1
	end
end

function ShuffleDice()
	for i = 1, #ShowPos do
		table.insert(Cup, ShowPos[i])
		table.insert(CupValues, ShowPosValues[i])
	end
	ShowPos = {}
	ShowPosValues = {}
	for i = 1, #Cup do
		local r = math.random(6)
		local NewFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. r .. ".tga"
		CupValues[i] = r
		Cup[i]:SetBackdrop({bgFile = NewFile})
	end
	SendChatMessage("Ich würfel!", "PARTY")
	SendAddonMessage("CnDCDHide", "collect", "RAID")
	RedrawDice()
end

function ShowDice()
	for i = 1, #Cup do
		table.insert(ShowPos, Cup[i])
		table.insert(ShowPosValues, CupValues[i])
	end
	Cup = {}
	CupValues = {}
	local s = ""
	for i = 1, #ShowPos do
		s = s .. ShowPosValues[i]
	end
	RedrawDice()
	SendAddonMessage("CnDCDShow", s, "RAID")
end


function CollectDice()
	for i = 1, #TableTop do
		table.insert(Cup, TableTop[i])
		table.insert(CupValues, TableTopValues[i])
	end
	for i = 1, #ShowPos do
		table.insert(Cup, ShowPos[i])
		table.insert(CupValues, ShowPosValues[i])
	end
	ShowPos = {}
	ShowPosValues = {}
	TableTop = {}
	TableTopValues = {}
	SendAddonMessage("CnDCDHide", "collect", "RAID")
	RedrawDice()

end

function ClearValues()
	TableTopValues = {}
	for i = 1, #Cup do
		Cup[i]:Hide()
	end
	CupValues = {}
	ShowPosValues = {}
	OppoShow = {}
end

function ToggleCupTable(this)
	local t = this:GetName()
	local foundVar = false
	for i = 1, #Cup do
		if this == Cup[i] then
			foundVar = true
			SendChatMessage("Ich lege einen Würfel ab", "PARTY")
			table.remove(Cup, i)
			table.insert(TableTop, this)
			SendAddonMessage("CnDCDLose", t, "RAID")
		end
	end
	for i = 1, #TableTop do
		if this == TableTop[i] and foundVar == false then
			foundVar = true
			SendChatMessage("Ich nehme einen Würfel auf", "PARTY")
			table.remove(TableTop, i)
			table.insert(Cup, this)
			SendAddonMessage("CnDCDTake", t, "RAID")
		end
	end
	for i = 1, #ShowPos do
		if this == ShowPos[i] and foundVar == false then
			foundVar = true
			SendChatMessage("Ich lege einen Würfel ab", "PARTY")
			table.remove(ShowPos, i)
			table.insert(TableTop, this)
			SendAddonMessage("CnDCDLose", t, "RAID")
		end
	end
	RedrawDice()
end

function PrepareTrade(that)
	if this.Glow then
		if this.Glow:IsVisible() then
			this.Glow:Hide()
		else 
			this.Glow:Show()
		end
	else
		TradeElement = that:GetName()
		Marker = that:CreateTexture(nil, "OVERLAY")
		Marker:SetTexture"Interface\\Buttons\\UI-ActionButton-Border"
		Marker:SetWidth(110)
		Marker:SetHeight(170)
		Marker:SetBlendMode"ADD"
		Marker:SetPoint("CENTER", that)
		this.Glow = Marker
	end
	if this.Glow:IsVisible() then
		table.insert(Trading, that)
	else
		for i = 1, #Trading do
			if Trading[i] == this then table.remove(Trading, i) end
		end
	end
end

function TradeCards(that)
	local msgTar = ""
	local msgC = ""
	local PName = ""
	PlayerValid = false
	for i = 1, #Trading do
		msgC = msgC .. Trading[i]:GetName()
		Trading[i].Glow:Hide()
	end
	local TarName = that:GetName()
--	local CardID = getglobal(that:GetName() .. "TexLabel"):GetText()
--	local CardFace = string.sub(CardID, 3, 3)
	if that:GetName() == "TableTopScreen" then
		SendChatMessage("Played card(s)", "PARTY")
		for i = 1, #Trading do
			table.insert(TableCards, Trading[i])
			Trading[i]:ClearAllPoints()
			Trading[i]:SetPoint("CENTER", "TableTopScreen", "BOTTOM", -100 + i * 50, 70)
		end
		msgTar = "TableTopScreen"
		msg = msgC .. ":" .. msgTar
	elseif that:GetName() == "OwnScreen" then
		SendChatMessage("Drawed a card", "PARTY")
		for i = 1, #Trading do
			table.insert(Hand, Trading[i])
		end
		RedrawCards()
		msgTar = GetUnitName("player")
		msg = msgC .. ":" .. msgTar
	elseif getglobal(that:GetName() .. "DisplayLabel"):GetText() and string.sub(that:GetName(), 2, 2) ~= "w" then
		local j = string.sub(that:GetName(), 2, 2)
		if GetUnitName("party" .. j) == getglobal(that:GetName() .. "DisplayLabel"):GetText() then
			PlayerValid = true
			msgTar = GetUnitName("party" .. j)
			local PlayerjHand = OppoHand["Player" .. j]
			for i = 1, #Trading do
				table.insert(PlayerjHand, Trading[i])
			end
			RedrawCards()
			msg = msgC .. ":" .. msgTar
			SendChatMessage("Gave " .. #Trading ..  " card(s) to player " .. j .. ", " .. GetUnitName("party" .. j), "PARTY")
		end
	end
	if msgTar == "TableTopScreen" then
		for k = 1, #Trading do
			for i = 1, #Hand do
				if Hand[i] == Trading[k] then
					table.remove(Hand, i)
				end
			end
			for i = 1, #CardsDeck do
				if CardsDeck[i] == Trading[k] then
					table.remove(CardsDeck, i)
				 end
			end
			for j = 1, #Players do
				for i = 1, #OppoHand["Player" .. j] do
					if OppoHand["Player" .. j][i] == Trading[k] then
						table.remove(OppoHand["Player" .. j], i) 
					end
				end
			end
		end
	elseif msgTar == GetUnitName("player") then
		for k = 1, #Trading do
			for i = 1, #TableCards do
				if TableCards[i] == Trading[k] then
					table.remove(TableCards, i)
				end
			end
			for i = 1, #CardsDeck do
				if CardsDeck[i] == Trading[k] then
					table.remove(CardsDeck, i)
				 end
			end
			for j = 1, #Players do
				for i = 1, #OppoHand["Player" .. j] do
					if OppoHand["Player" .. j][i] == Trading[k] then
						table.remove(OppoHand["Player" .. j], i) 
					end
				end
			end
		end
	elseif PlayerValid then
		for k = 1, #Trading do
			for i = 1, #TableCards do
				if TableCards[i] == Trading[k] then
					table.remove(TableCards, i)
				end
			end
			for i = 1, #CardsDeck do
				if CardsDeck[i] == Trading[k] then
					table.remove(CardsDeck, i)
				 end
			end		
			for i = 1, #Hand do
				if Hand[i] == Trading[k] then
					table.remove(Hand, i)
				end
			end
			for j = 1, #Players do
				if msgTar ~= GetUnitName("party" .. j) then
					for i = 1, #OppoHand["Player" .. j] do
						if OppoHand["Player" .. j][i] == Trading[k] then
							table.remove(OppoHand["Player" .. j], i)
						end
					end
				end
			end
		end
	else Trading = {} msgC = ""
	Trading = {}
	end
	for i = 1, #Hand do
		for j = i + 1, #Hand do
			if Hand[i] == Hand[j] then table.remove(Hand, j) end
		end
	end
	for i = 1, #TableCards do
		for j = i + 1, #TableCards do
			if TableCards[i] == TableCards[j] then table.remove(TableCards, j) end
		end
	end
	for k = 1, #Players do
		for i = 1, #OppoHand["Player" .. k] do
			for j = i + 1, #OppoHand["Player" .. k] do
				if OppoHand["Player" .. k][i] == OppoHand["Player" .. k][j] then table.remove(OppoHand["Player" .. k], j) end
			end
		end
	end
	msg = msgC .. ":" .. msgTar
	SendChatMessage(msg)
	Trading = {}
	RedrawCards()
	SendAddonMessage("CnDCTrade", msg, "RAID")
end

function SimTradeCards(that)
	if that == "TableTopScreen" then
		for i = 1, #SimTrading do
			table.insert(TableCards, SimTrading[i])
			SimTrading[i]:ClearAllPoints()
			SimTrading[i]:SetPoint("CENTER", "TableTopScreen", "BOTTOM", -100 + i * 50, 70)
		end
	elseif that == GetUnitName("player") then 
		for i = 1, #SimTrading do
			table.insert(Hand, SimTrading[i])
		end
	else 	for j = 1, #Players do
			if that == GetUnitName("party"  .. j) then
				for i = 1, #SimTrading do
					table.insert(OppoHand["Player" .. j], SimTrading[i])
				end
			end
		end
	end
	if that == "TableTopScreen" then
		for k = 1, #SimTrading do
			for i = 1, #Hand do
				if Hand[i] == SimTrading[k] then table.remove(Hand, i) end
			end
			for i = 1, #CardsDeck do
				if CardsDeck[i] == SimTrading[k] then table.remove(CardsDeck, i) end
			end
			for j = 1, #Players do
				for i = 1, #OppoHand["Player" .. j] do
					if OppoHand["Player" .. j][i] == SimTrading[k] then
						table.remove(OppoHand["Player" .. j], i) 
					end
				end
			end
		end
	elseif that == GetUnitName("player") then
		for k = 1, #SimTrading do
			for i = 1, #TableCards do
				if TableCards[i] == SimTrading[k] then
					table.remove(TableCards, i)
				end
			end
			for i = 1, #CardsDeck do
				if CardsDeck[i] == SimTrading[k] then
					table.remove(CardsDeck, i)
				 end
			end
			for j = 1, #Players do
				for i = 1, #OppoHand["Player" .. j] do
					if OppoHand["Player" .. j][i] == SimTrading[k] then
						table.remove(OppoHand["Player" .. j], i) 
					end
				end
			end
		end
	elseif PlayerValid then
		for k = 1, #SimTrading do
			for i = 1, #TableCards do
				if TableCards[i] == SimTrading[k] then table.remove(TableCards, i) end
			end
			for i = 1, #CardsDeck do
				if CardsDeck[i] == SimTrading[k] then table.remove(CardsDeck, i) end
			end		
			for i = 1, #Hand do
				if Hand[i] == SimTrading[k] then
					table.remove(Hand, i)
				end
			end
			for j = 1, #Players do
				if that ~= GetUnitName("party" .. j) then
					for i = 1, #OppoHand["Player" .. j] do
						if OppoHand["Player" .. j][i] == SimTrading[k] then
							table.remove(OppoHand["Player" .. j], i)
						end
					end
				end
			end
		end
	end
	for i = 1, #Hand do
		for j = i + 1, #Hand do
			if Hand[i] == Hand[j] then table.remove(Hand, j) end
		end
	end
	for i = 1, #TableCards do
		for j = i + 1, #TableCards do
			if TableCards[i] == TableCards[j] then table.remove(TableCards, j) end
		end
	end
	for k = 1, #Players do
		for i = 1, #OppoHand["Player" .. k] do
			for j = i + 1, #OppoHand["Player" .. k] do
				if OppoHand["Player" .. k][i] == OppoHand["Player" .. k][j] then table.remove(OppoHand["Player" .. k], j) end
			end
		end
	end
	RedrawCards()
	SimTrading = {}
end

function RedrawCards()
	for i = 1, #Players do
		local d = math.floor(180/#OppoHand["Player" .. i]) - 1
		for j = 1, #OppoHand["Player" .. i] do
			OppoHand["Player" .. i][j]:ClearAllPoints()
			OppoHand["Player" .. i][j]:SetPoint("LEFT", "P" .. i .. "Screen", "LEFT", - 10 + j * d, 10)
		end
	end
	local e = math.floor(460/#Hand) - 1
	for i = 1, #Hand do
		Hand[i]:ClearAllPoints()
		Hand[i]:SetPoint("CENTER", "OwnScreen", "BOTTOM", -180 + i * e, 55)
	end
	for i = 1, #TableCards do
		TableCards[i]:SetPoint(TableCards[i]:GetPoint())
	end
end

function RedrawDice()
	for i = 1, #TableTop do
		TableTop[i]:ClearAllPoints()
		TableTop[i]:SetPoint("BOTTOM", TableDicePosX[i], 300)
	end
	for i = 1, #ShowPos do
		ShowPos[i]:ClearAllPoints()
		ShowPos[i]:SetPoint("BOTTOM", ShowPosX[i], 200)	
	end
	for i = 1, #Cup do
		Cup[i]:ClearAllPoints()
		Cup[i]:SetPoint("BOTTOM", CupDicePosX[i], CupDicePosY[i])
	end
end