require ("/Librarys/Constants")
require ("/main/Heldenpanel")

function createWuerfelButton()

    local xmlTable = {
        {
            tag="VerticalLayout",
            attributes={
                height=350,
                width=50,
                color="rgba(0,0,0,0.7)",
                position = "-50 0",
                anchorMin="1 0.5",
                anchorMax="1 0.5",
                visibility = "White|Blue|Yellow|Red|Green",
                id = "wuerfelMenu",
                },
                children={
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Blue",
                            onClick = "wuerfeln",
                            id = "Blue",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Red",
                            onClick = "wuerfeln",
                            id = "Red",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Yellow",
                            onClick = "wuerfeln",
                            id = "Yellow",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Green",
                            onClick = "wuerfeln",
                            id = "Green",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Grey",
                            onClick = "wuerfeln",
                            id = "Grey", 
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Black",
                            onClick = "wuerfeln",
                            id = "Black",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Brown",
                            onClick = "wuerfeln",
                            id = "Brown",
                        },
                        value="",
                    },
                },
            },
            {
                tag = "Text",
                attributes = {
                    id = "showResultID",
                    richText = "true",
                    fontSize = "40",
                    color = "white",
                    alignment = "UpperCenter",
                    position = "0 -100",
                    text = "", -- Der Text mit den <color>-Tags
                },
            },
            {
                tag = "HorizontalLayout",
                attributes = {
                    width = nil,
                    height = 50,
                    rectAlignment = "MiddleRight",
                    offsetXY = "-10 45",
                    --position = "-100 50",
                    anchorMin="1 0.7",
                    anchorMax="1 0.7",
                    spacing = 5,
                    color = "rgba(0,0,0,0)",
                    id = "diceResultDM",
                },
            },
            {
                tag = "Text",
                attributes = {
                    id = "NameDM",
                    richText = "true",
                    fontSize = "20",
                    color = "white",
                    alignment = "UpperRight",
                    position = "-25 -225",
                    text = "Dungeon Master: ", -- Der Text mit den <color>-Tags
                },
            },
            {
                tag = "Text",
                attributes = {
                    id = "spielerName",
                    richText = "true",
                    fontSize = "20",
                    color = "white",
                    alignment = "UpperRight",
                    position = "-115 -125",
                    text = "Spieler:", -- Der Text mit den <color>-Tags

                },
            },
            {
                tag = "HorizontalLayout",
                attributes = {
                    width = nil,
                    height = 50,
                    rectAlignment = "UpperRight",
                    offsetXY = "-10 170",
                    --position = "-100 50",
                    anchorMin="1 0.7",
                    anchorMax="1 0.7",
                    spacing = 5,
                    color = "rgba(0,0,0,0)",
                    id = "diceResult",
                },
            },
        }
end

local currentDice = {}
local playerName = ""
local playerColor = ""
local lastPlayer = ""


function checkCurrentPlayer(player)
    if lastPlayer == "" or lastPlayer == playerColor then
        lastPlayer = playerColor
        return
    elseif lastPlayer ~= playerColor then 
        if isRolling == true then
            log("Würfel rollen noch")
            return
        end

        -- Nur die Würfel des letzten Spielers löschen
        if currentDice[lastPlayer] then
            for _, cube in ipairs(currentDice[lastPlayer]) do
                destroyObject(cube)
            end
            currentDice[lastPlayer] = nil -- Lösche nur den Eintrag für den letzten Spieler
        end

        isRolling = false
        rollingDone = false
        diceCount = 0
        lastPlayer = playerColor -- Aktualisiere lastPlayer auf den neuen Spieler
    end
end

--[[ function decreaseCounter_1_1()
    if counter_1_1 > 0 then
        counter_1_1 = counter_1_1 - 1
        UI.setValue("counterText_1_1", tostring(counter_1_1))
        Dice_value_1_1 = counter_1_1  -- Wert speichern
    end
end --]]

function redDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    local panelID = "redDiceCountText_" .. playerColor
    if allowedDMColor[playerColor] then
        local redDiceCount = tonumber(UI.getValue(panelID))
        if redDiceCount == nil then
            redDiceCount = 0
        end
        if value == "-1" then
            if redDiceCount < 6 and redDiceCount >= 0 then
                redDiceCount = redDiceCount + 1
                UI.setValue(panelID, tostring(redDiceCount))
                dicesToThrow[playerColor].Red = redDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if redDiceCount <= 6 and redDiceCount > 0 then
                redDiceCount = redDiceCount - 1
                UI.setValue(panelID, tostring(redDiceCount))
                dicesToThrow[playerColor].Red = redDiceCount  -- Wert speichern
            end
        end
    end
    
    if allowedPlayerColors[playerColor] then
        if redDiceCount == nil then
            redDiceCount = 0
        else
            redDiceCount = tonumber(redDiceCount) or 0
        end
        if value == "-1" then
            if redDiceCount < 6 and redDiceCount >= 0 then
                redDiceCount = redDiceCount + 1
                UI.setValue(panelID, tostring(redDiceCount))
                dicesToThrow[playerColor].Red = redDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if redDiceCount <= 6 and redDiceCount > 0 then
                redDiceCount = redDiceCount - 1
                UI.setValue(panelID, tostring(redDiceCount))
                dicesToThrow[playerColor].Red = redDiceCount  -- Wert speichern
            end
        end
    end
end

function blueDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    
    local panelID = "blueDiceCountText_" .. playerColor
    if allowedDMColor then
        local blueDiceCount = tonumber(UI.getValue(panelID))
        if blueDiceCount == nil then
            blueDiceCount = 0
        end
        if value == "-1" then
            log(blueDiceCount)
            if blueDiceCount < 6 and blueDiceCount >= 0 then
                blueDiceCount = blueDiceCount + 1
                log(blueDiceCount)
                log(panelID)
                UI.setValue(panelID, tostring(blueDiceCount))
                dicesToThrow[playerColor].Red = blueDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if blueDiceCount <= 6 and blueDiceCount > 0 then
                blueDiceCount = blueDiceCount - 1
                UI.setValue(panelID, tostring(blueDiceCount))
                dicesToThrow[playerColor].Red = blueDiceCount  -- Wert speichern
            end
        end
    end
end

function yellowDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    
    local panelID = "yellowDiceCountText_" .. playerColor
    if allowedDMColor then
        local yellowDiceCount = tonumber(UI.getValue(panelID))
        if yellowDiceCount == nil then
            yellowDiceCount = 0
        end
        if value == "-1" then
            log(yellowDiceCount)
            if yellowDiceCount < 6 and yellowDiceCount >= 0 then
                yellowDiceCount = yellowDiceCount + 1
                log(yellowDiceCount)
                log(panelID)
                UI.setValue(panelID, tostring(yellowDiceCount))
                dicesToThrow[playerColor].Red = yellowDiceCountceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if yellowDiceCount <= 6 and yellowDiceCount > 0 then
                yellowDiceCount = yellowDiceCount - 1
                UI.setValue(panelID, tostring(yellowDiceCount))
                dicesToThrow[playerColor].Red = yellowDiceCount  -- Wert speichern
            end
        end
    end
end

function greenDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    
    local panelID = "greenDiceCountText_" .. playerColor
    if allowedDMColor then
        local greenDiceCount = tonumber(UI.getValue(panelID))
        if greenDiceCount == nil then
            greenDiceCount = 0
        end
        if value == "-1" then
            log(greenDiceCount)
            if greenDiceCount < 6 and greenDiceCount >= 0 then
                greenDiceCount = greenDiceCount + 1
                log(greenDiceCount)
                log(panelID)
                UI.setValue(panelID, tostring(greenDiceCount))
                dicesToThrow[playerColor].Red = greenDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if greenDiceCount <= 6 and greenDiceCount > 0 then
                greenDiceCount = greenDiceCount - 1
                UI.setValue(panelID, tostring(greenDiceCount))
                dicesToThrow[playerColor].Red = greenDiceCount  -- Wert speichern
            end
        end
    end
