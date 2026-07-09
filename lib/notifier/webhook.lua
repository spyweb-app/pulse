local M = {}

function M.send(cfg, alert)
    return http_post(cfg.url, json_encode({
        event = "monitor_alert",
        monitor = alert.monitor,
        url = alert.url,
        severity = alert.severity,
        message = alert.message,
        timestamp = alert.timestamp,
    }), { ["Content-Type"] = "application/json" })
end

return M
