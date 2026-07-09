local H = require("helpers")
local db = require("lib.db")
local import_export = require("lib.import_export")

local M = {}

function M.export(self)
    local fmt = self.query.format or "json"
    local rows = db.export_all()
    if fmt == "csv" then
        return {
            status = 200,
            body = import_export.export_csv(rows),
            headers = {
                ["Content-Type"] = "text/csv",
                ["Content-Disposition"] = 'attachment; filename="pulse-monitors.csv"',
            },
        }
    end
    return H.json_response(200, rows)
end

function M.import(self)
    local entries = import_export.parse_import(self.body or "")
    if not entries then
        return H.json_response(400, nil, "Invalid JSON or CSV — check the file format and try again")
    end
    local imported, skipped, failed = 0, 0, 0
    for _, entry in ipairs(entries) do
        if not import_export.validate_entry(entry) then
            failed = failed + 1
        else
            local ok, _ = db.insert_monitor(entry)
            if ok then
                imported = imported + 1
            else
                skipped = skipped + 1
            end
        end
    end
    return H.json_response(200, {
        imported = imported, skipped = skipped, failed = failed, total = #entries,
    })
end

function M.list(self)
    local cmd = self.path_args[1]
    local id = tonumber(cmd)

    if id then
        local sub = self.path_args[2]

        if sub == "history" then
            local before = H.int_param(self.query, "before", os.time())
            local limit = H.int_param(self.query, "limit", 50)
            local rows = db.get_history(id, before, limit)
            return H.json_response(200, rows)
        end

        if sub == "summary" then
            local days = H.int_param(self.query, "days", 7)
            local group = H.str_param(self.query, "group", "day")
            local rows = db.get_summary(id, days, group)
            return H.json_response(200, rows)
        end

        if sub == "channels" then
            return H.json_response(200, db.get_monitor_channel_ids(id))
        end

        local row = db.get(id)
        if not row then
            return H.json_response(404, nil, "Monitor not found")
        end
        return H.json_response(200, row)
    end

    local opts = {
        page = H.int_param(self.query, "page", 1),
        per_page = H.int_param(self.query, "per_page", 25),
        sort = self.query.sort or "name",
        order = self.query.order or "asc",
        q = self.query.q or "",
    }
    if self.query.enabled ~= nil then
        opts.enabled = H.int_param(self.query, "enabled")
    end
    local result = db.monitor_list(opts)
    return H.json_response(200, result)
end

function M.create(self)
    local data = json_decode(self.body or "")
    if not data or type(data) ~= "table" then
        return H.json_response(400, nil, "Invalid JSON body")
    end

    if not data.name or data.name == "" then
        return H.json_response(400, nil, "name is required")
    end
    if not data.url or data.url == "" then
        return H.json_response(400, nil, "url is required")
    end

    if db.get_by_url(data.url) then
        return H.json_response(409, nil, "A monitor with this URL already exists")
    end

    local ok2, err = db.insert_monitor(data)
    if not ok2 then
        return H.json_response(409, nil, "Failed to create: " .. tostring(err))
    end

    local row = db.get_by_url(data.url)
    return H.json_response(201, row)
end

function M.update(self)
    local id = H.id_or_nil(self.path_args)
    if not id then
        return H.json_response(400, nil, "Monitor ID required")
    end

    if self.path_args[2] == "channels" then
        local data = json_decode(self.body or "")
        if not data or type(data) ~= "table" then
            return H.json_response(400, nil, "Invalid JSON body")
        end
        db.set_monitor_channels(id, data)
        return H.json_response(200, { success = true })
    end

    local data = json_decode(self.body or "")
    if not data or type(data) ~= "table" then
        return H.json_response(400, nil, "Invalid JSON body")
    end

    local sets = {}
    local params = {}

    local updatable = { "name", "url", "method", "interval_sec", "timeout_ms", "check_value", "enabled", "desktop_notify", "check_cert", "cert_threshold_days" }
    for _, field in ipairs(updatable) do
        if data[field] ~= nil then
            table.insert(sets, field .. " = ?")
            table.insert(params, data[field])
        end
    end

    if #sets == 0 then
        return H.json_response(400, nil, "No fields to update")
    end

    db.update_monitor(id, sets, params)

    local row = db.get(id)
    if not row then
        return H.json_response(404, nil, "Monitor not found")
    end
    return H.json_response(200, row)
end

function M.remove(self)
    local id = H.id_or_nil(self.path_args)
    if not id then
        return H.json_response(400, nil, "Monitor ID required")
    end

    local row = db.get(id)
    if not row then
        return H.json_response(404, nil, "Monitor not found")
    end

    db.delete_monitor(id)
    return H.json_response(200, { deleted = true })
end

return M
