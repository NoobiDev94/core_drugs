local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
coRE = {}
Tunnel.bindInterface("core_drugs",coRE)
local idgens = Tools.newIDGenerator()

CreateThread(
    function()
        updatePlants()
    end
)
vRP._prepare("core_drugs/DeadPlants","SELECT id FROM plants WHERE (water < 2 OR food < 2) AND rate > 0")
vRP._prepare("core_drugs/GrowPlants","SELECT id, growth FROM plants WHERE(growth >= 30 AND growth <= 31) OR (growth >= 80 AND growth <= 81)")
vRP._prepare("core_drugs/UpdatePlantsDead","UPDATE plants SET rate = @rate, food = @food, water = @water  WHERE id = @id")
vRP._prepare("core_drugs/UpdatePlantsReduction","UPDATE plants SET growth = growth + (0.01 * rate), food = food - (0.02 * rate), water = water - (0.02 * rate) WHERE water >= 2 OR food >= 2")
function updatePlants()
    Citizen.SetTimeout(
        Config.GlobalGrowthRate * 1000,
        function()
            updatePlants()
        end
    )

    --DEAD PLANTS


    local info = vRP.query("core_drugs/DeadPlants")
    for _, v in ipairs(info) do
        vRP.execute("core_drugs/UpdatePlantsDead",{id = v.id, rate = 0, food = 0, water = 0 })

    end



       

    -- ALIVE PLANT REDUCTION
            vRP.execute("core_drugs/UpdatePlantsReduction")
            TriggerClientEvent("core_drugs:growthUpdate", -1)


    -- GROW PLANTS


    local info2 = vRP.query("core_drugs/GrowPlants")

            for _, v in ipairs(info2) do
                TriggerClientEvent("core_drugs:growPlant", -1, v.id, v.growth)
            end



end

function proccesing(player, type)
    TriggerClientEvent("core_drugs:process", player, type)
end

function plant(player, type)
    TriggerClientEvent("core_drugs:plant", player, type)
end

function drug(player, type)
    TriggerClientEvent("core_drugs:drug", player, type)
end

function addProcess(type, coords, rot)
    MySQL.Async.insert(
        "INSERT INTO processing (type, item, time, coords, rot) VALUES (@type, @item, @time, @coords, @rot)",
        {
            ["@coords"] = json.encode({x = coords[1], y = coords[2], z = coords[3]}),
            ["@type"] = type,
            ["@item"] = "{}",
            ["@time"] = 0,
            ["@rot"] = rot
        },
        function(id)
            TriggerClientEvent("core_drugs:addProcess", -1, type, coords, id, rot)
        end
    )
end
vRP._prepare("core-drugs/addPlant","INSERT IGNORE INTO plants (coords, type, growth, rate,water,food, markid) VALUES(@coords, @type, @growth, @rate, @water, @food, @markid)")

function addPlant(type, coords, id)
    local rate = Config.DefaultRate
    local zone = nil

    print("cheguei no server plant", type, coords, id)
    for _, v in ipairs(Config.Zones) do
        if #(v.Coords - coords) < v.Radius then
            local contains = false
            for _, g in ipairs(v.Exclusive) do
                if g == type then
                    contains = true
                end
            end

            if contains then
                rate = v.GrowthRate
                zone = v
            end
        end
    end

    if Config.OnlyZones == true then
        if zone == nil then
            TriggerClientEvent("core_drugs:sendMessage", id, Config.Text["cant_plant"])
            return
        end
    end
    vRP.execute("core-drugs/addPlant",{ coords = json.encode({x = coords[1], y = coords[2], z = coords[3]}), type = type, growth = 0, rate = rate, water = 10, food =  10, markid = id})
    TriggerClientEvent("core_drugs:addPlant", -1, type, coords,id)
    --[[MySQL.Async.insert(
        "INSERT INTO plants (coords, type, growth, rate,water,food) VALUES (@coords, @type, @growth, @rate, @water, @food)",
        {
            ["@coords"] = json.encode({x = coords[1], y = coords[2], z = coords[3]}),
            ["@type"] = type,
            ["@growth"] = 0,
            ["@rate"] = rate,
            ["@food"] = 10,
            ["@water"] = 10
        },
        function(id)
            TriggerClientEvent("core_drugs:addPlant", -1, type, coords, id)
        end
    )]]
