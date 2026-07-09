local M = {}

function M.classify_status(fetch_result)
    if not fetch_result.ok and not fetch_result.response then
        return {
            is_up = 0,
            severity = "DOWN",
            status_code = 0,
            err = (fetch_result.error and fetch_result.error.message) or "unknown"
        }
    end

    if fetch_result.response then
        local status = fetch_result.response.status

        if status >= 500 then
            return { is_up = 0, severity = "DOWN", status_code = status }
        elseif status >= 400 then
            return { is_up = 1, severity = "BLOCKED", status_code = status }
        elseif status >= 200 then
            return { is_up = 1, severity = "UP", status_code = status }
        else
            return { is_up = 0, severity = "DOWN", status_code = status }
        end
    end

    return { is_up = 0, severity = "DOWN", status_code = 0, err = "unknown error" }
end

function M.check_content(body, value)
    if not value or value == "" then return nil end
    if not body then
        return { is_up = 0, err = "No response body to check" }
    end
    if not body:find(value, 1, true) then
        return { is_up = 0, err = "Expected content not found: " .. value }
    end
    return nil
end

return M
