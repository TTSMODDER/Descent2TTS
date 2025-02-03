
require("/main/Heldenpanel_Liste")  

-- Hinweis :die erstellung der Spilerpanel basiert auf der Liste : "Heldenliste"

--ONLOAD Bereich
    function initHeldenpanel()
        Heldenliste_onlaod()
    end

-- Sichtbarkeit 
    function updatePanelVisibility(_, selectedOption, id)


        -- Extrahiere die Zeilen-ID aus der Dropdown-ID (z. B. "dropdown_1" → 1)
        local rowIndex = tonumber(id:match("dropdown_(%d+)"))
        if not rowIndex then
        
            return
        end

        -- Panel-ID basierend auf der Zeilennummer bestimmen
        local panelId = "Parent_PlayerPanel_" .. rowIndex
      

        -- Spielerfarben aus der Auswahl holen
        local visibilityColors = visibilityOptions and visibilityOptions[selectedOption]
        if not visibilityColors then
        
            return
        end

        -- Dynamisches Hinzufügen der Sichtbarkeitseigenschaft
        UI.setAttribute(panelId, "visibility", visibilityColors)
    
    end



-- I. Bars &buttons

        function updatePlayerPanels()
            --print("Aktualisiere Spielerpanels...")
            for i, playerData in ipairs(listData) do
                -- Zuerst die UI-Elemente aktualisieren
                UI.setAttribute("name_" .. i .. "_panel", "text", " " .. (playerData.name or ""))
                UI.setAttribute("description_" .. i .. "_panel", "text", " " .. (playerData.description or ""))
                UI.setAttribute("health_" .. i .. "_panel", "text", " " .. (playerData.health or "0 / 0"))
                UI.setAttribute("exhaustion_" .. i .. "_panel", "text", " " .. (playerData.exhaustion or "0 / 0"))
                
                -- Dann die Button-Funktionen definieren
                local currentGuid = playerData.guid
                local currentIndex = i
                
                _G["adjustHealthUp_" .. i] = function(player)
                    adjustMiniBarDirectly(currentGuid, 1, 1)
                    syncValuesToUIFromMini(currentGuid, currentIndex)
                end

                _G["adjustHealthDown_" .. i] = function(player)
                    adjustMiniBarDirectly(currentGuid, 1, -1)
                    syncValuesToUIFromMini(currentGuid, currentIndex)
                end

                _G["adjustExhaustionUp_" .. i] = function(player)
                    adjustMiniBarDirectly(currentGuid, 2, 1)
                    syncValuesToUIFromMini(currentGuid, currentIndex)
                end

                _G["adjustExhaustionDown_" .. i] = function(player)
                    adjustMiniBarDirectly(currentGuid, 2, -1)
                    syncValuesToUIFromMini(currentGuid, currentIndex)
                end
            end
        end
        

        function adjustMiniBarDirectly(guid, barIndex, amount)
            local obj = getObjectFromGUID(guid)
            if not obj then
                print("Fehler: Objekt mit GUID " .. guid .. " nicht gefunden.")
                return
            end

            -- Direkter Aufruf von adjustBar auf der Miniatur
            local success, errorMessage = pcall(function()
                obj.call("adjustBar", { index = barIndex, amount = amount })
            end)

            if success then
                --print("Bar " .. barIndex .. " von GUID " .. guid .. " erfolgreich angepasst.")
                -- Finde den korrekten playerIndex basierend auf der GUID
                local playerIndex
                for i, data in ipairs(listData) do
                    if data.guid == guid then
                        playerIndex = i
                        break
                    end
                end
                syncValuesToUIFromMini(guid, playerIndex) -- Korrigiert: Verwende playerIndex statt barIndex
            else
                print("Fehler beim Anpassen der Bar von GUID " .. guid .. ": " .. (errorMessage or "Unbekannter Fehler"))
            end
        end


        function syncValuesToUIFromMini(guid, playerIndex)
            local obj = getObjectFromGUID(guid)
            if not obj then
                print("Fehler: Objekt mit GUID " .. guid .. " nicht gefunden.")
                return
            end

            -- Rufe die Funktion getBarse auf der Miniatur auf
            local success, bars = pcall(function()
                return obj.call("getBars", {})
            end)

            if not success or not bars or #bars < 2 then
                print("Warnung: Balkendaten konnten nicht abgerufen werden für GUID " .. guid)
                UI.setAttribute("health_" .. playerIndex .. "_panel", "text", " 0 / 0")
                UI.setAttribute("exhaustion_" .. playerIndex .. "_panel", "text", " 0 / 0")
                return
            end

            -- Leben aktualisieren
            local healthBar = bars[1]
            local healthText = healthBar.current .. "/" .. healthBar.maximum
            UI.setAttribute("health_" .. playerIndex .. "_panel", "text", " " .. healthText)

            -- Erschöpfung aktualisieren
            local exhaustionBar = bars[2]
            local exhaustionText = exhaustionBar.current .. "/" .. exhaustionBar.maximum
            UI.setAttribute("exhaustion_" .. playerIndex .. "_panel", "text", " " .. exhaustionText)
        end

        function getBarsFromJSON(guid)
            local obj = getObjectFromGUID(guid)
            if not obj then
                print("Fehler: Objekt mit GUID " .. guid .. " nicht gefunden.")
                return nil
            end

            local rawJson = obj.getJSON()
            if not rawJson or not rawJson:find('"LuaScriptState":') then
                print("Fehler: JSON-Daten oder LuaScriptState nicht verfügbar für " .. guid)
                return nil
            end

            local success, jsonData = pcall(function() return JSON.decode(rawJson) end)
            if not success or not jsonData then
                print("Fehler: JSON-Daten konnten nicht dekodiert werden für " .. guid)
                return nil
            end

            local luaScriptState = jsonData.LuaScriptState
            if not luaScriptState then
                print("LuaScriptState nicht gefunden für " .. guid)
                return nil
            end

            local successLua, barsData = pcall(function() return JSON.decode(luaScriptState) end)
            if not successLua or not barsData or not barsData.bars then
                print("Fehler: Balkendaten konnten nicht ausgelesen werden für " .. guid)
                return nil
            end

            return barsData.bars
        end




