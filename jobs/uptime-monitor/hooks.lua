local db = require("lib.db")
local check = require("lib.check")
local alert = require("alert")

db.ensure_schema()

function before_fetch(request, ctx)
    local rows = db.claim_next_due()
    if #rows == 0 then return nil end

    local m = rows[1]
    request.url = m.url
    request.method = (m.check_value and m.check_value ~= "") and "GET" or (m.method or "HEAD")

    ctx.shared = {
        monitor_id = m.id,
        monitor_name = m.name,
        monitor_url = m.url,
        check_value = m.check_value or "",
        was_up = m.is_up == 1,
        prev_failures = m.consecutive_failures or 0,
        desktop_notify = m.desktop_notify or 0,
        check_cert = m.check_cert or 0,
        cert_threshold_days = m.cert_threshold_days or 14,
        cert_last_check = m.cert_last_check,
    }

    return request
end

function after_fetch(fetch_result, ctx)
    local s = ctx.shared
    if not s.monitor_id then return nil end

    local now = os.time()
    local response_time_ms = (fetch_result.response and fetch_result.response.time_ms) or 0

    local r = check.classify_status(fetch_result)
    local is_up, severity, status_code, err_msg = r.is_up, r.severity, r.status_code, r.err or ""

    if is_up == 1 and s.check_value ~= "" then
        local cc = check.check_content(fetch_result.response and fetch_result.response.body, s.check_value)
        if cc then
            is_up, severity, err_msg = 0, "DOWN", cc.err
        end
    end

    local new_failures = alert.compute_failures(is_up, severity, s.prev_failures)

    db.insert_check(s.monitor_id, status_code, response_time_ms, is_up, err_msg)
    db.update_monitor_status(s.monitor_id, is_up, status_code, response_time_ms, new_failures)

    alert.maybe_alert(s, severity, new_failures, now, status_code, err_msg)

    -- Cert check (if enabled and HTTPS)
    if s.check_cert == 1 then
        local last = s.cert_last_check
        if not last or (now - tonumber(last)) >= 86400 then
            local host = s.monitor_url:match("https://([^/]+)")
            if host then
                local cert, err = tls_probe(host)
                if cert then
                    db.update_cert_info(s.monitor_id, cert.not_after, cert.days_left, now)
                    if cert.days_left < s.cert_threshold_days then
                        alert.do_alert(s, "DOWN", "Certificate expires in " .. cert.days_left .. " days (" .. cert.subject .. ")")
                    end
                else
                    db.update_cert_info(s.monitor_id, nil, nil, now)
                    alert.do_alert(s, "DOWN", "TLS probe failed: " .. (err or "unknown"))
                end
            end
        end
    end

    return nil
end
