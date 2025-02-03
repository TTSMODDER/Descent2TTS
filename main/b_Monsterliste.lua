-- Monster.lua

-- Globale Variablen
amount = {"M"}
bag_GUIDw = {"5c4fff"}
bag_GUIDr = {"7642f5"}
whiteCounter = 1
redCounter = 1
monsterList = {} -- Globale Tabelle für Monster-Daten

function onload_Monster()
    -- Bestehende Monster scannen und Liste aufbauen
    scanForExistingMonsters()
end

-- Am Anfang der Monster.lua
function scanForExistingMonsters()
    -- Alle Objekte auf dem Spielfeld durchsuchen
    local allObjects = getAllObjects()
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

-- Hauptfunktion zum Spawnen
function spawnMonster(params)
    local sourceObject = params[1]
    local spawnType = params[2] or "red"
    local bag_GUIDw = params[3]  -- empfange weiße Beutel GUIDs
    local bag_GUIDr = params[4]  -- empfange rote Beutel GUIDs
    
    -- Wähle die korrekten Beutel basierend auf spawnType
    local bagList = spawnType == "red" and bag_GUIDr or bag_GUIDw
    
    local pos = sourceObject.getPosition()
    local newPos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
    
    if #bagList > 1 then 
        newPos.z = newPos.z + 1.5 
    end
    
    for num, bag_GUID in pairs(bagList) do
        newPos.z = newPos.z - 1.5*(num - 1)
        local bag = getObjectFromGUID(bag_GUID)
        print("Spawning from bag " .. bag_GUID) 
        
        if amount[num] == "M" then
            for _, mini in pairs(bag.getObjects()) do
                if mini.name == sourceObject.getName() then
                    local original = bag.takeObject({
                        guid = mini.guid,
                        callback_function = function(obj)
                            -- Direkter Aufruf statt Timer
                            local new = obj.clone({
                                position = newPos
                            })
                            getObjectFromGUID(bag_GUID).putObject(obj)
                            take_callback(new, bag_GUID, sourceObject)
                        end
                    })
                end
            end
        elseif amount[num] == "I" then
            bag.clone({
                position = newPos
            }).unlock()
        else
            for i=1, amount[num] do
                bag.takeObject({
                    position       = {newPos.x, newPos.y + 0.2*i, newPos.z},
                    rotation      = sourceObject.getRotation(),
                    callback      = "take_callback",
                    callback_owner = self
                })
            end
        end
    end
end

function cloneDelayed(params)
    local original = params[1]
    local bag_GUID = params[2]
    local newPos = params[3]
    local sourceObject = params[4]
    
    local new = original.clone({
        position = newPos
    })
    getObjectFromGUID(bag_GUID).putObject(original)
    take_callback(new, bag_GUID, sourceObject)
end

-- take_callback anpassen
function take_callback(object_spawned, source_bag_guid, sourceObject)
    local originalName = sourceObject.getName()
    
    -- Counter und Namen setzen wie bisher
    if source_bag_guid and source_bag_guid == bag_GUIDr[1] then
        object_spawned.setName(originalName .. " " .. redCounter .. " E")
        redCounter = redCounter + 1
    else
        object_spawned.setName(originalName .. " " .. whiteCounter)
        whiteCounter = whiteCounter + 1
    end
    
    -- Monster-Daten im Objekt selbst speichern
    object_spawned.setLuaScript(string.format([[
        objtype = 'mini'
        mcardguid = '%s'
        monsterData = {
            guid = '%s',
            name = '%s',
            suffix = '%s',
            skill1 = '-',
            skill2 = '-',
            skill3 = '-',
            skill4 = '-'
        }
    ]], sourceObject.getGUID(), object_spawned.getGUID(), object_spawned.getName(), object_spawned.getName():match("%d+")))
    
    -- Liste aktualisieren
    addMonsterToList(object_spawned)
end

-- Spaltendefinitionen
local columnDefs = {
    {id = "guid", label = "GUID", getter = function(obj) return obj.getGUID() end},
    {id = "name", label = "Name", getter = function(obj) return obj.getName() end},
    {id = "suffix", label = "Suffix Nr", getter = function(obj) return obj.getName():match("%d+") end},
    {id = "skill1", label = "Skill 1", getter = function(obj) return "-" end},
    {id = "skill2", label = "Skill 2", getter = function(obj) return "-" end},
    {id = "skill3", label = "Skill 3", getter = function(obj) return "-" end},
    {id = "skill4", label = "Skill 4", getter = function(obj) return "-" end}
}

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
        whiteCounter = loadedData.whiteCounter or 1
        redCounter = loadedData.redCounter or 1
        -- UI wiederherstellen
        rebuildMonsterList()
    end
end

-- Funktion zum Wiederherstellen der UI-Liste
function rebuildMonsterList()
    print("Starte rebuildMonsterList")
    
    -- Monster-Zeilen aufbauen...
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
    for guid, _ in pairs(monsterList) do
        local obj = getObjectFromGUID(guid)
        if obj then
            local rowData = {}
            for _, column in ipairs(columnDefs) do
                rowData[column.id] = column.getter(obj)
            end
            
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