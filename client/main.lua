PlantTypes = {
    -- small is growth 0-30%, medium is 30-80%, large is 80-100%
    ["plant1"] = {
        small = {"bkr_prop_weed_01_small_01a", -1.65},
        medium = {"bkr_prop_weed_med_01a", -4.2},
        large = {"bkr_prop_weed_lrg_01a", -4.0}
    },
    ["plant2"] = {
        small = {"bkr_prop_weed_01_small_01b", -1.65},
        medium = {"bkr_prop_weed_med_01b", -4.2},
        large = {"bkr_prop_weed_lrg_01b", -4.0}
    },
    ["small_plant"] = {
        small = {"bkr_prop_weed_bud_pruned_01a", -1.05},
        medium = {"bkr_prop_weed_bud_02b", -1.05},
        large = {"bkr_prop_weed_bud_02a", -1.05}
    }
}

ESX = nil

Plants = {}
SpawnedPlants = {}
ProcessingTables = {}
SpawnedTables = {}
Dealers = {}
CurrentPlant = nil
CurrentPlantInfo = nil
CurrentTable = nil

local nearPlant = true
local shown = false
local interactive = false
local action = false
local processing = false

local infinateStamina = false
local healthRegen = false
local foodRegen = false
local cameraShake = false
local strength = false
local outOfBody = false

Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    ESX = obj
                end
            )
            Citizen.Wait(0)
        end

         while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end

        ESX.TriggerServerCallback(
            "core_drugs:getInfo",
            function(plants, process)
                Plants = plants
                ProcessingTables = process

                for k, v in pairs(Plants) do

                    spawnPlant(v.type, v.coords, v.info.growth, k)
                end

                for b, g in pairs(ProcessingTables) do
                    spawnProcessingTable(g.type, g.coords, b, g.rot)
                end
            end
        )
    end
)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(500)
    end
end

function spawnPlant(plant, coords, percent, id)

    local plantType = Config.Plants[plant].PlantType

    if percent < 30 then
        SpawnedPlants[id] =
            CreateObject(
            GetHashKey(PlantTypes[plantType].small[1]),
            coords[1],
            coords[2],
            coords[3] + PlantTypes[plantType].small[2],
            false,
            true,
            1
        )
    elseif percent < 80 then
        SpawnedPlants[id] =
            CreateObject(
            GetHashKey(PlantTypes[plantType].medium[1]),
            coords[1],
            coords[2],
            coords[3] + PlantTypes[plantType].medium[2],
            false,
            true,
            1
        )
    elseif percent <= 100 then
        SpawnedPlants[id] =
            CreateObject(
            GetHashKey(PlantTypes[plantType].large[1]),
            coords[1],
            coords[2],
            coords[3] + PlantTypes[plantType].large[2],
            false,
            true,
            1
        )
    end

    SetEntityAsMissionEntity(SpawnedPlants[id], true, true)
end

function spawnProcessingTable(type, coords, id, rot)
    local tableType = Config.ProcessingTables[type]
    SpawnedTables[id] = CreateObject(GetHashKey(tableType.Model), coords[1], coords[2], coords[3], false, true, 1)

    SetEntityAsMissionEntity(SpawnedTables[id], true, true)

    SetEntityHeading(SpawnedTables[id], rot)
end

function process(type)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, -1.2)
    local rot = GetEntityHeading(ped)

    TriggerServerEvent("core_drugs:addProcess", type, coords, rot)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, false)

        Citizen.Wait(2000)

        ClearPedTasks(ped)
end


