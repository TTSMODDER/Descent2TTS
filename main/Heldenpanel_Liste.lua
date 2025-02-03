require("/main/Heldenpanel")    

-- ONLOAD
    function Heldenliste_onlaod()
    local Panelvariiablen = require("Librarys.Heldenpanel_Variabeln")   

    -- Initiale Sichtbarkeit setzen
    for _, panelId in ipairs(panelIds) do
        UI.setAttribute(panelId, "visibility", "Black,White,Yellow,Red,Blue,Green")
        end

        extractMinisGUIDs()   
        updateNameAndDescription()
        updateListAndPanels()
        createDynamicTable()
        
        local allMarkers = getAllMarkersFromJSON()
        updateMarkerImages(allMarkers)

    end

-- Miniaturen GUID ID aus Helden Panel tracker auslesen


        -- Funktion zur Ermittlung der Miniaturen-GUIDs  die gerade im TTS Modul  angemeldet sind
        function extractMinisGUIDs()
            print("Ermitteln der betroffenen Figuren gestartet...")

            local dataObject = getObjectFromGUID(dataContainerGUID)
            if not dataObject then
                print("Fehler:  nicht gefunden.")
                return
            end

            -- JSON-Daten abrufen
            local rawJson = dataObject.getJSON()
            if not rawJson or not rawJson:find('"LuaScriptState":') then
                --print("Fehler: JSON-Daten oder LuaScriptState nicht verfügbar.")
                return
            end

            -- JSON-Daten dekodieren
            local success, data = pcall(function() return JSON.decode(rawJson) end)
            if not success or not data or not data.LuaScriptState then
                --print("Fehler: LuaScriptState konnte nicht dekodiert werden.")
                return
            end

            -- LuaScriptState erneut dekodieren
            local luaScriptStateSuccess, luaData = pcall(function() return JSON.decode(data.LuaScriptState) end)
            if not luaScriptStateSuccess or not luaData then
                --print("Fehler: LuaScriptState konnte nicht gelesen werden.")
                return
            end

            -- GUIDs der Miniaturen ermitteln
            if luaData.minis then
                targetGUIDs = luaData.minis  -- Array von GUIDs als Strings
                --print("Betroffene Figuren-GUIDs:")
                for _, guid in ipairs(targetGUIDs) do
                    --print("- " .. guid)
                end

                -- GUIDs in die `listData`-Tabelle übertragen
                for i = 1, #listData do
                    listData[i].guid = targetGUIDs[i] or "" -- Falls weniger GUIDs vorhanden sind, bleibt es leer
                end

            else
                --print("Keine Miniaturen-GUIDs gefunden.")
                targetGUIDs = {} -- Leere Liste sicherstellen
            end

            -- Aktualisiere die Liste in der UI
            updateListData()
        end


                    -- Debugging-Funktion zum Überprüfen der GUID-Formate
                    function checkGUIDFormat()
                        for i, guid in ipairs(targetGUIDs) do
                        
                        end
                        
                        -- FIGURE_GUIDS Format
        
                        for i, guid in ipairs(FIGURE_GUIDS) do
            
                        end
                    end

-- Miniaturen-Inhalte auslesen

    -- Aktualisierung von "Name" und "Beschreibung"   der minis  basierend auf GUIDs
        function updateNameAndDescription()
            for i, playerData in ipairs(listData) do
                -- Zuerst alle Werte auf Standardwerte zurücksetzen
                playerData.name = "leer"
                playerData.description = "leer"
                playerData.health = "00/00"
                playerData.exhaustion = "00/00"

                local guid = playerData.guid
                if guid and guid ~= "" then
                    local obj = getObjectFromGUID(guid)
                    if obj then
                        -- Name und Beschreibung aktualisieren
                        playerData.name = obj.getName() or "Unbenannt"
                        playerData.description = obj.getDescription() or "Keine Beschreibung"

                        -- JSON-Werte auslesen
                        local bars = getBarsFromJSON(guid)
                        if bars and #bars >= 2 then
                            local healthBar = bars[1]
                            playerData.health = healthBar[3] .. "/" .. healthBar[4]

                            local exhaustionBar = bars[2]
                            playerData.exhaustion = exhaustionBar[3] .. "/" .. exhaustionBar[4]
                        end
                    end
                end

                -- UI immer aktualisieren, unabhängig ob Objekt gefunden wurde oder nicht
                UI.setAttribute("name_" .. i, "text", "Name: " .. playerData.name)
                UI.setAttribute("description_" .. i, "text", "Bezeichnung: " .. playerData.description)
            end
        end






