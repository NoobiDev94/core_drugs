local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
coRE = {}
Tunnel.bindInterface("core_drugs", coRE)
local idgens = Tools.newIDGenerator()
if Config.CheckDbIfExist then
CreateThread(function()
    vRP.execute('core_drugs/create_plants')
    vRP.execute('core_drugs/create_tabletprocess')
 print("Checando banco de dados, aguarde.")
 Citizen.Wait(10000)
 print("Inicialização do banco de dados finalizada.")
end)

end
vRP._prepare("core_drugs/DeadPlants", "SELECT markid,id FROM plants WHERE (water < 2 OR food < 2) AND rate > 0")
vRP._prepare("core_drugs/DeadPlantsGet", "SELECT markid, id FROM plants")
vRP._prepare("core_drugs/GrowPlants",
    "SELECT id,markid, growth FROM plants WHERE (growth >= 30 AND growth <= 79) OR (growth >= 80 AND growth <= 100)")
vRP._prepare("core_drugs/GrowPlantsGet",
    "SELECT id,markid, growth FROM plants")
vRP._prepare("core_drugs/UpdatePlantsDead",
    "UPDATE plants SET rate = @rate, food = @food, water = @water  WHERE markid = @id")
vRP._prepare("core_drugs/UpdatePlantsReduction",
    "UPDATE plants SET growth = growth + (0.01 * rate), food = food - (0.02 * rate), water = water - (0.02 * rate), rate = rate + 1 WHERE water >= 2 OR food >= 2")
function coRE.ReturnPermissionPlayer(table)
    local src = source
    local user_id = vRP.getUserId(src)
     return  vRP.hasPermission(user_id,table)

end
function coRE.ReturnPermissionPlayer2(table)
    local src = source
    local user_id = vRP.getUserId(src)
     return  vRP.hasPermission(user_id,table)

end

function coRE.ReturnId()
    local src = source
    local user_id = vRP.getUserId(src)
     return user_id

end

CreateThread(
    function()
        while true do
        
            updatePlants()

           Citizen.Wait(Config.GlobalGrowthRate * 1000)
       end
    end
)

function updatePlants()

    --DEAD PLANTS


    local info = vRP.query("core_drugs/DeadPlants")
    local info4 = vRP.query("core_drugs/DeadPlantsGet")
    if #info > 0 then
    for _, v in ipairs(info) do
            if #info > 0 then
        vRP.execute("core_drugs/UpdatePlantsDead", { id = v.markid, rate = 0, food = 0, water = 0 })
            end

    end
end


        -- ALIVE PLANT REDUCTION
    vRP.execute("core_drugs/UpdatePlantsReduction")
    TriggerClientEvent("core_drugs:growthUpdate", -1)




    -- GROW PLANTS


    local info2 = vRP.query("core_drugs/GrowPlants")
     local info3 = vRP.query("core_drugs/GrowPlantsGet")

if #info3 > 0 then
    for _, v in ipairs(info2) do
  if parseInt(v.growth) >= 100 then
           
              TriggerClientEvent("core_drugs:growPlant", -1, v.markid, 100)
          else
            if (v.growth >= 30 or v.growth <=31) and (v.growth >= 80 or v.growth <= 81) then
 
              TriggerClientEvent("core_drugs:growPlant", -1, v.markid, v.growth)

          end
       end
      
    end

end


end
RegisterCommand('pro',function(source,args,rawCommand)
    local source = source

    proccesing(source,'pasta-base')
   
end)
function proccesing(source,type)


    local source = source
    local user_id = vRP.getUserId(source)
    local tablex = Config.ProcessingTables[type]

  
    if tablex.Permission then

        if vRP.hasPermission(user_id,tablex.PermissionGroup) then

    TriggerClientEvent("core_drugs:process",source,type)
        else
            TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["no_permission"], "negado")
        end
        else
            TriggerClientEvent("core_drugs:process",source,type)

   
    end
end

function plant(player, type)

    TriggerClientEvent("core_drugs:plant", player, type)
end

function drug(player, type)
    TriggerClientEvent("core_drugs:drug", player, type)
end
vRP._prepare("core-drugs/addProcessing","INSERT INTO processing (type, item, time, coords, rot, markid, owner) VALUES (@type, @item, @time, @coords, @rot, @markid, @owner)")
function addProcess(type, coords, rot)
            local idgen =  parseInt(math.random(100) + os.clock())

            local source = source
            local user_id = vRP.getUserId(source)
if  vRP.tryGetInventoryItem(user_id,type,parseInt(1)) then
            vRP.execute("core-drugs/addProcessing",{ coords = json.encode({ x = coords[1], y = coords[2], z = coords[3] }), type = type, item = "{}", time = os.time(), rot = rot, markid = idgen, owner = user_id})
            TriggerClientEvent("core_drugs:addProcess", -1, type, coords, idgen, rot,user_id)

        else

 TriggerClientEvent("core_drugs:sendMessage",source, Config.Text["no_table"], "negado")
