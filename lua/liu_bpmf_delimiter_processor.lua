-- liu_bpmf_delimiter_processor.lua
-- 分節符 ' 由 Lua 插入，不經 speller（避免分節時誤上屏前段字）

local function refresh(context)
    if context.refresh_non_confirmed_composition then
        context:refresh_non_confirmed_composition()
    end
end

local function is_apostrophe_key(repr)
    return repr == "'" or repr == "apostrophe"
end

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_bpmf" then
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
    -- 符號清單／擴充模式：不要把 ' 當注音分節
    if input:sub(1, 1) == "`" then
        return 2
    end
    context:push_input("'")
    refresh(context)
    return 1
end

return processor