-- Spielerliste erstellen und die Spielereinzelpanels vorbereitet
        function createDynamicTable()
            -- Bestehende XML abrufen und als Tabelle interpretieren
            local xmlTable = UI.getXmlTable()

            -- Überprüfen, ob das Panel existiert, und es entfernen
            for i, element in ipairs(xmlTable) do
                if element.attributes and element.attributes.id == "Farbpanel_main" then
                    table.remove(xmlTable, i)
                    --print("Bestehendes Farbpanel entfernt.")
                    break
                end
            end

            -- Aktuelle Spielerfarben abrufen
            activeColors = getSeatedPlayers()

            -- Optionen für Dropdown-Menü
            local dropdownOptions = '<option value="none">Keine</option><option value="all">Alle</option>'
            for _, color in ipairs(activeColors) do
                dropdownOptions = dropdownOptions .. '<option value="' .. color .. '">' .. color .. '</option>'
            end


            -- Funktion zur Verarbeitung der Dropdown-Auswahl
            function onDropdownChange(player, value, id)
                --print("Dropdown " .. id .. " geändert auf: " .. value)
            end

            -- Tabelle dynamisch erstellen
            local tableContent = ""

            for i, playerData in ipairs(listData) do
                tableContent = tableContent .. [[
                    <Row>
                        <!-- Spalte 1: Spielername -->
                        
                        <Cell><Text text="]] .. playerData.guid .. [[" /></Cell>
                        <Cell><Text text="]] .. playerData.name .. [[" /></Cell>
                        <Cell><Text text="]] .. playerData.description .. [[" /></Cell>

                        <!-- Spalte 3: Dropdown-Menü -->
        <Cell>
            <Dropdown id="dropdown_]] .. i .. [[" onValueChanged="updatePanelVisibility">
                <option value="Keine">Keine</option>
                <option value="Alle">Alle</option>
                <option value="Red">Rot</option>
                <option value="Yellow">Gelb</option>
                <option value="Blue">Blau</option>
                <option value="Green">Grün</option>
                <option value="GM">GM</option>
            </Dropdown>
        </Cell>
                    </Row>
                ]]
            end

            local newPanel = {
                tag = "Panel",
                attributes = {
                    id = "Farbpanel_main",
                    width = "410",
                    height = "260",
                    position = "-300 300",
                    color = "#00000000",
                    rectAlignment = "MiddleCenter",
                    allowDragging = "true",
                    returntooriginalpositionwhenreleased = "false",
                    visibility = "Black|White", -- Sichtbarkeit für GM only
                },
                children = {
                    {
                        tag = "Button",
                        attributes = {
                            id = "myButton",
                            rectAlignment = "MiddleLeft",
                            width = "150", 
                            height = "40",
                            color="#9999FF",
                            position = "-650 100  ",
                            onClick = "toggleFarbpanel",
                            tooltip = "Helden-Panels für alle aktiven Spieler einblenden (GM -Funktion!)\nZunächst die jeweiligen aktiven Helden Figuren im „Helden-Panel Tracker“ registrieren (liegt unten rechts neben den Spielerkarten): \nHelden Figuren einzeln nacheinander in die Mitte dieses Treckers stellen  und „Track mini“ wählen\nFigur erscheint in der Liste des Trackers, aber auch  in der Liste  hier im Heldenpanel \nDort nun die  registrierten Figuren dem jeweiligen Spieler zuordnen.",
                        },
                        children = {
                            {
                                tag = "Text",
                                attributes = {
                                    alignment = "MiddleCenter",
                                    color="#FFFFFF",
                                    text = "Helden-Panels",
                                },
                            },
                        },
                    },
                    {
                        tag = "Panel",
                        attributes = {
                            id = "Farbpanel",
                            width = "400",
                            height = "150",
                            position = "0 0 ",
                            color = "White",
                            --padding = "10",
                        },
                        children = {
                            {
                                tag = "TableLayout",
                                attributes = {
                                    id = "Spielerliste",
                                    columnWidths = "100,70,100",
                                },
                                value = tableContent,
                            },
                            {
                                tag = "Panel",
                                attributes = {
                                    id = "AdditionalButtonPanel",
                                    width = "10",
                                    height = "10",
                                    position = "120 0 0",
                                    
                                    rectAlignment = "MiddleCenter",
                                },
                                children = {
                                    {
                                        tag = "Button",
                                        attributes = {
                                            id = "extraButton",
                                            rectAlignment = "MiddleCenter",
                                            width = "100",
                                            height = "40",
                                            position = "30 -100 0",
                                            color="#9999FF",
                                            --onClick="updateListAndPanels",
                                            onClick="onLoad()",
                                        },
                                        children = {
                                            {
                                                tag = "Text",
                                                attributes = {
                                                    alignment = "MiddleCenter",
                                                    color="#FFFFFF",
                                                    text = "aktualisieren",
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            }
            


    -- Neues Panel zur XML-Tabelle hinzufügen
            table.insert(xmlTable, newPanel)

            -- Aktualisierte XML-Tabelle setzen
            UI.setXmlTable(xmlTable)
            --print("Dynamische Tabelle mit Buttons wurde erstellt und sollte sichtbar sein.")
        end


     -- Heldenpanelliste  einlenden

                    -- Status der Sichtbarkeit der Übersichtsliste

                    function toggleFarbpanel(player, value, id)
                        isFarbpanelVisible = not isFarbpanelVisible -- Status umkehren
                        if isFarbpanelVisible then
                            UI.show("Farbpanel")
                            --print("Farbpanel wird angezeigt.")
                        else
                            UI.hide("Farbpanel")
                            --print("Farbpanel wird versteckt.")
                        end
                    end

     -- aktualisieren

        function updateListData()
            for i, playerData in ipairs(listData) do
                UI.setAttribute("guid_" .. i, "text", playerData.guid)
                UI.setAttribute("name_" .. i, "text", playerData.name)
                UI.setAttribute("description_" .. i, "text", playerData.description)
                UI.setAttribute("health_" .. i, "text", playerData.health)
                UI.setAttribute("exhaustion_" .. i, "text", playerData.exhaustion)
                UI.setAttribute("marker_" .. i, "text", playerData.marker)
            end
        end



            function updateListAndPanels()
                    extractMinisGUIDs()
                    updateNameAndDescription()
                    updatePlayerPanels()-- auf helden panel lua
                    createDynamicTable()
                    --updateMarkerImages()
                    print("Liste und Panels wurden aktualisiert.")
                end

--   ==> Übergabe an Heldenpanel
