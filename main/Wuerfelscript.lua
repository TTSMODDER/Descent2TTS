require ("/Librarys/Constants")

function createWuerfelButton()
    UI.setXmlTable({
        {
            tag="VerticalLayout",
            attributes={
                height=350,
                width=50,
                color="rgba(0,0,0,0.7)",
                position = "-25 0",
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
                }
            }
        }
    )
end


local currentDice = {}


-- clickFunction to start dice process
function wuerfeln(player, value, id)
    -- Nur für Spielerfarben, nicht für DM
    if allowedPlayerColors[player.color] then
       
        log(diceCount)
        if isRolling == true then
            log("würfel rollen noch")
            return
        end
        if diceCount >= maxDice then
            log("maximale anzahl an würfel wurde erreicht!")
            return
        end
        if wuerfel[id] then
            local url = wuerfel[id].url
            local startPos = vector(0, 0, 0) -- Anfangsposition
            local offset = 3

            -- Berechne die Position des neuen Würfels basierend auf der Anzahl bestehender Würfel
            local newPos = vector(startPos.x + #currentDice * offset, 10, -10)

            -- Würfel an der berechneten Position spawnen
            spawnObjFromCloud(url, id, callback, newPos)

            
        end
    elseif allowedDMColor[player.color] then
        log("Der DM rollt die Würfel")
    else
        log("nichts passiert")
    end
end


---@params url string Cloud URL from Library/Constants
---@params id string ButtonID of pushed button
---@params callback function for delayed reaction after spawning
---@params obj object Spawned object
---@return currentDice obj List element with all current dices

function spawnObjFromCloud (url, id, callback, position)
    diceCount = diceCount + 1

    WebRequest.get(url, function(response)
        local objectJSON = response.text
        -- Objekt mit dem geladenen JSON spawnen
        local spawnedObject = spawnObjectJSON({
            json = objectJSON,
            position = position,
            callback_function = function(obj)
                obj.setName(id.." Cube")
                table.insert(currentDice, obj)
                --startRollTimer(obj)
                if callback then
                    callback(obj)
                end
            end
        })
    end)
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
        return
    end

    -- Timer erneut starten, um die Geschwindigkeit weiter zu überwachen
    startRollTimer(obj)
end

-- callback Funktion for rolling dices and destroy after rolling all dices
function callback (obj)
    Wait.time(function()
        isRolling = true
        for i=1, #currentDice do
            local dice = currentDice[i]
            dice.roll()
            startRollTimer(obj)
        end

        -- destroy all dices after rolling --
        Wait.time(function()
            for _, cube in ipairs (currentDice) do
                destroyObject(cube)
                diceCount = 0
                isRolling = false
            end
            currentDice = {}
        end, 10)
        --displayResults()
    end,3) 
end
function checkDiceMovement(objGUID)
    log(objGUID)
    local dice = getObjectFromGUID(objGUID)
    if not dice then
        Timer.destroy("dice_check_" .. objGUID)
        return
    end

    local currentPosition = dice.getPosition()
    local velocity = dice.getVelocity()
    log(velocity)

    if math.abs(velocity.x) < 0.01 and math.abs(velocity.y) < 0.01 and math.abs(velocity.z) < 0.01 then
        Timer.destroy("dice_check_" .. objGUID)
        showDiceValue(dice)
    end
end



function showDiceValue(dice)
    log ("funktioniert")
end



function wuerfelCoroutine()
    print("vor der Pause")
    coroutine.yield()  -- Hier wird die Ausführung pausiert
    print("Nach der Pause")
end


-------------------------------------------TEST ---------------
--[[

function checkDiceResting()
    -- Prüfen, ob currentDice leer ist
    if #currentDice == 0 then
        log("Keine Würfel zum Prüfen.")
        return false
    end

    -- Annahme: Alle Würfel ruhen
    local allResting = true

    -- Alle Würfel durchgehen
    for i = 1, #currentDice do
        local dice = currentDice[i]
        resting = dice.isResting()
        log(resting)

        -- Prüfen, ob das Objekt gültig ist und die Methode isResting besitzt
        if not dice.isResting then
            log("Objekt hat keine isResting-Methode: " .. dice.getName())
            return false
        end

        -- Wenn ein Würfel nicht ruht, ändere allResting und brich die Schleife ab
        if not dice.isResting() then
            allResting = false
            log("Ein Würfel bewegt sich noch: " .. dice.getName())
            break
        end
    end

    -- Ergebnis loggen
    if allResting then
        log("Alle Würfel ruhen.")
    else
        log("Mindestens ein Würfel bewegt sich noch.")
    end

    return allResting
end --]]

--[[ function displayResults(color)
    local total = 0
    local resultTable = {}

    --Tally result info
    for _, die in ipairs(currentDice) do
        if die ~= nil then
            --Tally value info
            --local value = die.getValue()
			            --total = total + value
			         			   --Custom dice value
            if die.getName() == "Blue Cube" then
			                	value = ref_Blue[die.getValue()]
            			end
            if die.getName() == "Red Cube" then
                				value = ref_Red[die.getValue()]
            			end
            if die.getName() == "Yellow Cube" then
                				value = ref_Yellow[die.getValue()]
            			end
            if die.getName() == "Green Cube" then
                				value = ref_Green[die.getValue()]
            			end
            if die.getName() == "Grey Cube" then
                				value = ref_Grey[die.getValue()]
            			end
            if die.getName() == "Black Cube" then
                				value = ref_Black[die.getValue()]
            			end
            if die.getName() == "Brown Cube" then
                				value = ref_Brown[die.getValue()]
            			end			
            --Tally color info
            local textColor = {1,1,1}
            if announce_color == "player" then
                textColor = stringColorToRGB(color)
            elseif announce_color == "die" then
                textColor = stringColorToRGB(die.getName())
            end
            --Get die type
            local dSides = ""
            local dieCustomInfo = die.getCustomObject()
            if next(dieCustomInfo) then
                dSides = ref_customDieSides_rev[dieCustomInfo.type+1]
            else
                dSides = tonumber(string.match(tostring(die),"%d+"))
            end
            --Add to table
            table.insert(resultTable, {value=value, color=textColor, sides=dSides})
        end
    end
end --]]