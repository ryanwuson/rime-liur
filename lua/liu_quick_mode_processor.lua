-- liu_quick_mode_processor.lua
-- 處理快捷鍵切換模式
-- ,,sp = 快打模式
-- ,,wc = 萬用查字模式 (wildcard)

local function processor(key, env)
    local context = env.engine.context
    local input = context.input
    
    -- ,,sp + 空格 = 切換快打模式
    if input == ",,sp" and key:repr() == "space" then
        context:set_option("quick_mode", not context:get_option("quick_mode"))
        context:clear()
        return 1
    end
    
    -- ,,wc + 空格 = 切換萬用查字模式 (wildcard)
    if input == ",,wc" and key:repr() == "space" then
        context:set_option("wildcard_mode", not context:get_option("wildcard_mode"))
        context:clear()
        return 1
    end
    
    return 2
end

return processor
