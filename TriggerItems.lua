local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")
vRP = Proxy.getInterface("vRP")
coRE = {}
coRE = Tunnel.getInterface("core_drugs")


--  TriggerServerEvent("core_drugs:Produzir", source, "nome do item configurado")

RegisterServerEvent("core_drugs:Produzir")
AddEventHandler(
    "core_drugs:Produzir",
    function(source, type)

				proccesing(source, type)
			
			
		
    end
)

--  TriggerServerEvent("core_drugs:Plantar", source, "nome do item configurado")

RegisterServerEvent("core_drugs:Plantar")
AddEventHandler(
    "core_drugs:Plantar",
    function(source, type)

				plant(source, type)
	
    end
)

--  TriggerServerEvent("core_drugs:UsarDroga", source, "nome do item configurado")

RegisterServerEvent("core_drugs:UsarDroga")
AddEventHandler(
    "core_drugs:UsarDroga",
    function(source, type)
		drug(source, type)
    end
)
