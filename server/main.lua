RPX = exports['rpx-core']:GetObject()

--@NetEvent: rpx-banking:Server:Transact
--@description: This event is called by a client when a player is trying to transact money.
lib.callback.register('rpx-banking:transact', function(src, data)
    local type, amount = data.type, data.amount
    local player = RPX.GetPlayer(src)
    if not player then return false end

    amount = tonumber(amount)
    if amount <= 0 then
        lib.notify(src, {title = "Invalid amount.", type = "error"})
        return false
    end
    if type == 1 and player.money.bank >= amount then
        local after = player.money.bank - amount
        player.RemoveMoney('bank', amount)
        player.AddMoney('cash', amount)
        return true, after
    elseif type == 2 and player.money.cash >= amount then
        local after = player.money.bank + amount
        player.RemoveMoney('cash', amount)
        player.AddMoney('bank', amount)
        return true, after
    else
        lib.notify(src, {title = "Insufficient funds.", type = "error"})
        return false
    end
end)