require("/Librarys/Charakters")


spawnPositions = {  -- Positionen für Spielerfarben
    White = {x = 10, y = 1, z = 0},
    Red = {x = 10, y = 1, z = 5},
    Blue = {x = 10, y = 1, z = -5},
    Green = {x = 10, y = 1, z = 10},
    Yellow = {x = 10, y = 1, z = -10},
}



-- Menü erstellen
function createMenu()
    local menuPosition = {0, 1, 0}  -- Position des Menüs
    local spacing = 3  -- Abstand zwischen Karten
    local offset = -((#characters - 1) * spacing) / 2

    for i, char in ipairs(charactersteam) do
        local pos = {menuPosition[1] + offset + (i - 1) * spacing, menuPosition[2], menuPosition[3]}
        spawnObject({
            type = "Card",
            position = pos,
            rotation = {0, 180, 0},
            scale = {2, 2, 2},
            callback_function = function(obj)
                obj.setCustomObject({face = getObjectFromGUID(char.cardGUID).getCustomObject().face})
                obj.setName(char.name)
                obj.setDescription("Klicke, um diesen Charakter auszuwählen.")
                obj.setLuaScript("function onClick(playerColor)\n" ..
                                 "    Global.call('selectCharacter', {" .. i .. ", playerColor})\n" ..
                                 "end")
            end
        })
    end
end

-- Charakterauswahl
selectedCharacters = {}  -- Liste der ausgewählten Charaktere

function selectCharacter(params)
    local charIndex, playerColor = params[1], params[2]
    if selectedCharacters[playerColor] then
        printToColor("Du hast bereits einen Charakter ausgewählt!", playerColor, {1, 0, 0})
        return
    end

    local char = characterCards[charIndex]
    local spawnPos = spawnPositions[playerColor]
    if not spawnPos then
        printToColor("Deine Farbe hat keinen festgelegten Platz!", playerColor, {1, 0, 0})
        return
    end

    local sheet = getObjectFromGUID(char.sheetGUID)
    if not sheet then
        printToColor("Charakterbogen nicht gefunden!", playerColor, {1, 0, 0})
        return
    end

    sheet.clone({
        position = spawnPos,
        rotation = {0, 180, 0}
    })
    selectedCharacters[playerColor] = char.name

    printToAll(playerColor .. " hat " .. char.name .. " ausgewählt.", {0, 1, 0})

    checkAllSelected()
end

-- Überprüfung, ob alle Spieler gewählt haben
function checkAllSelected()
    local players = Player.getPlayers()
    for _, player in ipairs(players) do
        if player.seated and not selectedCharacters[player.color] then
            return  -- Ein Spieler hat noch nicht ausgewählt
        end
    end
    printToAll("Alle Spieler haben einen Charakter ausgewählt! Das Spiel kann beginnen.", {0, 1, 0})
end