-- II Markeranzeige 


    -- Funktion: JSON-Daten aller Figuren auslesen
    function getAllMarkersFromJSON()
        local allMarkers = {}
        for i, playerData in ipairs(listData) do
            local guid = playerData.guid
            if guid and guid ~= "" then
                local obj = getObjectFromGUID(guid)
                if obj then
                    local jsonData = obj.getJSON()
                    if jsonData and jsonData ~= "" then
                        local success, data = pcall(function() return JSON.decode(jsonData) end)
                        if success and data and data.LuaScriptState then
                            local successState, state = pcall(function() return JSON.decode(data.LuaScriptState) end)
                            if successState and state and state.markers then
                                table.insert(allMarkers, {guid = guid, markers = state.markers})
                            else
                                table.insert(allMarkers, {guid = guid, markers = {}})
                            end
                        else
                            table.insert(allMarkers, {guid = guid, markers = {}})
                        end
                    else
                        table.insert(allMarkers, {guid = guid, markers = {}})
                    end
                else
                    table.insert(allMarkers, {guid = guid, markers = {}})
                end
            else
                table.insert(allMarkers, {guid = guid, markers = {}})
            end
        end
        return allMarkers
    end


    -- Marker löschen
        function removeMarker(player, button, id)
            local row, col = id:match("button2_(%d+)_(%d+)")
            
            if not row or not col then
                print("[Debug Global] Fehler: Ungültiges Button-ID Format:", id)
                return
            end
            
            -- GUID aus listData holen statt aus FIGURE_GUIDS
            local guid = listData[tonumber(row)].guid
            if not guid or guid == "" then
                print("[Debug Global] Fehler: Keine GUID für Reihe", row)
                return
            end
            
            -- Bild sofort entfernen
            local imageId = string.format("image_%s_%s", row, col)
            UI.setAttribute(imageId, "image", "")
            
            --print("[Debug Global] removeMarker Start - GUID:", guid, "Index:", col)
            local obj = getObjectFromGUID(guid)
            if obj then
                --print("[Debug Global] Objekt gefunden, rufe Figur-Funktion auf")
                obj.call("removeMarker", {index = tonumber(col)})
                --print("[Debug Global] Figur-Funktion aufgerufen")
                
                -- Nach 2 Sekunden Update durchführen
                Wait.time(function()
                    local allMarkers = getAllMarkersFromJSON()
                    --updateMarkerImages(allMarkers)
                    --print("[Debug Global] Update nach Entfernen durchgeführt")
                    updateMarkerImages(allMarkers)
                end, 8)
            else
                --print("[Debug Global] FEHLER: Objekt nicht gefunden für GUID:", guid)
            end
        end

    -- Funktion zum Aktualisieren der UI mit Debug-Output
        function updateMarkerImages(allMarkers)

            for i, markerSet in ipairs(allMarkers) do
                --print(string.format("[Debug] GUID %s:", markerSet.guid))
                for j = 1, 5 do
                    local imageId = string.format("image_%d_%d", i, j)
                    if j <= #markerSet.markers then
                        local marker = markerSet.markers[j]
                        local url = marker[2] or placeholderUrl
                        --print(string.format("  - Marker %d: URL = %s", j, url))
                        UI.setAttribute(imageId, "image", url)
                    else
                        --print(string.format("  - Marker %d: leer, setze Platzhalter", j))
                        UI.setAttribute(imageId, "image", placeholderUrl)
                        UI.setAttribute(imageId, "color", "#FFFFFF88") -- Halbtransparent
                    end
                end
            end

        end



    function updateMarkerPanel()
    local allMarkers = getAllMarkersFromJSON()
    for i = 1, 4 do
        local markerData = allMarkers[i]
        if markerData and #markerData.markers > 0 then
            local markers = markerData.markers
            for j = 1, 5 do
                local markerId = "marker_" .. i .. "_" .. j
                if j <= #markers then
                    local marker = markers[j]
                    UI.setAttribute(markerId, "image", marker)
                else
                    UI.setAttribute(markerId, "image", placeholderUrl)
                end
            end
        else
            for j = 1, 5 do
                local markerId = "marker_" .. i .. "_" .. j
                UI.setAttribute(markerId, "image", placeholderUrl)
            end
        end
    end
    end

                 -- MArkerpanel manuell aktualisieren
                 function updateOnlyMarkerPanels()
                    local allMarkers = getAllMarkersFromJSON()
                    updateMarkerImages(allMarkers)
                    print("Marker-Panels wurden aktualisiert.")
                end




