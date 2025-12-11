-- liu_phonetic_hint_processor.lua
-- 在讀音查詢模式下屏蔽 ctrl+' 切換反查功能

local function liu_phonetic_hint_processor(key, env)
    local input_text = env.engine.context.input
    -- 讀音查詢模式（;;）下屏蔽 Ctrl+'
    if input_text and input_text:sub(1, 2) == ";;" and key:repr() == "Control+apostrophe" then
        return 1
    end
    return 2
end

return liu_phonetic_hint_processor
