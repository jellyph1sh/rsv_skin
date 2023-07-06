RegisterServerEvent("rsv_skin:saveclothes")
AddEventHandler("rsv_skin:saveclothes", function(clothes)
    SaveResourceFile(GetCurrentResourceName(), "./data/"..string.gsub(GetPlayerIdentifierByType(source, "license"), "license:", "")..".json", json.encode(clothes), -1)
end)

RegisterServerEvent("rsv_skin:getclothes")
AddEventHandler("rsv_skin:getclothes", function()
    local file = LoadResourceFile(GetCurrentResourceName(), "./data/"..string.gsub(GetPlayerIdentifierByType(source, "license"), "license:", "")..".json")
    if (file == nil) then
        return
    end
    local clothes = json.decode(file)
    TriggerClientEvent("rsv_skin:setclothes", source, clothes)
end)