end

function whiteDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    
    local panelID = "whiteDiceCountText_" .. playerColor
    if allowedDMColor then
        local whiteDiceCount = tonumber(UI.getValue(panelID))
        if whiteDiceCount == nil then
            whiteDiceCount = 0
        end
        if value == "-1" then
            log(whiteDiceCount)
            if whiteDiceCount < 6 and whiteDiceCount >= 0 then
                whiteDiceCount = whiteDiceCount + 1
                log(whiteDiceCount)
                log(panelID)
                UI.setValue(panelID, tostring(whiteDiceCount))
                dicesToThrow[playerColor].Red = whiteDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if whiteDiceCount <= 6 and whiteDiceCount > 0 then
                whiteDiceCount = whiteDiceCount - 1
                UI.setValue(panelID, tostring(whiteDiceCount))
                dicesToThrow[playerColor].Red = whiteDiceCount  -- Wert speichern
            end
        end
    end
end

function blackDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    
    local panelID = "blackDiceCountText_" .. playerColor
    if allowedDMColor then
        local blackDiceCount = tonumber(UI.getValue(panelID))
        if blackDiceCount == nil then
            blackDiceCount = 0
        end
        if value == "-1" then
            log(blackDiceCount)
            if blackDiceCount < 6 and blackDiceCount >= 0 then
                blackDiceCount = blackDiceCount + 1
                log(blackDiceCount)
                log(panelID)
                UI.setValue(panelID, tostring(blackDiceCount))
                dicesToThrow[playerColor].Red = blackDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if blackDiceCount <= 6 and blackDiceCount > 0 then
                blackDiceCount = blackDiceCount - 1
                UI.setValue(panelID, tostring(blackDiceCount))
                dicesToThrow[playerColor].Red = blackDiceCount  -- Wert speichern
            end
        end
    end
end

function brownDiceCounter(player, value, id)
    local diceColor = id
    
    playerColor = player.color
    
    local panelID = "brownDiceCountText_" .. playerColor
    if allowedDMColor then
        local brownDiceCount = tonumber(UI.getValue(panelID))
        if brownDiceCount == nil then
            brownDiceCount = 0
        end
        if value == "-1" then
            log(brownDiceCount)
            if brownDiceCount < 6 and brownDiceCount >= 0 then
                brownDiceCount = brownDiceCount + 1
                log(brownDiceCount)
                log(panelID)
                UI.setValue(panelID, tostring(brownDiceCount))
                dicesToThrow[playerColor].Red = brownDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if brownDiceCount <= 6 and brownDiceCount > 0 then
                brownDiceCount = brownDiceCount - 1
                UI.setValue(panelID, tostring(brownDiceCount))
                dicesToThrow[playerColor].Red = brownDiceCount  -- Wert speichern
            end
        end
    end
end

function angriff_1b (player, value, id)
    local diceSum = 0
    playerColor = player.color
    
    local panelID = "redDiceCountText_" .. playerColor
    if allowedDMColor then
        local blueDiceCount = tonumber(UI.getValue(panelID))
        if blueDiceCount == nil then
            blueDiceCount = 0
        end
        if value == "-1" then
            if blueDiceCount < 6 and blueDiceCount >= 0 then
                blueDiceCount = blueDiceCount + 1
                UI.setValue(panelID, tostring(blueDiceCount))
                dicesToThrow[playerColor].Blue = blueDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if blueDiceCount <= 6 and blueDiceCount > 0 then
                blueDiceCount = blueDiceCount - 1
                UI.setValue(panelID, tostring(blueDiceCount))
                dicesToThrow[playerColor].Blue = blueDiceCount  -- Wert speichern
            end
        end
    end
