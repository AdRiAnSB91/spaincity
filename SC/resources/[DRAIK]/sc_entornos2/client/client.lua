
---------------------------------
blipTime = 180 
blipRadius = 30.0 
botonable = false

TriggerEvent("chat:addSuggestion", "/entorno", "Avisa a las autoridades.", {
    { name = "Alerta", help = "Obligatorio para rol!"}
})

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	local xPlayer = ESX.GetPlayerData()
end)

RegisterCommand('entorno', function(source, args)
local name = GetPlayerName(PlayerId())
local ped = GetPlayerPed(PlayerId())
local x, y, z = table.unpack(GetEntityCoords(ped, true))
local street = GetStreetNameAtCoord(x, y, z)
local location = GetStreetNameFromHashKey(street)
local msg = table.concat(args, ' ')

    if args[1] == nil then
        TriggerEvent('chatMessage', '[^2LLAMADA^0]', {255,255,255}, '^1^*EL ENTORNO NO PUEDE ESTAR EN BLANCO.^0')
    end
    if args[1] ~= nil then
      if not(string.find(args[1], "<style>")) then 

        TriggerServerEvent('llamarcnp', location, msg, x, y, z, name)
        ExecuteCommand("JHSDJAHDJAKDHJSDHUHNJHNLSHJDA ^2^*Un entorno ha sido enviado en tu zona: ^0"..msg..".")
        TriggerEvent("HSJDAJDHDVGSAJ",  msg)
      else
        TriggerServerEvent("GSDTGFVABHYDTGFABDU7TGH","STYLE")
      end

    end
end)
RegisterNetEvent('HSJDAJDHDVGSAJ')
AddEventHandler('HSJDAJDHDVGSAJ', function(msg)
local args = msg
local ped = GetPlayerPed(PlayerId())
local x, y, z = table.unpack(GetEntityCoords(ped, true))
local street = GetStreetNameAtCoord(x, y, z)
local location = GetStreetNameFromHashKey(street)
local pos = GetEntityCoords(GetPlayerPed(-1))
local dist = CalculateTravelDistanceBetweenPoints(x,y,z,pos.x,pos.y,pos.z) / 1000
TriggerServerEvent("PUTOSENTORNOS", source, args, location, args,x,y)

TriggerServerEvent('trew_hud_ui:adminNotifyAllPlayers', {"ENTORNO", ""..msg.."", "red"})


end)

RegisterNetEvent('AJHD')
AddEventHandler('AJHD', function(id, name, location, args,x,y)
  local myId = PlayerId()
  local pid = GetPlayerFromServerId(id)
	local xPlayer = ESX.GetPlayerData()
	if xPlayer.job.name == 'cnp' or  xPlayer.job.name == 'military' then
        botonable = true
		SendNUIMessage({ action = 'sendNotification', title = "ENTORNO", message = "Llamada  en  "..location.." </br>  Contenido: "..args.."</br> <b style='color:#3efe00'>[H Recibido] </b>", type = "red" })

end


end)

RegisterNetEvent('TERECIBOYTEMARCO')
AddEventHandler('TERECIBOYTEMARCO', function(x,y)
  SetNewWaypoint(x, y)
end)

RegisterNetEvent('setBlip')
AddEventHandler('setBlip', function(name, x, y, z)
blip = nil
blips = {}
Citizen.CreateThread(function()
  botonable = true 
  while botonable do
    if IsControlJustReleased(1, 304) then
      TriggerServerEvent("TEMARCOENEELMAPA")
      SendNUIMessage({ action = 'sendNotification', title = "ENTORNO", message = "Has aceptado la llamada", type = "red" })
      botonable = false

    end
    Citizen.Wait(0)
  end 
end)
local blip = AddBlipForRadius(x, y, z, blipRadius)
	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, 2)
	SetBlipAlpha (blip, 128)
local blip1 = AddBlipForCoord(x, y, z)
	SetBlipSprite (blip1, sprite)
	SetBlipDisplay(blip1, true)
	SetBlipScale  (blip1, 0.9)
	SetBlipColour (blip1, 2)
    SetBlipAsShortRange(blip1, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Entorno - " .. name)
    EndTextCommandSetBlipName(blip1)
    table.insert(blips, blip1)
    Wait(blipTime * 1000)
    for i, blip1 in pairs(blips) do 
        RemoveBlip(blip)
        RemoveBlip(blip1)
    end
end)


