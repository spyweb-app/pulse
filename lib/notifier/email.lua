local M = {}

function M.send(cfg, alert)
    if cfg.provider == "sendgrid" then
        return http_post("https://api.sendgrid.com/v3/mail/send", json_encode({
            personalizations = {{ to = {{ email = cfg.to }}}},
            from = { email = cfg.from },
            subject = "[" .. (cfg.instance_name or "PULSE") .. "] " .. alert.severity .. ": " .. alert.monitor,
            content = {{ type = "text/plain", value = alert.message .. "\n\n" .. alert.url }},
        }), {
            ["Authorization"] = "Bearer " .. cfg.api_key,
            ["Content-Type"] = "application/json",
        })
    end
end

return M
