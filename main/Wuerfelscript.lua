require ("/Librarys/Constants")
require ("/main/Heldenpanel")

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

            if yellowDiceCount < 6 and yellowDiceCount >= 0 then
                yellowDiceCount = yellowDiceCount + 1
                UI.setValue(panelID, tostring(yellowDiceCount))
                dicesToThrow[playerColor].Yellow = yellowDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if yellowDiceCount <= 6 and yellowDiceCount > 0 then
                yellowDiceCount = yellowDiceCount - 1
                UI.setValue(panelID, tostring(yellowDiceCount))
                dicesToThrow[playerColor].Yellow = yellowDiceCount  -- Wert speichern
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
            if greenDiceCount < 6 and greenDiceCount >= 0 then
                greenDiceCount = greenDiceCount + 1
                UI.setValue(panelID, tostring(greenDiceCount))
                dicesToThrow[playerColor].Green = greenDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if greenDiceCount <= 6 and greenDiceCount > 0 then
                greenDiceCount = greenDiceCount - 1
                UI.setValue(panelID, tostring(greenDiceCount))
                dicesToThrow[playerColor].Green = greenDiceCount  -- Wert speichern
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

            if whiteDiceCount < 6 and whiteDiceCount >= 0 then
                whiteDiceCount = whiteDiceCount + 1
                UI.setValue(panelID, tostring(whiteDiceCount))
                dicesToThrow[playerColor].Grey = whiteDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if whiteDiceCount <= 6 and whiteDiceCount > 0 then
                whiteDiceCount = whiteDiceCount - 1
                UI.setValue(panelID, tostring(whiteDiceCount))
                dicesToThrow[playerColor].Grey = whiteDiceCount  -- Wert speichern
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
            if blackDiceCount < 6 and blackDiceCount >= 0 then
                blackDiceCount = blackDiceCount + 1
                UI.setValue(panelID, tostring(blackDiceCount))
                dicesToThrow[playerColor].Black = blackDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if blackDiceCount <= 6 and blackDiceCount > 0 then
                blackDiceCount = blackDiceCount - 1
                UI.setValue(panelID, tostring(blackDiceCount))
                dicesToThrow[playerColor].Black = blackDiceCount  -- Wert speichern
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
            if brownDiceCount < 6 and brownDiceCount >= 0 then
                brownDiceCount = brownDiceCount + 1
                UI.setValue(panelID, tostring(brownDiceCount))
                dicesToThrow[playerColor].Brown = brownDiceCount  -- Wert speichern
            end
        elseif value == "-2" then
            if brownDiceCount <= 6 and brownDiceCount > 0 then
                brownDiceCount = brownDiceCount - 1
                UI.setValue(panelID, tostring(brownDiceCount))
                dicesToThrow[playerColor].Brown = brownDiceCount  -- Wert speichern
            end
        end
    end
end

function angriff (player, value, id)
    playerColor = player.color
    local atkDices = {"Red", "Blue", "Yellow", "Green"}
    local delay = 0  -- Startverzögerung

    for k, count in pairs(dicesToThrow) do
        if k == playerColor then -- Würfeltabelle des aktiven Spielers durchgehen
            for i = 1, #atkDices do  -- i beginnt bei 1, nicht bei 0
                local diceType = atkDices[i]
                
                if count[diceType] and count[diceType] > 0 then
                    local numCurrentDice = count[diceType]
                    
                    for j = 1, numCurrentDice do
                        -- Verzögerter Würfelwurf
                        Wait.time(function()
                            log("Würfelt Würfel: " .. diceType)
                            wuerfeln(player, nil, diceType)
                        end, delay)
                        
                        delay = delay + 0.2  -- Erhöhe Verzögerung um 0.5 Sekunden pro Wurf
                    end
                end
            end
        end
    end
end

function probe(player, value, id)
    playerColor = player.color
    wuerfeln(player, nil, "Black")
    Wait.time(function()
        wuerfeln(player, nil, "Grey")
        isRolling = true
    end, 0.2)
end

function heal(player, value, id)
    playerColor = player.color
    wuerfeln(player, nil, "Red")
    Wait.time(function()
        wuerfeln(player, nil, "Red")
        isRolling = true
    end, 0.2)
end

local clickEvent = 0

function abwehr (player, value, id)
    if clickEvent == 1 then
        return
    end
    clickEvent = clickEvent + 1
    playerColor = player.color
    local abwDices = {"Grey", "Black", "Brown"}
    local delay = 0  -- Startverzögerung
    for k, count in pairs(dicesToThrow) do
        if k == playerColor then -- Würfeltabelle des aktiven Spielers durchgehen
            
            ---- berechnet die Gesamtanzahl der Würfel ---
            local diceSum = 0
            for i = 1, #abwDices do
                local diceType = abwDices[i]
                if count[diceType] and count[diceType] > 0 then
                    diceSum = diceSum + count[diceType]
                end
            end
            
            --- durchläuft alle Würfeltypen und spawned die eingestellten Werte ---
            for i = 1, #abwDices do  -- i beginnt bei 1, nicht bei 0
                local diceType = abwDices[i]
                if count[diceType] and count[diceType] > 0 then
                    local numCurrentDice = count[diceType]
                    for j = 1, numCurrentDice do
                        -- Verzögerter Würfelwurf
                        Wait.time(function()
                            log("Würfelt Würfel: " .. diceType)
                            wuerfeln(player, nil, diceType)
                        end, delay)
                        diceSum = diceSum - 1
                        delay = delay + 0.2  -- Erhöhe Verzögerung um 0.2 Sekunden pro Wurf
                        log(diceSum)
                    end
                end
            end
        end
    end
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
                clickEvent = 0
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

        ---------------------------------------------------------
        --- Bildanzeige Würfelergebnisse aktuell ohne Funktion---
        --showImginUI(result, diceImgTbl, resultToPrint)
        ---------------------------------------------------------
        
        self.UI.setAttribute("showResultID", "text", resultDM) 
        print("Dungeon Master: "  .. resultToPrint)
        
        Wait.time(function()
            self.UI.setAttribute("showResultID", "text", "")
        end, 5)

    elseif allowedPlayerColors[playerColor] then
        
        ---------------------------------------------------------
        --- Bildanzeige Würfelergebnisse aktuell ohne Funktion---
            --showImginUI(result, diceImgTbl, resultToPrint)
        ---------------------------------------------------------
        
        self.UI.setAttribute("showResultID", "text", result)
        print(playerName .. ": " .. resultToPrint)

        Wait.time(function()
            self.UI.setAttribute("showResultID", "text", "")
        end, 5)
    end
end

function showImginUI(result, diceImgTbl, resultToPrint)
    if playerColor == "White" then
        local imgURLDM = imgURL
        local currentUI = UI.getXmlTable()
        local variableWidth = (#diceImgTbl * 50) + (#diceImgTbl * 3)
        self.UI.setAttributes("diceResultDM", "color", "rgba(0,0,0,0)")
        log(currentUI)
        for _,element in ipairs (currentUI) do
            if element.attributes and element.attributes.id == "diceResultDM" then
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

        self.UI.setAttribute("diceResultDM", "width", variableWidth)
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

        self.UI.setAttribute("diceResult", "width", variableWidth)
        self.UI.setAttribute("spielerName", "text", playerName)
        self.UI.setAttribute("resultIMG", "image", imgURL)
    end
end