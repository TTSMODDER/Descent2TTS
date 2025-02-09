
local Panelvariariablen = {} 
   
dataContainerGUID = "e894f6"  -- GUID des Datencontainers wo alle betroffen minis aus der TTRS Controller objekt übernommen werden
targetGUIDs = {} -- Globale Variable für die Ziel-GUIDs
linkedObjects = {} -- Verknüpfte Miniaturen

listData = {
    { guid = "", name = "leer", description = "leer", health = "00/00", exhaustion = "00/00", marker = "-", color = "Rot" },
    { guid = "", name = "leer", description = "leer", health = "00/00", exhaustion = "00/00", marker = "-", color = "Blau" },
    { guid = "", name = "leer", description = "leer", health = "00/00", exhaustion = "00/00", marker = "-", color = "Grün" },
    { guid = "", name = "leer", description = "leer", health = "00/00", exhaustion = "00/00", marker = "-", color = "Gelb" }
}


panelIds = {
    "Parent_PlayerPanel_1",
    "Parent_PlayerPanel_2",
    "Parent_PlayerPanel_3",
    "Parent_PlayerPanel_4",
}

visibilityOptions = {
    ["Alle"] = "Black|White|Red|Yellow|Green|Blue", -- Sichtbarkeit für bestimmte Spielerfarben",
    ["Keine"] = "Pink", 
    ["Rot"] = "Red",
    ["Gelb"] = "Yellow",
    ["Blau"] = "Blue",
    ["Grün"] = "Green",
    ["GM"] = "Black|White",
}
refreshImageUrl = "https://steamusercontent-a.akamaihd.net/ugc/38943008356279628/CD88682242B1D1BAF65E7A2BF01E63E4876CE421/"
UI.setAttributes("image_refresh", {image = refreshImageUrl })
UI.setAttributes("image-refresh_1", { image = refreshImageUrl })
UI.setAttributes("image-refresh_2", { image = refreshImageUrl })
UI.setAttributes("image-refresh_3", { image = refreshImageUrl })
UI.setAttributes("image-refresh_4", { image = refreshImageUrl })

placeholderUrl = "https://steamusercontent-a.akamaihd.net/ugc/38943008356388258/91803389597F92AC3B0B4119084274587295F410/"

isFarbpanelVisible = true -- Status der Sichtbarkeit des Farbpanels
panelSpacing = 10 -- Abstand zwischen Panels

--info: Spieler 1 = blau, Spieler 2= grün, Spieler 3 = gelb, Spieler 4 = rot.

return Panelvariariablen






