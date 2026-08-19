-- liu_wildcard_processor.lua
-- 萬用字元開關處理器
-- 預設關閉：? 鍵直接輸出 ? 符號
-- 開啟時：? 作為萬用字元用於查字

local function processor(key, env)
    -- 只處理按下事件，忽略釋放事件
    if key:release() then
        return 2  -- kNoop
    end
    
    local key_repr = key:repr()
    
    -- 只處理 ? 鍵（Shift+/）
    if key_repr ~= "question" and key_repr ~= "Shift+slash" and key.keycode ~= 0x3F then
        return 2  -- kNoop
    end
    
    local context = env.engine.context
    
    -- 萬用字元模式開啟時，讓 speller 處理
    if context:get_option("wildcard_mode") then
        return 2  -- kNoop
    end
    
    -- 萬用字元模式關閉：直接輸出 ? 符號
    -- 如果 preedit 有內容，先上屏目前選中的候選，再輸出 ?
    -- （與 liu_tilde_processor 的 ~ 處理邏輯相同）
    local input = context.input
    if input and #input > 0 then
        if context:has_menu() then
            context:confirm_current_selection()
        end
        context:commit()
    end
    env.engine:commit_text(context:get_option("full_shape") and "？" or "?")
    return 1  -- kAccepted
end

return processor
