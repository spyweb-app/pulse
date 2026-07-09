local M = {}

function M.send(cfg, alert)
    local server = cfg.url or "https://ntfy.sh"
    local headers = { ["Content-Type"] = "application/json" }
    if cfg.token then headers["Authorization"] = "Bearer " .. cfg.token end

    return http_post(server .. "/" .. cfg.topic, json_encode({
        topic = cfg.topic,
        title = alert.severity .. ": " .. alert.monitor,
        message = alert.message .. "\n\n" .. alert.url,
        priority = alert.severity == "DOWN" and 4 or 3,
        tags = { alert.severity == "DOWN" and "rotating_light" or "warning" },
    }), headers)
end

return M
