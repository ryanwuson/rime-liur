-- liu_tilde_processor.lua
-- 處理單獨輸入 ~ 時直接輸出，不進入候選框
-- 但在造詞模式（; 開頭）中允許 ~ 作為分隔符

local function processor(key, env)
    local engine = env.engine
    local context = engine.context
    local input = context.input
    
    -- 只處理按下事件，不處理釋放事件
    if key:release() then
        return 2  -- kNoop
    end
    
    -- 使用 key.keycode 檢查是否為 ~ (ASCII 126 = 0x7E)
    local keycode = key.keycode
    if keycode ~= 0x7E and keycode ~= 126 then
        return 2  -- kNoop
    end
    
    -- 如果在造詞模式（; 開頭），讓 Rime 處理
    if input:match("^;") then
        return 2  -- kNoop
    end
    
    -- 如果輸入為空，直接輸出 ~
    if input == "" then
        engine:commit_text("~")
        return 1  -- kAccepted
    end
    
    -- 如果有候選字，先確認當前選擇
    if context:has_menu() then
        context:confirm_current_selection()
    end
    
    -- 上屏當前內容
    context:commit()
    
    -- 輸出 ~
    engine:commit_text("~")
    return 1  -- kAccepted
end

return processor
