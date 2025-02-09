
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


        --toggeln von diceboards
        function showDiceboard_1()
            local currentVisibility = UI.getAttribute("diceboard_1", "visibility")
            if currentVisibility == "hidden" then
                UI.setAttribute("diceboard_1", "visibility", "")
            else
                UI.setAttribute("diceboard_1", "visibility", "hidden")
            end
        end

        function showDiceboard_2()
            local currentVisibility = UI.getAttribute("diceboard_2", "visibility")
            if currentVisibility == "hidden" then
                UI.setAttribute("diceboard_2", "visibility", "")
            else
                UI.setAttribute("diceboard_2", "visibility", "hidden")
            end
        end



        function showDiceboard_3()
            local currentVisibility = UI.getAttribute("diceboard_3", "visibility")
            if currentVisibility == "hidden" then
                UI.setAttribute("diceboard_3", "visibility", "")
            else
                UI.setAttribute("diceboard_3", "visibility", "hidden")
            end
        end




    function showDiceboard_4()
        local currentVisibility = UI.getAttribute("diceboard_4", "visibility")
        if currentVisibility == "hidden" then
            UI.setAttribute("diceboard_4", "visibility", "")
        else
            UI.setAttribute("diceboard_4", "visibility", "hidden")
        end
    end






