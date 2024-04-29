---@diagnostic disable: missing-parameter

local LegacyFramework = GetResourceState('LegacyFramework'):find('start') and exports["LegacyFramework"]:ReturnFramework() or nil
local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil
local QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil


local pauseMenuActive = false
local NameServer = Config.ServerName

function OpenPauseMenu()
    if LocalPlayer.state.invOpen then
        return
    end

    local playerName = GetPlayerName(PlayerId())

    --[[ Default Format ]]
    local DataPlayer = {
        name = "John Doe",
        job = "Unemployed",
        cash = 1000000,
        group = "admin",
        playerID = cache.serverId,
        playerName = playerName,
        char = "Identifier",
        nameServer = NameServer,
    }

    if LegacyFramework then
        local LGF = LocalPlayer.state.playerData -- Retrieve Client Data By State Bag
        local playerData = LGF[1]
        local moneyAccounts = json.decode(playerData.moneyAccounts)

        DebugPrint(AllData) -- debug

        DataPlayer = {
            name = playerData.firstName .. ' ' .. playerData.lastName,
            job = playerData.nameJob,
            cash = moneyAccounts.money,
            group = playerData.playerGroup,
            playerID = cache.serverId,
            playerName = playerName,
            identifier = playerData.charName,
            nameServer = NameServer,
        }

        SendNUIMessage({
            DataPlayer = DataPlayer,
            action = "showPauseMenu",
            nameServer = NameServer
        })
    elseif ESX then
        local AllData = lib.callback.await('esx:PlayerDataPauseMenu', false)
        local playerData = AllData
        local moneyAccounts = AllData.moneyAccounts

        DebugPrint(AllData) -- debug

        DataPlayer = {
            name = playerData.firstName .. ' ' .. playerData.lastName,
            job = playerData.nameJob,
            cash = moneyAccounts,
            group = playerData.playerGroup,
            playerID = cache.serverId,
            playerName = playerName,
            identifier = playerData.identifier,
            nameServer = NameServer,
        }

        SendNUIMessage({
            DataPlayer = DataPlayer,
            action = "showPauseMenu",
            nameServer = NameServer
        })
    elseif QBCore then
        local AllData = QBCore.Functions.GetPlayerData()
        local playerData = AllData
        local moneyAccounts = AllData.money
        local cash = moneyAccounts.cash

        DebugPrint(AllData) -- debug

        DataPlayer = {
            name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname,
            job = playerData.job.label,
            cash = cash,
            group = playerData.job.name,
            playerID = cache.serverId,
            playerName = playerName,
            identifier = playerData.license,
            nameServer = NameServer,
        }
    end

    SendNUIMessage({
        DataPlayer = DataPlayer,
        action = "showPauseMenu",
        nameServer = NameServer,
        discordInvite = Config.DiscordInvite
    })

    SetNuiFocus(true, true)
    pauseMenuActive = true
    SetPauseMenuActive(false)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        OpenCam(PlayerPedId())
    else
        return
    end
end

function ClosePauseMenu()
    SetNuiFocus(false, false)
    pauseMenuActive = false
    SetPauseMenuActive(true)
end

RegisterNetEvent("copyIdentifiers:client", function()
    local AllData = QBCore.Functions.GetPlayerData()
    local playerData = AllData
    local moneyAccounts = AllData.money
    local cash = moneyAccounts.cash

    lib.setClipboard(playerData.license)
end)

lib.addKeybind({
    name = 'pausemenu',
    description = 'Open pause menu',
    defaultKey = 'ESCAPE',
    onPressed = function(self)
        if not IsPauseMenuActive() then
            OpenPauseMenu()
        end
        while pauseMenuActive do
            Wait(0)
            DisableControlAction(1, 200, true)
        end
    end,
    onReleased = function(self)
    end

})

Citizen.CreateThread(function()

    ReplaceHudColourWithRgba( 116 , Config.RGBA.LINE["RED"] , Config.RGBA.LINE["GREEN"] , Config.RGBA.LINE["BLUE"] , Config.RGBA.LINE["ALPHA"]) --LINE ABOVE EACH OPTION
    ReplaceHudColourWithRgba( 117 , Config.RGBA.STYLE["RED"] , Config.RGBA.STYLE["GREEN"] , Config.RGBA.STYLE["BLUE"] , Config.RGBA.STYLE["ALPHA"]) -- BACKGROUND OF EACH OPTION + BLIPS IN THE LIST
    ReplaceHudColourWithRgba( 142 , Config.RGBA.WAYPOINT["RED"] , Config.RGBA.WAYPOINT["GREEN"] , Config.RGBA.WAYPOINT["BLUE"] , Config.RGBA.WAYPOINT["ALPHA"]) -- WAYPOINT COLOURS

end)