Citizen.CreateThread(
    function()
        while true do
            if healthRegen then
                local ped = PlayerPedId()
                local health = GetEntityHealth(ped)
                SetEntityHealth(ped, health + 5)
                Citizen.Wait(3000)
            else
                Citizen.Wait(3000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if outOfBody then
                local pid = PlayerId()
                ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 3.2)
                Citizen.Wait(10000)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if cameraShake then
                local pid = PlayerId()
                ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.2)
                Citizen.Wait(1100)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if infinateStamina then
                local pid = PlayerId()
                RestorePlayerStamina(pid, 1.0)
                Citizen.Wait(0)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if true then
                TriggerEvent("esx_status:add", "hunger", 40000)
                TriggerEvent("esx_status:add", "thirst", 20000)
                Citizen.Wait(4000)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if strength then
                local pid = PlayerId()
                local ped = PlayerPedId()
                if GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_UNARMED") then
                    SetPlayerMeleeWeaponDamageModifier(pid, 2.0)
                end
                Citizen.Wait(5)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

function addEffect(effect, status)
    local ped = PlayerPedId()

    if effect == "runningSpeedIncrease" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    SetPedMoveRateOverride(PlayerId(), 10.0)
                    SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
                end
            )
        else
            SetPedMoveRateOverride(PlayerId(), 0.0)
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
    elseif effect == "infinateStamina" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    infinateStamina = true
                end
            )
        else
            infinateStamina = false
        end
    elseif effect == "moreStrength" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    strength = true
                end
            )
        else
            strength = false
        end
    elseif effect == "healthRegen" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    healthRegen = true
                end
            )
        else
            healthRegen = false
        end
    elseif effect == "foodRegen" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    foodRegen = true
                end
            )
        else
            foodRegen = false
        end
    elseif effect == "drunkWalk" then
        if status then
            Citizen.CreateThread(
                function()
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
                        Citizen.Wait(0)
                    end

                    Citizen.Wait(30000)
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", true)
                end
            )
        else
            ResetPedMovementClipset(ped, 0)
        end
    elseif effect == "psycoWalk" then
        if status then
            Citizen.CreateThread(
                function()
                    RequestAnimSet("MOVE_M@QUICK")
                    while not HasAnimSetLoaded("MOVE_M@QUICK") do
                        Citizen.Wait(0)
                    end

                    Citizen.Wait(30000)
                    SetPedMovementClipset(ped, "MOVE_M@QUICK", true)
                end
            )
        else
            ResetPedMovementClipset(ped, 0)
        end
    elseif effect == "outOfBody" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    outOfBody = true
                end
            )
        else
            ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
            outOfBody = false
        end
    elseif effect == "cameraShake" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    cameraShake = true
                end
            )
        else
            ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.0)
            cameraShake = false
        end
    elseif effect == "fogEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                    Citizen.Wait(30000)

                    AnimpostfxPlay("DrugsMichaelAliensFightIn", 100000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxStop("DrugsDrivingIn")
                    AnimpostfxPlay("DrugsDrivingOut", 20000, true)
                    AnimpostfxStop("DrugsMichaelAliensFightIn")
                    Citizen.Wait(20000)
                    AnimpostfxStop("DrugsDrivingOut")
                end
            )
        end
    elseif effect == "confusionEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("Rampage", 30000, true)
                    Citizen.Wait(30000)
                    AnimpostfxPlay("Dont_tazeme_bro", 30000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxStop("Rampage")
                    AnimpostfxStop("Dont_tazeme_bro")
                    AnimpostfxPlay("RampageOut", 20000, true)
                    Citizen.Wait(20000)
                    AnimpostfxStop("RampageOut")
                end
            )
        end
    elseif effect == "whiteoutEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                    Citizen.Wait(30000)
                    AnimpostfxPlay("PeyoteIn", 100000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingOut", 20000, true)
                    AnimpostfxPlay("PeyoteOut", 20000, true)
                    AnimpostfxStop("PeyoteIn")
                    AnimpostfxStop("DrugsDrivingIn")
                    Citizen.Wait(20000)
                    AnimpostfxStop("DrugsDrivingOut")
                    AnimpostfxStop("PeyoteOut")
                end
            )
        end
    elseif effect == "intenseEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                    Citizen.Wait(30000)
                    AnimpostfxPlay("DMT_flight_intro", 100000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingOut", 20000, true)
                    AnimpostfxStop("DMT_flight_intro")
                    AnimpostfxStop("DrugsDrivingIn")
                    Citizen.Wait(20000)
                    AnimpostfxStop("DrugsDrivingOut")
                end
            )
        end
    elseif effect == "focusEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("FocusIn", 100000, true)
                end
            )
        else
            AnimpostfxStop("FocusIn")
            AnimpostfxPlay("FocusOut", 10000, false)
        end
    end
