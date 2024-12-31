require ("/Librarys/Constants")

function createWuerfelButton()
    UI.setXmlTable({
        {
            tag="VerticalLayout",
            attributes={
                height=350,
                width=50,
                color="rgba(0,0,0,0.7)",
                position = "-25 0",
                anchorMin="1 0.5",
                anchorMax="1 0.5",
                id = "wuerfelMenu"
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
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Yellow",
                            onClick = "wuerfeln",
                            id = "Yellow",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Green",
                            onClick = "wuerfeln",
                            id = "Green",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Grey",
                            onClick = "wuerfeln",
                            id = "Grey",
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Black",
                            onClick = "wuerfeln",
                            id = "Black", 
                        },
                        value="",
                    },
                    {
                        tag="Button",
                        attributes={
                            height=50,
                            width = 50,
                            color="Brown",
                            onClick = "wuerfeln",
                            id = "Brown",
                        },
                        value="",
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
                        value="",
                    },
                }
            }
        }
    )
end

function wuerfeln (player, value, id)
   
    if  allowedPlayerColors[player.color] then
        if wuerfel[id] then
            local url = wuerfel[id].url
            spawnObjFromCloud(url, id, callback, position)
        end
    end  
end

local spawnedCubes ={}

function spawnObjFromCloud (url, id, callback)
    WebRequest.get(url, function(response)
        local objectJSON = response.text
        -- Objekt mit dem geladenen JSON spawnen
        local spawnedObject = spawnObjectJSON({
            json = objectJSON,
            position = {x = xValue , y = 10, z = -10},
            callback_function = function(obj)
                obj.setName(id.." Cube")
                table.insert(spawnedCubes, obj)
                for i = 1, #spawnedCubes do
                    log(position)
                    local position = {x = xValue + (i * 3), y= 10, z=-10}
                    spawnedCubes[i].setPosition(position)
                    log(spawnedCubes[i])
                end
                if callback then
                    log("wird ausgeführt")
                    callback(obj)
                end
            end
        })
    end)
end

function callback (obj)
    
  
    Wait.time(function()
        obj.roll()
    end,0.5, 3)
    Wait.time(function()
        for _, cube in ipairs (spawnedCubes) do
            destroyObject(cube)
        end
        spawnedCubes = {}
    end, 10)
end