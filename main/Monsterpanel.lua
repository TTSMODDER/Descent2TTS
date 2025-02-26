-- Monster.lua
require ("/main/Kamerapositionen")

-- 1. Globale Variablen und Hilfsfunktionen
monsterList = {}
local selectedMonsterGUID = nil
local monsterToPanelMap = {}
local panelToMonsterMap = {}
local panelsVisible = true

local function getMonsterCount(monsterTable)
    local count = 0
    for _ in pairs(monsterTable) do
        count = count + 1
    end
    return count
end

-- Am Anfang der Datei, vor allen anderen Funktionen:
function sanitizeId(str)  -- "local" entfernt -> globale Funktion
    -- Ersetze alle nicht-alphanumerischen Zeichen durch Unterstriche
    str = str:gsub("[^%w]", "_")
    -- Stelle sicher, dass ID nicht mit Zahl beginnt
    if str:match("^%d") then
        str = "m_" .. str
    end
    return str
end


function toggleOLView(player)
  --CAMera switch für OL
    if player.color == "White" or player.color == "Black" then
        if isMapCam then
            Global.call("OL_Card_Cam", player)
        else
            Global.call("mapCam", player)
        end
        isMapCam = not isMapCam
    end
end




-- 2. Laden/Speichern Funktionen
function onLoad(savedData)
    if (savedData ~= "") then
        local loadedData = JSON.decode(savedData)
        monsterList = loadedData.monsterList or {}
    else
        monsterList = {}
    end
end

function onSave()
    local dataToSave = {
        monsterList = monsterList
    }
    return JSON.encode(dataToSave)
end

-- 3. Monster Verwaltung
function addMonsterToList(monster)
    local guid = monster.getGUID()
    local health = "0/0"
    
    -- JSON-Daten der Figur auslesen
    local rawJson = monster.getJSON()
    if rawJson and rawJson:find('"LuaScriptState":') then
        local success, jsonData = pcall(function() return JSON.decode(rawJson) end)
        if success and jsonData and jsonData.LuaScriptState then
            local successLua, barsData = pcall(function() 
                return JSON.decode(jsonData.LuaScriptState) 
            end)
            if successLua and barsData and barsData.bars and barsData.bars[1] then
                local healthBar = barsData.bars[1]
                if healthBar[3] and healthBar[4] then
                    health = healthBar[3] .. "/" .. healthBar[4]
                end
            end
        end
    end

    monsterList[guid] = {
        guid = guid,
        name = monster.getName(),
        health = health
    }
end

function scanForExistingMonsters()
   
    local allObjects = getAllObjects()
    local tempMonsterList = {}
    
    for _, obj in pairs(allObjects) do
        if obj.getLuaScript():find('TRH_Class%s*=%s*[\'"]mini_Monster[\'"]') then
            table.insert(tempMonsterList, obj)
        end
    end
    
    for _, monster in ipairs(tempMonsterList) do
        addMonsterToList(monster)
    end
    
    updateMonsterPanels()
end

-- 4. UI Handling
function updatePanelColor()
    for i = 1, 20 do
        local panelId = "monster_panel_" .. i
        local textId = "monster_text_" .. i
        self.UI.setAttribute(panelId, "color", "#000000")
    end
    
    if selectedMonsterGUID and monsterToPanelMap[selectedMonsterGUID] then
        local panelIndex = monsterToPanelMap[selectedMonsterGUID]
        local panelId = "monster_panel_" .. panelIndex
        self.UI.setAttribute(panelId, "color", "#FF0000")
    end
    
    if selectedMonsterGUID then
        local monster = monsterList[selectedMonsterGUID]
        local monsterObj = getObjectFromGUID(selectedMonsterGUID)
        if monster and monsterObj then
            -- Akt 2 Prüfung
            local description = monsterObj.getDescription()
            local textColor = description:match("Akt 2") and "#FFFF00" or "#FFFFFF"
            
            self.UI.setAttribute("selected_monster_name", "text", monster.name)
            self.UI.setAttribute("selected_monster_name", "color", textColor)
            
            self.UI.setAttribute("selected_monster_health", "text", monster.health)
            self.UI.setAttribute("selected_monster_health", "color", textColor)
        end
    else
        self.UI.setAttribute("selected_monster_name", "text", "")
        self.UI.setAttribute("selected_monster_health", "text", "")
    end
end

