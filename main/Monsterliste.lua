-- Monster.lua



function Monsterliste_onload()
    -- Bestehende Monster scannen und Liste aufbauen

    scanForExistingMonsters()
   
end

-- Am Anfang der Monster.lua
function scanForExistingMonsters()
    -- Alle Objekte auf dem Spielfeld durchsuchen
    local allObjects = getAllObjects()
        print("scanForExistingMonsters")
    for _, obj in pairs(allObjects) do
        -- Prüfen ob es ein geklontes Monster ist (anhand des Skripts)
        if obj.getLuaScript():find('objtype = \'mini\'') then
            -- Monster zur Liste hinzufügen
            addMonsterToList(obj, true) -- true = kein UI-Update
        end
    end
    -- UI einmal komplett neu aufbauen
    rebuildMonsterList()
end



function addMonsterToList(monster, skipUIUpdate)
    local guid = monster.getGUID()
    monsterList[guid] = guid  -- Nur GUID speichern
    
    if not skipUIUpdate then
        rebuildMonsterList()
    end
end

-- Save-Funktion erweitern
function onSave()
    local dataToSave = {
        monsterList = monsterList,
        whiteCounter = whiteCounter,
        redCounter = redCounter
    }
    return JSON.encode(dataToSave)
end

-- Load-Funktion erweitern
function onLoad(savedData)
    if savedData ~= "" then
        local loadedData = JSON.decode(savedData)
        monsterList = loadedData.monsterList or {}

        -- UI wiederherstellen
        rebuildMonsterList()
    end
end

-- Funktion zum Wiederherstellen der UI-Liste
function rebuildMonsterList()
    print("Starte rebuildMonsterList")
    
    -- Monster-Zeilen aufbauen...
    print("Starte zeilen aufbau")
    local tableContent = [[
        <Row preferredHeight="30">
            <Cell><Text color="white">GUID</Text></Cell>
            <Cell><Text color="white">Name</Text></Cell>
            <Cell><Text color="white">Suffix Nr</Text></Cell>
            <Cell><Text color="white">Skill 1</Text></Cell>
            <Cell><Text color="white">Skill 2</Text></Cell>
            <Cell><Text color="white">Skill 3</Text></Cell>
            <Cell><Text color="white">Skill 4</Text></Cell>
        </Row>
    ]]
    
    -- Monster-Zeilen hinzufügen
    print("zeilen hinzu1a")
    for guid, _ in pairs(monsterList) do
        print("zeilen hinzu2")
        local obj = getObjectFromGUID(guid)
        if obj then
            local rowData = {}
            for _, column in ipairs(columnDefs) do
                rowData[column.id] = column.getter(obj)
            end
            print("zeilen hinzu2")
            tableContent = tableContent .. string.format([[
                <Row preferredHeight="30">
                    <Cell><Text color="white">%s</Text></Cell>
                    <Cell><Text color="white">%s</Text></Cell>
                    <Cell><Text color="white">%s</Text></Cell>
                    <Cell><Text color="white">%s</Text></Cell>
                    <Cell><Text color="white">%s</Text></Cell>
                    <Cell><Text color="white">%s</Text></Cell>
                    <Cell><Text color="white">%s</Text></Cell>
                </Row>
            ]], 
            rowData.guid or "-",
            rowData.name or "-",
            rowData.suffix or "-",
            rowData.skill1 or "-",
            rowData.skill2 or "-",
            rowData.skill3 or "-",
            rowData.skill4 or "-")
        end
        print("zeilen hinzu3")
    end

    -- XML Pattern-Suche für das TableLayout innerhalb des Panels
    local currentXml = UI.getXml()
    local startTag = "<TableLayout id=\"MonsterTableLayout\" autoCalculateHeight=\"true\">"
    local endTag = "</TableLayout>"
    
    local startPos = currentXml:find(startTag)
    local endPos = currentXml:find(endTag, startPos)
    
    if startPos and endPos then
        -- Nur den TableLayout-Inhalt ersetzen, Panel-Struktur beibehalten
        local beforeTable = currentXml:sub(1, startPos + #startTag - 1)
        local afterTable = currentXml:sub(endPos)
        local newXml = beforeTable .. tableContent .. afterTable
        
        print("Table-Update: Start=" .. startPos .. ", End=" .. endPos)
        UI.setXml(newXml)
    else
        print("MonsterTableLayout nicht gefunden!")
    end
end