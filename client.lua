local QBCore = exports['qb-core']:GetCoreObject()
local pitizni = 0
local pitizniTimer = 0
local displayTimer = 0 -- Make displayTimer global
local pitizniThread = nil

RegisterCommand('pitizni', function()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local playerJob = QBCore.Functions.GetPlayerData().job

    if IsPedInAnyVehicle(playerPed, false) then
        if playerJob and playerJob.name == 'police' and playerJob.onduty then
            if pitizni == 0 then
                pitizni = 1
                QBCore.Functions.Notify("Pit İzni İstendi", "success")

                pitizniTimer = 1000 -- How many seconds should the pit track be?
                displayTimer = pitizniTimer

                pitizniThread = Citizen.CreateThread(function()
                    while displayTimer > 0 do
                        Citizen.Wait(1000) -- Wait for 1 second
                        displayTimer = displayTimer - 1

                        if displayTimer % 10 == 0 then -- A place where you can write how many seconds it will notify every time.
                            QBCore.Functions.Notify("Kalan süre: " .. displayTimer .. " saniye", "error")
                        end
                    end

                    pitizni = 3
                    -- Pit izni iptal edildikten sonra bir bildirim göstermek istiyorsanız bu satırı kullanabilirsiniz
                    -- QBCore.Functions.Notify("Pit İzni Verildi", "success")
                end)
            else
                QBCore.Functions.Notify("Pit İzni İstenmişti Lütfen Bekleyin", "error")
            end
        else
            QBCore.Functions.Notify("Bu komutu kullanma izniniz yok veya araçta değilsiniz.", "error")
        end
    else
        QBCore.Functions.Notify("Araçta değilsiniz.", "error")
    end
end, false)

RegisterCommand('pkalanzaman', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        if pitizni == 0 then
            QBCore.Functions.Notify("Pit İzni İstenmedi", "error")
        else
            local remainingTime = displayTimer
            if remainingTime <= 0 then
                QBCore.Functions.Notify("Pit İzni İstenmedi", "error")
            else
                QBCore.Functions.Notify("Kalan süre: " .. remainingTime .. " saniye", "error")
            end
        end
    else
        QBCore.Functions.Notify("Araçta değilsiniz.", "error")
    end
end, false)

RegisterCommand('piptal', function()
    if pitizni == 1 then
        pitizni = 0
        displayTimer = 0
        if pitizniThread then
            Citizen.StopThread(pitizniThread)
        end
        QBCore.Functions.Notify("Pit İzni İptal Edildi", "error")
    elseif pitizni == 3 then
        QBCore.Functions.Notify("Pit İzni Verildi", "success")
        pitizni = 0
    else
        QBCore.Functions.Notify("Henüz Pit İzni istenmemiş.", "error")
    end
end, false)
