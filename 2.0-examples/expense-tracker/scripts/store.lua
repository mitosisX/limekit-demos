-- store.lua -- everything the expense tracker knows about its data.
--
-- The rest of the app never writes SQL. It asks this module for rows and
-- totals and tells it about changes, so the interface and the storage can
-- change independently: swap SQLite for a JSON file here and main.lua is
-- untouched.
--
-- A project's scripts folder is on package.path, so main.lua reaches this
-- with require("store") -- the same way the designer's generated modules
-- are reached with require("designed.<name>").

local db = require("limekit.db")
local fs = require("limekit.fs")
local sys = require("limekit.sys")

local Store = {}

Store.CATEGORIES = { "Food", "Transport", "Home", "Health", "Fun", "Other" }

local connection = nil

--- Opens (or creates) the database and makes sure the table is there.
function Store.open(path)
    connection = db.Sqlite3(path)
    connection:createTable("expenses", {
        id = "INTEGER PRIMARY KEY AUTOINCREMENT",
        day = "TEXT NOT NULL",            -- yyyy-mm-dd, so it sorts as text
        category = "TEXT NOT NULL",
        amount = "REAL NOT NULL",
        note = "TEXT DEFAULT ''",
    }, true)
    connection:save()
end

--- Seeds a few months of plausible spending the first time the app runs,
--- so the charts have something to show before a single entry is typed.
function Store.seedIfEmpty()
    connection:execute("SELECT COUNT(*) FROM expenses;")
    if connection:fetchOne() ~= 0 then return false end

    local System = sys.System
    local rows = {}
    local notes = {
        Food = { "Groceries", "Lunch out", "Coffee", "Takeaway" },
        Transport = { "Fuel", "Bus pass", "Taxi", "Parking" },
        Home = { "Electricity", "Internet", "Cleaning", "Repairs" },
        Health = { "Pharmacy", "Gym", "Dentist" },
        Fun = { "Cinema", "Books", "Concert", "Games" },
        Other = { "Gift", "Subscription", "Haircut" },
    }
    local typical = { Food = 18, Transport = 25, Home = 60, Health = 30, Fun = 22, Other = 15 }
    for month = 1, 6 do
        for _ = 1, 9 do
            local category = System.randomChoice(Store.CATEGORIES)
            local day = string.format("2026-%02d-%02d", month, math.random(1, 28))
            local amount = typical[category] * (0.5 + math.random() * 1.5)
            rows[#rows + 1] = { day, category, math.floor(amount * 100 + 0.5) / 100,
                                System.randomChoice(notes[category]) }
        end
    end
    connection:executeMany("INSERT INTO expenses (day, category, amount, note) VALUES (?, ?, ?, ?);", rows)
    connection:save()
    return true
end

-- WRITES --------------------------------------------------------------------

function Store.add(day, category, amount, note)
    connection:insert("expenses", { day = day, category = category, amount = amount, note = note })
    connection:save()
end

function Store.update(id, day, category, amount, note)
    connection:execute("UPDATE expenses SET day = ?, category = ?, amount = ?, note = ? WHERE id = ?;",
        { day, category, amount, note, id })
    connection:save()
end

function Store.remove(id)
    connection:execute("DELETE FROM expenses WHERE id = ?;", { id })
    connection:save()
end

-- READS ---------------------------------------------------------------------

-- A filter is { month = "2026-03" or nil, category = "Food" or nil,
-- text = "lunch" or nil }. Each part narrows; none means everything.
local function whereClause(filter)
    local parts, params = {}, {}
    if filter.month then
        parts[#parts + 1] = "day LIKE ?"
        params[#params + 1] = filter.month .. "-%"
    end
    if filter.category then
        parts[#parts + 1] = "category = ?"
        params[#params + 1] = filter.category
    end
    if filter.text and filter.text ~= "" then
        parts[#parts + 1] = "LOWER(note) LIKE ?"
        params[#params + 1] = "%" .. filter.text:lower() .. "%"
    end
    if #parts == 0 then return "", params end
    return " WHERE " .. table.concat(parts, " AND "), params
end

--- Rows matching the filter, newest first, as tables with named fields.
function Store.list(filter)
    local where, params = whereClause(filter or {})
    connection:execute("SELECT id, day, category, amount, note FROM expenses" .. where
        .. " ORDER BY day DESC, id DESC;", params)
    return connection:fetchAll(true)
end

--- One row by id, or nil.
function Store.get(id)
    connection:execute("SELECT id, day, category, amount, note FROM expenses WHERE id = ?;", { id })
    return connection:fetchOne(true)
end

--- The distinct months with any spending, newest first: { "2026-06", ... }.
function Store.months()
    connection:execute("SELECT DISTINCT SUBSTR(day, 1, 7) AS month FROM expenses ORDER BY month DESC;")
    local months = {}
    for _, row in ipairs(connection:fetchAll()) do months[#months + 1] = row end
    return months
end

--- Total per category for the filter, in Store.CATEGORIES order (zeros
--- included, so a chart always has one bar per category).
function Store.byCategory(filter)
    local where, params = whereClause(filter or {})
    connection:execute("SELECT category, SUM(amount) FROM expenses" .. where .. " GROUP BY category;", params)
    local totals = {}
    for _, row in ipairs(connection:fetchAll()) do totals[row[1]] = row[2] end
    local out = {}
    for _, name in ipairs(Store.CATEGORIES) do out[#out + 1] = totals[name] or 0 end
    return out
end

--- Total per month, oldest first: { { month = "2026-01", total = 412.5 }, ... }.
function Store.byMonth()
    connection:execute("SELECT SUBSTR(day, 1, 7) AS month, SUM(amount) FROM expenses GROUP BY month ORDER BY month;")
    local out = {}
    for _, row in ipairs(connection:fetchAll()) do
        out[#out + 1] = { month = row[1], total = row[2] }
    end
    return out
end

--- The sum for a filter.
function Store.total(filter)
    local where, params = whereClause(filter or {})
    connection:execute("SELECT COALESCE(SUM(amount), 0) FROM expenses" .. where .. ";", params)
    return connection:fetchOne()
end

-- EXPORT --------------------------------------------------------------------

local function csvField(value)
    local text = tostring(value)
    if text:find('[,"\n]') then return '"' .. text:gsub('"', '""') .. '"' end
    return text
end

--- Writes the filtered rows as CSV. Returns how many.
function Store.exportCSV(path, filter)
    local rows = Store.list(filter)
    local lines = { "date,category,amount,note" }
    for _, row in ipairs(rows) do
        lines[#lines + 1] = table.concat({ row.day, csvField(row.category),
            string.format("%.2f", row.amount), csvField(row.note) }, ",")
    end
    fs.FileSystem.writeFile(path, table.concat(lines, "\n") .. "\n")
    return #rows
end

return Store
