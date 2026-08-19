-- liu_pinyin_delimiter_processor.lua
-- 手動分節符 ' 由 Lua 插入，預輸入顯示 U+2009+⁞+U+2009

local function refresh(context)
    if context.refresh_non_confirmed_composition then
        context:refresh_non_confirmed_composition()
    end
end

local function is_apostrophe_key(repr)
    return repr == "'" or repr == "apostrophe"
end

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_pinyin" then
        return 2
    end
    if key:release() then
        return 2
    end
    if not is_apostrophe_key(key:repr()) then
        return 2
    end

    local context = env.engine.context
    local input = context.input or ""
    -- 擴充模式 ``：不要把 ' 當拼音分節（`' 數字變體仍由本 processor 推進）
    if input:sub(1, 2) == "``" then
        return 2
    end
    context:push_input("'")
    refresh(context)
    return 1
end

return processor