function updateMonsterPanels()
    for i = 1, 20 do
        self.UI.setAttribute("monster_text_" .. i, "text", "")
        self.UI.setAttribute("monster_panel_" .. i, "active", "false")
    end
    
    monsterToPanelMap = {}
    panelToMonsterMap = {}
    
    local sortedMonsters = {}
    for _, monster in pairs(monsterList) do
        table.insert(sortedMonsters, monster)
    end
    table.sort(sortedMonsters, function(a, b) 
        return a.name < b.name 
    end)
    
    local panelIndex = 1
    for _, monster in ipairs(sortedMonsters) do
        if panelIndex <= 20 then
            local monsterObj = getObjectFromGUID(monster.guid)
            local description = monsterObj and monsterObj.getDescription() or ""
            local isAct2 = description:match("Akt 2") ~= nil
            
            local panelId = "monster_panel_" .. panelIndex
            self.UI.setAttribute(panelId, "active", "true")
            
            -- Gelb (#FFFF00) statt Rot für Akt 2
            local textColor = isAct2 and "#FFFF00" or "#FFFFFF"
            
            -- Text mit entsprechender Farbe setzen
            self.UI.setAttribute("monster_text_1_" .. panelIndex, "text", monster.name)
            self.UI.setAttribute("monster_text_1_" .. panelIndex, "color", textColor)
            
            self.UI.setAttribute("monster_text_2_" .. panelIndex, "text", monster.health)
            self.UI.setAttribute("monster_text_2_" .. panelIndex, "color", textColor)
            
            -- Root Panel Text-Farbe aktualisieren wenn dies das selektierte Monster ist
            if monster.guid == selectedMonsterGUID then
                self.UI.setAttribute("selected_monster_name", "color", textColor)
                self.UI.setAttribute("selected_monster_health", "color", textColor)
            end
            
            monsterToPanelMap[monster.guid] = panelIndex
            panelToMonsterMap[panelId] = monster.guid
            panelIndex = panelIndex + 1
        end
    end
    
    updatePanelColor()
end

function togglePanelsVisibility()
    panelsVisible = not panelsVisible
    
    for i = 1, 20 do
        local panelId = "monster_panel_" .. i
        self.UI.setAttribute(panelId, "visibility", 
            panelsVisible and "White|Black" or "Purple")
    end
    
    self.UI.setAttribute("toggle_panels_button", "text", 
        panelsVisible and "-" or "o")
end

-- 5. Event Handler
function Monsterliste_onload()
    printToAll("wird aktualisiert...")
    scanForExistingMonsters()
    printToAll("Monster aktualisiert ")
end

function onObjectPickUp(player_color, picked_up_object)
    if picked_up_object.getLuaScript():find('TRH_Class%s*=%s*[\'"]mini_Monster[\'"]') then
        local newGUID = picked_up_object.getGUID()
        
        if not monsterList[newGUID] then
            printToAll("Monster nicht gelistet ")
            return
        end
        
        if selectedMonsterGUID then
            local previousMonster = getObjectFromGUID(selectedMonsterGUID)
            if previousMonster then
                previousMonster.highlightOff()
            end
        end
        
        if selectedMonsterGUID == newGUID then
            selectedMonsterGUID = nil
        else
            selectedMonsterGUID = newGUID
            picked_up_object.highlightOn('Yellow')
        end
        
        updatePanelColor()
    end
end

function onObjectDrop(player_color, dropped_object)
    updatePanelColor()
end

function onPanelClick(player, panel_id)
    if panel_id:find("monster_panel_") then
        local monsterGUID = panelToMonsterMap[panel_id]
        
        if monsterGUID then
            if selectedMonsterGUID == monsterGUID then
                selectedMonsterGUID = nil
            else
                selectedMonsterGUID = monsterGUID
            end
            updatePanelColor()
        end
    end
end

function Click_MonsterPanel(player, value, id)
    local monsterGUID = panelToMonsterMap[id]
    
    -- Wenn kein Monster-GUID gefunden wurde
    if not monsterGUID then
        printToAll("Monster nicht gelistet,!")
        return
    end

    -- Prüfen ob das Monster noch existiert
    local monsterObj = getObjectFromGUID(monsterGUID)
    
    -- Wenn das Monster nicht mehr existiert
    if not monsterObj then
        printToAll("Monster nicht gelistet")
        -- Aktuelles Monster deselektieren
        selectedMonsterGUID = nil
        -- Panel-Listen aktualisieren
        monsterList[monsterGUID] = nil
        updateMonsterPanels()
        return
    end

    -- Monster existiert - normale Auswahl-Logik
    if selectedMonsterGUID == monsterGUID then
        monsterObj.highlightOff()
        selectedMonsterGUID = nil
    else
        -- Vorheriges Monster highlight entfernen
        if selectedMonsterGUID then
            local previousMonster = getObjectFromGUID(selectedMonsterGUID)
            if previousMonster then
                previousMonster.highlightOff()
            end
        end
        -- Neues Monster auswählen
        selectedMonsterGUID = monsterGUID
        monsterObj.highlightOn('Yellow')
    end
    
    updatePanelColor()
end

function adjustSelectedMonsterHealth(player, value, id)
    if selectedMonsterGUID then
        local amount
        if id == "health_up" then
            amount = 1
        elseif id == "health_down" then
            amount = -1
        end
        
        if amount then
            local panelIndex = monsterToPanelMap[selectedMonsterGUID]
            if panelIndex then
                adjustMonsterBarDirectly(selectedMonsterGUID, 1, amount)
                syncMonsterValuesToUI(selectedMonsterGUID, panelIndex)
            end
        end
    end
end

function adjustMonsterBarDirectly(guid, barIndex, amount)
    local obj = getObjectFromGUID(guid)
    if not obj then return end

    local success, errorMessage = pcall(function()
        obj.call("adjustBar", { index = barIndex, amount = amount })
    end)

    if success then
        local panelIndex = monsterToPanelMap[guid]
        if panelIndex then
            syncMonsterValuesToUI(guid, panelIndex)
        end
    end
end

function syncMonsterValuesToUI(guid, panelIndex)
    local obj = getObjectFromGUID(guid)
    if not obj then return end

    local success, bars = pcall(function()
        return obj.call("getBars", {})
    end)

    if success and bars and bars[1] then
        if bars[1].current and bars[1].maximum then
            local healthText = bars[1].current .. "/" .. bars[1].maximum
            -- Update Panel-Anzeige
            self.UI.setAttribute("monster_text_2_" .. panelIndex, "text", healthText)
            
            -- Update Root-Panel wenn es das selektierte Monster ist
            if guid == selectedMonsterGUID then
                self.UI.setAttribute("selected_monster_health", "text", healthText)
            end
        end
    end
end

-- Neue Funktion für den Monster-Angriffs, defense button etc.
function MonsterAttackButton(player)
    if selectedMonsterGUID then
        local monsterObj = getObjectFromGUID(selectedMonsterGUID)
        if monsterObj then
            local fullName = monsterObj.getName()
            local monsterName = fullName:gsub("%s+%d+$", "")
            local description = monsterObj.getDescription()
            
            -- Bestimme Akt aus Beschreibung
            local aktTable = _G.Monsterklassen.Akt1  -- Standard: Akt 1
            local aktNum = "1"
            
            if description:match("Akt 2") then
                aktTable = _G.Monsterklassen.Akt2
                aktNum = "2"
            end
            
            -- Suche in entsprechender Monsterklassen-Tabelle
            local monsterFound = false
            
            for id, monsterData in pairs(aktTable) do
                if monsterData[1] == monsterName then
                    monsterFound = true
                    
                    -- Würfelkonfiguration erstellen
                    local attackDice = {
                        Red = monsterData[4],
                        Blue = monsterData[5],
                        Yellow = monsterData[6],
                        Green = monsterData[7]
                    }
                    
                    -- In dicesToThrow für "White" (DM) speichern
                    if not dicesToThrow["White"] then
                        dicesToThrow["White"] = {}
                    end
                    
                    -- Werte übertragen
                    dicesToThrow["White"].Red = attackDice.Red
                    dicesToThrow["White"].Blue = attackDice.Blue
                    dicesToThrow["White"].Yellow = attackDice.Yellow
                    dicesToThrow["White"].Green = attackDice.Green
                    
                    -- Debug Ausgabe mit Akt-Information
                    printToAll("Angriff von " .. monsterName .. " (Akt " .. aktNum .. ") gewürfelt", {0,1,0})
                    
                    -- Angriffswurf auslösen
                    angriff(Player["White"], nil, nil)
                    return
                end
            end
            
            -- Monster nicht gefunden
            if not monsterFound then
                printToAll("Warnung: Keine Würfelkonfiguration für " .. monsterName .. " in Akt " .. aktNum .. " gefunden", {1,0,0})
            end
        else
            printToAll("Fehler: Ausgewähltes Monster-Objekt nicht gefunden", {1,0,0})
        end
    else
        printToAll("Bitte wähle zuerst ein Monster aus", {1,1,0})
    end
end

function MonsterDefendButton(player)
    if selectedMonsterGUID then
        local monsterObj = getObjectFromGUID(selectedMonsterGUID)
        if monsterObj then
            local fullName = monsterObj.getName()
            local monsterName = fullName:gsub("%s+%d+$", "")
            
            -- Suche in Monsterklassen
            for id, monsterData in pairs(_G.Monsterklassen.Akt1) do
                if monsterData[1] == monsterName then
                    -- Würfelkonfiguration erstellen
                    local defendDice = {
                        Grey = monsterData[8],    -- Position 8: Grau
                        Black = monsterData[9],   -- Position 9: Schwarz
                        Brown = monsterData[10]   -- Position 10: Braun
                    }
                    
                    -- In dicesToThrow für "White" (DM) speichern
                    if not dicesToThrow["White"] then
                        dicesToThrow["White"] = {}
                    end
                    
                    -- Werte übertragen
                    dicesToThrow["White"].Grey = defendDice.Grey
                    dicesToThrow["White"].Black = defendDice.Black
                    dicesToThrow["White"].Brown = defendDice.Brown
                    
                    -- Debug Ausgabe
                    printToAll("Verteidigung von " .. monsterName .. " gewürfelt:")
                    
                    -- Verteidigungswurf auslösen
                    abwehr(Player["White"], nil, nil)
                    return
                end
            end
        end
    end
end

function toggleDicePanel(player)
    local panel = self.UI.getAttribute("dice_small_root", "active")
    -- String zu Boolean konvertieren und umkehren
    local newState = panel ~= "true"  -- Wichtig: Vergleich mit String "true"

    self.UI.setAttribute("dice_small_root", "active", tostring(newState))
end