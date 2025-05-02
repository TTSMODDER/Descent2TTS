require ("/Librarys/Constants")

local showAndHide = false


function showCamMenu (player, value, id)
    if showAndHide == false then
        UI.setAttribute("CamPanel", "visibility", "")
        showAndHide = true
    else
        UI.setAttribute("CamPanel", "visibility", "hidden")
        showAndHide = false
    end
end

function mapCam(player)
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = {x=5,y=0,z=0},
            pitch    = 60,
            yaw      = 180,
            distance = 35,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = {x=5,y=0,z=0},
            pitch    = 60,
            yaw      = 0,
            distance = 35,
        })
    end    
end



function redCam(player) --Soielerpanel_4
    local redMap = getObjectFromGUID(playerMap.Red)
    local mapPos = redMap.getPosition()
    local playerColor = player.color

    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 180,
            distance = 15,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 0,
            distance = 15,
        })
    end
end

function yellowCam(player) --Soielerpanel_3
    local yellowMap = getObjectFromGUID(playerMap.Yellow)
    local mapPos = yellowMap.getPosition()
    local playerColor = player.color

    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 180,
            distance = 15,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 0,
            distance = 15,
        })
    end
end

function greenCam(player) --Soielerpanel_2
    local greenMap = getObjectFromGUID(playerMap.Green)
    local mapPos = greenMap.getPosition()
    local playerColor = player.color

    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 180,
            distance = 15,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 0,
            distance = 15,
        })
    end
end

function blueCam(player) --Soielerpanel_1
    local blueMap = getObjectFromGUID(playerMap.Blue)
    local mapPos = blueMap.getPosition()
    local playerColor = player.color

    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 180,
            distance = 15,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 0,
            distance = 15,
        })
    end
end

function whiteCam(player)
    local whiteMap = getObjectFromGUID(playerMap.White)
    local mapPos = whiteMap.getPosition()
    local playerColor = player.color

    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 160,
            distance = 15,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 0,
            distance = 15,
        })
    end
end

function truheCam(player)
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = {x=60,y=0,z=0},
            pitch    = 60,
            yaw      = 0,
            distance = 35,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = {x=60,y=0,z=10},
            pitch    = 60,
            yaw      = 0,
            distance = 35,
        })
    end
end

function zustandCam(player)
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = {x=-30,y=0,z=0},
            pitch    = 60,
            yaw      = 180,
            distance = 40,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = {x=-25,y=0,z=0},
            pitch    = 60,
            yaw      = 0,
            distance = 40,
        })
    end
end

function reiseCam (player)
    --local map = getObjectFromGUID(reiseMap)
    --local mapPos = map.getPosition()
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            --position = mapPos,
            --pitch    = 60,
            --yaw      = 90,
            --distance = 30,


            position = {x=50,y=-5,z=-20},
            pitch    = 100,
            yaw      = 90,
            distance = 35,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            --position = mapPos,
            --pitch    = 60,
            --yaw      = 0,
            --distance = 30,

            position = {x=50,y=-5,z=-20},
            pitch    = 100,
            yaw      = 90,
            distance = 35,


        })
    end
end

-- Funktione für OL CArds Kamerapositionen
function OL_Card_Cam(player)
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = {x=3,y=3,z=-43},
            pitch    = 90,
            yaw      = 0,
            distance = 16,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = {x=3,y=3,z=-43},
            pitch    = 90,
            yaw      = 0,
            distance = 16,
        })
    end
end





-- Funktionen für toggle Buttons auf Spleierpanels
    local isMapCamActive = true

    -- Toggle-Funktion für Kamerawechsel_Spieler Blau = Panel _1
    function toggleCameras_1(player)
        if isMapCamActive then
            blueCam(player)
        else
            mapCam(player)
        end
        -- Status umschalten
        isMapCamActive = not isMapCamActive
    end

    -- Toggle-Funktion für Kamerawechsel_Spieler Gelb= Panel _2
    function toggleCameras_2(player)
        if isMapCamActive then
            greenCam(player)
        else
            mapCam(player)
        end
        -- Status umschalten
        isMapCamActive = not isMapCamActive
    end

    -- Toggle-Funktion für Kamerawechsel_Spieler grün= Panel _3
    function toggleCameras_3(player)
        if isMapCamActive then
            yellowCam(player)
        else
            mapCam(player)
        end
        -- Status umschalten
        isMapCamActive = not isMapCamActive
    end

    -- Toggle-Funktion für Kamerawechsel_Spieler rot= Panel _4
    function toggleCameras_4(player)
        if isMapCamActive then
            redCam(player)
        else
            mapCam(player)
        end
        -- Status umschalten
        isMapCamActive = not isMapCamActive
    end