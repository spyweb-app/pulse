local H = require("helpers")
local M = {}

function M.check(self)
    return H.json_response(200, { status = "ok", headless = engine.headless })
end

return M
