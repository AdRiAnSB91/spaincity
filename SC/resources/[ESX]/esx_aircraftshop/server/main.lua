ESX              = nil
local Categories = {}
local Vehicles   = {}
local hasSqlRun  = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'aircraftdealer', _U('dealer_customers'), false, false)
TriggerEvent('esx_society:registerSociety', 'aircraftdealer', _U('aircraft_dealer'), 'society_aircraftdealer', 'society_aircraftdealer', 'society_aircraftdealer', {type = 'private'})

function RemoveOwnedVehicle(plate)
	MySQL.Async.execute('DELETE FROM owned_aircrafts WHERE plate = @plate', {
		['@plate'] = plate
	})
end

MySQL.ready(function()
	Categories     = MySQL.Sync.fetchAll('SELECT * FROM aircraft_categories')
	local vehicles = MySQL.Sync.fetchAll('SELECT * FROM aircrafts')

	for i=1, #vehicles, 1 do
		local vehicle = vehicles[i]

		for j=1, #Categories, 1 do
			if Categories[j].name == vehicle.category then
				vehicle.categoryLabel = Categories[j].label
				break
			end
		end

		table.insert(Vehicles, vehicle)
	end

	-- send information after db has loaded, making sure everyone gets vehicle information
	TriggerClientEvent('esx_aircraftshop:sendCategories', -1, Categories)
	TriggerClientEvent('esx_aircraftshop:sendVehicles', -1, Vehicles)
end)

function LoadLicenses (source)
  TriggerEvent('esx_license:getLicenses', source, function (licenses)
    TriggerClientEvent('esx_aircraftshop:loadLicenses', source, licenses)
  end)
end

if Config.EnableLicense == true then
  AddEventHandler('esx:playerLoaded', function (source)
    LoadLicenses(source)
  end)
end

RegisterServerEvent('esx_aircraftshop:buyLicense')
AddEventHandler('esx_aircraftshop:buyLicense', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local money = xPlayer.getMoney()
	if money >= Config.LicensePrice then
		xPlayer.removeMoney(Config.LicensePrice)

		TriggerEvent('esx_license:addLicense', _source, 'aircraft', function ()
			LoadLicenses(_source)
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
	end
end)

RegisterServerEvent('esx_aircraftshop:setVehicleOwned')
AddEventHandler('esx_aircraftshop:setVehicleOwned', function (vehicleProps)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_aircrafts (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps)
	},
	function (rowsChanged)
		TriggerClientEvent('esx:showNotification', _source, _U('vehicle_belongs', vehicleProps.plate))
	end)
end)

RegisterServerEvent('esx_aircraftshop:setVehicleOwnedPlayerId')
AddEventHandler('esx_aircraftshop:setVehicleOwnedPlayerId', function (playerId, vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	MySQL.Async.execute('INSERT INTO owned_aircrafts (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps)
	},
	function (rowsChanged)
		TriggerClientEvent('esx:showNotification', playerId, _U('vehicle_belongs', vehicleProps.plate))
	end) 
end)

RegisterServerEvent('esx_aircraftshop:setVehicleOwnedSociety')
AddEventHandler('esx_aircraftshop:setVehicleOwnedSociety', function (society, vehicleProps)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('INSERT INTO owned_aircrafts (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)',
	{
		['@owner']   = 'society:' .. society,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps),
	},
	function (rowsChanged)

	end)
end)

RegisterServerEvent('esx_aircraftshop:sellVehicle')
AddEventHandler('esx_aircraftshop:sellVehicle', function (vehicle)
	MySQL.Async.fetchAll('SELECT * FROM aircraftdealer_aircrafts WHERE vehicle = @vehicle LIMIT 1', {
		['@vehicle'] = vehicle
	}, function (result)
		local id = result[1].id

		MySQL.Async.execute('DELETE FROM aircraftdealer_aircrafts WHERE id = @id', {
			['@id'] = id
		})
	end)
end)

