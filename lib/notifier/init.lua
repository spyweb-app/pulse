local db = require("lib.db")

local services = {
    webhook = require("lib.notifier.webhook"),
    discord = require("lib.notifier.discord"),
    slack   = require("lib.notifier.slack"),
    ntfy    = require("lib.notifier.ntfy"),
    email   = require("lib.notifier.email"),
}

function dispatch(monitor_id, alert)
    local channels = db.get_alert_channels(monitor_id)
    for _, ch in ipairs(channels) do
        local cfg = json_decode(ch.config) or {}
        local svc = services[ch.type]
        if svc then
            local ok, err = pcall(svc.send, cfg, alert)
            if not ok then
                log("Notification channel " .. ch.id .. " (" .. ch.type .. ") failed: " .. tostring(err))
            end
        end
    end
end

function dispatch_to_channel(channel_id, alert)
    local ch = db.get_channel(channel_id)
    if not ch then return nil, "Channel not found" end
    local cfg = json_decode(ch.config) or {}
    local svc = services[ch.type]
    if not svc then return nil, "Unknown channel type: " .. ch.type end
    local ok, resp = pcall(svc.send, cfg, alert)
    if not ok then return nil, tostring(resp) end
    return true, resp
end

return { dispatch = dispatch, dispatch_to_channel = dispatch_to_channel }