end
            
                   
              
         
end

vRP._prepare("core-drugs/addPlant","INSERT IGNORE INTO plants (coords, type, growth, rate,water,food, markid, owner) VALUES(@coords, @type, @growth, @rate, @water, @food, @markid, @owner)")

function addPlant(type, coords, id)
    local rate = Config.DefaultRate
    local zone = nil


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

    if Config.OnlyZones then
        if zone == nil then
            TriggerClientEvent("core_drugs:sendMessage", id, Config.Text["cant_plant"], "negado")
            return
        end
    end
    local source = source
    local user_id = vRP.getUserId(source)
    vRP.execute("core-drugs/addPlant",{ coords = json.encode({ x = coords[1], y = coords[2], z = coords[3] }), type = type, growth = 0, rate = rate, water = 10, food = 10, markid = id, owner = user_id })
    TriggerClientEvent("core_drugs:addPlant", -1, type, coords, id)

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
        if vRP.tryGetInventoryItem(Player, type, parseInt(typeInfo.AmountSeed)) then
            PlantProgress(source, type)
            local genID = parseInt(math.random(100) + os.clock())
  
            addPlant(type, coords, genID)
        end

    end
)

RegisterServerEvent("core_drugs:processed")
AddEventHandler(
    "core_drugs:processed",
    function(type, amount)
        local source = source
        local user_id = vRP.getUserId(source)
        local table = Config.ProcessingTables[type]
       
        if table.Permission then

            if vRP.hasPermission(user_id,table.PermissionGroup) then
                for k, v in pairs(table.Ingrediants) do
               print("primeira etapa", vRP.getInventoryItemAmount(user_id, k), "<", k,v)
                    if vRP.getInventoryItemAmount(user_id, k) < v then
                        TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["missing_ingrediants"], "negado")
                        return
                    else
                        vRP.tryGetInventoryItem(user_id,k,v)
    
                    end
          
                end
            
                TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["success_process"]..table.Item, "sucesso")
                vRP.giveInventoryItem(user_id, table.Item, amount)

            else
                TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["no_permission"], "negado")
            end
        else
            for k, v in pairs(table.Ingrediants) do
                 print("primeira etapa2", vRP.getInventoryItemAmount(user_id, k), "<", v)
                if vRP.getInventoryItemAmount(user_id, k) < v then
                    TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["missing_ingrediants"], "negado")
                    return
                else
                    vRP.tryGetInventoryItem(user_id,k,v)

                end
      
            end
        
            TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["success_process"]..table.Item, "sucesso")
            vRP.giveInventoryItem(user_id, table.Item, amount)

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
        if vRP.tryGetInventoryItem(Player, item, parseInt(count)) then
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
            TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["sold_dealer"] .. pay, "negado")
        else
            TriggerClientEvent("core_drugs:sendMessage", source, Config.Text["no_drugs"], "negado")
        end
    end
)
vRP._prepare("core_drugs/deletePlant", "DELETE FROM plants WHERE markid = @markid")

RegisterServerEvent("core_drugs:deletePlant")
AddEventHandler(
    "core_drugs:deletePlant",
    function(id)

        vRP.execute("core_drugs/deletePlant", { markid = id })

    end
)
vRP._prepare("core_drugs/deleteTable", "DELETE FROM processing WHERE markid = @id")
RegisterServerEvent("core_drugs:deleteTable")
AddEventHandler(
    "core_drugs:deleteTable",
    function(id, type)
        local Player = vRP.getUserId(source)

        vRP.execute("core_drugs/deleteTable", { id = id })
         vRP.giveInventoryItem(Player, type, parseInt(1))
    end
)
vRP._prepare("core_drugs/updatePlant", "UPDATE plants SET growth= @growth, rate = @rate, food = @food, water = @water  WHERE markid = @markid")
RegisterServerEvent("core_drugs:updatePlant")
AddEventHandler(
    "core_drugs:updatePlant",
    function(id, info)
if parseInt(info.growth) >= 100 then
   info.growth = 100
elseif parseInt(info.rate) >= 100 then
    info.rate = 100
elseif parseInt(info.food) >= 100 then
    info.food = 100
 elseif  parseInt(info.water) >= 100 then
    info.water = 100
end
        vRP.query("core_drugs/updatePlant",
            { markid = id, growth = info.growth, rate = info.rate, food = info.food, water = info.water })

    end
)

