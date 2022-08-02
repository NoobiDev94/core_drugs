Config = {

    OnlyZones = false, -- Se true, somente poderá plantar nas zonas definidas
    GlobalGrowthRate = 10, -- In how many seconds it takes to update the plant (At 100% rate plant will grow 1% every update)
    DefaultRate = 10, -- Plants planted outside zone default growth rate percentage
    WeightSystem = true, -- Ignorar
    NPCDealer = true, -- Se for utilizar o sistema de venda por NPC do proprio script, deixar true.
    TimeDelayNui = 3000, --Ao plantar é importante definir quanto tempo a NUi demora pra aparecer. Nunca deixe 0.
    CheckDbIfExist = true, -- Após primeiro starte pode desabilitar, ou deixei para sempre verificar estado do banco de dados.
    
    
    Zones = {
    
        {
            Coords = vector3(1854.1574707031,4907.66015625,44.745887756348),
            Radius = 100.0,
            GrowthRate = 30.0,
            Display = true,
            DisplayBlip = 469, -- Select blip from (https://docs.fivem.net/docs/game-references/blips/)
            DisplayColor = 2, -- Select blip color from (https://docs.fivem.net/docs/game-references/blips/)
            DisplayText = 'Fertilizada para coca',
            Exclusive = {'semente-coca'} -- Types of drugs that will be affected in this are.
        }
        
    },
    
    PlantWater = {
      ['agua'] = 10 -- Item e porcentagem para aguar a planta
    },
    
    PlantFood = {
      ['fertilizante'] = 15 -- Item e procentagem para ajudar a planta crescer aos er consumido
    },
    
    
    Plants = { -- Create seeds for drugs
    
        ['semente-coca']  = { -- Index do item
            NameItem = 'Somente de coca', -- Nome da semente que aparece na NUI
            Label = 'Coca Plant', --Nome da planta que aparece abaixo do nome da semente na NUI
            Type = 'semente-coca', -- Index do item
            Image = 'coca.png', -- Nome do PNG do icone da planta que aparece no topo da NUI
            PlantType = 'plant2', -- Tipo do prop ao ser plantado (plant1, plant2, small_plant) voce pode ver as opções em main/client.lua line: 2
            Color = '255, 255, 255', -- Cor em RGB da font na NUI
            Produce = 'folhas-coca', -- Item que recebe ao colher
            RobberyPermission = true,
            Permission = true, -- Se esse item precisa de permissão para plantar
            PermissionGroup = "manager.permissao", -- Permissão para plantar
            Amount = 3, -- O maximo que pode ser colhido
            SeedChance = 50, -- Porcentagem de ao colher ganhar uma semente
            Time = 30, -- Tempo até a colheita (Em milisegundos)
            AmountSeed = 2, -- Quantidade de sementes consumidar ao plantar.
            Ratebonus = 50 -- Aqui voce define a qualidade que a planta tem que ter para a colheita ter um bonus
        }
    
    },
    
    ProcessingTables = { -- Create processing table
        
            ['molas'] = {
    
                Label = 'Cocaina', --Nome do item que será processado
                Model = 'bkr_prop_coke_table01a', -- Tipos de bancadas: bkr_prop_weed_table_01a, bkr_prop_meth_table01a, bkr_prop_coke_table01a
                Color = '255, 255, 255', -- Cor da font em RGB que aparece na NUI
                Item = 'cocaina', -- Ao produzir que item recebe
                RobberyPermission = true,
                Permission = true, -- Se precisa de permissão para produzir esse item
                PermissionGroup = "manager.permissao", -- Permissão para produzir esse item
                Time = 10, -- Tempo em segundos para fazer 1 item
                Ingrediants = { -- itens para produzir
                    ['folhas-coca'] = 3,
                    ['dinheiro'] = 1
                }
    
                }
    
    },
    
    Drugs = { -- Create you own drugs
        
        ['weed_lemonhaze'] = {
    
            Label = 'Lemon Haze',
            Animation = 'blunt', -- Animations: blunt, sniff, pill
            Time = 3, -- Time is added on top of 30 seconds
            Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
                'intenseEffect',
                'healthRegen',
                'moreStrength',
                'drunkWalk'
            }
            
        },
        ['cocaine'] = {
    
            Label = 'Cocaine',
            Animation = 'sniff', -- Animations: blunt, sniff, pill
            Time = 6, -- Time is added on top of 30 seconds
            Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
                'runningSpeedIncrease',
                'infinateStamina',
                'fogEffect',
                'psycoWalk'
            }
            
        }
    
    },
    
    Dealers = {
        
            {
                Ped = 'g_m_importexport_01',
                Coords = vector3(167.51689147949,6631.5473632813,30.527015686035),
                Heading = 200.0,
                Prices = {
                    ['weed_lemonhaze'] = 10 -- Item name and price for 1
                }
            }
    
    },
    
    
    
    Text = { 
        ['planted'] = 'Seed was planted!',
        ['feed'] = 'Plant was fed!',
        ['water'] = 'Plant was watered!',
        ['destroy'] = 'Plant was destroyed!',
        ['harvest'] = 'You harvested the plant!',
        ['cant_plant'] = 'You cant plant here!',
        ['processing_table_holo'] = '~r~E~w~  Processing Table',
        ['cant_hold'] = 'You dont have space for this item!',
        ['missing_ingrediants'] = 'You dont have these ingrediants',
        ['dealer_holo'] = '~g~E~w~  Sell drugs',
        ['sold_dealer'] = 'You sold drugs to dealer! +$',
        ['no_drugs'] = 'You dont have enough drugs',
        ['success_process'] = 'Você produziu ',
        ['no_permission'] = 'Você não possuem habilidades para fazer essa ação desejada.',
        ['no_robbery'] = 'Não mexa no que não é seu!',
        ['no_table'] = 'Você não possue bancada!'
    }
    
    }
    function PlantProgress(source, itemName)
    
        TriggerClientEvent('nbi_inventory:Update', source, 'updateInventory')
        TriggerClientEvent('progress', source, 10000, 'plantando')
        TriggerClientEvent('itensNotify', source, 'use', 'Plantando', '' .. itemName .. '')
        
    end
    
    -- Only change if you know what are you doing!
    function SendTextMessage(source, msg, type)
    
            local source = source
            TriggerEvent("Notify",type,msg,6000)
    
    
    end
    
    