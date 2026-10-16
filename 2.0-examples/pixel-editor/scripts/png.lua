-- png.lua -- a PNG encoder in Lua, with nothing but string.pack and the
-- integer operators.
--
-- A PNG is a signature and a list of chunks; each chunk is a length, a
-- four-letter type, the data, and a CRC32 of type-plus-data. Three chunks
-- make a picture:
--
--   IHDR   width, height, 8 bits per channel, RGBA
--   IDAT   the pixels, in a zlib stream
--   IEND   nothing
--
-- The zlib stream is the only tricky part, and there is a way round the
-- hard bit: deflate allows *stored* blocks, which are the bytes as they
-- are, 65535 at a time, with a five-byte header each. No compression --
-- a 32x32 image is 4 KB instead of a few hundred bytes -- but every
-- viewer reads it, and the encoder stays short enough to read in one
-- sitting. Then an Adler-32 of the raw data closes the stream.
--
-- Each row starts with a filter byte (0: none) followed by RGBA per pixel.
--
-- The result is bytes, and bytes cannot cross to Python as a Lua string,
-- which arrives as text. So the file goes out as base64 through
-- fs.FileSystem.writeBase64, encoded here.

local PNG = {}

-- CRC32, table driven, as in the PNG specification's own sample code.
local CRC = {}
for i = 0, 255 do
    local c = i
    for _ = 1, 8 do
        if c & 1 == 1 then c = 0xEDB88320 ~ (c >> 1) else c = c >> 1 end
    end
    CRC[i] = c
end

local function crc32(s)
    local c = 0xFFFFFFFF
    for i = 1, #s do
        c = CRC[(c ~ s:byte(i)) & 0xFF] ~ (c >> 8)
    end
    return (c ~ 0xFFFFFFFF) & 0xFFFFFFFF
end

local function adler32(s)
    local a, b = 1, 0
    for i = 1, #s do
        a = (a + s:byte(i)) % 65521
        b = (b + a) % 65521
    end
    return (b << 16) | a
end

local function chunk(kind, data)
    return string.pack(">I4", #data) .. kind .. data .. string.pack(">I4", crc32(kind .. data))
end

-- A zlib stream of stored blocks: header, blocks, Adler-32.
local function zlibStored(raw)
    local parts = { "\x78\x01" }
    local pos, n = 1, #raw
    repeat
        local size = math.min(65535, n - pos + 1)
        local last = pos + size > n
        parts[#parts + 1] = string.char(last and 1 or 0)
            .. string.pack("<I2", size) .. string.pack("<I2", (~size) & 0xFFFF)
            .. raw:sub(pos, pos + size - 1)
        pos = pos + size
    until pos > n
    parts[#parts + 1] = string.pack(">I4", adler32(raw))
    return table.concat(parts)
end

--- The bytes of a PNG. pixelAt(row, column) returns r, g, b, a (0-255).
function PNG.encode(width, height, pixelAt)
    local rows = {}
    for r = 1, height do
        local row = { "\0" }                        -- filter: none
        for c = 1, width do
            local red, green, blue, alpha = pixelAt(r, c)
            row[#row + 1] = string.char(red, green, blue, alpha)
        end
        rows[r] = table.concat(row)
    end
    local raw = table.concat(rows)
    local header = string.pack(">I4I4", width, height) .. string.char(8, 6, 0, 0, 0)
    return "\137PNG\r\n\26\n" .. chunk("IHDR", header) .. chunk("IDAT", zlibStored(raw)) .. chunk("IEND", "")
end

-- BASE64 ----------------------------------------------------------------------

local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

--- Bytes as base64 text, for fs.FileSystem.writeBase64.
function PNG.base64(data)
    local out = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i + 2)
        local n = (a << 16) | ((b or 0) << 8) | (c or 0)
        local quad = {
            ALPHABET:sub((n >> 18) + 1, (n >> 18) + 1),
            ALPHABET:sub(((n >> 12) & 63) + 1, ((n >> 12) & 63) + 1),
            b and ALPHABET:sub(((n >> 6) & 63) + 1, ((n >> 6) & 63) + 1) or "=",
            c and ALPHABET:sub((n & 63) + 1, (n & 63) + 1) or "=",
        }
        out[#out + 1] = table.concat(quad)
    end
    return table.concat(out)
end

--- "#rrggbb" to three numbers.
function PNG.rgb(hex)
    local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
    if not r then return 0, 0, 0 end
    return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

return PNG
