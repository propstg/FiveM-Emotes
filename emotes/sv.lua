RegisterCommand('emotes', function (source, args)
    TriggerClientEvent("emote:display", source)
end, false)

RegisterCommand('emote', function (source, args)
    if #args == 0 then
        return TriggerClientEvent("chatMessage", source, "ERROR", {255,0,0}, "^7Use \"^3/emotes^7\" to display all of the emotes")
    end

    TriggerClientEvent("emote:invoke", source, args[1])
end, false)

RegisterCommand('cancelemote', function (source, args)
    TriggerClientEvent("emote:cancelnow", source)
end, false)