end

function coRE.returnInventory()
    local source = source
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    return data
end

RegisterServerEvent("core_drugs:addPlant")
AddEventHandler(
    "core_drugs:addPlant",
    function(type, coords)
        local Player = vRP.getUserId(source)
        local typeInfo = Config.Plants[type]

        print("vou remover o item", type, coords, Player)
       if vRP.tryGetInventoryItem(Player,type,parseInt(typeInfo.AmountSeed)) then

        local genID = idgens:gen()
        print("mostra id ", genID )
        addPlant(type, coords, genID)
       end
        --Player.removeInventoryItem(type, 1)
    end
)

RegisterServerEvent("core_drugs:processed")
AddEventHandler(
    "core_drugs:processed",
    function(type, amount)
        local Player = vRP.getUserId(source)
        local table = Config.ProcessingTables[type]

        if Config.WeightSystem then
            if Player.canCarryItem(table.Item, amount) then
                for k, v in pairs(table.Ingrediants) do
                    if Player.getInventoryItem(k).count < v then
                        TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["missing_ingrediants"])
                        return
                    else
                        Player.removeInventoryItem(k, v * amount)
                    end
                end

                Player.addInventoryItem(table.Item, amount)
            else
                TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["cant_hold"])
            end
        else
            if Player.getInventoryItem(table.Item).limit >= (Player.getInventoryItem(table.Item).count + 1) then
                for k, v in pairs(table.Ingrediants) do
                    if Player.getInventoryItem(k).count < v then
                        TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["missing_ingrediants"])
                        return
                    else
                        Player.removeInventoryItem(k, v * amount)
                    end
                end

                Player.addInventoryItem(table.Item, amount)
            else
                TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["cant_hold"])
            end
        end
    end
)

RegisterServerEvent("core_drugs:addProcess")
AddEventHandler(
    "core_drugs:addProcess",
    function(type, coords, rot)
        source = source
        local Player = vRP.getUserId(source)
        addProcess(type, coords, rot)

        Player.removeInventoryItem(type, 1)
    end
)

RegisterServerEvent("core_drugs:tableStatus")
AddEventHandler(
    "core_drugs:tableStatus",
    function(id, status)
        TriggerClientEvent("core_drugs:changeTableStatus", -1, id, status)
    end
)

RegisterServerEvent("core_drugs:removeItem")
AddEventHandler(
    "core_drugs:removeItem",
    function(item, count)
        local Player = vRP.getUserId(source)
        if vRP.tryGetInventoryItem(Player,item,parseInt(count)) then
            return true
        else
            return false
        end

    end
)

RegisterServerEvent("core_drugs:sellDrugs")
AddEventHandler(
    "core_drugs:sellDrugs",
    function(prices)
        local Player = vRP.getUserId(source)
        local inventory = Player.getInventory(true)
        local pay = 0

        for k, v in pairs(prices) do
            if inventory[k] then
                pay = pay + (v * inventory[k])
                Player.removeInventoryItem(k, inventory[k])
            end
        end

        if pay > 0 then
            Player.addMoney(pay)
            TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["sold_dealer"] .. pay)
        else
            TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["no_drugs"])
        end
    end
)
vRP._prepare("core_drugs/deletePlant","DELETE FROM plants WHERE markid = @markid")

RegisterServerEvent("core_drugs:deletePlant")
AddEventHandler(
    "core_drugs:deletePlant",
    function(id)
        print("vim apagar o id ", id)
        vRP.execute("core_drugs/deletePlant", { markid = id})

    end
)