-- III. Dice Panel


                        -- Dicepanel spieler_1
            counter_1_1 = 0
            counter_2_1 = 0
            counter_3_1 = 0
            counter_4_1 = 0
            counter_5_1 = 0
            counter_6_1 = 0
            counter_7_1 = 0
        
        Dice_value_1_1 = 0
        Dice_value_2_1 = 0
        Dice_value_3_1 = 0
        Dice_value_4_1 = 0
        Dice_value_5_1 = 0
        Dice_value_6_1 = 0
        Dice_value_7_1 = 0

        -- Dicepanel spieler_2
        counter_1_2 = 0
        counter_2_2 = 0
        counter_3_2 = 0
        counter_4_2 = 0
        counter_5_2 = 0
        counter_6_2 = 0
        counter_7_2 = 0

        Dice_value_1_2 = 0
        Dice_value_2_2 = 0
        Dice_value_3_2 = 0
        Dice_value_4_2 = 0
        Dice_value_5_2 = 0
        Dice_value_6_2 = 0
        Dice_value_7_2 = 0

        -- Dicepanel spieler_3
        counter_1_3 = 0
        counter_2_3 = 0
        counter_3_3 = 0
        counter_4_3 = 0
        counter_5_3 = 0
        counter_6_3 = 0
        counter_7_3 = 0

        Dice_value_1_3 = 0
        Dice_value_2_3 = 0
        Dice_value_3_3 = 0
        Dice_value_4_3 = 0
        Dice_value_5_3 = 0
        Dice_value_6_3 = 0
        Dice_value_7_3 = 0

        -- Dicepanel spieler_4
        counter_1_4 = 0
        counter_2_4 = 0
        counter_3_4 = 0
        counter_4_4 = 0
        counter_5_4 = 0
        counter_6_4 = 0
        counter_7_4 = 0

        Dice_value_1_4 = 0
        Dice_value_2_4 = 0
        Dice_value_3_4 = 0
        Dice_value_4_4 = 0
        Dice_value_5_4 = 0
        Dice_value_6_4 = 0
        Dice_value_7_4 = 0

        -- Dicepanel spieler_5
        counter_1_5 = 0
        counter_2_5 = 0
        counter_3_5 = 0
        counter_4_5 = 0
        counter_5_5 = 0
        counter_6_5 = 0
        counter_7_5 = 0

        Dice_value_1_5 = 0
        Dice_value_2_5 = 0
        Dice_value_3_5 = 0
        Dice_value_4_5 = 0
        Dice_value_5_5 = 0
        Dice_value_6_5 = 0
        Dice_value_7_5 = 0

        -- Dicepanel spieler_6
        counter_1_6 = 0
        counter_2_6 = 0
        counter_3_6 = 0
        counter_4_6 = 0
        counter_5_6 = 0
        counter_6_6 = 0
        counter_7_6 = 0

        Dice_value_1_6 = 0
        Dice_value_2_6 = 0
        Dice_value_3_6 = 0
        Dice_value_4_6 = 0
        Dice_value_5_6 = 0
        Dice_value_6_6 = 0
        Dice_value_7_6 = 0

        -- Dicepanel spieler_7
        counter_1_7 = 0
        counter_2_7 = 0
        counter_3_7 = 0
        counter_4_7 = 0
        counter_5_7 = 0
        counter_6_7 = 0
        counter_7_7 = 0

        Dice_value_1_7 = 0
        Dice_value_2_7 = 0
        Dice_value_3_7 = 0
        Dice_value_4_7 = 0
        Dice_value_5_7 = 0
        Dice_value_6_7 = 0
        Dice_value_7_7 = 0

     --DICE Pannel Spieler _1
        
            function decreaseCounter_1_1()
                if counter > 0 then
                    counter = counter - 1
                    UI.setValue("counterText_1_1", tostring(counter))
                    Dice_value_1_1 = counter  -- Wert speichern
                end
            end

            function decreaseCounter_1_1()
                if counter_1_1 > 0 then
                    counter_1_1 = counter_1_1 - 1
                    UI.setValue("counterText_1_1", tostring(counter_1_1))
                    Dice_value_1_1 = counter_1_1  -- Wert speichern
                end
            end
            
            function increaseCounter_1_1()
                if counter_1_1 < 6 then
                    counter_1_1 = counter_1_1 + 1
                    UI.setValue("counterText_1_1", tostring(counter_1_1))
                    Dice_value_1_1 = counter_1_1  -- Wert speichern
                end
            end
            
            function decreaseCounter_2_1()
                if counter_2_1 > 0 then
                    counter_2_1 = counter_2_1 - 1
                    UI.setValue("counterText_2_1", tostring(counter_2_1))
                    Dice_value_2_1 = counter_2_1  -- Wert speichern
                end
            end
            
            function increaseCounter_2_1()
                if counter_2_1 < 6 then
                    counter_2_1 = counter_2_1 + 1
                    UI.setValue("counterText_2_1", tostring(counter_2_1))
                    Dice_value_2_1 = counter_2_1  -- Wert speichern
                end
            end
            
            function decreaseCounter_3_1()
                if counter_3_1 > 0 then
                    counter_3_1 = counter_3_1 - 1
                    UI.setValue("counterText_3_1", tostring(counter_3_1))
                    Dice_value_3_1 = counter_3_1  -- Wert speichern
                end
            end
            
            function increaseCounter_3_1()
                if counter_3_1 < 6 then
                    counter_3_1 = counter_3_1 + 1
                    UI.setValue("counterText_3_1", tostring(counter_3_1))
                    Dice_value_3_1 = counter_3_1  -- Wert speichern
                end
            end
            
            function decreaseCounter_4_1()
                if counter_4_1 > 0 then
                    counter_4_1 = counter_4_1 - 1
                    UI.setValue("counterText_4_1", tostring(counter_4_1))
                    Dice_value_4_1 = counter_4_1  -- Wert speichern
                end
            end
            
            function increaseCounter_4_1()
                if counter_4_1 < 6 then
                    counter_4_1 = counter_4_1 + 1
                    UI.setValue("counterText_4_1", tostring(counter_4_1))
                    Dice_value_4_1 = counter_4_1  -- Wert speichern
                end
            end
            
            function decreaseCounter_5_1()
                if counter_5_1 > 0 then
                    counter_5_1 = counter_5_1 - 1
                    UI.setValue("counterText_5_1", tostring(counter_5_1))
                    Dice_value_5_1 = counter_5_1  -- Wert speichern
                end
            end
            
            function increaseCounter_5_1()
                if counter_5_1 < 6 then
                    counter_5_1 = counter_5_1 + 1
                    UI.setValue("counterText_5_1", tostring(counter_5_1))
                    Dice_value_5_1 = counter_5_1  -- Wert speichern
                end
            end
            
            function decreaseCounter_6_1()
                if counter_6_1 > 0 then
                    counter_6_1 = counter_6_1 - 1
                    UI.setValue("counterText_6_1", tostring(counter_6_1))
                    Dice_value_6_1 = counter_6_1  -- Wert speichern
                end
            end
            
            function increaseCounter_6_1()
                if counter_6_1 < 6 then
                    counter_6_1 = counter_6_1 + 1
                    UI.setValue("counterText_6_1", tostring(counter_6_1))
                    Dice_value_6_1 = counter_6_1  -- Wert speichern
                end
            end
            
            function decreaseCounter_7_1()
                if counter_7_1 > 0 then
                    counter_7_1 = counter_7_1 - 1
                    UI.setValue("counterText_7_1", tostring(counter_7_1))
                    Dice_value_7_1 = counter_7_1  -- Wert speichern
                end
            end
            
            function increaseCounter_7_1()
                if counter_7_1 < 6 then
                    counter_7_1 = counter_7_1 + 1
                    UI.setValue("counterText_7_1", tostring(counter_7_1))
                    Dice_value_7_1 = counter_7_1  -- Wert speichern
                end
            end

        --toggeln von diceboard spieler_1
        function showDiceboard_1()
            local currentVisibility = UI.getAttribute("diceboard_1", "visibility")
            if currentVisibility == "hidden" then
                UI.setAttribute("diceboard_1", "visibility", "")
            else
                UI.setAttribute("diceboard_1", "visibility", "hidden")
            end
        end

   

     --DICE Pannel Spieler _2

        function decreaseCounter_1_2()
            if counter_1_2 > 0 then
                counter_1_2 = counter_1_2 - 1
                UI.setValue("counterText_1_2", tostring(counter_1_2))
                Dice_value_1_2 = counter_1_2  -- Wert speichern
            end
        end

        function increaseCounter_1_2()
            if counter_1_2 < 6 then
                counter_1_2 = counter_1_2 + 1
                UI.setValue("counterText_1_2", tostring(counter_1_2))
                Dice_value_1_2 = counter_1_2  -- Wert speichern
            end
        end

        function decreaseCounter_2_2()
            if counter_2_2 > 0 then
                counter_2_2 = counter_2_2 - 1
                UI.setValue("counterText_2_2", tostring(counter_2_2))
                Dice_value_2_2 = counter_2_2  -- Wert speichern
            end
        end

        function increaseCounter_2_2()
            if counter_2_2 < 6 then
                counter_2_2 = counter_2_2 + 1
                UI.setValue("counterText_2_2", tostring(counter_2_2))
                Dice_value_2_2 = counter_2_2  -- Wert speichern
            end
        end

        function decreaseCounter_3_2()
            if counter_3_2 > 0 then
                counter_3_2 = counter_3_2 - 1
                UI.setValue("counterText_3_2", tostring(counter_3_2))
                Dice_value_3_2 = counter_3_2  -- Wert speichern
            end
        end

        function increaseCounter_3_2()
            if counter_3_2 < 6 then
                counter_3_2 = counter_3_2 + 1
                UI.setValue("counterText_3_2", tostring(counter_3_2))
                Dice_value_3_2 = counter_3_2  -- Wert speichern
            end
        end

        function decreaseCounter_4_2()
            if counter_4_2 > 0 then
                counter_4_2 = counter_4_2 - 1
                UI.setValue("counterText_4_2", tostring(counter_4_2))
                Dice_value_4_2 = counter_4_2  -- Wert speichern
            end
        end

        function increaseCounter_4_2()
            if counter_4_2 < 6 then
                counter_4_2 = counter_4_2 + 1
                UI.setValue("counterText_4_2", tostring(counter_4_2))
                Dice_value_4_2 = counter_4_2  -- Wert speichern
            end
        end

        function decreaseCounter_5_2()
            if counter_5_2 > 0 then
                counter_5_2 = counter_5_2 - 1
                UI.setValue("counterText_5_2", tostring(counter_5_2))
                Dice_value_5_2 = counter_5_2  -- Wert speichern
            end
        end

        function increaseCounter_5_2()
            if counter_5_2 < 6 then
                counter_5_2 = counter_5_2 + 1
                UI.setValue("counterText_5_2", tostring(counter_5_2))
                Dice_value_5_2 = counter_5_2  -- Wert speichern
            end
        end

        function decreaseCounter_6_2()
            if counter_6_2 > 0 then
                counter_6_2 = counter_6_2 - 1
                UI.setValue("counterText_6_2", tostring(counter_6_2))
                Dice_value_6_2 = counter_6_2  -- Wert speichern
            end
        end

        function increaseCounter_6_2()
            if counter_6_2 < 6 then
                counter_6_2 = counter_6_2 + 1
                UI.setValue("counterText_6_2", tostring(counter_6_2))
                Dice_value_6_2 = counter_6_2  -- Wert speichern
            end
        end

        function decreaseCounter_7_2()
            if counter_7_2 > 0 then
                counter_7_2 = counter_7_2 - 1
                UI.setValue("counterText_7_2", tostring(counter_7_2))
                Dice_value_7_2 = counter_7_2  -- Wert speichern
            end
        end

        function increaseCounter_7_2()
            if counter_7_2 < 6 then
                counter_7_2 = counter_7_2 + 1
                UI.setValue("counterText_7_2", tostring(counter_7_2))
                Dice_value_7_2 = counter_7_2  -- Wert speichern
            end
        end


                    --diceboard spieler_2
            -- board sichtbarmachen:
        --toggeln von diceboard spieler_
        function showDiceboard_2()
            local currentVisibility = UI.getAttribute("diceboard_2", "visibility")
            if currentVisibility == "hidden" then
                UI.setAttribute("diceboard_2", "visibility", "")
            else
                UI.setAttribute("diceboard_2", "visibility", "hidden")
            end
        end

        --  functions  der Dice innerhalb des Diceboards gelten für alle, daheer sind diese ausserhalb der individuellen panels

     --DICE Pannel Spieler _3

        function decreaseCounter_1_3()
            if counter_1_3 > 0 then
                counter_1_3 = counter_1_3 - 1
                UI.setValue("counterText_1_3", tostring(counter_1_3))
                Dice_value_1_3 = counter_1_3  -- Wert speichern
            end
        end

        function increaseCounter_1_3()
            if counter_1_3 < 6 then
                counter_1_3 = counter_1_3 + 1
                UI.setValue("counterText_1_3", tostring(counter_1_3))
                Dice_value_1_3 = counter_1_3  -- Wert speichern
            end
        end

        function decreaseCounter_2_3()
            if counter_2_3 > 0 then
                counter_2_3 = counter_2_3 - 1
                UI.setValue("counterText_2_3", tostring(counter_2_3))
                Dice_value_2_3 = counter_2_3  -- Wert speichern
            end
        end

        function increaseCounter_2_3()
            if counter_2_3 < 6 then
                counter_2_3 = counter_2_3 + 1
                UI.setValue("counterText_2_3", tostring(counter_2_3))
                Dice_value_2_3 = counter_2_3  -- Wert speichern
            end
        end

        function decreaseCounter_3_3()
            if counter_3_3 > 0 then
                counter_3_3 = counter_3_3 - 1
                UI.setValue("counterText_3_3", tostring(counter_3_3))
                Dice_value_3_3 = counter_3_3  -- Wert speichern
            end
        end

        function increaseCounter_3_3()
            if counter_3_3 < 6 then
                counter_3_3 = counter_3_3 + 1
                UI.setValue("counterText_3_3", tostring(counter_3_3))
                Dice_value_3_3 = counter_3_3  -- Wert speichern
            end
        end

        function decreaseCounter_4_3()
            if counter_4_3 > 0 then
                counter_4_3 = counter_4_3 - 1
                UI.setValue("counterText_4_3", tostring(counter_4_3))
                Dice_value_4_3 = counter_4_3  -- Wert speichern
            end
        end

        function increaseCounter_4_3()
            if counter_4_3 < 6 then
                counter_4_3 = counter_4_3 + 1
                UI.setValue("counterText_4_3", tostring(counter_4_3))
                Dice_value_4_3 = counter_4_3  -- Wert speichern
            end
        end

        function decreaseCounter_5_3()
            if counter_5_3 > 0 then
                counter_5_3 = counter_5_3 - 1
                UI.setValue("counterText_5_3", tostring(counter_5_3))
                Dice_value_5_3 = counter_5_3  -- Wert speichern
            end
        end

        function increaseCounter_5_3()
            if counter_5_3 < 6 then
                counter_5_3 = counter_5_3 + 1
                UI.setValue("counterText_5_3", tostring(counter_5_3))
                Dice_value_5_3 = counter_5_3  -- Wert speichern
            end
        end

        function decreaseCounter_6_3()
            if counter_6_3 > 0 then
                counter_6_3 = counter_6_3 - 1
                UI.setValue("counterText_6_3", tostring(counter_6_3))
                Dice_value_6_3 = counter_6_3  -- Wert speichern
            end
        end

        function increaseCounter_6_3()
            if counter_6_3 < 6 then
                counter_6_3 = counter_6_3 + 1
                UI.setValue("counterText_6_3", tostring(counter_6_3))
                Dice_value_6_3 = counter_6_3  -- Wert speichern
            end
        end

        function decreaseCounter_7_3()
            if counter_7_3 > 0 then
                counter_7_3 = counter_7_3 - 1
                UI.setValue("counterText_7_3", tostring(counter_7_3))
                Dice_value_7_3 = counter_7_3  -- Wert speichern
            end
        end

        function increaseCounter_7_3()
            if counter_7_3 < 6 then
                counter_7_3 = counter_7_3 + 1
                UI.setValue("counterText_7_3", tostring(counter_7_3))
                Dice_value_7_3 = counter_7_3  -- Wert speichern
            end
        end


        --toggeln von diceboard spieler_
        function showDiceboard_3()
            local currentVisibility = UI.getAttribute("diceboard_3", "visibility")
            if currentVisibility == "hidden" then
                UI.setAttribute("diceboard_3", "visibility", "")
            else
                UI.setAttribute("diceboard_3", "visibility", "hidden")
            end
        end


            --  functions  der Dice innerhalb des Diceboards gelten für alle, daheer sind diese ausserhalb der individuellen panels


    --DICE Pannel Spieler _4

        function decreaseCounter_1_4()
            if counter_1_4 > 0 then
                counter_1_4 = counter_1_4 - 1
                UI.setValue("counterText_1_4", tostring(counter_1_4))
                Dice_value_1_4 = counter_1_4  -- Wert speichern
            end
        end

        function increaseCounter_1_4()
            if counter_1_4 < 6 then
                counter_1_4 = counter_1_4 + 1
                UI.setValue("counterText_1_4", tostring(counter_1_4))
                Dice_value_1_4 = counter_1_4  -- Wert speichern
            end
        end

        function decreaseCounter_2_4()
            if counter_2_4 > 0 then
                counter_2_4 = counter_2_4 - 1
                UI.setValue("counterText_2_4", tostring(counter_2_4))
                Dice_value_2_4 = counter_2_4  -- Wert speichern
            end
        end

        function increaseCounter_2_4()
            if counter_2_4 < 6 then
                counter_2_4 = counter_2_4 + 1
                UI.setValue("counterText_2_4", tostring(counter_2_4))
                Dice_value_2_4 = counter_2_4  -- Wert speichern
            end
        end

        function decreaseCounter_3_4()
            if counter_3_4 > 0 then
                counter_3_4 = counter_3_4 - 1
                UI.setValue("counterText_3_4", tostring(counter_3_4))
                Dice_value_3_4 = counter_3_4  -- Wert speichern
            end
        end

        function increaseCounter_3_4()
            if counter_3_4 < 6 then
                counter_3_4 = counter_3_4 + 1
                UI.setValue("counterText_3_4", tostring(counter_3_4))
                Dice_value_3_4 = counter_3_4  -- Wert speichern
            end
        end

        function decreaseCounter_4_4()
            if counter_4_4 > 0 then
                counter_4_4 = counter_4_4 - 1
                UI.setValue("counterText_4_4", tostring(counter_4_4))
                Dice_value_4_4 = counter_4_4  -- Wert speichern
            end
        end

        function increaseCounter_4_4()
            if counter_4_4 < 6 then
                counter_4_4 = counter_4_4 + 1
                UI.setValue("counterText_4_4", tostring(counter_4_4))
                Dice_value_4_4 = counter_4_4  -- Wert speichern
            end
        end

        function decreaseCounter_5_4()
            if counter_5_4 > 0 then
                counter_5_4 = counter_5_4 - 1
                UI.setValue("counterText_5_4", tostring(counter_5_4))
                Dice_value_5_4 = counter_5_4  -- Wert speichern
            end
        end

        function increaseCounter_5_4()
            if counter_5_4 < 6 then
                counter_5_4 = counter_5_4 + 1
                UI.setValue("counterText_5_4", tostring(counter_5_4))
                Dice_value_5_4 = counter_5_4  -- Wert speichern
            end
        end

        function decreaseCounter_6_4()
            if counter_6_4 > 0 then
                counter_6_4 = counter_6_4 - 1
                UI.setValue("counterText_6_4", tostring(counter_6_4))
                Dice_value_6_4 = counter_6_4  -- Wert speichern
            end
        end

        function increaseCounter_6_4()
            if counter_6_4 < 6 then
                counter_6_4 = counter_6_4 + 1
                UI.setValue("counterText_6_4", tostring(counter_6_4))
                Dice_value_6_4 = counter_6_4  -- Wert speichern
            end
        end

        function decreaseCounter_7_4()
            if counter_7_4 > 0 then
                counter_7_4 = counter_7_4 - 1
                UI.setValue("counterText_7_4", tostring(counter_7_4))
                Dice_value_7_4 = counter_7_4  -- Wert speichern
            end
        end

        function increaseCounter_7_4()
            if counter_7_4 < 6 then
                counter_7_4 = counter_7_4 + 1
                UI.setValue("counterText_7_4", tostring(counter_7_4))
                Dice_value_7_4 = counter_7_4  -- Wert speichern
            end
        end


    --toggeln von diceboard spieler_
    function showDiceboard_4()
        local currentVisibility = UI.getAttribute("diceboard_4", "visibility")
        if currentVisibility == "hidden" then
            UI.setAttribute("diceboard_4", "visibility", "")
        else
            UI.setAttribute("diceboard_4", "visibility", "hidden")
        end
    end



     --  functions  der Dice innerhalb des Diceboards gelten für alle, daheer sind diese ausserhalb der individuellen panels

    -- Diceboard funktionen , gelten für alle:
        function showColorRot()
            print("Dice: rot")
        end

        function showColorBlau()
            print("Dice: blau")
        end

        function showColorGelb()
            print("Dice: gelb")
        end

        function showColorGruen()
            print("Dice: grün")
        end

        function showColorHellgrau()
            print("Dice: hellgrau")
        end

        function showColorSchwarz()
            print("Dice: schwarz")
        end

        function showColorBraun()
            print("Dice: braun")
        end




