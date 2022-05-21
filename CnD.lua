local SmallDeckCount = {7,8,9, 0,"J", "Q","K","A"}
local BigDeckCount = {2,3,4,5,6}
local CardColors = {"A", "H", "L", "S"}
local CardsDeck = {}
local Hand = {}
local Cup = {}
local TableTop = {}
local Players = {}
local ShowPos = {}
local DeckPosition = {x = 160, y = 250}
local DiscardPilePosition = {x = 165, y = 105}

local Trading = {}
local SimTrading = {}

local GameActive = false

local OppoShow = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
local OppoTable = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
local TableCards = {}
local DisplayCards = {}
local DiscardPile = {}

local ShowPosX = {-180, -140,-100,-60,-20,20,60,100,140,180,220}
local CupDicePosX = {-40,0,40,-60,-20,20,60,-40,0,40}
local CupDicePosY = {20,20, 20,60, 60,60,60,100, 100,100}
local TableDicePosX = {-180, -140,-100,-60,-20,20,60,100,140,180,220}
local PlayersPosition = {15, -50, 15, -230, 760, -50, 760, -230}

SLASH_CNDCOM1 = "/cnd"
SLASH_CNDCOM2 = "/cardsndice"
SlashCmdList["CNDCOM"] = function(msg)
	if msg == "help" or msg == "" then
		SendChatMessage("Available commands:")
		SendChatMessage("/cnd open or /cnd start - opens the gaming table")
		SendChatMessage("/cnd close or cnd quit - closes the gaming table")
	elseif msg == "open" or msg == "start" or msg == "OPEN" or msg == "START" then
		CnD:Show()
	elseif msg == "close" or msg == "quit" or msg == "CLOSE" or msg == "QUIT" then
		CnD:Hide()
	end