end

function drug(type)
    local info = Config.Drugs[type]
    local ped = PlayerPedId()

    Citizen.CreateThread(
        function()
            if info.Animation == "pill" then
                loadAnimDict("mp_suicide")
                TaskPlayAnim(ped, "mp_suicide", "pill", 3.0, 3.0, 2000, 48, 0, false, false, false)
            elseif info.Animation == "sniff" then
                loadAnimDict("anim@mp_player_intcelebrationmale@face_palm")
                TaskPlayAnim(
                    ped,
                    "anim@mp_player_intcelebrationmale@face_palm",
                    "face_palm",
                    3.0,
                    3.0,
                    3000,
                    48,
                    0,
                    false,
                    false,
                    false
                )
            elseif info.Animation == "blunt" then
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(4500)
                ClearPedTasks(ped)
            end

            for _, effect in ipairs(info.Effects) do
                addEffect(effect, true)
            end

            Citizen.Wait(31000 + (info.Time * 1000))

            for _, effect in ipairs(info.Effects) do
                addEffect(effect, false)
            end
        end
    )
end

function plant(plant)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if
        GetGroundHash(ped) == -1286696947 or GetGroundHash(ped) == -1885547121 or GetGroundHash(ped) == 223086562 or
            GetGroundHash(ped) == -461750719
     then
        local canPlant = true
        for k, v in pairs(Plants) do
            if #(coords - v.coords) < 2.5 then
                canPlant = false
            end
        end

        if canPlant and not action then
            TriggerServerEvent("core_drugs:addPlant", plant, coords)
            action = true
        else
            SendTextMessage(Config.Text["cant_plant"])
        end
    else
        SendTextMessage(Config.Text["cant_plant"])
    end
end

function setPlant(id, percent)
    local plant = Plants[id].type
    local plantType = Config.Plants[plant].PlantType

    if SpawnedPlants[id] ~= nil then
        local coords = Plants[id].coords
        DeleteEntity(SpawnedPlants[id])

        if percent < 30 then
            SpawnedPlants[id] =
                CreateObject(
                GetHashKey(PlantTypes[plantType].small[1]),
                coords[1],
                coords[2],
                coords[3] + PlantTypes[plantType].small[2],
                false,
                true,
                1
            )
        elseif percent < 80 then
            SpawnedPlants[id] =
                CreateObject(
                GetHashKey(PlantTypes[plantType].medium[1]),
                coords[1],
                coords[2],
                coords[3] + PlantTypes[plantType].medium[2],
                false,
                true,
                1
            )
        elseif percent <= 100 then
            SpawnedPlants[id] =
                CreateObject(
                GetHashKey(PlantTypes[plantType].large[1]),
                coords[1],
                coords[2],
                coords[3] + PlantTypes[plantType].large[2],
                false,
                true,
                1
            )
        end

        SetEntityAsMissionEntity(SpawnedPlants[id], true, true)
    else
        Citizen.Trace("Plant not found!")
    end
end

RegisterNUICallback(
    "feed",
    function(data)
        local percent = 0
        local item = nil

        for _, i in ipairs(ESX.GetPlayerData().inventory) do
            for k, v in pairs(Config.PlantFood) do
                if i.name == k and i.count > 0 then
                    percent = v
                    item = k
                end
                break
            end
        end

        if percent > 0 then
            CurrentPlantInfo.food = CurrentPlantInfo.food + percent
            if CurrentPlantInfo.food > 100 then
                CurrentPlantInfo.food = 100
            end
            TriggerServerEvent("core_drugs:updatePlant", CurrentPlant, CurrentPlantInfo)
            TriggerServerEvent("core_drugs:removeItem", item, 1)

            SendNUIMessage(
                {
                    type = "updatePlant",
                    info = CurrentPlantInfo
                }
            )
        end
    end
)

