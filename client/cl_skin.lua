local appearance

function GetAllDrawablesIndexes(drawables)
    local indexes = {}
    for idx, _ in pairs(drawables) do
        table.insert(indexes, GetPedDrawableVariation(PlayerPedId(), idx) + 1)
    end
    return indexes
end

function GetAllPropsIndexes(props)
    local indexes = {}
    for idx, _ in pairs(props) do
        local addition = 2
        if idx == 1 then
            addition = 1
        end
        indexes[idx] = GetPedPropIndex(PlayerPedId(), idx) + addition
    end
    return indexes
end

function ApplyClothes(clothes)
    local ped = PlayerPedId()
    for idx, _ in pairs(Config.Components) do
        SetPedComponentVariation(ped, idx, clothes.drawables[idx], clothes.drawablesText[idx], 2)
    end
    local propsIndexes = {0, 1, 2, 6, 7}
    for idx, v in pairs(propsIndexes) do
        SetPedPropIndex(ped, v, clothes.props[idx], clothes.propsText[idx], true)
    end
end

function SaveClothes()
    local ped = PlayerPedId()
    local clothes = {
        drawables = {},
        drawablesText = {},
        props = {},
        propsText = {}
    }
    for idx, _ in pairs(Config.Components) do
        clothes.drawables[idx] = GetPedDrawableVariation(ped, idx)
        clothes.drawablesText[idx] = GetPedTextureVariation(ped, idx)
    end
    for idx, _ in pairs(Config.Props) do
        table.insert(clothes.props, GetPedPropIndex(ped, idx))
        table.insert(clothes.propsText, GetPedPropTextureIndex(ped, idx)) 
    end
    return clothes
end

function ClothesItems(items)
    local ped = PlayerPedId()
    -- Drawables
    for dIdx, name in pairs(Config.Components) do
        local texture = GetPedTextureVariation(ped, dIdx)
        local drawablesList = {}
        for i = 0, GetNumberOfPedDrawableVariations(ped, dIdx) - 1, 1 do
            table.insert(drawablesList, i)
        end
        items:List(name, drawablesList, dIndexes[dIdx], nil, {}, true, {
            onListChange = function(idx, item)
                dIndexes[dIdx] = idx
                texture = 0
                SetPedComponentVariation(ped, dIdx, drawablesList[idx], texture, 2)
            end,
            onSelected = function(idx, item)
                texture = GetPedTextureVariation(ped, dIdx) + 1
                if (texture >= GetNumberOfPedTextureVariations(ped, dIdx, drawablesList[idx])) then
                    texture = 0
                end
                SetPedComponentVariation(ped, dIdx, drawablesList[idx], texture, 2)
            end
        })
    end

    -- Props
    for pIdx, name in pairs(Config.Props) do
        local texture = GetPedPropTextureIndex(ped, pIdx)
        local propsList = {}
        local startIdx = -1
        if pIdx == 1 then
            startIdx = 0
        end
        for i = startIdx, GetNumberOfPedPropDrawableVariations(ped, pIdx) - 1, 1 do
            table.insert(propsList, i)
        end
        items:List(name, propsList, pIndexes[pIdx], nil, {}, true, {
            onListChange = function(idx, item)
                pIndexes[pIdx] = idx
                if (propsList[idx] == -1) then
                    ClearPedProp(ped, pIdx)
                    return
                end
                texture = 0
                SetPedPropIndex(ped, pIdx, propsList[idx], texture, true)
            end,
            onSelected = function(idx, item)
                texture = GetPedTextureVariation(ped, pIdx) + 1
                if (texture >= GetNumberOfPedPropTextureVariations(ped, pIdx, propsList[idx])) then
                    texture = 0
                end
                SetPedPropIndex(ped, pIdx, propsList[idx], texture, true)
            end
        })
    end

    if save then
        items:Button("Save", "~b~Save your clothes!", {LeftBadge = RageUI.BadgeStyle.Tick}, true, {
            onSelected = function()
                TriggerServerEvent("rsv_skin:saveclothes", SaveClothes())
                appearanceMenu:close()
            end
        })
    end
end

function CreateCreatorMenu()

end

function AppearanceMenu(haveSave)
    appearanceMenu = RageUI.CreateMenu("Appearance", "~b~Change your appearance!")
    save = haveSave
    appearanceMenu.Closable = not save
    appearanceMenu.EnableMouse = false
    dIndexes = GetAllDrawablesIndexes(Config.Components)
    pIndexes = GetAllPropsIndexes(Config.Props)
    appearanceMenu:isVisible(ClothesItems)
    return appearanceMenu