RegisterServerEvent("core_drugs:deleteTable")
AddEventHandler(
    "core_drugs:deleteTable",
    function(id, type)
        local Player = vRP.getUserId(source)

        MySQL.Async.execute(
            "DELETE FROM processing WHERE id = @id",
            {["@id"] = id},
            function()
            end
        )

        Player.addInventoryItem(type, 1)
    end
)
vRP._prepare("core_drugs/updatePlant","UPDATE plants SET growth= @growth, rate = @rate, food = @food, water = @water  WHERE id = @id")
RegisterServerEvent("core_drugs:updatePlant")
AddEventHandler(
    "core_drugs:updatePlant",
    function(id, info)

        vRP.query("core_drugs/updatePlant", {id = id, growth = info.growth, rate = info.rate, food = info.food, water = info.water})

    end
)

RegisterServerEvent("core_drugs:harvest")
AddEventHandler("core_drugs:harvest",function(type, info)
        local src = source
        local typeInfo = Config.Plants[type]
        local Player = vRP.getUserId(src)

        local val = typeInfo.Amount * tonumber(info.growth) / 100
        val = math.floor(val + 0.5)

        if info.growth < 20 then
            val = 0
        end

        if (typeInfo.SeedChance >= math.random(1, 100)) then
            vRP.giveInventoryItem(Player,type,parseInt(1))

     
           -- Player.addInventoryItem(type, 1)
        end
        vRP.giveInventoryItem(Player,typeInfo.Produce,parseInt(val))
    end
)
vRP._prepare("core-drugs/getplants","SELECT * FROM plants")
vRP._prepare("core-drugs/getplantes","SELECT * FROM plants WHERE id = @id")
vRP._prepare("core-drugs/process","SELECT * FROM processing")
function coRE.getinfoPlants()
    local plants = {}

    local plantas =  vRP.query("core-drugs/getplants")

print("verifico db ", plantas)

    for _, v in ipairs(plantas) do
        local coords = json.decode(v.coords) or {x = 0, y = 0, z = 0}
   
        local data = {growth = v.growth, rate = v.rate, water = v.water, food = v.food}
        coords = vector3(coords.x, coords.y, coords.z)
        print("verifico db2 ", v.type, v.markid)

        plants[v.markid] = {type = v.type, coords = coords, info = data}
    end

   
    return plants


end
function coRE.getPlants(nplant)
    local plants = {}

    local plantas =  vRP.query("core-drugs/getplantes", {id = nplant})

print("verifico nplanta ", nplant)

    for _, v in ipairs(plantas) do
        local coords = json.decode(v.coords) or {x = 0, y = 0, z = 0}
   
        local data = {growth = v.growth, rate = v.rate, water = v.water, food = v.food}
        coords = vector3(coords.x, coords.y, coords.z)
        print("verifico db2 ", v.type, v.id)

        plants[v.markid] = {type = v.type, coords = coords, info = data}
    end

   
    return plants


end
function coRE.getinfoProcess()

        local processo =  vRP.query("core-drugs/process")
        local process = {}
    
 
        for _, g in ipairs(processo) do
            local coords = json.decode(g.coords) or {x = 0, y = 0, z = 0}
            local data = json.decode(g.item) or {}
            coords = vector3(coords.x, coords.y, coords.z)
    
            process[g.id] = {
                type = g.type,
                coords = coords,
                item = data,
                time = g.time,
                rot = g.rot,
                usable = true
            }
        end
    
        return process

  

end


