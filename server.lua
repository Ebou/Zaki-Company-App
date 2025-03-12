ESX = exports["es_extended"]:getSharedObject()
local companyStatus = {}

local function UpdateCompanyStatus()
    companyStatus = {}

    for _, playerId in ipairs(ESX.GetPlayers()) do
        local player = ESX.GetPlayerFromId(playerId)
        if player then
            local jobName = player.job.name
            companyStatus[jobName] = true
        end
    end

    for _, company in ipairs(Config.Companies) do
        companyStatus[company.job] = companyStatus[company.job] or false
    end
end

Citizen.CreateThread(function()
    while true do
        UpdateCompanyStatus()
        Citizen.Wait(30000) 
    end
end)

lib.callback.register('company_app:GetCompanies', function(source)
    local results = {}
    local xPlayer = ESX.GetPlayerFromId(source)

    for _, company in ipairs(Config.Companies) do
        local jobStatus = companyStatus[company.job] or false
        local isWorker = xPlayer.job.name == company.job

        table.insert(results, {
            img = company.img,
            name = company.name,
            showStatus = company.showStatus,
            status = jobStatus,
            job = company.job,
            isWorker = isWorker,
        })
    end

    return results
end)

RegisterServerEvent("company_app:SendCompanyMessage")
AddEventHandler("company_app:SendCompanyMessage", function(message, jobName)
    local src = source
    local jobFound = false
    print(jobName)
    for _, company in ipairs(Config.Companies) do
        if company.job == jobName then
            jobFound = true
            exports['visualz_opkaldsliste']:AddCall(src, message, jobName, nil)

            exports["lb-phone"]:SendNotification(src, {
                title = company.name,
                content = "Din besked er blevet sendt!",
                icon = Config.Icon,
            })

            for _, playerId in ipairs(ESX.GetPlayers()) do
                local xTarget = ESX.GetPlayerFromId(playerId)
                if xTarget and xTarget.job.name == jobName then
                    print("Notifying player ID " .. playerId .. " with job: " .. jobName)
                end
            end
            break
        end
    end

    if not jobFound then
        print("Job not found for name: " .. jobName)
    end
end)
RegisterServerEvent("company_app:SendAd")
AddEventHandler("company_app:SendAd", function(message, jobName)
    local src = source
    local jobFound = false
    print(jobName)
    for _, company in ipairs(Config.Companies) do
        if company.job == jobName then
            jobFound = true
            TriggerClientEvent("company_app:GetCompanyAd", -1, message, jobName, company.name)

            
            exports["lb-phone"]:SendNotification(src, {
                title = company.name,
                content = "Din reklame er blevet sendt!",
                icon = Config.Icon,
            })

          
            break
        end
    end

    if not jobFound then
        print("Job not found for name: " .. jobName)
    end
end)
