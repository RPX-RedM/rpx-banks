local BankOpen = false
local BankBlips = {}

--@function: OpenBank
--@description: This function opens the bank.
local OpenBank = function()
    SendNUIMessage({action = "OPEN_BANK", balance = LocalPlayer.state.bank})
    SetNuiFocus(true, true)
    BankOpen = true
end

--@function: CloseBank
--@description: This function closes the bank.
local CloseBank = function()
    SendNUIMessage({action = "CLOSE_BANK"})
    SetNuiFocus(false, false)
    BankOpen = false
end

--@thread: MainThread
--@description: This is the main thread for the banking system.
CreateThread(function()
    for id, bank in pairs(Config.Banks) do
        local blip = N_0x554d9d53f696d002(1664425300, bank)
        SetBlipSprite(blip, GetHashKey('blip_proc_bank'), 52)
        SetBlipScale(blip, 0.2)
        BankBlips[id] = blip
        
        if not Config.ThirdEye then
            exports['rpx-core']:createPrompt('rpx_bank_'..id, bank, 0xF3830D8E, 'Access Bank', {
                func = function()
                    OpenBank()
                end
            })
        end
    end
end)

--@event: onResourceStop
--@description: This event is called when the resource is stopped.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    for id, bank in pairs(Config.Banks) do
        if Config.ThirdEye then
            exports['meta_target']:removeTarget('rpx_bank_stdenis')
            exports['meta_target']:removeTarget('rpx_bank_bw')
            exports['meta_target']:removeTarget('rpx_bank_armadillo')
            exports['meta_target']:removeTarget('rpx_bank_rhodes')
            exports['meta_target']:removeTarget('rpx_bank_valentine')
        else
            exports['rpx-core']:deletePrompt('rpx_bank_'..id)
        end

        RemoveBlip(BankBlips[id])
    end
end)

--@NUICallback: CloseNUI
--@description: This callback is called by the NUI when a close command is received.
RegisterNUICallback('CloseNUI', function()
    CloseBank()
end)

--@NUICallback: Transact
--@description: This callback is called by the NUI when a transaction is made.
RegisterNUICallback('Transact', function(data)
    TriggerServerEvent('rpx-banking:Server:Transact', data.type, data.amount)
end)

--@StateBagChangeHandler: bank
--@description: This handler is called when the bank state bag is changed, so we can update it.
AddStateBagChangeHandler("bank", nil, function(bagName, key, value) 
    if GetPlayerFromStateBagName(bagName) ~= PlayerId() then return end
    if not BankOpen then return end
    SendNUIMessage({action = "UPDATE_BALANCE", balance = value})
end)

--@event: rpx-banks:client:OpenBanking
--@description: This event is called by the client when a player is trying to open the bank.
AddEventHandler("rpx-banks:client:OpenBanking", function()
    local PlayerCoords = GetEntityCoords(PlayerPedId())
    for id, bank in pairs(Config.Banks) do
        if #(PlayerCoords - bank) < 5.0 then
            OpenBank()
            return
        end
    end
end)