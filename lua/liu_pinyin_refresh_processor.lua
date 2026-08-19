-- liu_pinyin_refresh_processor.lua

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_pinyin" then
        return 2
    end

    if key:release() then
        return 2
    end

    local context = env.engine.context
    if context:is_composing() and context.refresh_non_confirmed_composition then
        context:refresh_non_confirmed_composition()
    end

    return 2
end

return processor
