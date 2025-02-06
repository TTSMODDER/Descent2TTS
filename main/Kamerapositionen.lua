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