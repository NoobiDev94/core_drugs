
-- SEED USABLE ITEM REGISTER
-- Register every seed only changing the name of it between ''
--inicio

ESX.RegisterUsableItem('weed_lemonhaze_seed', function(playerId)
		plant(playerId, 'weed_lemonhaze_seed')
end)

ESX.RegisterUsableItem('coca_seed', function(playerId)
		plant(playerId, 'coca_seed')
end)

-- DRUGS USABLE ITEM REGISTER
-- Register every drug only changing the name of it between ''

ESX.RegisterUsableItem('weed_lemonhaze', function(playerId)
		drug(playerId, 'weed_lemonhaze')
end)

ESX.RegisterUsableItem('cocaine', function(playerId)
		drug(playerId, 'cocaine')
end)

-- PROCCESING TABLE ITEM REGISTER
-- Register every proccesing table only changing the name of it between ''

ESX.RegisterUsableItem('cocaine_processing_table', function(playerId)
		proccesing(playerId, 'cocaine_processing_table')
end)

