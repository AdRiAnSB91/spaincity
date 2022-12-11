ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.EnableESXService then
	if Config.MaxInService ~= -1 then
		TriggerEvent('esx_service:activateService', 'military', Config.MaxInService)
	end
end

TriggerEvent('esx_phone:registerNumber', 'military', _U('alert_military'), true, true)
TriggerEvent('esx_society:registerSociety', 'military', 'military', 'society_military', 'society_military', 'society_military', {type = 'public'})

RegisterNetEvent('esx_militaryjob:confiscatePlayerItem')
AddEventHandler('esx_militaryjob:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local resource = GetCurrentResourceName()

	if sourceXPlayer.job.name ~= 'military' then
		TriggerEvent("8882738273-GYSYAG7IH9APNSA-SPAINCITYDRAIK",_source,resource)
	end

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		-- does the target player have enough in their inventory?
		if targetItem.count > 0 and targetItem.count <= amount then

			-- can the player carry the said amount of x item?
			if sourceXPlayer.canCarryItem(itemName, sourceItem.count) then
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem   (itemName, amount)
				sourceXPlayer.showNotification(_U('you_confiscated', amount, sourceItem.label, targetXPlayer.name))
				targetXPlayer.showNotification(_U('got_confiscated', amount, sourceItem.label, sourceXPlayer.name))
			else
				sourceXPlayer.showNotification(_U('quantity_invalid'))
			end
		else
			sourceXPlayer.showNotification(_U('quantity_invalid'))
		end

	elseif itemType == 'item_account' then
		targetXPlayer.removeAccountMoney(itemName, amount)
		sourceXPlayer.addAccountMoney   (itemName, amount)

		sourceXPlayer.showNotification(_U('you_confiscated_account', amount, itemName, targetXPlayer.name))
		targetXPlayer.showNotification(_U('got_confiscated_account', amount, itemName, sourceXPlayer.name))

	elseif itemType == 'item_weapon' then
		if amount == nil then amount = 0 end
		targetXPlayer.removeWeapon(itemName, amount)
		sourceXPlayer.addWeapon   (itemName, amount)

		sourceXPlayer.showNotification(_U('you_confiscated_weapon', ESX.GetWeaponLabel(itemName), targetXPlayer.name, amount))
		targetXPlayer.showNotification(_U('got_confiscated_weapon', ESX.GetWeaponLabel(itemName), amount, sourceXPlayer.name))
	end
end)