end

function angriff_1c (player, value, id)
    local diceSum = 0
    playerColor = player.color
    local atkDices = {"Red", "Blue", "Green", "Yellow"}
    for k, count in pairs (dicesToThrow) do
        if k == playerColor then
            for i = 0, #atkDices do 
                i = i + 1
                if count[atkDices[i]] and count[atkDices[i]] > 0 then
                    log(count[atkDices[i]])
                    local diceNumber = count[atkDices[i]]
                    local diceSum = diceSum + diceNumber 
                    log(diceSum)
                    local diceID = atkDices[i]
                    wuerfeln(player, diceNumber, diceID, diceSum)
                end
            end
        end
    end
end

function probe_1()
    local dice_5_1 = 1
    local dice_6_1 = 1
    print("Probe Spieler 1: Würfelwerte - Dice 5: " .. dice_5_1 .. ", Dice 6: " .. dice_6_1)
end

-- clickFunction to start dice process
function wuerfeln(player, value, id)
    self.UI.setAttribute("resultIMG", "color", "rgba(0,0,0,0)")
    playerColor = player.color
    checkCurrentPlayer(player)

    -- Nur für Spielerfarben, nicht für DM
    if allowedPlayerColors[playerColor] or allowedDMColor [playerColor] then 
        local playerObj = Player[playerColor]
        playerName = playerObj.steam_name -- Oder .getName(), falls benötigt

        if isRolling == true then
            log("würfel rollen noch")
            return
        end
        if rollingDone == true then
            for _, cube in ipairs(currentDice[playerColor]) do
                destroyObject(cube)
            end
            isRolling = false
            rollingDone = false
            diceCount = 0
            currentDice = {}
        end
        if diceCount >= maxDice then
            log("maximale anzahl an würfel wurde erreicht!")
            return
        end
       
        if currentDice[player.color] == nil  then
            currentDice[player.color] = {}
        end

        if wuerfel[id] then
            local url = wuerfel[id].url
            if allowedPlayerColors[playerColor] then
                local startPos = vector(-8, 10, 8)
                local diceForPlayer = currentDice[playerColor]
                local newDicePos = vector(startPos.x + #diceForPlayer * -3, startPos.y, startPos.z)
                spawnObjFromCloud(url, id, callback, newDicePos, player)
            elseif allowedDMColor [playerColor] then
                local startPos = vector(-18, 10, -3) -- Anfangsposition (nur einmal festgelegt)
                local diceForPlayer = currentDice[playerColor]
                local newDicePos = vector(startPos.x + #diceForPlayer * 3, startPos.y, startPos.z)
                spawnObjFromCloud(url, id, callback, newDicePos, player)
            end
        end
    end
end


---@params url string Cloud URL from Library/Constants
---@params id string ButtonID of pushed button
---@params callback function for delayed reaction after spawning
---@params obj object Spawned object
---@return currentDice obj List element with all current dices

function spawnObjFromCloud (url, id, callback, newDicePos, player)
    
    log(diceForPlayer)
    if allowedPlayerColors [playerColor] then
        diceCount = diceCount + 1
    elseif allowedDMColor [playerColor] then
        diceCountDM = diceCountDM + 1
    end
    WebRequest.get(url, function(response)
        local objectJSON = response.text
        -- Objekt mit dem geladenen JSON spawnen
        local spawnedObject = spawnObjectJSON({
            json = objectJSON,
            position = newDicePos,
            callback_function = function(obj)
                obj.setName(id.." Cube")
                if currentDice[playerColor] == nil then
                    currentDice[playerColor] = {}
                end
                
                table.insert(currentDice[playerColor], obj)
                
                --table.insert(currentDice, obj)
                --startRollTimer(obj)
                if callback then
                    callback(obj, playerColor)
                end
            end
        })
    end)
    
    -- Gibt Dictonary mit Farbzuweisung zurück an die übergeordnete Variable Current Dice
    return currentDice
end

function startRollTimer(obj)
    local timerID = "dice_check_" .. obj.getGUID()
    -- Falls der Timer bereits existiert, wird er gelöscht
    Timer.destroy(timerID)
  
    Timer.create({
        identifier = "dice_check_" .. obj.getGUID(),
        function_name = "rollDice",
        parameters = {obj.getGUID()}, -- GUID korrekt übergeben
        delay = 0.1,
        repetitions = 0,
    })
end

function rollDice(params)
    local diceGUID = params[1]
    local obj = getObjectFromGUID(diceGUID)
    if not obj then
        log("Error: Object not found for GUID: " .. diceGUID)
        Timer.destroy("dice_check_" .. diceGUID)
        return
    end

    -- Geschwindigkeit des Würfels überprüfen
    local velocity = obj.getVelocity()

    -- Wenn der Würfel still ist, beenden
    if math.abs(velocity.x) < 0.01 and math.abs(velocity.y) < 0.01 and math.abs(velocity.z) < 0.01 then
        Timer.destroy("dice_check_" .. diceGUID)  -- Timer stoppen, wenn der Würfel gestoppt ist
        if allowedPlayerColors[playerColor] then
            if diceCount > 0 then
                diceCount = diceCount - 1
            end
            if diceCount == 0 then
                local result, imgURL, resultToPrint = displayResults()
                showResult(result, imgURL, resultToPrint)
            end 
        elseif allowedDMColor [playerColor] then
            if diceCountDM > 0 then
                diceCountDM = diceCountDM - 1
            end
            if diceCountDM == 0 then
                local result, imgURL, resultToPrint = displayResults()
                showResult(result, imgURL, resultToPrint)
            end 
        end

        if allowedPlayerColors[playerColor] or allowedDMColor[playerColor] then
            lastPlayer = playerColor
        end
        return
    end

    -- Timer erneut starten, um die Geschwindigkeit weiter zu überwachen
    startRollTimer(obj)
end

-- callback Funktion for rolling dices
function callback(obj, playerColor)
    Wait.time(function()
        if allowedPlayerColors[playerColor] or allowedDMColor[playerColor] then
            isRolling = true
        end
        
        local diceTbl = currentDice[playerColor]  -- Hole die Würfel des entsprechenden Spielers
        if diceTbl then
            for _, dice in ipairs(diceTbl) do
                dice.roll()
                startRollTimer(obj)
            end
        end
        Wait.time(function()
            if allowedPlayerColors[playerColor] or allowedDMColor[playerColor] then
                isRolling = false
                rollingDone = true
            end
        end, 3)
    end, 3)
end

function displayResults()
    diceResults = {}
    diceResultsDM = {} -- Stelle sicher, dass das Array leer ist.
    local diceImgTbl = {}
    local diceImgTblDM = {}
    local diceIMG = ""
  
    for key, diceList in pairs (currentDice) do
        for i = 1, #diceList do
            local dice = diceList[i]
            local color, value
            if dice.getName() == "Blue Cube" then
                value = ref_Blue[dice.getValue()]
                diceIMG = blueDiceIMGs[dice.getValue()]
                color = "#287eb0"    
            elseif dice.getName() == "Red Cube" then
                value = ref_Red[dice.getValue()]
                diceIMG = redDiceIMGs[dice.getValue()]
                color = "#cc391f"
            elseif dice.getName() == "Yellow Cube" then
                value = ref_Yellow[dice.getValue()]
                diceIMG = yellowDiceIMGs[dice.getValue()]
                color = "#e0e322"
            elseif dice.getName() == "Green Cube" then
                value = ref_Green[dice.getValue()]
                diceIMG = greenDiceIMGs[dice.getValue()]
                color = "#2aa136"
            elseif dice.getName() == "Grey Cube" then
                value = ref_Grey[dice.getValue()]
                diceIMG = greyDiceIMGs[dice.getValue()]
                color = "#b5b5ae"
            elseif dice.getName() == "Black Cube" then
                value = ref_Black[dice.getValue()]
                diceIMG = blackDiceIMGs[dice.getValue()]
                color = "#1c1c1c"
            elseif dice.getName() == "Brown Cube" then
                value = ref_Brown[dice.getValue()]
                diceIMG = brownDiceIMGs[dice.getValue()]
                color = "#734c0a"
            end

            if allowedPlayerColors[playerColor] or allowedDMColor[playerColor] then
                if value then
                    table.insert(diceResults, {value = value, color = color})
                end
                if diceIMG then
                    table.insert(diceImgTbl, diceIMG)
                end
            end
        end
    end
    local result = ""
    local resultToPrint = ""
    local imgURL = ""
    if allowedPlayerColors[playerColor] or allowedDMColor[playerColor] then
        for i = 1, #diceImgTbl do
            imgURL = diceImgTbl[i]
            --imgURL = string.format([["%s"]], diceImgTbl[i])
        end
        for _, dice in ipairs(diceResults) do
            local coloredText = string.format("<color=%s>%s</color>", dice.color, dice.value)
    
            resultToPrint = resultToPrint .. dice.value .. " | "
            result = result .. coloredText .. " | " 
        end
    end
    return result, diceImgTbl, resultToPrint
end        

function showResult(result, diceImgTbl, resultToPrint)
    if playerColor == "White" then
        local resultDM = result
        local imgURLDM = imgURL
        local currentUI = UI.getXmlTable()
        local variableWidth = (#diceImgTbl * 50) + (#diceImgTbl * 3)
        --self.UI.setAttributes("diceResultDM", "color", "rgba(0,0,0,0)")
        --log(currentUI)
        for _,element in ipairs (currentUI) do
            if element.attributes and element.attributes.id == "diceResultDM" then
                element.children = {}
                
                for i = 1, #diceImgTbl do
                    log(i)
                    log(element)
                    table.insert(element.children, {
                        tag = "Image",
                        attributes = {
                            width = 50,
                            height = 50,
                            image = diceImgTbl[i],
                        },
                    })
                end
            end
        end
        UI.setXmlTable(currentUI)
        
        
        self.UI.setAttribute("showResultID", "text", resultDM)
        self.UI.setAttribute("diceResultDM", "width", variableWidth)
        print("Dungeon Master: "  .. resultToPrint)

        Wait.time(function()
            self.UI.setAttribute("showResultID", "text", "")
        end, 5)
    elseif allowedPlayerColors[playerColor] then
        local currentUI = UI.getXmlTable()
        local variableWidth = (#diceImgTbl * 50) + (#diceImgTbl * 3)

        for _,element in ipairs (currentUI) do
            if element.attributes and element.attributes.id == "diceResult" then
                element.children = {}
                
                for i = 1, #diceImgTbl do
                    table.insert(element.children, {
                        tag = "Image",
                        attributes = {
                            width = 50,
                            height = 50,
                            image = diceImgTbl[i],
                        },
                    })
                end
            end
        end
        UI.setXmlTable(currentUI)
        
        
        self.UI.setAttribute("showResultID", "text", result)
        self.UI.setAttribute("diceResult", "width", variableWidth)
        print(playerName .. ": " .. resultToPrint)

        Wait.time(function()
            self.UI.setAttribute("showResultID", "text", "")
        end, 5)


        self.UI.setAttribute("spielerName", "text", playerName)
        self.UI.setAttribute("showResultID", "text", result)
        self.UI.setAttribute("resultIMG", "image", imgURL)
        
        Wait.time(function()
            self.UI.setAttribute("showResultID", "text", "")
        end, 5)
    end
end

