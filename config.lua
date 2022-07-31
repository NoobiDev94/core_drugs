Config = {

OnlyZones = false, -- Allow drug growth only in defined zones
GlobalGrowthRate = 10, -- In how many seconds it takes to update the plant (At 100% rate plant will grow 1% every update)
DefaultRate = 10, -- Plants planted outside zone default growth rate percentage
WeightSystem = true, -- Using ESX Weight System

Zones = {

	{
		Coords = vector3(1854.1574707031,4907.66015625,44.745887756348),
		Radius = 100.0,
		GrowthRate = 30.0,
		Display = true,
		DisplayBlip = 469, -- Select blip from (https://docs.fivem.net/docs/game-references/blips/)
		DisplayColor = 2, -- Select blip color from (https://docs.fivem.net/docs/game-references/blips/)
		DisplayText = 'Weed Zone',
		Exclusive = {'weed_lemonhaze_seed'} -- Types of drugs that will be affected in this are.
	}
	
},

PlantWater = {
  ['water'] = 10 -- Item and percent it adds to overall plant water  
},

PlantFood = {
  ['fertilizer'] = 15 -- Item and percent it adds to overall plant food  
},


Plants = { -- Create seeds for drugs
    
    ['weed_lemonhaze_seed'] = {
        Label = 'Lemon Haze', -- 
        Type = 'weed', -- Type of drug
        Image = 'weed.png', -- Image of plant
        PlantType = 'plant1', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
        Color = '122, 232, 19', -- Main color of the plant rgb
        Produce = 'weed_lemonhaze', -- Item the plant is going to produce when harvested
        Amount = 3, -- The max amount you can harvest from the plant
        SeedChance = 50, -- Percent of getting back the seed
        Time = 3000 -- Time it takes to harvest in miliseconds
    },
    ['coca_seed'] = {
        Label = 'Coca Plant', -- 
        Type = 'cocaine', -- Type of drug
        Image = 'coca.png', -- Image of plant
        PlantType = 'plant2', -- Choose plant types from (plant1, plant2, small_plant) also you can change plants yourself in main/client.lua line: 2
        Color = '255, 255, 255', -- Main color of the plant rgb
        Produce = 'coca', -- Item the plant is going to produce when harvested
        Amount = 3, -- The max amount you can harvest from the plant
        SeedChance = 50, -- Percent of getting back the seed
        Time = 3000 -- Time it takes to harvest in miliseconds
    }

},

ProcessingTables = { -- Create processing table
    
        ['cocaine_processing_table'] = {

            Label = 'Cocaine',
            Model = 'bkr_prop_coke_table01a', -- Exanples: bkr_prop_weed_table_01a, bkr_prop_meth_table01a, bkr_prop_coke_table01a
            Color = '255, 255, 255', -- Color in RGB
            Item = 'cocaine', -- Processed item
            Time = 10, -- Time in seconds to process 1 item
            Ingrediants = {
                ['coca'] = 3,
                ['fuel'] = 1
            }

            }

},

Drugs = { -- Create you own drugs
    
    ['weed_lemonhaze'] = {

    	Label = 'Lemon Haze',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
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
        Time = 60, -- Time is added on top of 30 seconds
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
    ['no_drugs'] = 'You dont have enough drugs'
}

}

-- Only change if you know what are you doing!
function SendTextMessage(msg)

        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(0,1)

        --EXAMPLE USED IN VIDEO
        --exports['mythic_notify']:DoHudText('error', msg)

end

