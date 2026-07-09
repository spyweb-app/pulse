local H = require("helpers")
local db = require("lib.db")
local notifier = require("lib.notifier")

local M = {}

function M.list(self)
    return H.json_response(200, db.list_channels())
end

function M.create(self)
    local data = json_decode(self.body or "")
    if not data or type(data) ~= "table" then
        return H.json_response(400, nil, "Invalid JSON body")
    end

    if not data.name or data.name == "" then
        return H.json_response(400, nil, "name is required")
    end
    if not data.type or data.type == "" then
        return H.json_response(400, nil, "type is required")
    end

    local row, err = db.create_channel(data)
    if not row then
        return H.json_response(500, nil, "Failed to create: " .. tostring(err))
    end

    return H.json_response(201, row)
end

function M.test(self)
    local id = tonumber(self.path_args[1])
    if not id then
        return H.json_response(400, nil, "Channel ID required")
    end
    local row = db.get_channel(id)
    if not row then
        return H.json_response(404, nil, "Channel not found")
    end
    local body = json_decode(self.body or "{}")
    local msg = (type(body) == "table" and body.message) or "Test notification from PULSE"
    local ok, resp = notifier.dispatch_to_channel(id, {
        monitor = "Test",
        url = "",
        severity = "UP",
        message = msg,
        timestamp = os.time(),
    })
    if not ok then
        return H.json_response(500, nil, "Test failed: " .. tostring(resp))
    end
    if type(resp) == "table" and resp.status and resp.status >= 400 then
        return H.json_response(200, {
            name = row.name,
            type = row.type,
            response = resp,
            error = "HTTP " .. resp.status,
        })
    end
    return H.json_response(200, { name = row.name, type = row.type, response = resp })
end

function M.update(self)
    local id = tonumber(self.path_args[1])
    if not id then
        return H.json_response(400, nil, "Channel ID required")
    end

    if self.path_args[2] == "test" then
        return M.test(self)
    end

    local data = json_decode(self.body or "")
    if not data or type(data) ~= "table" then
        return H.json_response(400, nil, "Invalid JSON body")
    end

    local row = db.get_channel(id)
    if not row then
        return H.json_response(404, nil, "Channel not found")
    end

    row = db.update_channel(id, data)
    return H.json_response(200, row)
end

function M.remove(self)
    local id = tonumber(self.path_args[1])
    if not id then
        return H.json_response(400, nil, "Channel ID required")
    end

    local row = db.get_channel(id)
    if not row then
        return H.json_response(404, nil, "Channel not found")
    end

    db.delete_channel(id)
    return H.json_response(200, { deleted = true })
end

return M