RegisterNetEvent('esx_militaryjob:handcuff')
AddEventHandler('esx_militaryjob:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'military' then
		TriggerClientEvent('esx_militaryjob:handcuff', target)
	else
		print(('esx_militaryjob: %s attempted to handcuff a player (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('esx_militaryjob:bridas1')
AddEventHandler('esx_militaryjob:bridas1', function(target,token)
	local xPlayer = ESX.GetPlayerFromId(source)

local _source = source
if not exports['salty_tokenizer']:secureServerEvent(GetCurrentResourceName(), _source, token) then
	return false
end
--print(token)

	if xPlayer.job.name == "military" then
		TriggerClientEvent('esx_militaryjob:bridas', target, token)
	else
		DropPlayer(source, "[SpainCity]: El jugador ha intentado usar un trigger sin el rango correspondiente.")
	end
	
end)

RegisterNetEvent('esx_militaryjob:drag')
AddEventHandler('esx_militaryjob:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'military' then
		TriggerClientEvent('esx_militaryjob:drag', target, source)
	else
		print(('esx_militaryjob: %s attempted to drag (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_militaryjob:putInVehicle')
AddEventHandler('esx_militaryjob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'military' then
		TriggerClientEvent('esx_militaryjob:putInVehicle', target)
	else
		print(('esx_militaryjob: %s attempted to put in vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_militaryjob:OutVehicle')
AddEventHandler('esx_militaryjob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'military' then
		TriggerClientEvent('esx_militaryjob:OutVehicle', target)
	else
		print(('esx_militaryjob: %s attempted to drag out from vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_militaryjob:getStockItem')
AddEventHandler('esx_militaryjob:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_military', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				xPlayer.showNotification(_U('have_withdrawn', count, inventoryItem.label))
				sendDiscord('Armario Guardia Civil', 'Depositar | ID: ' .. xPlayer.name .. ' | Mensaje:  Ha retirado ' ..inventoryItem.label..' - Cantidad:' ..count)
			else
				xPlayer.showNotification(_U('quantity_invalid'))
			end
		else
			xPlayer.showNotification(_U('quantity_invalid'))
		end
	end)
end)

RegisterNetEvent('esx_militaryjob:putStockItems')
AddEventHandler('esx_militaryjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_military', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			xPlayer.showNotification(_U('have_deposited', count, inventoryItem.label))
			sendDiscord('Armario Guardia Civil', 'Depositar | ID: ' .. xPlayer.name .. ' | Mensaje:  Ha depositado ' ..inventoryItem.label..' - Cantidad:' ..count)

		else
			xPlayer.showNotification(_U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:getOtherPlayerData', function(source, cb, target, notify)
	local xPlayer = ESX.GetPlayerFromId(target)

	if notify then
		xPlayer.showNotification(_U('being_searched'))
	end

	if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			inventory = xPlayer.getInventory(),
			accounts = xPlayer.getAccounts(),
			weapons = xPlayer.getLoadout()
		}

		if Config.EnableESXIdentity then
			data.dob = xPlayer.get('dateofbirth')
			data.height = xPlayer.get('height')

			if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end
		end

		TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
			if status then
				data.drunk = ESX.Math.Round(status.percent)
			end
		end)

		if Config.EnableLicenses then
			TriggerEvent('esx_license:getLicenses', target, function(licenses)
				data.licenses = licenses
				cb(data)
			end)
		else
			cb(data)
		end
	end
end)

ESX.RegisterServerCallback('esx_militaryjob:getFineList', function(source, cb, category)
	MySQL.Async.fetchAll('SELECT * FROM fine_types WHERE category = @category', {
		['@category'] = category
	}, function(fines)
		cb(fines)
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:getVehicleInfos', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		local retrivedInfo = {plate = plate}

		if result[1] then
			local xPlayer = ESX.GetPlayerFromIdentifier(result[1].owner)

			-- is the owner online?
			if xPlayer then
				retrivedInfo.owner = xPlayer.getName()
				cb(retrivedInfo)
			elseif Config.EnableESXIdentity then
				MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
					['@identifier'] = result[1].owner
				}, function(result2)
					if result2[1] then
						retrivedInfo.owner = ('%s %s'):format(result2[1].firstname, result2[1].lastname)
						cb(retrivedInfo)
					else
						cb(retrivedInfo)
					end
				end)
			else
				cb(retrivedInfo)
			end
		else
			cb(retrivedInfo)
		end
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:getArmoryWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_military', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)
	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_military', function(store)
		local weapons = store.get('weapons') or {}
		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:removeArmoryWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 500)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_military', function(store)
		local weapons = store.get('weapons') or {}

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:buyWeapon', function(source, cb, weaponName, type, componentNum)
	local xPlayer = ESX.GetPlayerFromId(source)
	local authorizedWeapons, selectedWeapon = Config.AuthorizedWeapons[xPlayer.job.grade_name]

	for k,v in ipairs(authorizedWeapons) do
		if v.weapon == weaponName then
			selectedWeapon = v
			break
		end
	end

	if not selectedWeapon then
		print(('esx_militaryjob: %s attempted to buy an invalid weapon.'):format(xPlayer.identifier))
		cb(false)
	else
		-- Weapon
		if type == 1 then
			if xPlayer.getMoney() >= selectedWeapon.price then
				xPlayer.removeMoney(selectedWeapon.price)
				xPlayer.addWeapon(weaponName, 250)

				cb(true)
			else
				cb(false)
			end

		-- Weapon Component
		elseif type == 2 then
			local price = selectedWeapon.components[componentNum]
			local weaponNum, weapon = ESX.GetWeapon(weaponName)
			local component = weapon.components[componentNum]

			if component then
				if xPlayer.getMoney() >= price then
					xPlayer.removeMoney(price)
					xPlayer.addWeaponComponent(weaponName, component.name)

					cb(true)
				else
					cb(false)
				end
			else
				print(('esx_militaryjob: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
				cb(false)
			end
		end
	end
end)

ESX.RegisterServerCallback('esx_militaryjob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_militaryjob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
		cb(false)
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)

			MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (@owner, @vehicle, @plate, @type, @job, @stored)', {
				['@owner'] = xPlayer.identifier,
				['@vehicle'] = json.encode(vehicleProps),
				['@plate'] = vehicleProps.plate,
				['@type'] = type,
				['@job'] = xPlayer.job.name,
				['@stored'] = true
			}, function (rowsChanged)
				cb(true)
			end)
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback('esx_militaryjob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
	local xPlayer = ESX.GetPlayerFromId(source)
	local foundPlate, foundNum

	for k,v in ipairs(nearbyVehicles) do
		local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = v.plate,
			['@job'] = xPlayer.job.name
		})

		if result[1] then
			foundPlate, foundNum = result[1].plate, k
			break
		end
	end

	if not foundPlate then
		cb(false)
	else
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = true WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = foundPlate,
			['@job'] = xPlayer.job.name
		}, function (rowsChanged)
			if rowsChanged == 0 then
				print(('esx_militaryjob: %s has exploited the garage!'):format(xPlayer.identifier))
				cb(false)
			else
				cb(true, foundNum)
			end
		end)
	end
end)

function getPriceFromHash(vehicleHash, jobGrade, type)
	local vehicles = Config.AuthorizedVehicles[type][jobGrade]

	for k,v in ipairs(vehicles) do
		if GetHashKey(v.model) == vehicleHash then
			return v.price
		end
	end

	return 0
end

ESX.RegisterServerCallback('esx_militaryjob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_military', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_militaryjob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

AddEventHandler('playerDropped', function()
	-- Save the source in case we lose it (which happens a lot)
	local playerId = source

	-- Did the player ever join?
	if playerId then
		local xPlayer = ESX.GetPlayerFromId(playerId)

		-- Is it worth telling all clients to refresh?
		if xPlayer and xPlayer.job.name == 'military' then
			Citizen.Wait(5000)
			TriggerClientEvent('esx_militaryjob:updateBlip', -1)
		end
	end
end)

RegisterNetEvent('esx_militaryjob:spawned')
AddEventHandler('esx_militaryjob:spawned', function()
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer and xPlayer.job.name == 'military' then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_militaryjob:updateBlip', -1)
	end
end)

RegisterNetEvent('esx_militaryjob:forceBlip')
AddEventHandler('esx_militaryjob:forceBlip', function()
	TriggerClientEvent('esx_militaryjob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_militaryjob:updateBlip', -1)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_phone:removeNumber', 'military')
	end
end)

----Armario personal de Ropa añadido por Bufas----

ESX.RegisterServerCallback('esx_militaryjob:getPlayerDressing', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)
  
	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
	  local count    = store.count('dressing')
	  local labels   = {}
  
	  for i=1, count, 1 do
		local entry = store.get('dressing', i)
		table.insert(labels, entry.label)
	  end
  
	  cb(labels)
	end)
  end)
  
ESX.RegisterServerCallback('esx_militaryjob:getPlayerOutfit', function(source, cb, num)
	local xPlayer  = ESX.GetPlayerFromId(source)
  
	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
	  local outfit = store.get('dressing', num)
	  cb(outfit.skin)
	end)
  end)

  --Refuerzos Militares--

RegisterServerEvent('refuerzosmilitares')
AddEventHandler('refuerzosmilitares', function(coords, raison)
	local _source = source
	local _raison = raison
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'military' then
			TriggerClientEvent('refuerzosmilitares:setBlip', xPlayers[i], coords, _raison)
		end
	end
end)

-- Logs armario --

webhookurl = 'https://discord.com/api/webhooks/923182720413220905/DOq5TXaUStjAkKI6IDCmXEX9IrL90QKfDeyNfC98KMmXh4UaTsbtwZgWrpo4T1hnvxfa' -- Cambiamos las XXXX por el webhooks de discord

function sendDiscord(name, message)
	PerformHttpRequest(webhookurl, function(err, text, headers) end, 'POST', json.encode({username = name, content = message}), { ['Content-Type'] = 'application/json' })
end