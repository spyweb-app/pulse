local M = {}

local COLORS = { DOWN = 15548997, BLOCKED = 15844367, UP = 5763719 }

function M.send(cfg, alert)
    return http_post(cfg.url, json_encode({
        embeds = {{
            title = alert.severity .. ": " .. alert.monitor,
            description = alert.message,
            color = COLORS[alert.severity] or 10070709,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", alert.timestamp),
            fields = {{ name = "URL", value = alert.url, inline = false }},
        }}
    }), { ["Content-Type"] = "application/json" })
end

return M
