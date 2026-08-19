-- liu_bpmf_refresh_processor.lua
-- 每次按鍵後刷新組字，讓預輸入區跟上完整字串

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_bpmf" then
        return 2
    end

    if key:release() then
        return 2
    end

    local repr = key:repr()
    if repr == "space" or repr == "Space" then
        return 2
    end

    local context = env.engine.context
    if context:is_composing() and context.refresh_non_confirmed_composition then
        context:refresh_non_confirmed_composition()
    end

    return 2
end

return processor