----------------------------ENTORNOS-----------------------------



RegisterCommand("forzar", function(source, args)
  local playername = GetPlayerName(PlayerId())
  local ped = GetPlayerPed(PlayerId())
  local x, y, z = table.unpack(GetEntityCoords(ped, true))
  local street = GetStreetNameAtCoord(x, y, z)
  local location = GetStreetNameFromHashKey(street)
  local estaDentro = IsPedInAnyVehicle(ped, false)
  local model = GetEntityModel(veh)
  local vehicleModel = GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))
  local vehiculo = GetVehiclePedIsIn(ped)
  local primary = GetVehicleColours(vehiculo)
  primary = Config.colorNames[tostring(primary)]
  local modelo = GetDisplayNameFromVehicleModel(vehicleModel)
  local matricula = GetVehicleNumberPlateText(vehiculo)

  if estaDentro then
    ExecuteCommand("entorno Hola buenas soy la vieja de siempre, veo a una persona robar un "..modelo.." de color "..primary.." y con matricula "..matricula..", AYUDA!")
  else
    ESX.ShowNotification("~y~No estas en ningún vehiculo~y~") 
  end
end)






Config.colorNames = {
  ['0'] = "Negro metálico",
  ['1'] = "Negro grafito metálico",
  ['2'] = "Robo negro metálico",
  ['3'] = "Plata oscura metalizada",
  ['4'] = "Plata metálica",
  ['5'] = "Azul metálico plateado",
  ['6'] = "Gris metálico de acero",
  ['7'] = "Plata metálica sombra",
  ['8'] = "Plata de piedra metálica",
  ['9'] = "Plata metálica de medianoche",
  ['10'] = "Pistola metálica de metal",
  ['11'] = "Gris antracita metálico",
  ['12'] = "Negro mate",
  ['13'] = "Gris mate",
  ['14'] = "Gris claro mate",
  ['15'] = "Util Black",
  ['16'] = "Util Black Poly",
  ['17'] = "Util plata oscura",
  ['18'] = "Util Silver",
  ['19'] = "Util Gun Metal",
  ['20'] = "Util Shadow Silver",
  ['21'] = "Negro desgastado",
  ['22'] = "Grafito desgastado",
  ['23'] = "Gris plateado gastado",
  ['24'] = "Plata gastada",
  ['25'] = "Plata azul gastada",
  ['26'] = "Plata de sombra gastada",
  ['27'] = "Rojo metálico",
  ['28'] = "Rojo Torino Metálico",
  ['29'] = "Fórmula metálica roja",
  ['30'] = "Rojo metálico resplandor",
  ['31'] = "Rojo metálico elegante",
  ['32'] = "Rojo granate metálico",
  ['33'] = "Rojo metálico del desierto",
  ['34'] = "Rojo Cabernet metálico",
  ['35'] = "Rojo caramelo metálico",
  ['36'] = "Naranja metálico del amanecer",
  ['37'] = "Oro clásico metálico",
  ['38'] = "Naranja Metálico",
  ['39'] = "Rojo mate",
  ['40'] = "Rojo oscuro mate",
  ['41'] = "Naranja mate",
  ['42'] = "Amarillo mate",
  ['43'] = "Util Red",
  ['44'] = "Util rojo brillante",
  ['45'] = "Util Garnet Red",
  ['46'] = "Rojo desgastado",
  ['47'] = "Rojo dorado desgastado",
  ['48'] = "Rojo oscuro desgastado",
  ['49'] = "Verde oscuro metalizado",
  ['50'] = "Metallic Racing Green",
  ['51'] = "Verde Mar Metálico",
  ['52'] = "Verde oliva metálico",
  ['53'] = "Verde metálico",
  ['54'] = "Gasolina Metálica Azul Verde",
  ['55'] = "Verde lima mate",
  ['56'] = "Util verde oscuro",
  ['57'] = "Util Green",
  ['58'] = "Verde oscuro desgastado",
  ['59'] = "Verde desgastado",
  ['60'] = "Lavado de mar gastado",
  ['61'] = "Azul metálico de medianoche",
  ['62'] = "Azul metálico oscuro",
  ['63'] = "Azul metálico de Sajonia",
  ['64'] = "Azul metálico",
  ['65'] = "Azul marino metálico",
  ['66'] = "Azul metálico del puerto",
  ['67'] = "Azul Diamante Metálico",
  ['68'] = "Azul metálico de surf",
  ['69'] = "Azul náutico metálico",
  ['70'] = "Azul metálico brillante",
  ['71'] = "Azul metalizado morado",
  ['72'] = "Azul metálico de spinnaker",
  ['73'] = "Metallic Ultra Blue",
  ['74'] = "Azul metálico brillante",
  ['75'] = "Util Azul Oscuro",
  ['76'] = "Util Midnight Blue",
  ['77'] = "Util Blue",
  ['78'] = "Util Sea Foam Blue",
  ['79'] = "Uil Lightning blue",
  ['80'] = "Util Maui Blue Poly",
  ['81'] = "Util Bright Blue",
  ['82'] = "Azul oscuro mate",
  ['83'] = "Azul mate",
  ['84'] = "Azul medianoche mate",
  ['85'] = "Azul oscuro desgastado",
  ['86'] = "Azul desgastado",
  ['87'] = "Azul claro desgastado",
  ['88'] = "Taxi metálico amarillo",
  ['89'] = "Raza metálica amarilla",
  ['90'] = "Bronce metálico",
  ['91'] = "Amarillo Metálico",
  ['92'] = "Cal metálica",
  ['93'] = "Champán metálico",
  ['94'] = "Pueblo Beige metálico",
  ['95'] = "Marfil oscuro metálico",
  ['96'] = "Marrón Choco Metálico",
  ['97'] = "Marrón dorado metálico",
  ['98'] = "Marrón claro metálico",
  ['99'] = "Beige pajizo metálico",
  ['100'] = "Marrón musgo metálico",
  ['101'] = "Marrón de pistón metálico",
  ['102'] = "Madera de haya metálica",
  ['103'] = "Madera de haya oscura metálica",
  ['104'] = "Naranja Choco Metálico",
  ['105'] = "Arena metálica de playa",
  ['106'] = "Arena Metálica Bleeched Sun",
  ['107'] = "Crema metálica",
  ['108'] = "Util Brown",
  ['109'] = "Util Medium Brown",
  ['110'] = "Util marrón claro",
  ['111'] = "Blanco metálico",
  ['112'] = "Blanco Frost Metálico",
  ['113'] = "Miel Beige desgastado",
  ['114'] = "Marrón gastado",
  ['115'] = "Marrón oscuro desgastado",
  ['116'] = "Color beige paja gastado",
  ['117'] = "Acero cepillado",
  ['118'] = "Acero negro cepillado",
  ['119'] = "Aluminio cepillado",
  ['120'] = "Chrome",
  ['121'] = "Desgastado Blanco",
  ['122'] = "Util Off White",
  ['123'] = "Naranja gastada",
  ['124'] = "Naranja claro gastado",
  ['125'] = "Verde metálico Securicor",
  ['126'] = "Taxi amarillo desgastado",
  ['127'] = "coche de policía azul",
  ['128'] = "Verde mate",
  ['129'] = "Marrón mate",
  ['130'] = "Naranja gastada",
  ['131'] = "Blanco mate",
  ['132'] = "Blanco desgastado",
  ['133'] = "Ejército verde oliva desgastado",
  ['134'] = "Blanco puro",
  ['135'] = "Rosa fuerte",
  ['136'] = "Rosa salmón",
  ['137'] = "Rosa metalizado bermellón",
  ['138'] = "Naranja",
  ['139'] = "Verde",
  ['140'] = "Azul",
  ['141'] = "Mettalic Black Blue",
  ['142'] = "Negro metalizado morado",
  ['143'] = "Negro metalizado rojo",
  ['144'] = "verde cazador",
  ['145'] = "Púrpura metálico",
  ['146'] = "Metaillic V Dark Blue",
  ['147'] = "MODSHOP BLACK1",
  ['148'] = "Púrpura mate",
  ['149'] = "Púrpura oscuro mate",
  ['150'] = "Rojo metálico lava",
  ['151'] = "Verde bosque mate",
  ['152'] = "Malva Oliva mate",
  ['153'] = "Marrón Desierto Mate",
  ['154'] = "Bronceado mate del desierto",
  ['155'] = "Verde mate de foilaje",
  ['156'] = "COLOR DE ALEACIÓN PREDETERMINADO",
  ['157'] = "Epsilon Blue",
}