end

function SpawnConnectedPlayer()
    while (not NetworkIsPlayerActive(PlayerId())) do
        Wait(100)
    end

    appearance = AppearanceMenu(true)
end

RegisterNetEvent("rsv_skin:setclothes")
AddEventHandler("rsv_skin:setclothes", function(clothes)
    ApplyClothes(clothes)
end)

RegisterCommand("skin", function()
    appearance:toggle()
end, false)

SpawnConnectedPlayer()

--[[
local skinMenu = RageUI.CreateMenu("Skin Menu", "~b~Personalize your skin.")
skinMenu.EnableMouse = true
local heritageMenu = RageUI.CreateSubMenu(skinMenu, "Heritage", "~b~Choose your heritage.")
local clothesMenu = RageUI.CreateSubMenu(skinMenu, "Clothes", "~b~Choose your clothes.")

local genders = {"Female", "Male"}
local models = {"mp_f_freemode_01", "mp_m_freemode_01"}
local amount = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 }
local mum = { "Hannah", "Aubrey", "Jasmine", "Gisele", "Amelia", "Isabella", "Zoe", "Ava", "Camila", "Violet", "Sophia", "Evelyn", "Nicole", "Ashley", "Gracie", "Brianna", "Natalie", "Olivia", "Elizabeth", "Charlotte", "Emma" };
local dad = { "Benjamin", "Daniel", "Joshua", "Noah", "Andrew", "Juan", "Alex", "Isaac", "Evan", "Ethan", "Vincent", "Angel", "Diego", "Adrian", "Gabriel", "Michael", "Santiago", "Kevin", "Louis", "Samuel", "Anthony", " Claude", "Niko" };
local mumIdx = 1
local dadIdx = 1
local ressemblanceIdx = 5
local skinToneIdx = 5

function RageUI.PoolMenus:SkinMenu()
    skinMenu:IsVisible(function(items)
        local genderIdx = 1
        if GetEntityModel(PlayerPedId()) == GetHashKey(models[2]) then
            genderIdx = 2
        end
        items:AddList("Gender", genders, genderIdx, nil, {IsDisabled = false}, function(idx, onSelected, onListChange)
            if (onListChange) then
                genderIdx = idx
                local hash = exports.rsv_utils:LoadModel(models[genderIdx])
                SetPlayerModel(PlayerId(), hash)
                SetPedDefaultComponentVariation(PlayerPedId())
            end
        end)
        items:AddButton("Heritage", "~b~Choose your heritage", { IsDisabled = false }, function(onSelected)end, heritageMenu)
        items:AddButton("Clothes", "~b~Choose your clothes", { IsDisabled = false }, function(onSelected)end, clothesMenu)
    end, function(panels)
    
    end)

    heritageMenu:IsVisible(function(items)
        items:Heritage(mumIdx, dadIdx)
        items:AddList("Mum", mum, mumIdx, nil, { IsDisabled = false }, function(idx, onSelected, onListChange)
			if (onListChange) then
				mumIdx = idx;
                SetPedHeadBlendData(PlayerPedId(), dadIdx, mumIdx, nil, dadIdx, mumIdx, nil, ressemblanceIdx/10, skinToneIdx/10, nil, true)
			end
		end)

        items:AddList("Dad", dad, dadIdx, nil, { IsDisabled = false }, function(idx, onSelected, onListChange)
			if (onListChange) then
				dadIdx = idx;
                SetPedHeadBlendData(PlayerPedId(), dadIdx, mumIdx, nil, dadIdx, mumIdx, nil, ressemblanceIdx/10, skinToneIdx/10, nil, true)
			end
		end)

        items:AddList("Ressemblance", amount, ressemblanceIdx, nil, { IsDisabled = false }, function(idx, onSelected, onListChange)
            if (onListChange) then
                ressemblanceIdx = idx
                SetPedHeadBlendData(PlayerPedId(), dadIdx, mumIdx, nil, dadIdx, mumIdx, nil, ressemblanceIdx/10, skinToneIdx/10, nil, true)
            end
        end)

        items:AddList("Skin Tone", amount, skinToneIdx, nil, { IsDisabled = false }, function(idx, onSelected, onListChange)
            if (onListChange) then
                skinToneIdx = idx
                SetPedHeadBlendData(PlayerPedId(), dadIdx, mumIdx, nil, dadIdx, mumIdx, nil, ressemblanceIdx/10, skinToneIdx/10, nil, true)
            end
        end)
    end, function()
        
    end)

    return skinMenu
end]]--