RegisterNUICallback(
    "water",
    function(data)
        local percent = 0
        local item = nil

        for _, i in ipairs(ESX.GetPlayerData().inventory) do
            for k, v in pairs(Config.PlantWater) do
                if i.name == k and i.count > 0 then
                    percent = v
                    item = k
                end
                break
            end
        end

        if percent > 0 then
            CurrentPlantInfo.water = CurrentPlantInfo.water + percent
            if CurrentPlantInfo.water > 100 then
                CurrentPlantInfo.water = 100
            end
            TriggerServerEvent("core_drugs:updatePlant", CurrentPlant, CurrentPlantInfo)
            TriggerServerEvent("core_drugs:removeItem", item, 1)

            SendNUIMessage(
                {
                    type = "updatePlant",
                    info = CurrentPlantInfo
                }
            )
        end
    end
)

RegisterNUICallback(
    "harvest",
    function(data)
        if action then
            return
        end

        action = true
        local ped = PlayerPedId()
        TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, false)

        SendNUIMessage(
            {
                type = "hidePlant"
            }
        )

        Citizen.Wait(Config.Plants[Plants[CurrentPlant].type].Time)

        if SpawnedPlants[CurrentPlant] ~= nil then
            DeleteEntity(SpawnedPlants[CurrentPlant])
        end

        TriggerServerEvent("core_drugs:deletePlant", CurrentPlant)
        TriggerServerEvent("core_drugs:harvest", Plants[CurrentPlant].type, CurrentPlantInfo)
        Plants[CurrentPlant] = nil
        SpawnedPlants[CurrentPlant] = nil
        CurrentPlant = nil
        CurrentPlantInfo = nil

        ClearPedTasks(ped)
        Citizen.Wait(4000)
        action = false
        ClearPedTasksImmediately(ped)
    end
)

RegisterNUICallback(
    "close",
    function(data)
        TriggerServerEvent("core_drugs:tableStatus", CurrentTable, true)
        CurrentTable = nil
        processing = false
        ClearPedTasks(PlayerPedId())
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "process",
    function(data)
        local table, amount, time = data["type"], data["amount"], data["time"]

        Citizen.CreateThread(
            function()
                local ped = PlayerPedId()
                processing = true
                TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, false)
                Citizen.Wait(time)

                if (processing) then
                    ClearPedTasks(ped)

                    TriggerServerEvent("core_drugs:processed", table, amount)

                    processing = false
                end
            end
        )
    end
)

RegisterNUICallback(
    "deleteTable",
    function(data)
        DeleteEntity(SpawnedTables[CurrentTable])
        TriggerServerEvent("core_drugs:deleteTable", CurrentTable, ProcessingTables[CurrentTable].type)
        ProcessingTables[CurrentTable] = nil
        SpawnedTables[CurrentTable] = nil
        CurrentTable = nil
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "destroy",
    function(data)
        if action then
            return
        end

        local ped = PlayerPedId()
        action = true
        TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, false)

        SendNUIMessage(
            {
                type = "hidePlant"
            }
        )

        Citizen.Wait(2000)

        if SpawnedPlants[CurrentPlant] ~= nil then
            DeleteEntity(SpawnedPlants[CurrentPlant])
        end
        Plants[CurrentPlant] = nil
        SpawnedPlants[CurrentPlant] = nil

        TriggerServerEvent("core_drugs:deletePlant", CurrentPlant)
        CurrentPlant = nil
        CurrentPlantInfo = nil

        ClearPedTasks(ped)
        Citizen.Wait(4000)
        action = false
        ClearPedTasksImmediately(ped)
    end
)

