-- liu_charset_filter.lua
-- 自定義字符集過濾器，將 CJK Compatibility Forms 區塊加入常用字集

local common = require("liu_common")
local is_extended_charset = common.is_extended_charset

local function filter(input, env)
    if env.engine.context:get_option("extended_charset") then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    for cand in input:iter() do
        local accept = true
        for _, code in utf8.codes(cand.text) do
            if is_extended_charset(code) then
                accept = false
                break
            end
        end
        if accept then yield(cand) end
    end
end

return filter