RegisterServerEvent("core_drugs:harvest")
AddEventHandler("core_drugs:harvest", function(type, info)
    local src = source
    local typeInfo = Config.Plants[type]
    local Player = vRP.getUserId(src)

    local val = typeInfo.Amount * tonumber(info.growth) / 100
    val = math.floor(val + 0.5)

    if info.growth < 20 then
        val = 0
    end
if info.rate >= typeInfo.Ratebonus then
vRP.giveInventoryItem(Player, type, parseInt(1))
vRP.giveInventoryItem(Player, typeInfo.Produce, parseInt(math.random(1,3)))
end

    if (typeInfo.SeedChance >= math.random(1, 100)) then
        vRP.giveInventoryItem(Player, type, parseInt(1))


        -- Player.addInventoryItem(type, 1)
    end
    vRP.giveInventoryItem(Player, typeInfo.Produce, parseInt(val))
end
)
vRP._prepare("core-drugs/getplants", "SELECT * FROM plants")
vRP._prepare("core-drugs/getplantes", "SELECT * FROM plants WHERE id = @id")
vRP._prepare("core-drugs/process", "SELECT * FROM processing")
function coRE.getinfoPlants()
    local plants = {}

    local plantas = vRP.query("core-drugs/getplants")

    for _, v in ipairs(plantas) do
        local coords = json.decode(v.coords) or { x = 0, y = 0, z = 0 }

        local data = { growth = v.growth, rate = v.rate, water = v.water, food = v.food, owner = v.owner }
        coords = vector3(coords.x, coords.y, coords.z)

        plants[v.markid] = { type = v.type, coords = coords, info = data, owner = v.owner }
    end


    return plants


end

function coRE.getPlants(nplant)
    local plants = {}

    local plantas = vRP.query("core-drugs/getplantes", { id = nplant })

    for _, v in ipairs(plantas) do
        local coords = json.decode(v.coords) or { x = 0, y = 0, z = 0 }

        local data = { growth = v.growth, rate = v.rate, water = v.water, food = v.food, owner = v.owner}
        coords = vector3(coords.x, coords.y, coords.z)

        plants[v.markid] = { type = v.type, coords = coords, info = data, owner = v.owner }
    end


    return plants


end

function coRE.getinfoProcess()

    local processo = vRP.query("core-drugs/process")
    local process = {}


    for _, g in ipairs(processo) do
        local coords = json.decode(g.coords) or { x = 0, y = 0, z = 0 }
        local data = json.decode(g.item) or {}
        coords = vector3(coords.x, coords.y, coords.z)

        process[g.markid] = {
            markid = g.markid,
            type = g.type,
            coords = coords,
            item = data,
            time = g.time,
            rot = g.rot,
            owner = g.owner,
            usable = true
        }
    end

    return process



end

vRP._prepare("core-drugs/plants", "SELECT * FROM plants WHERE id = @id LIMIT 1")
vRP._prepare("core-drugs/Checkplants", "SELECT * FROM plants")
local datadb = {}
local refreshdb = 500
Citizen.CreateThread(function()

    while true do

        local plantas = vRP.query("core-drugs/plants", { id = nPlant })
        local Checkplants = vRP.query("core-drugs/Checkplants")


        if #Checkplants > 0 then
            if #Checkplants >= 1 then
         
                datadb = {}
                goto continuelooping
            end
            ::continuelooping::
            for k, v in pairs(Checkplants) do

                table.insert(datadb,
                    { id = v.id, markid = v.markid, growth = v.growth, rate = v.rate, water = v.water, food = v.food, owner = v.owner })

                    refreshdb = 10
           
                if #Checkplants == #datadb then
                    goto breaklooping
                end

            end
            ::breaklooping::
            refreshdb = 500
        end


        Citizen.Wait(refreshdb)

    end

end)
function coRE.getPlant(nPlant)

    if datadb ~= nil then
        for k, v in pairs(datadb) do
            if v.markid == nPlant then

                local dataid = { id = v.id, markid = v.markid, growth = v.growth, rate = v.rate, water = v.water,
                    food = v.food }
                refreshdb = 500
                return dataid
            end

        end
    else
        return false
    end


end

Citizen.CreateThread( function()
    updatePath = "/NoobiDev94/core_drugs" 
    resourceName = "("..GetCurrentResourceName()..")" 
    
    function checkVersion(err,responseText, headers)
        curVersion = LoadResourceFile(GetCurrentResourceName(), "version") 
    
        if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
            print("\n###############################")
            print("\n"..resourceName.." está desatualizado, versão atualizada:\n"..responseText.."sua versão:\n"..curVersion.."\npor favor atualize-o através do https://github.com"..updatePath.."")
            print("\n###############################")
        elseif tonumber(curVersion) > tonumber(responseText) then
            print("Você de alguma forma pulou algumas versões do script "..resourceName.." ou o github ficou offline, se ainda estiver online eu aconselho você atualizar (ou fazer downgrade?)")
        else
            print(resourceName.." iniciado com sucesso. Versão: "..string.gsub(curVersion, "%s+", ""))
        end
    end
    
    PerformHttpRequest("raw.githubusercontent.com"..updatePath.."/main/version", checkVersion, "GET")
    end)