RegisterServerEvent('esx_aircraftshop:rentVehicle')
AddEventHandler('esx_aircraftshop:rentVehicle', function (vehicle, plate, playerName, basePrice, rentPrice, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	MySQL.Async.fetchAll('SELECT * FROM aircraftdealer_aircrafts WHERE vehicle = @vehicle LIMIT 1', {
		['@vehicle'] = vehicle
	}, function (result)
		local id    = result[1].id
		local price = result[1].price
		local owner = xPlayer.identifier

		MySQL.Async.execute('DELETE FROM aircraftdealer_aircrafts WHERE id = @id', {
			['@id'] = id
		})

		MySQL.Async.execute('INSERT INTO rented_aircrafts (vehicle, plate, player_name, base_price, rent_price, owner) VALUES (@vehicle, @plate, @player_name, @base_price, @rent_price, @owner)',
		{
			['@vehicle']     = vehicle,
			['@plate']       = plate,
			['@player_name'] = playerName,
			['@base_price']  = basePrice,
			['@rent_price']  = rentPrice,
			['@owner']       = owner,
		})
	end)
end)

-- unused?
RegisterServerEvent('esx_aircraftshop:setVehicleForAllPlayers')
AddEventHandler('esx_aircraftshop:setVehicleForAllPlayers', function (props, x, y, z, radius)
	TriggerClientEvent('esx_aircraftshop:setVehicle', -1, props, x, y, z, radius)
end)

RegisterServerEvent('esx_aircraftshop:getStockItem')
AddEventHandler('esx_aircraftshop:getStockItem', function (itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_aircraftdealer', function (inventory)
		local item = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and item.count >= count then
		
			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, _U('player_cannot_hold'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, _U('have_withdrawn', count, item.label))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_in_society'))
		end
	end)
end)

RegisterServerEvent('esx_aircraftshop:putStockItems')
AddEventHandler('esx_aircraftshop:putStockItems', function (itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_aircraftdealer', function (inventory)
		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, _U('have_deposited', count, item.label))
		else
			TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_aircraftshop:getCategories', function (source, cb)
	cb(Categories)
end)

ESX.RegisterServerCallback('esx_aircraftshop:getVehicles', function (source, cb)
	cb(Vehicles)
end)

ESX.RegisterServerCallback('esx_aircraftshop:buyVehicle', function (source, cb, vehicleModel)
	local xPlayer     = ESX.GetPlayerFromId(source)
	local vehicleData = nil

	for i=1, #Vehicles, 1 do
		if Vehicles[i].model == vehicleModel then
			vehicleData = Vehicles[i]
			break
		end
	end

	if xPlayer.getMoney() >= vehicleData.price then
		xPlayer.removeMoney(vehicleData.price)
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_aircraftshop:buyVehicleSociety', function (source, cb, society, vehicleModel)
	local vehicleData = nil

	for i=1, #Vehicles, 1 do
		if Vehicles[i].model == vehicleModel then
			vehicleData = Vehicles[i]
			break
		end
	end

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function (account)
		if account.money >= vehicleData.price then

			account.removeMoney(vehicleData.price)
			MySQL.Async.execute('INSERT INTO aircraftdealer_aircrafts (vehicle, price) VALUES (@vehicle, @price)',
			{
				['@vehicle'] = vehicleData.model,
				['@price']   = vehicleData.price,
			})

			cb(true)
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('esx_aircraftshop:getPersonnalVehicles', function (source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_aircrafts WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function (result)
		local vehicles = {}

		for i=1, #result, 1 do
			local vehicleData = json.decode(result[i].vehicle)
			table.insert(vehicles, vehicleData)
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_aircraftshop:getCommercialVehicles', function (source, cb)
	MySQL.Async.fetchAll('SELECT * FROM aircraftdealer_aircrafts ORDER BY vehicle ASC', {}, function (result)
		local vehicles = {}

		for i=1, #result, 1 do
			table.insert(vehicles, {
				name  = result[i].vehicle,
				price = result[i].price
			})
		end

		cb(vehicles)
	end)
end)





ESX.RegisterServerCallback('esx_aircraftshop:getStockItems', function (source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_aircraftdealer', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_aircraftshop:getPlayerInventory', function (source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({ items = items })
end)

ESX.RegisterServerCallback('esx_aircraftshop:isPlateTaken', function (source, cb, plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_aircrafts WHERE @plate = plate', {
		['@plate'] = plate
	}, function (result)
		cb(result[1] ~= nil)
	end)
end)

if Config.EnablePaCommand then
	ESX.RegisterCommand('pa', 'user', function(xPlayer, args, showError)
		TriggerClientEvent('esx_aircraftshop:openPersonnalVehicleMenu', source)
	end, false, {help = _U('leaving')})
end


