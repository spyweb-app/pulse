local db = require("lib.db")

function on_finished()
    local now = os.time()
    local last = tonumber(global_store_get("last_cleanup")) or 0

    if now - last >= 86400 then
        global_store_set("last_cleanup", tostring(now))

        local days = db.get_retention_days()
        local deleted = db.cleanup_old_history(days)
        if deleted and deleted > 0 then
            log("Cleaned " .. deleted .. " records older than " .. days .. " days")
        end
    end

end
