
-- SEED USABLE ITEM REGISTER
-- Register every seed only changing the name of it between ''


RegisterServerEvent("core_drugs:Plantar")
AddEventHandler(
    "core_drugs:Plantar",
    function(type)
		plant(type)
    end
)
RegisterServerEvent("core_drugs:UsarDroga")
AddEventHandler(
    "core_drugs:UsarDroga",
    function(source, type)
		drug(source, type)
    end
)
--[[]
-- PROCCESING TABLE ITEM REGISTER
-- Register every proccesing table only changing the name of it between ''

ESX.RegisterUsableItem('cocaine_processing_table', function(playerId)
		proccesing(playerId, 'cocaine_processing_table')
end)
]]
