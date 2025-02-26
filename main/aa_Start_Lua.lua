-- hier kommt alles rein, was beim Start des Projekts geladen werden soll, und normalerwesie in der Global.lua stehen würde!!


require("/main/Heldenpanel")    
require("/main/Heldenpanel_Liste")  
require("/main/Heldenpanel_Bildauswahl")
require ("/main/Spielerauswahl")
require ("/main/Wuerfelscript")
require ("/main/Monsterpanel")
require ("/main/Kamerapositionen")
require ("/Librarys/Monsterpanel_Variablen")
require ("/Librarys/Monster_Klassen") 
 

function project_onLoad(save_state)

        -- Monster: 
    
        Monster_Klassen_onload() -- in den monster_klassen  
        Monster_onload() -- in den monsterpanel_variabeln  
        Monsterliste_onload() -- in den monsterpanels
        --updateAllMonsterCards()-- in dne monsterpanel_ variabeln, falls die Monsterkarten geändert werden sollen aktivieren!

        initHeldenpanel()

        -- Bildauswahl Heldenpanelladen 
        local Bildauswahl = require("main.Heldenpanel_Bildauswahl") 
        Bildauswahl_onLoad()-- 
   
end


