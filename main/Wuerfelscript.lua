require ("/Librarys/Constants")

function createWuerfelButton()
    UI.setXmlTable({
        {
            tag="VerticalLayout",
            attributes={
                height=100,
                width=50,
                color="rgba(0,0,0,0.7)",
                position = "-25 0",
                anchorMin="1 0.5",
                anchorMax="1 0.5",
            },
            children={
                {
                    tag="Button",
                    attributes={
                        height=50,
                        width = 50,
                        color="Blue",
                        onClick = "wuerfeln",
                        id = "Blue",
                    },
                    value="Example",
                },
                {
                    tag="Button",
                    attributes={
                        height=50,
                        width = 50,
                        color="red",
                        onClick = "wuerfeln",
                        id = "Red",
                    },
                    value="Example",
                },
            }
        }
    })
end

function wuerfeln (player, value, id)
    
    if  allowedPlayerColors[player.color] then
        if wuerfel[id] then
            local url = wuerfel[id].url
            spawnObjFromCloud(url)
            log (value)
        end
    end  
end

function spawnObjFromCloud (url)
    WebRequest.get(url, function(response)
        local objectJSON = response.text
        -- Objekt mit dem geladenen JSON spawnen
        local spawnedObject = spawnObjectJSON({
            json = objectJSON,
            position = position,
            callback_function = function(obj)
                obj.setName(id)
                if callback then
                    log("wird ausgeführt")
                    callback(obj)
                end
            end
        })
    end)
end