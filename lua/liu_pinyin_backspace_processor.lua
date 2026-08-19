-- liu_pinyin_backspace_processor.lua
-- 刪除時一併清掉孤立的分節符（空白或 '），避免殘碼

local function refresh(context)
    if context.refresh_non_confirmed_composition then
        context:refresh_non_confirmed_composition()
    end
end

local function is_delimiter_ch(ch)
    return ch == "'" or ch == " "
end

local function trim_trailing_delimiters(input)
    local s = input
    while s ~= "" and is_delimiter_ch(s:sub(-1)) do
        s = s:sub(1, -2)
    end
    return s
end

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_pinyin" then
        return 2
    end

    if key:release() then
        return 2
    end

    local repr = key:repr()
    if repr ~= "BackSpace" and repr ~= "Delete" then
        return 2
    end

    local context = env.engine.context
    local input = context.input or ""
    if input == "" then
        return 2
    end
    -- 符號清單／擴充／變體：交給對應 processor
    if input:sub(1, 1) == "`" then
        return 2
    end

    local next_input

    if is_delimiter_ch(input:sub(-1)) then
        local without_delim = input:sub(1, -2)
        if without_delim == "" then
            next_input = ""
        else
            next_input = without_delim:sub(1, -2)
            next_input = trim_trailing_delimiters(next_input)
        end
    else
        next_input = input:sub(1, -2)
        next_input = trim_trailing_delimiters(next_input)
    end

    if next_input == "" then
        context:clear()
    else
        context.input = next_input
        refresh(context)
    end
    return 1
end

return processor