end

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
	if prefix == "Start" then
		if msg == "SmallDeck" then CreateSmallDeck()
		elseif msg == "BigDeck" then CreateBigDeck()
		elseif tonumber(msg) < 10 and tonumber(msg) > 0 then SendChatMessage(msg)
		end
	elseif prefix == "CnDCDShow" then
		_, one = string.gsub(msg, "1", "1")
		_, two = string.gsub(msg, "2", "2")
		_, three = string.gsub(msg, "3", "3")
		_, four = string.gsub(msg, "4", "4")
		_, five = string.gsub(msg, "5", "5")
		_, six = string.gsub(msg, "6", "6")
		ThrowSum = one .. two .. three .. four .. five .. six
		local k = 1
		local NewOppoDice
		for i = 1, #Players do
			PName = getglobal("P" .. i .. "ScreenDisplayLabel"):GetText()
			if PName == source then
				SendChatMessage(PName .. " zeigt seine Würfel!", "Party")
				for c = 1, 6 do
					if string.sub(ThrowSum, c, c) == "0" then
					else
						for j = 1, tonumber(string.sub(ThrowSum, c, c)) do
							local NeedNew = true
							local OffsetX = 0
							local OpShowY = 20
							for k = 1, #OppoShow["Player" .. i] do
								if OppoShow["Player" .. i][k]:IsVisible() == nil then
									OppoShow["Player" .. i][k]:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
									OppoShow["Player" .. i][k]:ClearAllPoints()
									OppoShow["Player" .. i][k]:SetPoint("RIGHT", k * 40 - 20 + OffsetX, OpShowY)  
									OppoShow["Player" .. i][k]:Show()
									NeedNew = false
								end
							end
							if NeedNew then
									local NewOppoTDice = CreateFrame("Frame", "OppoTDice" .. c, getglobal("P" .. i .. "Screen"), "DiceTemplate")
									NewOppoTDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. c .. ".tga"})
									if #OppoShow["Player" .. i] > 4 then
										OpTabY = -30
										OffsetX = - 200
									end
									table.insert(OppoShow["Player" .. i], NewOppoTDice)
									NewOppoTDice:ClearAllPoints()
									NewOppoTDice:SetPoint("LEFT", #OppoShow["Player" .. i] * 40 - 20 + OffsetX, OpShowY) 
									NewOppoTDice:Show()
								
							end
						end
					end
				end
			end
		end
	elseif prefix == "CnDCDTake" then
		SendChatMessage(source .. " Taking " .. msg)
		for i = 1, #Players do
			for j = 1, #OppoTable["Player" .. i] do
				local BGPath = OppoTable["Player" .. i][j]:GetBackdrop()["bgFile"]
				local DiceValue = string.sub(BGPath, -5, -5)
			SendChatMessage(DiceValue)
				if DiceValue == msg and OppoTable["Player" .. i][j]:IsVisible() then
					OppoTable["Player" .. i][j]:Hide()
					table.insert(OppoTable["Player" .. i], remove.table(OppoTable["Player" .. i], j))
					break
				end
			end
		end
	elseif prefix == "CnDCDLose" then
		for i = 1, #Players do
			PName = getglobal("P" .. i .. "ScreenDisplayLabel"):GetText()
			if PName == source then
				local NeedNew = true
				local OffsetX = 220
				local OpTabY = 20
				local TableDelta = 40
				if i == 3 or i == 4 then
					TableDelta = -40
					OffsetX = -20
				end
				SendChatMessage(PName .. " Losing " .. msg)
				for j = 1, #OppoTable["Player" .. i] do
					if OppoTable["Player" .. i][j]:IsVisible() == nil then
						OppoTable["Player" .. i][j]:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. msg .. ".tga"})
						OppoTable["Player" .. i][j]:ClearAllPoints()
						OppoTable["Player" .. i][j]:SetPoint("LEFT", j * TableDelta - 20 + OffsetX, OpTabY)  
						OppoTable["Player" .. i][j]:Show()
						NeedNew = false
						break
					end
				end
				if NeedNew then
					local NewOppoTDice = CreateFrame("Frame", "OppoTDice" .. msg, getglobal("P" .. i .. "Screen"), "DiceTemplate")
					NewOppoTDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. msg .. ".tga"})
					NewOppoTDice:ClearAllPoints()
					if #OppoTable["Player" .. i] > 4 and (i == 1 or i == 2) then
						OpTabY = -30
						OffsetX = 20
					elseif #OppoTable["Player" .. i] > 4 and (i == 3 or i == 4) then
						OpTabY = -30
						OffsetX = -20
					end
					NewOppoTDice:SetPoint("LEFT", (#OppoTable["Player" .. i] + 1) * TableDelta - 20 + OffsetX, OpTabY) 
					NewOppoTDice:Show()
					table.insert(OppoTable["Player" .. i], NewOppoTDice)
				end
			end
		end
	elseif prefix == "CnDCDHide" then
		for i = 1, #Players do
			PName = Players[i]
			if PName == source then
				SendChatMessage(msg)
				--SendChatMessage("collecting " .. PName .. "'s dice")
				for j = 1, #OppoShow["Player" .. i] do
					OppoShow["Player" .. i][j]:Hide()
				end
				for j = 1, #OppoTable["Player" .. i] do
					OppoTable["Player" .. i][j]:Hide()
				end
			end
		OppoShow["Player" .. i] = {}
		end
	elseif prefix == "CnDCTrade" then
		if GetUnitName("player") ~= source then
			if msg == "discard" then
				for i = 1, #TableCards do
					table.insert(DiscardPile, TableCards[i])
				end
				for i = 1, #DisplayCards do
					table.insert(DiscardPile, DisplayCards[i])
				end
				TableCards = {}
				DisplayCards = {}
				for i = 1, #DiscardPile do
					DiscardPile[i]:ClearAllPoints()
					DiscardPile[i]:SetPoint("CENTER", DiscardPilePosition.x + i, DiscardPilePosition.y)
					DiscardPile[i]:Hide()
					DiscardPile[i]:Show()
				end
			elseif mgs =="recycle" then
				if #DiscardPile > 0 then
					for i = 1, #DiscardPile do
						table.insert(CardsDeck, DiscardPile[i])
					end
					DiscardPile = {}
					CardsDeck = Shuffle(CardsDeck)
					for i = 1, #CardsDeck do
						CardsDeck[i]:ClearAllPoints()
						CardsDeck[i]:SetPoint("CENTER", DeckPosition.x + i, DeckPosition.y)
						CardsDeck[i]:Hide()
						CardsDeck[i]:Show()
					end
				end
			elseif msg == "reshuffle" then
				local CardsCount = #Hand + #TableCards + #DiscardPile + #DisplayCards
				for i = 1, #Players do
					CardsCount = CardsCount + #OppoHand["Player" .. i]
				end
				if CardsCount < 40 then CreateSmallDeck() else CreateBigDeck() end
			else
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
				for i = 1, #Trading do
					for j = 1, #SimTrading do
						if #Trading[i] == #SimTrading[j] then
							Trading[i].Glow:Hide()
							table.remove(Trading, i)
						end
					end
				end
				SimTrading = {}
			end
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

function Start()
--	if IsPartyLeader("player") == 1 or GetUnitName("party1") == nil then
		CnDMenu:Show()		
--	end
end

function CreateSmallDeck()
	if CardA2 then
		for i = 1, #CardColors do
			for j = 1, #BigDeckCount do
				local DiscardedCard = getglobal("Card" .. CardColors[i] .. BigDeckCount[j])
				DiscardedCard:Hide()
			end
		end
	end
	HandScreen:Show()
	ClearDice()
	CupScreen:Hide()
	CardDisplay:Show()
	DiscardPileSquare:Show()
	Discard:Show()
	Recycle:Show()
	Reshuffle:Show()	
	Reshuffle:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\Reshuffle.tga"})
	CardsDeck = {}
	Hand = {}
	OppoHand = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
	TableCards = {}
	DisplayCards = {}
	DiscardPile = {}
	local c = 1
	local card
	while c < 5 do
		local i = 1
		while i < 9 do
			if getglobal("Card" .. CardColors[c] .. SmallDeckCount[i]) then
				card = getglobal("Card" .. CardColors[c] .. SmallDeckCount[i])
			else
				card = CreateFrame("Frame", "Card" .. CardColors[c] .. SmallDeckCount[i], CnD, "CardTemplate")
			end
			card:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\" .. CardColors[c] .. SmallDeckCount[i] .. ".tga"})
			local FL = getglobal(card:GetName() .. "TexLabel") 
			FL:SetText(CardColors[c] .. SmallDeckCount[i] .. "1")
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
	CreateSmallDeck()
	local card
	local c = 1
	while c < 5 do
		local i = 1
		while i < 6 do
			if getglobal("Card" .. CardColors[c] .. BigDeckCount[i]) then
				card = getglobal("Card" .. CardColors[c] .. BigDeckCount[i])
			else
				card = CreateFrame("Frame", "Card" .. CardColors[c] .. BigDeckCount[i], CnD, "CardTemplate")
			end
			card:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Cards\\" .. CardColors[c] .. BigDeckCount[i] .. ".tga"})
			local FL = getglobal(card:GetName() .. "TexLabel")
			FL:SetText(CardColors[c] .. BigDeckCount[i] .. "1")
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
	if CardA7 then
		ReshuffleAllCards()
		for i = 1, #CardsDeck do
			CardsDeck[i]:Hide()
		end
	end
	HandScreen:Hide()
	CardDisplay:Hide()
	DiscardPileSquare:Hide()
	Discard:Hide()
	Recycle:Hide()
	Reshuffle:Hide()
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
	local DiceNumber = StartingDiceBox:GetText()
	while c < tonumber(DiceNumber) + 1 do
		if Cup[c] then
			Cup[c]:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice6.tga"})
			Cup[c]:Show()
		else
			local NewDice = CreateFrame("Frame", "Dice" .. c, CnD, "DiceTemplate")
			NewDice:SetPoint("BOTTOM", CupDicePosX[c], CupDicePosY[c])
			NewDice:SetBackdrop({bgFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice6.tga"})
			local DiceOwner = getglobal(NewDice:GetName() .. "StatsOwner")
			DiceOwner:SetText(GetUnitName("player"))
			table.insert(Cup, NewDice)
		end
		c = c + 1
	end
	SendAddonMessage("Start", DiceNumber, "RAID")
end

function ShuffleDice()
	for i = 1, #ShowPos do
		table.insert(Cup, ShowPos[i])
	end
	ShowPos = {}
	for i = 1, #Cup do
		local r = math.random(6)
		local NewFile = "Interface\\Addons\\CardsnDice\\Dice\\Dice" .. r .. ".tga"
		local DiceValue = getglobal(Cup[i]:GetName() .. "StatsValue")
		Cup[i]:SetBackdrop({bgFile = NewFile})
		DiceValue:SetText(r)
	end
	SendChatMessage("Ich würfel!", "PARTY")
	SendAddonMessage("CnDCDHide", "collect", "RAID")
	RedrawDice()
end

function ShowDice()
	for i = 1, #Cup do
		table.insert(ShowPos, Cup[i])
	end
	Cup = {}
	local s = ""
	for i = 1, #ShowPos do
		local z = getglobal(ShowPos[i]:GetName() .. "StatsValue")
		s = s .. z:GetText()
	end
	RedrawDice()
	SendAddonMessage("CnDCDShow", s, "RAID")
end


function CollectDice()
	for i = 1, #TableTop do
		table.insert(Cup, TableTop[i])
	end
	for i = 1, #ShowPos do
		table.insert(Cup, ShowPos[i])
	end
	ShowPos = {}
	TableTop = {}
	SendAddonMessage("CnDCDHide", "collect", "RAID")
	RedrawDice()

end

function ClearDice()
	for i = 1, #Cup do
		Cup[i]:Hide()
	end
	for i = 1, #TableTop do
		TableTop[i]:Hide()
	end
	for i = 1, #ShowPos do
		ShowPos[i]:Hide()
	end
	for i = 1, #Players do
		for j = 1, #OppoShow["Player" .. i] do
			OppoShow["Player" .. i][j]:Hide()
		end
	end
	OppoShow = {Player1 = {}, Player2 = {}, Player3 = {}, Player4 = {}}
end

function ToggleCupTable(this)
	local t = getglobal(this:GetName() .. "StatsValue"):GetText()
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
	for i = 1, #DiscardPile do
		if this == DiscardPile[i] then this.Glow:Hide() end
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
	if that:GetName() == "TableTopScreen" then
		for i = 1, #Trading do
			table.insert(TableCards, Trading[i])
			Trading[i]:ClearAllPoints()
			Trading[i]:SetPoint("CENTER", "TableTopScreen", "BOTTOM", -220 + i * 50, 70)
		end
		msgTar = "TableTopScreen"
		msg = msgC .. ":" .. msgTar
	elseif that:GetName() == "OwnScreen" then
		for i = 1, #Trading do
			table.insert(Hand, Trading[i])
		end
		RedrawCards()
		msgTar = GetUnitName("player")
		msg = msgC .. ":" .. msgTar
	elseif that:GetName() == "CardDisplay" then
		for i = 1, #Trading do
			table.insert(DisplayCards, Trading[i])
		end
		RedrawCards()
		msgTar = "CardDisplay"
		msg = msgC .. ":" .. msgTar
	elseif that:GetName() == "DiscardPileSquare" then
		for i = 1, #Trading do
			table.insert(DiscardPile, Trading[i])
		end
		RedrawCards()
		msgTar = "DiscardPileSquare"
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
		end
	end
	if msgTar == "TableTopScreen" then
		for k = 1, #Trading do

			local CardSig = getglobal(Trading[k]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "0" then TurnCard(Trading[k]) end
			for i = 1, #DisplayCards do
				if DisplayCards[i] == Trading[k] then
					table.remove(DisplayCards, i)
				end
			end
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

			local CardSig = getglobal(Trading[k]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "0" then TurnCard(Trading[k]) end
			for i = 1, #DisplayCards do
				if DisplayCards[i] == Trading[k] then
					table.remove(DisplayCards, i)
				end
			end
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
	elseif msgTar == "CardDisplay" then
		for k = 1, #Trading do

			local CardSig = getglobal(Trading[k]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "0" then TurnCard(Trading[k]) end
		
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
	elseif msgTar == "DiscardPileSquare" then
		for k = 1, #Trading do

			local CardSig = getglobal(Trading[k]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "1" then TurnCard(Trading[k]) end
			for i = 1, #DisplayCards do
				if DisplayCards[i] == Trading[k] then
					table.remove(DisplayCards, i)
				end
			end
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

			local CardSig = getglobal(Trading[k]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "1" then TurnCard(Trading[k]) end

			for i = 1, #DisplayCards do
				if DisplayCards[i] == Trading[k] then
					table.remove(DisplayCards, i)
				end
			end
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
	for i = 1, #DisplayCards do
		for j = i + 1, #DisplayCards do
			if DisplayCards[i] == DisplayCards[j] then table.remove(DisplayCards, j) end
		end
	end
	for i = 1, #DiscardPile do
		for j = i + 1, #DiscardPile do
			if DiscardPile[i] == DiscardPile[j] then table.remove(DiscardPile, j) end
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
	Trading = {}
	RedrawCards()
	SendAddonMessage("CnDCTrade", msg, "RAID")
end

function SimTradeCards(that)
	if that == "TableTopScreen" then
		for i = 1, #SimTrading do
			local CardSig = getglobal(SimTrading[i]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "0" then TurnCard(SimTrading[i]) end
			table.insert(TableCards, SimTrading[i])
			SimTrading[i]:ClearAllPoints()
			SimTrading[i]:SetPoint("CENTER", "TableTopScreen", "BOTTOM", -220 + i * 50, 70)
		end
	elseif that == GetUnitName("player") then 
		for i = 1, #SimTrading do

			local CardSig = getglobal(SimTrading[i]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "0" then TurnCard(SimTrading[i]) end

			table.insert(Hand, SimTrading[i])
		end
	elseif that == "CardDisplay" then 
		for i = 1, #SimTrading do

			local CardSig = getglobal(SimTrading[i]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "0" then TurnCard(SimTrading[i]) end

			table.insert(DisplayCards, SimTrading[i])
		end
	elseif that == "DiscardPileSquare" then 
		for i = 1, #SimTrading do

			local CardSig = getglobal(SimTrading[i]:GetName() .. "TexLabel"):GetText()
			local CardFace = string.sub(CardSig, 3, 3)
			if CardFace == "1" then TurnCard(SimTrading[i]) end

			table.insert(DiscardPile, SimTrading[i])
		end
	else 	for j = 1, #Players do
			if that == GetUnitName("party"  .. j) then
				for i = 1, #SimTrading do

					local CardSig = getglobal(SimTrading[i]:GetName() .. "TexLabel"):GetText()
					local CardFace = string.sub(CardSig, 3, 3)
					if CardFace == "1" then TurnCard(SimTrading[i]) end
					table.insert(OppoHand["Player" .. j], SimTrading[i])
				end
			end
		end
	end
	if that == "TableTopScreen" then
		for k = 1, #SimTrading do
			for i = 1, #DisplayCards do
				if DisplayCards[i] == SimTrading[k] then
					table.remove(DisplayCards, i)
				end
			end
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
			for i = 1, #DisplayCards do
				if DisplayCards[i] == SimTrading[k] then
					table.remove(DisplayCards, i)
				end
			end
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
	elseif that == "CardDisplay" then
		for k = 1, #SimTrading do
			for i = 1, #Hand do
				if Hand[i] == SimTrading[k] then table.remove(Hand, i) end
			end
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
	elseif that == "DiscardPileSquare" then
		for k = 1, #SimTrading do
			for i = 1, #Hand do
				if Hand[i] == SimTrading[k] then table.remove(Hand, i) end
			end
			for i = 1, #DisplayCards do
				if DisplayCards[i] == SimTrading[k] then
					table.remove(DisplayCards, i)
				end
			end
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
	else 	--if PlayerValid then
		for k = 1, #SimTrading do
			for i = 1, #DisplayCards do
				if DisplayCards[i] == SimTrading[k] then table.remove(DisplayCards, i) end
			end
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
	for i = 1, #DisplayCards do
		for j = i + 1, #DisplayCards do
			if DisplayCards[i] == DisplayCards[j] then table.remove(DisplayCards, j) end
		end
	end
	for i = 1, #DiscardPile do
		for j = i + 1, #DiscardPile do
			if DiscardPile[i] == DiscardPile[j] then table.remove(DiscardPile, j) end
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
	local f = math.floor(270/#DisplayCards) - 1
	for i = 1, #Hand do
		Hand[i]:ClearAllPoints()
		Hand[i]:SetPoint("CENTER", "OwnScreen", "BOTTOM", -170 + i * e, 55)
	end
	for i = 1, #DisplayCards do
		DisplayCards[i]:ClearAllPoints()
		DisplayCards[i]:SetPoint("CENTER", "CardDisplay", "CENTER", -150 + i * f, 0)
	end
	for i = 1, #TableCards do
		TableCards[i]:SetPoint(TableCards[i]:GetPoint())
		TableCards[i]:Hide()
		TableCards[i]:Show()
	end
	for i = 1, #DiscardPile do
		DiscardPile[i]:ClearAllPoints()
		DiscardPile[i]:SetPoint("CENTER", DiscardPilePosition.x + i, DiscardPilePosition.y)
		DiscardPile[i]:Hide()
		DiscardPile[i]:Show()
	end
end

function DiscardTable()
	for i = 1, #TableCards do
		table.insert(DiscardPile, TableCards[i])
	end
	for i = 1, #DisplayCards do
		table.insert(DiscardPile, DisplayCards[i])
	end
	TableCards = {}
	DisplayCards = {}
	for i = 1, #Trading do
		Trading[i].Glow:Hide()
	end
	Trading = {}
	for i = 1, #DiscardPile do
		DiscardPile[i]:ClearAllPoints()
		DiscardPile[i]:SetPoint("CENTER", DiscardPilePosition.x + i, DiscardPilePosition.y)
		DiscardPile[i]:Hide()
		DiscardPile[i]:Show()
	end
	SendAddonMessage("CnDCTrade", "discard", "RAID")
end

function RecycleDiscarded()
	if #DiscardPile > 0 then
		for i = 1, #DiscardPile do
			table.insert(CardsDeck, DiscardPile[i])
		end
		DiscardPile = {}
		CardsDeck = Shuffle(CardsDeck)
		for i = 1, #CardsDeck do
			CardsDeck[i]:ClearAllPoints()
			CardsDeck[i]:SetPoint("CENTER", DeckPosition.x + i, DeckPosition.y)
			CardsDeck[i]:Hide()
			CardsDeck[i]:Show()
		end
	end
	SendAddonMessage("CnDCTrade", "recycle", "RAID")
end

function DrawXCards()
	local DrawXNumber = tonumber(DrawCardsBox:GetText())
	if DrawXNumber < #CardsDeck then
		for i = 1, DrawXNumber do
			TurnCard(CardsDeck[#CardsDeck])
			table.insert(Hand, table.remove(CardsDeck, #CardsDeck))
		end
	else
		for i = 1, #CardsDeck do
			TurnCard(CardsDeck[#CardsDeck])
			table.insert(Hand, table.remove(CardsDeck, #CardsDeck))
		end
	end
	RedrawCards()
end

function FoldCards()
	msg = ""
	for i = 1, #Hand do
		TurnCard(Hand[i])
		table.insert(DiscardPile, Hand[i])
		msg = msg .. Hand[i]:GetName()
	end
	Hand = {}
	for i = 1, #Trading do
		Trading[i].Glow:Hide()
	end
	Trading = {}
	for i = 1, #DiscardPile do
		DiscardPile[i]:ClearAllPoints()
		DiscardPile[i]:SetPoint("CENTER", DiscardPilePosition.x + i, DiscardPilePosition.y)
		DiscardPile[i]:Hide()
		DiscardPile[i]:Show()
	end
	msg = msg .. "DiscardPileSquare"
	SendAddonMessage("CnDCTrade", msg, "RAID")
end

function ReshuffleAllCards()
	local CardsCount = #CardsDeck + #Hand + #TableCards + #DiscardPile + #DisplayCards
	for i = 1, #Players do
		CardsCount = CardsCount + #OppoHand["Player" .. i]
	end
	if CardsCount < 40 then CreateSmallDeck() else CreateBigDeck() end
	SendAddonMessage("CnDCTrade", "reshuffle", "RAID")
end

function RedrawDice()
	for i = 1, #TableTop do
		TableTop[i]:ClearAllPoints()
		TableTop[i]:SetPoint("BOTTOM", TableDicePosX[i], 280)
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