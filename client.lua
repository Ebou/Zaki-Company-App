--------------- [[ STANDARD LB PHONE APP SETUP ]] ---------------

local appInfo = {
    identifier = "firmaer",
    name = "Services",
    description = "Kontakt et firma",
    icon = Config.Icon
}

function CallbackOperation(callback, args, successMenu, errorMenu)
    local response = lib.callback.await(callback, false, table.unpack(args))
    if not response then
        lib.notify({
            type = "error",
            description = "Der skete en fejl, prøv igen senere."
        })
        return
    end
end

Citizen.CreateThread(function()
    local added, errorMessage = exports["lb-phone"]:AddCustomApp({
        identifier = appInfo.identifier,
        name = appInfo.name,
        description = appInfo.description,
        icon = appInfo.icon,
        ui = GetCurrentResourceName() .. "/ui/index.html" 
    })

    if not added then
        print("Could not add app:", errorMessage)
    end
end)
RegisterNUICallback("setupApp", function(data, cb)
    local firmaer = lib.callback.await('company_app:GetCompanies', false)
    print(json.encode(firmaer))
    cb(lib.callback.await('company_app:GetCompanies', false))
end)

RegisterNUICallback("sendMessage", function(data, cb)
    local message = data.message
    local job = data.job

    if message and job then
        TriggerServerEvent("company_app:SendCompanyMessage", message, job)
        TriggerEvent("InteractSound_CL:PlayOnOne", "ding", 15)

        cb("Message sent successfully")
    else
        cb("Failed to send message")
    end
end)
RegisterNUICallback("sendAd", function(data, cb)
    local message = data.message
    local job = data.job

    if message and job then
        TriggerServerEvent("company_app:SendAd", message, job)
        TriggerEvent("InteractSound_CL:PlayOnOne", "ding", 15)

        cb("Message sent successfully")
    else
        cb("Failed to send message")
    end
end)
RegisterNetEvent("company_app:updateCompanies", function(companies)
    local firmaer = lib.callback.await('company_app:GetCompanies', false)
    print(firmaer)
    lib.notify({ title = 'Success!', description = "Du togglede job-status.", type = 'success' })
    exports["lb-phone"]:SendCustomAppMessage(appInfo.identifier, {
        action = "refreshCompanies",
        companies = firmaer,
        icon = appInfo.icon,
    })
end)
RegisterNetEvent("company_app:GetCompanyAd", function(message, job, jobLabel)
    print(job)
    exports["lb-phone"]:SendNotification({
        app =appInfo.identifier,
        title = jobLabel,
        content = message,
        avatar = "https://cfx-nui-lb-vanilla/ui/assets/"..job..".png",
    })
end)
