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

function redCam(player)
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

function yellowCam(player)
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

function greenCam(player)
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

function blueCam(player)
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

function truheCam(player)
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = {x=60,y=0,z=0},
            pitch    = 60,
            yaw      = 180,
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
    local map = getObjectFromGUID(reiseMap)
    local mapPos = map.getPosition()
    local playerColor = player.color
    if allowedPlayerColors[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 90,
            distance = 30,
        })
    elseif allowedDMColor[playerColor] then
        Player[playerColor].lookAt({
            position = mapPos,
            pitch    = 60,
            yaw      = 0,
            distance = 30,
        })
    end
end