function GetGroundHash(ped)
    local posped = GetEntityCoords(ped)
    local num =
        StartShapeTestCapsule(posped.x, posped.y, posped.z + 4, posped.x, posped.y, posped.z - 2.0, 2, 1, ped, 7)
    local arg1, arg2, arg3, arg4, arg5 = GetShapeTestResultEx(num)
    return arg5
end

function nearPlant(ped)
    for k, v in pairs(Plants) do
        if #(v.coords - GetEntityCoords(ped)) < 1.3 then
            return k
        end
    end

    return false
end

function nearProccesing(ped)
    for k, v in pairs(ProcessingTables) do
        if #(v.coords - GetEntityCoords(ped)) < 2.0 then
            return k
        end
    end

    return false
end

RegisterNetEvent("core_drugs:sendMessage")
AddEventHandler(
    "core_drugs:sendMessage",
    function(msg)
        SendTextMessage(msg)
    end
)

RegisterNetEvent("core_drugs:changeTableStatus")
AddEventHandler(
    "core_drugs:changeTableStatus",
    function(id, status)
        ProcessingTables[id].usable = status
    end
)

RegisterNetEvent("core_drugs:growPlant")
AddEventHandler(
    "core_drugs:growPlant",
    function(id, percent)
        if Plants[id] ~= nil and SpawnedPlants[id] ~= nil then
            setPlant(id, percent)
        end
    end
)

RegisterNetEvent("core_drugs:growthUpdate")
AddEventHandler(
    "core_drugs:growthUpdate",
    function()
        if CurrentPlantInfo ~= nil then
            CurrentPlantInfo.water = CurrentPlantInfo.water - (0.02 * CurrentPlantInfo.rate)
            CurrentPlantInfo.food = CurrentPlantInfo.food - (0.02 * CurrentPlantInfo.rate)
            CurrentPlantInfo.growth = CurrentPlantInfo.growth + (0.01 * CurrentPlantInfo.rate)

            SendNUIMessage(
                {
                    type = "updatePlant",
                    info = CurrentPlantInfo
                }
            )
        end
    end
)

RegisterNetEvent("core_drugs:addProcess")
AddEventHandler(
    "core_drugs:addProcess",
    function(type, coords, id, rot)
        local ped = PlayerPedId()
        ProcessingTables[id] = {type = type, coords = coords, usable = true}
       

        Citizen.Wait(2000)

      
        spawnProcessingTable(type, coords, id, rot)
        action = false
    end
)

RegisterNetEvent("core_drugs:addPlant")
AddEventHandler(
    "core_drugs:addPlant",
    function(type, coords, id)
        local plantType = Config.Plants[type].PlantType

        local ped = PlayerPedId()
        Plants[id] = {type = type, coords = coords}
        TaskStartScenarioInPlace(ped, "world_human_gardener_plant", 0, false)

        Citizen.Wait(2000)

        ClearPedTasks(ped)

        SpawnedPlants[id] =
            CreateObject(
            GetHashKey(PlantTypes[plantType].small[1]),
            coords[1],
            coords[2],
            coords[3] + PlantTypes[plantType].small[2],
            false,
            true,
            1
        )

        SetEntityAsMissionEntity(SpawnedPlants[id], true, true)  
        action = false
    end
)

RegisterNetEvent("core_drugs:drug")
AddEventHandler(
    "core_drugs:drug",
    function(type)
        drug(type)
    end
)

RegisterNetEvent("core_drugs:plant")
AddEventHandler(
    "core_drugs:plant",
    function(type)
        plant(type)
    end
)

RegisterNetEvent("core_drugs:process")
AddEventHandler(
    "core_drugs:process",
    function(type)
        process(type)
    end
)

