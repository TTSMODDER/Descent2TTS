require ("/Librarys/Constants")

function createWuerfelButton()
    UI.setXmlTable({
        {
            tag="VerticalLayout",
            attributes={
                height=350,
                width=50,
                color="rgba(0,0,0,0.7)",
                position = "-50 0",
                anchorMin="1 0.5",
                anchorMax="1 0.5",
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
                tag = "Image",
                attributes = {
                    id = "resultIMG",
                    width = 50,
                    height = 50,
                    rectAlignment = "UpperRight",  -- Positionierung des Bildes in der oberen rechten Ecke
                    offsetXY = "-25 -150",
                    --visibility = "True",
                    color = "rgba(0,0,0,0)",
                    image = "",
                   

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
                    position = "-100 -125",
                    text = "Spieler", -- Der Text mit den <color>-Tags

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
                    position = "-100 -225",
                    text = "Dungeon Master", -- Der Text mit den <color>-Tags

                },
            },
        }
    )
end


local currentDice = {}
local playerName = ""
local playerColor = ""
local lastPlayer = ""

function checkCurrentPlayer (player)
    if lastPlayer == "" or lastPlayer == player.color then
        return
    elseif player.color ~= "White" then
        if isRolling == true then
            log("würfel rollen noch")
            return
        end
        for _, cube in ipairs(currentDice[lastPlayer]) do
            destroyObject(cube)
        end
        isRolling = false
        rollingDone = false
        diceCount = 0
        currentDice = {}
        log(currentDice)
    else
        return
    end
end

-- clickFunction to start dice process
function wuerfeln(player, value, id)
    self.UI.setAttribute("resultIMG", "color", "rgba(0,0,0,0)")
    local playerObj = Player[player.color]
    playerName = playerObj.steam_name -- Oder .getName(), falls benötigt

    checkCurrentPlayer(player)

    -- Nur für Spielerfarben, nicht für DM
    if allowedPlayerColors[player.color] then 
        if isRolling == true then
            log("würfel rollen noch")
            return
        end
        if rollingDone == true then
            log(currentDice)
            for _, cube in ipairs(currentDice[player.color]) do
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
       
        if wuerfel[id] then
            local url = wuerfel[id].url
            local startPos = vector(-8, 10, 8) -- Anfangsposition (nur einmal festgelegt)

            if currentDice[player.color] == nil  then
                currentDice[player.color] = {}
            end
                
            
           
            local diceForPlayer = currentDice[player.color]
            local newDicePos = vector(startPos.x + #diceForPlayer * -3, startPos.y, startPos.z)
            
            -- Würfel spawnen
            spawnObjFromCloud(url, id, callback, newDicePos, player)
            lastPlayer = player.color
        end
    elseif allowedDMColor[player.color] then
        

        -- check if dices still rolling
        if isRollingDM == true then
            log("würfel rollen noch")
            return
        end

        --check if dices are rolled out
        if rollingDoneDM == true then
            log(currentDice)
            for key, diceTbl in pairs(currentDice) do
                if key == "White" then
                    for _,dice in ipairs(currentDice[key]) do
                        destroyObject(dice)
                    end
                end   
            end
            isRollingDM = false
            rollingDoneDM = false
            diceCountDM = 0
            currentDice[player.color] = {}
        end
        -- check maximum of possible dices
        if diceCountDM >= maxDice then
            log("maximale anzahl an würfel wurde erreicht!")
            return
        end
       
        if wuerfel[id] then
            local url = wuerfel[id].url
            local startPos = vector(-18, 10, -3) -- Anfangsposition (nur einmal festgelegt)

            if currentDice[player.color] == nil  then
                currentDice[player.color] = {}
            end
                
            
           
            local diceForPlayer = currentDice[player.color]
            local newDicePos = vector(startPos.x + #diceForPlayer * 3, startPos.y, startPos.z)
            
            -- Würfel spawnen
            spawnObjFromCloud(url, id, callback, newDicePos, player)
            
        end

    else
        log("nichts passiert")
    end
end


---@params url string Cloud URL from Library/Constants
---@params id string ButtonID of pushed button
---@params callback function for delayed reaction after spawning
---@params obj object Spawned object
---@return currentDice obj List element with all current dices

function spawnObjFromCloud (url, id, callback, newDicePos, player)
    
    playerColor = player.color
    if allowedPlayerColors [playerColor] then
        diceCount = diceCount + 1
        log(diceCount)
    elseif allowedDMColor [playerColor] then
        diceCountDM = diceCountDM + 1
        log(diceCountDM)
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
        
        if diceCount > 0 then
            diceCount = diceCount - 1
        end
        if diceCount == 0 then
           local result, imgURL, resultToPrint = displayResults()
           showResult(result, imgURL, resultToPrint)
        end 
        return
    end

    -- Timer erneut starten, um die Geschwindigkeit weiter zu überwachen
    startRollTimer(obj)
end

-- callback Funktion for rolling dices
function callback(obj, playerColor)
    Wait.time(function()
        if playerColor ~= "White" then
            isRolling = true
        else
            isRollingDM = true
        end
        local diceTbl = currentDice[playerColor]  -- Hole die Würfel des entsprechenden Spielers
        if diceTbl then
            for _, dice in ipairs(diceTbl) do
                dice.roll()
                startRollTimer(obj)
            end
        end
        Wait.time(function()
            if playerColor ~= "White" then
                isRolling = false
                rollingDone = true
            else
                isRollingDM = false
                rollingDoneDM = true
            end
        end, 3)
    end, 3)
end

function displayResults()
    diceResults = {} -- Stelle sicher, dass das Array leer ist.
    local diceImgTbl = {}
    local diceIMG = ""
    if playerColor == "White" then
        currentDice[lastPlayer] = {}
    end
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


            if value then
                table.insert(diceResults, {value = value, color = color})
            end
            if diceIMG then
                table.insert(diceImgTbl, diceIMG)
            -- log(diceImgTbl)
            end
        end
    end
    local imgURL = ""
    for i = 1, #diceImgTbl do
        imgURL = diceImgTbl[i]
        --imgURL = string.format([["%s"]], diceImgTbl[i])
    end

    local result = ""
    local resultToPrint = ""
    for _, dice in ipairs(diceResults) do
        local coloredText = string.format("<color=%s>%s</color>", dice.color, dice.value)

        resultToPrint = resultToPrint .. dice.value .. " | "
        result = result .. coloredText .. " | " 
    end
    
    return result, imgURL, resultToPrint
end        

function showResult(result, imgURL, resultToPrint)
    self.UI.setAttribute("spielerName", "text", playerName)
    self.UI.setAttribute("showResultID", "text", result)
    self.UI.setAttribute("resultIMG", "image", imgURL)
    self.UI.setAttribute("resultIMG", "color", "rgba(255,255,255,1)")
    print(playerName .. ": " .. resultToPrint)
    Wait.time(function()
        self.UI.setAttribute("showResultID", "text", "")
    end, 8)
end
