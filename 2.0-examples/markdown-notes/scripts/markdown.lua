-- markdown.lua -- a Markdown-to-HTML renderer in about a hundred lines.
--
-- Not the whole CommonMark spec; the parts people write in notes:
--
--   # headings           *italic*  **bold**  `code`
--   - bullets            1. numbered lists
--   > quotes             --- rules
--   ```fenced code```    [links](http://...)
--
-- It works a line at a time, keeping just enough state to know whether it
-- is inside a list, a quote or a code fence. ui.TextField:setHtml shows the
-- result -- Qt's rich text knows these tags, so no browser is needed.

local Markdown = {}

local function escape(text)
    return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Inline marks, applied after escaping so that a literal "<b>" in a note
-- shows as text rather than becoming bold.
local function inline(text)
    text = escape(text)
    text = text:gsub("`([^`]+)`", "<code>%1</code>")
    text = text:gsub("%*%*(.-)%*%*", "<b>%1</b>")
    text = text:gsub("%*(.-)%*", "<i>%1</i>")
    text = text:gsub("%[([^%]]+)%]%(([^%)]+)%)", '<a href="%2">%1</a>')
    return text
end

--- The HTML for a Markdown string.
function Markdown.toHtml(source)
    local out = {}
    local list = nil           -- "ul" or "ol" while inside a list
    local quote = false
    local fence = false
    local paragraph = {}

    local function closeParagraph()
        if #paragraph > 0 then
            out[#out + 1] = "<p>" .. table.concat(paragraph, " ") .. "</p>"
            paragraph = {}
        end
    end
    local function closeList()
        if list then out[#out + 1] = "</" .. list .. ">"; list = nil end
    end
    local function closeQuote()
        if quote then out[#out + 1] = "</blockquote>"; quote = false end
    end
    local function closeAll()
        closeParagraph(); closeList(); closeQuote()
    end

    for line in (source .. "\n"):gmatch("(.-)\r?\n") do
        if fence then
            if line:match("^```") then
                out[#out + 1] = "</pre>"
                fence = false
            else
                out[#out + 1] = escape(line)
            end
        elseif line:match("^```") then
            closeAll()
            out[#out + 1] = '<pre style="background:#f1f5f9;color:#111;padding:6px">'
            fence = true
        elseif line:match("^%s*$") then
            closeAll()
        elseif line:match("^#+%s") then
            closeAll()
            local hashes, text = line:match("^(#+)%s+(.*)$")
            local level = math.min(#hashes, 4)
            out[#out + 1] = string.format("<h%d>%s</h%d>", level, inline(text), level)
        elseif line:match("^%-%-%-+%s*$") or line:match("^%*%*%*+%s*$") then
            closeAll()
            out[#out + 1] = "<hr>"
        elseif line:match("^>%s?") then
            closeParagraph(); closeList()
            if not quote then
                out[#out + 1] = '<blockquote style="color:#555;margin-left:12px">'
                quote = true
            end
            out[#out + 1] = inline(line:gsub("^>%s?", "")) .. "<br>"
        elseif line:match("^%s*[%-%*]%s+") then
            closeParagraph(); closeQuote()
            if list ~= "ul" then closeList(); out[#out + 1] = "<ul>"; list = "ul" end
            out[#out + 1] = "<li>" .. inline(line:gsub("^%s*[%-%*]%s+", "")) .. "</li>"
        elseif line:match("^%s*%d+%.%s+") then
            closeParagraph(); closeQuote()
            if list ~= "ol" then closeList(); out[#out + 1] = "<ol>"; list = "ol" end
            out[#out + 1] = "<li>" .. inline(line:gsub("^%s*%d+%.%s+", "")) .. "</li>"
        else
            closeList(); closeQuote()
            paragraph[#paragraph + 1] = inline(line)
        end
    end
    if fence then out[#out + 1] = "</pre>" end
    closeAll()
    return table.concat(out, "\n")
end

--- The title a note gets from its text: the first heading, else the first
--- non-empty line, trimmed to fit a list.
function Markdown.title(source)
    for line in (source .. "\n"):gmatch("(.-)\r?\n") do
        local heading = line:match("^#+%s+(.-)%s*$")
        if heading and heading ~= "" then return heading:sub(1, 60) end
        local text = line:match("^%s*(.-)%s*$")
        if text ~= "" and not text:match("^```") then
            return (text:gsub("[%*`_#>]", "")):sub(1, 60)
        end
    end
    return "Untitled"
end

--- Words in a note, for the status bar.
function Markdown.wordCount(source)
    local count = 0
    for _ in source:gmatch("%S+") do count = count + 1 end
    return count
end

return Markdown
