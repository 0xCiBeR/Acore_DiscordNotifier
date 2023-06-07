--[[
    DiscordWebhookIntegration

    This script contains the necessary configuration and functions for Discord integration with a game server.
    It's primarily used to send chat events from the game server to a specified Discord channel.
    Supported events include: general chat, whispers, group chat, and guild chat.

    When using this script, it's important to set the global Discord webhook.
    If specific webhooks are not set for a certain type of event, the global webhook will be used instead.
    It's also possible to disable certain types of events by changing values in the eventOn table.

    Author: 0xCiBeR(https://github.com/0xCiBeR)
--]]

-- Config Flags Section -> EDIT TO YOUR LIKING!!

Config = {
    hooks = {},
    eventOn = {},
    privacyWarning = true,
    hooks = {
        globalWebook = "https://discord.com/api/webhooks/.............",
        PLAYER_EVENT_ON_CHAT = nil,
        PLAYER_EVENT_ON_WHISPER = nil,
        PLAYER_EVENT_ON_GROUP_CHAT = nil,
        PLAYER_EVENT_ON_GUILD_CHAT = nil,
    },
    eventOn = {
        PLAYER_EVENT_ON_CHAT = true,
        PLAYER_EVENT_ON_WHISPER = true,
        PLAYER_EVENT_ON_GROUP_CHAT = true,
        PLAYER_EVENT_ON_GUILD_CHAT = true,
    }
}

-- Event Mappings Section -- DO NOT TOUCH!!

local events = {
    PLAYER_EVENT_ON_CHAT = 18,
    PLAYER_EVENT_ON_WHISPER = 19,
    PLAYER_EVENT_ON_GROUP_CHAT = 20,
    PLAYER_EVENT_ON_GUILD_CHAT = 21,
    PLAYER_EVENT_ON_LOGIN = 3,
}

-- Utility Function Section -- DO NOT TOUCH!!

local function sendToDiscord(event, msg)
    if msg and event then
        local webhook = Config.hooks[event] or Config.hooks.globalWebook
        HttpRequest("POST", webhook, '{"content": "'..msg..'"}', "application/json", 
        function(status, body, headers)
            if status ~= 200 then
                print("DiscordNotifier[Lua] Error when sending webhook to discord. Response body is: "..body)
            end
        end)
    end
end

-- Events Section -- DO NOT TOUCH!!

local function OnChat(event, player, msg)
    if Config.eventOn[event] then
        local name = player:GetName()
        local guid = player:GetGUIDLow()
        sendToDiscord(event, '__CHAT__ -> **|'..guid..'| '..name..'**: '..msg)
    end
end

local function OnWhisperChat(event, player, msg, Type, lang, receiver)
    if Config.eventOn[event] then
        local sName = player:GetName()
        local sGuid = player:GetGUIDLow()
        local rName = receiver:GetName()
        local rGuid = receiver:GetGUIDLow()
        sendToDiscord(event, '__WHISPER__ -> **|'..sGuid..'| '..sName..' -> |'..rGuid..'| '..rName..'**: '..msg)
    end
end

-- OnGroupChat
local function OnGroupChat(event, player, msg, Type, lang, group)
    local name = player:GetName()
    local guid = player:GetGUIDLow()
    local leaderGuid = group:GetLeaderGUID()
    local leader = GetPlayerByGUID(leaderGuid)
    local lName = leader:GetName()
    local lGuidLow = leader:GetGUIDLow()
    sendToDiscord(event, '__GROUP CHAT__ -> **|'..guid..'| '..name..'**: '..msg..' **[LEADER -> '..lName..'('..lGuidLow..')]**')
end

-- OnGuildChat
local function OnGuildChat(event, player, msg, Type, lang, guild)
    local name = player:GetName()
    local guid = player:GetGUIDLow()
    local gName = guild:GetName()
    local gId = guild:GetId()
    sendToDiscord(event, '__GUILD__ -> **[ |'..gId..'| -> '..gName..'] |'..guid..'| '..name..'**: '..msg)
end

-- Register Events Section -- DO NOT TOUCH!!

RegisterPlayerEvent(events.PLAYER_EVENT_ON_CHAT, OnChat)
RegisterPlayerEvent(events.PLAYER_EVENT_ON_WHISPER, OnWhisperChat)
RegisterPlayerEvent(events.PLAYER_EVENT_ON_GROUP_CHAT, OnGroupChat)
RegisterPlayerEvent(events.PLAYER_EVENT_ON_GUILD_CHAT, OnGuildChat)

-- MISC -- DO NOT TOUCH!!

local messages = {
    [0] = "|cff00ff00[PRIVACY NOTICE] |cffff0000THIS SERVER IS CURRENTLY MONITORING AND FORWARDING TEXT MESSAGES SENT WITHIN THE SERVER TO DISCORD.",  -- enUS
    [1] = "|cff00ff00[개인정보 보호 알림] |cffff0000이 서버는 현재 서버 내에서 보낸 텍스트 메시지를 모니터링하고 DISCORD로 전달하고 있습니다.",  -- koKR
    [2] = "|cff00ff00[AVIS DE CONFIDENTIALITÉ] |cffff0000CE SERVEUR SURVEILLE ACTUELLEMENT ET TRANSFÈRE LES MESSAGES TEXTUELS ENVOYÉS DANS LE SERVEUR VERS DISCORD.",  -- frFR
    [3] = "|cff00ff00[DATENSCHUTZHINWEIS] |cffff0000DIESE SERVER ÜBERWACHT UND LEITET DERZEIT TEXTNACHRICHTEN WEITER, DIE INNERHALB DES SERVERS AN DISCORD GESCHICKT WERDEN.",  -- deDE
    [4] = "|cff00ff00[隐私声明] |cffff0000本服务器目前正在监控并转发在服务器内发送的文本消息至Discord。",  -- zhCN
    [5] = "|cff00ff00[隱私聲明] |cffff0000本伺服器目前正在監視並轉寄伺服器內發送的文字訊息至Discord。",  -- zhTW
    [6] = "|cff00ff00[AVISO DE PRIVACIDAD] |cffff0000ESTE SERVIDOR ESTÁ MONITORIZANDO Y REENVIANDO ACTUALMENTE LOS MENSAJES DE TEXTO ENVIADOS DENTRO DEL SERVIDOR A DISCORD.",  -- esES
    [7] = "|cff00ff00[AVISO DE PRIVACIDAD] |cffff0000ESTE SERVIDOR ESTÁ MONITORIZANDO Y REENVIANDO ACTUALMENTE LOS MENSAJES DE TEXTO ENVIADOS DENTRO DEL SERVIDOR A DISCORD.",  -- esMX
    [8] = "|cff00ff00[УВЕДОМЛЕНИЕ О КОНФИДЕНЦИАЛЬНОСТИ] |cffff0000ЭТОТ СЕРВЕР В НАСТОЯЩЕЕ ВРЕМЯ ОТСЛЕЖИВАЕТ И ПЕРЕНАПРАВЛЯЕТ ТЕКСТОВЫЕ СООБЩЕНИЯ, ОТПРАВЛЕННЫЕ ВНУТРИ СЕРВЕРА, В DISCORD.",  -- ruRU
}

local function privacyAlert(event, player)
    if Config.privacyWarning then
        for i, v in pairs(Config.eventOn) do
            if v == true then
                local language = player:GetSession():GetSessionDbLocaleIndex() 
                local message = messages[language] or messages[0] -- use English as default if preferred language not found
                player:SendBroadcastMessage(message)
                break
            end
        end
    end
end

RegisterPlayerEvent(events.PLAYER_EVENT_ON_LOGIN, privacyAlert)