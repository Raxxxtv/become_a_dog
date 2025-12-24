ESX = exports["es_extended"]:getSharedObject()

local isDog = false
local playerped = nil
local sit = false
local lay = false
local bark = false

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function loadmodel(model)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end
end

local function toggleDog()
    if isDog then
        local model = "mp_m_freemode_01"
        loadmodel(model)
        TriggerEvent("skinchanger:loadSkin", playerped)
        SetPedCanSwitchWeapon(PlayerPedId(), true)
        LocalPlayer.state.canUseWeapons = true
        LocalPlayer.state.invBusy = false
        exports.ox_inventory:weaponWheel(false)
    else
        ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
            playerped = skin
        end)
        local model = Config.DogModel
        loadmodel(model)
        SetPedCanSwitchWeapon(PlayerPedId(), false)
        LocalPlayer.state.canUseWeapons = false
        LocalPlayer.state.invBusy = true
        exports.ox_inventory:weaponWheel(true)
    end
    isDog = not isDog
end

CreateThread(function()
    local ped = PlayerPedId()
    while true do
        Wait(0)
        ped = PlayerPedId()
        if isDog then
            if GetVehiclePedIsTryingToEnter(ped) ~= 0 then
                ClearPedTasks(ped)
            end
        end
    end
end)

RegisterCommand('hund', function()
    toggleDog()
end)

RegisterCommand('sitz', function()
    if not isDog or lay or bark then
        return
    end

    if not sit then
        loadAnim('creatures@pug@amb@world_dog_sitting@base')
        TaskPlayAnim(PlayerPedId(), 'creatures@pug@amb@world_dog_sitting@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        ClearPedTasks(PlayerPedId())
    end
    sit = not sit
end)

RegisterCommand('platz', function()
    if not isDog or sit or bark then
        return
    end

    if not lay then
        loadAnim('creatures@pug@move')
        TaskPlayAnim(PlayerPedId(), 'creatures@pug@move', 'dead_left', 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        ClearPedTasks(PlayerPedId())
    end
    lay = not lay
end)

RegisterCommand('bellen', function()
    if not isDog or lay or sit then
        return
    end

    if not bark then
        loadAnim('creatures@pug@amb@world_dog_barking@idle_a')
        TaskPlayAnim(PlayerPedId(), 'creatures@pug@amb@world_dog_barking@idle_a', 'idle_a', 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        ClearPedTasks(PlayerPedId())
    end
    bark = not bark
end)

RegisterKeyMapping("bellen", "Taste zum bellen als Hund", "keyboard", "b")
RegisterKeyMapping("sitz", "Taste zum sitzen als Hund", "keyboard", "k")
RegisterKeyMapping("platz", "Taste zum hinlegen als Hund", "keyboard", "l")