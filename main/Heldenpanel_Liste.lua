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
                UI.setAttribute("name_" .. i, "text", "" .. playerData.name)
                UI.setAttribute("description_" .. i, "text", " " .. playerData.description)
            end
        end



-- Spielerliste erstellen und die Spielereinzelpanels vorbereitet



     -- Heldenpanelliste  einlenden

                    -- Status der Sichtbarkeit der Übersichtsliste

                    function toggleFarbpanel(player, value, id)
                        isFarbpanelVisible = not isFarbpanelVisible -- Status umkehren
                        if isFarbpanelVisible then
                            UI.show("Farbpanel_main")
                            --print("Farbpanel wird angezeigt.")
                        else
                            UI.hide("Farbpanel_main")
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
                    
                    --updateMarkerImages()
                    print("Liste und Panels wurden aktualisiert.")
                end

--   ==> Übergabe an Heldenpanel


