local M = {}

function M.send(cfg, alert)
    local color = alert.severity == "DOWN" and "#ef4444" or alert.severity == "BLOCKED" and "#eab308" or "#22c55e"
    return http_post(cfg.url, json_encode({
        attachments = {{
            color = color,
            blocks = {{
                type = "header",
                text = { type = "plain_text", text = alert.severity .. ": " .. alert.monitor }
            }, {
                type = "section",
                text = { type = "mrkdwn", text = alert.message }
            }, {
                type = "context",
                elements = {{ type = "mrkdwn", text = "<" .. alert.url .. "|" .. alert.url .. ">" }}
            }}
        }}
    }), { ["Content-Type"] = "application/json" })
end

return M