Citizen.CreateThread(
    function()
        for _, v in ipairs(Config.Zones) do
            if v.Display then
                local radius = AddBlipForRadius(v.Coords, v.Radius)

                SetBlipSprite(radius, 9)
                SetBlipColour(radius, v.DisplayColor)
                SetBlipAlpha(radius, 75)

                local blip = AddBlipForCoord(v.Coords)

                SetBlipSprite(blip, v.DisplayBlip)
                SetBlipColour(blip, v.DisplayColor)
                SetBlipAsShortRange(blip, true)
                SetBlipScale(blip, 0.9)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.DisplayText)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        local ped = PlayerPedId()

        for _, v in ipairs(Config.Dealers) do
            local Model = GetHashKey(v.Ped)
            if not HasModelLoaded(Model) then
                RequestModel(Model)
                while not HasModelLoaded(Model) do
                    Citizen.Wait(5)
                end
            end

            local ped = CreatePed(4, v.Ped, v.Coords, v.Heading, false, true)

            TaskSetBlockingOfNonTemporaryEvents(ped, 1)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetPedRandomComponentVariation(ped)
            SetPedRandomProps(ped)
            SetPedCanRagdoll(ped, true)
            SetEntityCollision(ped, 1, 0)

            table.insert(Dealers, ped)
        end

        while true do
            for _, v in ipairs(Config.Dealers) do
                local coords = GetEntityCoords(ped)
                if #(v.Coords - coords) < 2 then
                    Citizen.Wait(1)
                    DrawText3D(v.Coords[1], v.Coords[2], v.Coords[3] + 1.2, Config.Text["dealer_holo"])

                    if IsControlJustReleased(0, 51) then
                        TriggerServerEvent("core_drugs:sellDrugs", v.Prices)
                    end
                else
                    Citizen.Wait(1000)
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(5000)

        local ped = PlayerPedId()

        while true do
            local nPlant = nearPlant(ped)
            local nProcess = nearProccesing(ped)

            if nPlant ~= false then
                if not shown then
                    shown = true

                    SendNUIMessage(
                        {
                            type = "showPlant",
                            plantType = Plants[nPlant].type,
                            plants = Config.Plants,
                            plant = nPlant
                        }
                    )

                    ESX.TriggerServerCallback(
                        "core_drugs:getPlant",
                        function(info)
                            CurrentPlant = nPlant

                            CurrentPlantInfo = info

                            SendNUIMessage(
                                {
                                    type = "updatePlant",
                                    info = info
                                }
                            )
                        end,
                        nPlant
                    )
                end

                if IsControlPressed(0, 19) then
                    if not interactive then
                        interactive = true
                        SetNuiFocus(true, true)
                    end
                else
                    Citizen.Wait(10)
                    if interactive then
                        SetNuiFocus(false, false)
                        interactive = false
                    end
                end
            else
                if shown then
                    CurrentPlant = nil
                    CurrentPlantInfo = nil

                    SendNUIMessage(
                        {
                            type = "hidePlant"
                        }
                    )
                    shown = false
                end
            end

            if nProcess ~= false then
                local tableCoords = ProcessingTables[nProcess].coords
                DrawText3D(tableCoords[1], tableCoords[2], tableCoords[3] + 1.0, Config.Text["processing_table_holo"])

                if IsControlJustReleased(0, 51) and ProcessingTables[nProcess].usable then
                    SetNuiFocus(true, true)

                    local inv = {}
                    for _, v in ipairs(ESX.GetPlayerData().inventory) do
                        inv[v.name] = v.count
                    end

                    CurrentTable = nProcess

                    TriggerServerEvent("core_drugs:tableStatus", nProcess, false)
                    SendNUIMessage(
                        {
                            type = "showProcessing",
                            tables = Config.ProcessingTables,
                            process = ProcessingTables[nProcess].type,
                            inventory = inv
                        }
                    )
                end
            else
            end

            if nProcess == false and nPlant == false then
                Citizen.Wait(1000)
            else
                Citizen.Wait(1)
            end
        end
    end
)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0 * scale, 0.45 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)

        SetTextDropshadow(1, 1, 1, 1, 255)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.55 * scale, 4)
        local width = EndTextCommandGetWidth(4)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

AddEventHandler(
    "playerDropped",
    function(reason)
        TriggerServerEvent("core_drugs:tableStatus", CurrentTable, true)
    end
)
