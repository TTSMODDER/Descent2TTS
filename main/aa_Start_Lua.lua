
-- hier kommt alles rein, was beim Start des Projekts geladen werden soll, und normalerwesie in der Global.lua stehen würde!!


require("/main/Heldenpanel")    
require("/main/Heldenpanel_Liste")  
require("/main/Heldenpanel_Bildauswahl")
require ("/main/Spielerauswahl")
require ("/main/Wuerfelscript")
--require ("/main/Monsterliste")

function project_onLoad(save_state)
    initHeldenpanel()

        -- Bildauswahl laden 
        local Bildauswahl = require("main.Heldenpanel_Bildauswahl") 
        Bildauswahl_onLoad()
        --onload_Monster()    
        
end