--[[]

vRP._prepare("core-drugs/getplants","ALTER TABLE vrp_users ADD IF NOT EXISTS iniciante INT(2) NOT NULL DEFAULT 1")
vRP._prepare("noobi-vip/addcolumn_users2","ALTER TABLE vrp_users ADD IF NOT EXISTS viptemp INT(2) NOT NULL DEFAULT 0")
vRP._prepare("noobi-vip/get_users","SELECT * FROM vrp_users WHERE id = @user_id")
vRP._prepare("noobi-vip/update_users","UPDATE vrp_users SET iniciante = @iniciante, viptemp = @viptemp  WHERE id = @user_id")

vRP._prepare("noobi-vip/add_vehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")


RegisterServerEvent("core_drugs:getInfo")
AddEventHandler("core_drugs:getInfo",function(source, cb)
        MySQL.Async.fetchAll(
            "SELECT * FROM plants WHERE 1",
            {},
            function(infoPlants)
                MySQL.Async.fetchAll(
                    "SELECT * FROM processing WHERE 1",
                    {},
                    function(infoProcess)
                        local plants = {}
                        local process = {}

                        for _, v in ipairs(infoPlants) do
                            local coords = json.decode(v.coords) or {x = 0, y = 0, z = 0}
                            local data = {growth = v.growth, rate = v.rate, water = v.water, food = v.food}
                            coords = vector3(coords.x, coords.y, coords.z)

                            plants[v.id] = {type = v.type, coords = coords, info = data}
                        end

                        for _, g in ipairs(infoProcess) do
                            local coords = json.decode(g.coords) or {x = 0, y = 0, z = 0}
                            local data = json.decode(g.item) or {}
                            coords = vector3(coords.x, coords.y, coords.z)

                            process[g.id] = {
                                type = g.type,
                                coords = coords,
                                item = data,
                                time = g.time,
                                rot = g.rot,
                                usable = true
                            }
                        end

                        cb(plants, process)
                    end
                )
            end
        )
    end
)
]]
vRP._prepare("core-drugs/plants","SELECT * FROM plants WHERE id = @id LIMIT 1")
vRP._prepare("core-drugs/Checkplants","SELECT * FROM plants")
local datadb = {}
local refreshdb = 5000
Citizen.CreateThread( function()

    while true do
     
        local  plantas =  vRP.query("core-drugs/plants",{id = nPlant} )
        local  Checkplants =  vRP.query("core-drugs/Checkplants")


        if #Checkplants > 0 then
        if #Checkplants >= 1 then 
            print("entrei limpar")
            datadb = {}
            goto continuelooping
        end
::continuelooping::
print("teste 1", #datadb)
            for k,v in pairs(Checkplants) do
                
                table.insert(datadb, {id = v.id, markid = v.markid, growth = v.growth, rate = v.rate, water = v.water, food = v.food })
                if #Checkplants == v.id then
                    goto breaklooping
                end
           print("teste 2", #datadb)
            end
            ::breaklooping::
            refreshdb = 5000
        end


        Citizen.Wait(refreshdb)

    end

end)
function coRE.getPlant(nPlant)
    
print("me mostra valor no server ", #datadb)
        local  plantas =  vRP.query("core-drugs/plants",{id = nPlant} )
        local  Checkplants =  vRP.query("core-drugs/Checkplants")

if datadb ~= nil then
        for k,v in pairs(datadb) do
            if v.markid == nPlant then

                local dataid = {id = v.id, markid = v.markid, growth = v.growth, rate = v.rate, water = v.water, food = v.food}
                refreshdb = 500
                return dataid
            end
            ---table.insert(data, { growth = v.growth, rate = v.rate, water = v.water, food = v.food })
        end
    else
        return false
    end
        --local data = {growth = plantas[1].growth, rate = plantas[1].rate, water = plantas[1].water, food = plantas[1].food}
        -- print("mostra data", data)
         
  
end

--[[]
ESX.RegisterServerCallback(
    "core_drugs:getPlant",
    function(source, cb, id)
        MySQL.Async.fetchAll(
            "SELECT growth,rate,food,water FROM plants WHERE id = @id LIMIT 1",
            {["@id"] = id},
            function(info)
                local data = {growth = info[1].growth, rate = info[1].rate, water = info[1].water, food = info[1].food}

                cb(data)
            end
        )
    end
)
]]