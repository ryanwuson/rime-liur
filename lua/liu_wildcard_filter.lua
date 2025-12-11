-- liu_wildcard_filter.lua
-- 萬用字元模式下屏蔽反查功能

local function liu_wildcard_filter(input, env)
    local context = env.engine.context
    local input_code = context.input
    
    -- 如果輸入包含萬用字元，強制關閉反查模式
    if input_code and input_code:find("?", 1, true) and context:get_option("liu_w2c") then
        context:set_option("liu_w2c", false)
    end
    
    for cand in input:iter() do
        yield(cand)
    end
end

return liu_wildcard_filter