-- VI. Action Panels
    --Action Panels Funktionen für Spieler 1
            function angriff_1()
                local dice_1_1 = Dice_value_1_1
                local dice_2_1 = Dice_value_2_1
                local dice_3_1 = Dice_value_3_1
                local dice_4_1 = Dice_value_4_1
                print("Angriff Spieler 1: Würfelwerte - Dice 1: " .. dice_1_1 .. ", Dice 2: " .. dice_2_1 .. ", Dice 3: " .. dice_3_1 .. ", Dice 4: " .. dice_4_1)
            end

            function abwehr_1()
                local dice_5_1 = Dice_value_5_1
                local dice_6_1 = Dice_value_6_1
                local dice_7_1 = Dice_value_7_1
                print("Abwehr Spieler 1: Würfelwerte - Dice 5: " .. dice_5_1 .. ", Dice 6: " .. dice_6_1 .. ", Dice 7: " .. dice_7_1)
            end

            function probe_1()
                local dice_5_1 = 1
                local dice_6_1 = 1
                print("Probe Spieler 1: Würfelwerte - Dice 5: " .. dice_5_1 .. ", Dice 6: " .. dice_6_1)
            end

            function heilung_1()
                local dice_2_1 = 2
                print("Heilung Spieler 1: Würfelwert - Dice 2: " .. dice_2_1)
            end

    --Action Panels Funktionen für Spieler 2
            function angriff_2()
                local dice_1_2 = Dice_value_1_2
                local dice_2_2 = Dice_value_2_2
                local dice_3_2 = Dice_value_3_2
                local dice_4_2 = Dice_value_4_2
                print("Angriff Spieler 2: Würfelwerte - Dice 1: " .. dice_1_2 .. ", Dice 2: " .. dice_2_2 .. ", Dice 3: " .. dice_3_2 .. ", Dice 4: " .. dice_4_2)
            end

            function abwehr_2()
                local dice_5_2 = Dice_value_5_2
                local dice_6_2 = Dice_value_6_2
                local dice_7_2 = Dice_value_7_2
                print("Abwehr Spieler 2: Würfelwerte - Dice 5: " .. dice_5_2 .. ", Dice 6: " .. dice_6_2 .. ", Dice 7: " .. dice_7_2)
            end

            function probe_2()
                local dice_5_2 = 1
                local dice_6_2 = 1
                print("Probe Spieler 2: Würfelwerte - Dice 5: " .. dice_5_2 .. ", Dice 6: " .. dice_6_2)
            end

            function heilung_2()
                local dice_2_2 = 2
                print("Heilung Spieler 2: Würfelwert - Dice 2: " .. dice_2_2)
            end

    --Action Panels Funktionen für Spieler 3
            function angriff_3()
                local dice_1_3 = Dice_value_1_3
                local dice_2_3 = Dice_value_2_3
                local dice_3_3 = Dice_value_3_3
                local dice_4_3 = Dice_value_4_3
                print("Angriff Spieler 3: Würfelwerte - Dice 1: " .. dice_1_3 .. ", Dice 2: " .. dice_2_3 .. ", Dice 3: " .. dice_3_3 .. ", Dice 4: " .. dice_4_3)
            end

            function abwehr_3()
                local dice_5_3 = Dice_value_5_3
                local dice_6_3 = Dice_value_6_3
                local dice_7_3 = Dice_value_7_3
                print("Abwehr Spieler 3: Würfelwerte - Dice 5: " .. dice_5_3 .. ", Dice 6: " .. dice_6_3 .. ", Dice 7: " .. dice_7_3)
            end

            function probe_3()
                local dice_5_3 = 1
                local dice_6_3 = 1
                print("Probe Spieler 3: Würfelwerte - Dice 5: " .. dice_5_3 .. ", Dice 6: " .. dice_6_3)
            end

            function heilung_3()
                local dice_2_3 = 2
                print("Heilung Spieler 3: Würfelwert - Dice 2: " .. dice_2_3)
            end

    --Action Panels Funktionen für Spieler 4
            function angriff_4()
                local dice_1_4 = Dice_value_1_4
                local dice_2_4 = Dice_value_2_4
                local dice_3_4 = Dice_value_3_4
                local dice_4_4 = Dice_value_4_4
                print("Angriff Spieler 4: Würfelwerte - Dice 1: " .. dice_1_4 .. ", Dice 2: " .. dice_2_4 .. ", Dice 3: " .. dice_3_4 .. ", Dice 4: " .. dice_4_4)
            end

            function abwehr_4()
                local dice_5_4 = Dice_value_5_4
                local dice_6_4 = Dice_value_6_4
                local dice_7_4 = Dice_value_7_4
                print("Abwehr Spieler 4: Würfelwerte - Dice 5: " .. dice_5_4 .. ", Dice 6: " .. dice_6_4 .. ", Dice 7: " .. dice_7_4)
            end

            function probe_4()
                local dice_5_4 = 1
                local dice_6_4 = 1
                print("Probe Spieler 4: Würfelwerte - Dice 5: " .. dice_5_4 .. ", Dice 6: " .. dice_6_4)
            end

            function heilung_4()
                local dice_2_4 = 2
                print("Heilung Spieler 4: Würfelwert - Dice 2: " .. dice_2_4)
            end



