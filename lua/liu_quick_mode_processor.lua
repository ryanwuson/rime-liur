-- liu_quick_mode_processor.lua
-- 處理快捷鍵切換模式及強制快打邏輯
-- ,,sp = 快打提示模式
-- ,,sf = 強制快打模式
-- ,,wc = 萬用查字模式 (wildcard)

-- Opencc 實例統一由 liu_data 管理
local liu_data = require("liu_data")

-- ============ 強制快打學習流程狀態 ============
--
-- 流程：打全碼（如 ttmb）→ space 被阻止，顯示簡碼提示（如 tta）
--       → 使用者可以：
--         A. 接著打簡碼（tta）+ space → 上屏「頂」（學習路徑）
--         B. 再按一次 space → 清空編碼（放棄路徑）
--         C. 打不匹配的字元 → 清除 pending，把已打的字元推回 RIME 正常處理
--
-- pending_shortcodes: 所有最短簡碼的列表（如 {"lmv", "lnm"}）
-- pending_active_paths: 目前仍在匹配中的簡碼列表（逐字過濾後剩下的）
-- pending_typed_buffer: 使用者在 pending 狀態下已打的字元（被攔截的）

local pending_shortcodes = nil    -- 所有最短簡碼列表
local pending_active_paths = nil  -- 目前仍活著的匹配路徑
local pending_typed_buffer = nil  -- 已攔截的字元 buffer

-- 清除所有 pending 狀態
local function clear_pending()
    pending_shortcodes = nil
    pending_active_paths = nil
    pending_typed_buffer = nil
end

-- 獲取 Opencc 實例（從 liu_data 統一取用）
local function get_opencc(is_simplified)
    return liu_data.get_opencc_w2c(is_simplified)
end

-- 從 Opencc 返回的編碼字串中找所有最短簡碼（列表形式）
-- 輸入格式："⟨e⟩ ⟨f^v⟩ ⟨abc⟩"
-- 返回：最短簡碼的字串列表，或 nil
local function find_shortest_codes_list(codes_str, max_len)
    if not codes_str or codes_str == "" then
        return nil
    end
    
    local all_codes = {}
    local min_len = max_len
    
    -- 解析 ⟨code⟩ 格式的編碼
    codes_str = codes_str:gsub("\\⟩", "\x01")
    for code in codes_str:gmatch("⟨([^⟩]+)⟩") do
        code = code:gsub("\x01", "⟩")
        
        -- 只考慮「第一候選」的編碼（沒有 ^ 的）
        if not code:find("^", 1, true) then
            local len = #code
            if len < max_len then
                all_codes[#all_codes + 1] = {code = code:lower(), len = len}
                if len < min_len then
                    min_len = len
                end
            end
        end
    end
    
    -- 收集所有最短長度的編碼
    local shortest = {}
    for _, item in ipairs(all_codes) do
        if item.len == min_len then
            shortest[#shortest + 1] = item.code
        end
    end
    
    return #shortest > 0 and shortest or nil
end

-- 檢查是否應該阻止上屏
-- 返回值：blocked (boolean), shortcodes (list or nil)
local function should_block_commit(context)
    local input_text = context.input
    local input_length = #input_text
    
    -- 輸入 < 3 碼，允許上屏（2碼簡碼不需要檢查）
    if input_length < 3 then
        return false, nil
    end
    
    -- 特殊模式，允許上屏
    local first_char = input_text:sub(1, 1)
    if first_char == ";" or first_char == "`" or first_char == "'" or first_char == "," then
        return false, nil
    end
    
    -- 檢查第一個候選是否為單字且有簡碼
    local composition = context.composition
    if composition and not composition:empty() then
        local seg = composition:back()
        if seg and seg.menu and seg.menu:candidate_count() > 0 then
            local cand = seg:get_selected_candidate()
            if cand and utf8.len(cand.text) == 1 then
                local char = cand.text
                local is_simplified = context:get_option("simplification")
                
                local opencc = get_opencc(is_simplified)
                if not opencc then
                    return false, nil
                end
                
                local codes_str = opencc:convert(char)
                if codes_str == char then
                    codes_str = nil
                end
                
                local shortcodes = find_shortest_codes_list(codes_str, input_length)
                if shortcodes then
                    -- 檢查當前輸入是否已是某個簡碼
                    for _, code in ipairs(shortcodes) do
                        if input_text:lower() == code then
                            return false, nil  -- 已使用簡碼，允許上屏
                        end
                    end
                    return true, shortcodes  -- 有簡碼但沒使用，阻止上屏
                end
            end
        end
    end
    
    return false, nil
end

local function processor(key, env)
    -- 忽略按鍵釋放 (KeyUp) 事件，避免破壞狀態機（特別是在 Windows 小狼毫中）
    if key:release() then
        return 2
    end

    local context = env.engine.context
    local input = context.input
    local key_repr = key:repr()
    
    -- ,,sp + 空格 = 切換快打提示模式
    if input == ",,sp" and key_repr == "space" then
        local current_quick = context:get_option("quick_mode")
        local current_force = context:get_option("force_quick_mode")
        
        if current_quick then
            context:set_option("quick_mode", false)
        else
            if current_force then
                context:set_option("force_quick_mode", false)
            end
            context:set_option("quick_mode", true)
        end
        context:clear()
        return 1
    end
    
    -- ,,sf + 空格 = 切換強制快打模式
    if input == ",,sf" and key_repr == "space" then
        local current_quick = context:get_option("quick_mode")
        local current_force = context:get_option("force_quick_mode")
        
        if current_force then
            context:set_option("force_quick_mode", false)
        else
            if current_quick then
                context:set_option("quick_mode", false)
            end
            context:set_option("force_quick_mode", true)
        end
        context:clear()
        return 1
    end
    
    -- ,,wc + 空格 = 切換萬用查字模式 (wildcard)
    if input == ",,wc" and key_repr == "space" then
        context:set_option("wildcard_mode", not context:get_option("wildcard_mode"))
        context:clear()
        return 1
    end

    -- 桌面不需要：聯想預設關閉，不提供 ,,clean
    -- -- ,,clean + 空格 = 清除聯想學習
    -- if input == ",,clean" and key_repr == "space" then
    --     local ok, mod = pcall(require, "liu_user_predict")
    --     if ok and mod and mod.clear then
    --         mod.clear()
    --     end
    --     context:set_option("user_predict_cleared", not context:get_option("user_predict_cleared"))
    --     context:clear()
    --     return 1
    -- end
    
    -- ============ 強制快打模式邏輯 ============
    if not context:get_option("force_quick_mode") then
        return 2
    end
    
    -- committing 狀態：我們自己觸發的 space，直接放行
    -- （已移除，不再需要自動上屏）

    -- ---- pending 狀態下的按鍵處理 ----
    if pending_shortcodes then
        
        -- 情形 B：再按 space → 繼續攔截，ttmb 保留，提示繼續在
        if key_repr == "space" then
            return 1  -- 攔截，不清屏，不做任何事
        end
        
        -- 只處理單個小寫字母（a-z）
        local ch = key_repr:match("^([a-z])$")
        if not ch then
            -- 非字母鍵（如 backspace、enter 等）→ 清除 pending，把 buffer 推回，放行此鍵
            local buf = pending_typed_buffer or ""
            clear_pending()
            -- 把已攔截的字元推回 RIME
            for i = 1, #buf do
                env.engine:process_key(KeyEvent(buf:sub(i, i)))
            end
            -- 放行當前按鍵
            return 2
        end
        
        -- 任何字母鍵 → 清屏，全新開始（不追蹤前綴）
        clear_pending()
        context:clear()
        env.engine:process_key(KeyEvent(ch))
        return 1
    end
    
    -- ---- 非 pending 狀態下的 space 攔截 ----
    if key_repr == "space" then
        local blocked, shortcodes = should_block_commit(context)
        if blocked then
            -- 進入 pending 狀態，等待使用者打簡碼
            pending_shortcodes = shortcodes
            pending_active_paths = {}
            for _, c in ipairs(shortcodes) do
                pending_active_paths[#pending_active_paths + 1] = c
            end
            pending_typed_buffer = ""
            return 1  -- 攔截 space，候選框保持顯示
        end
    end
    
    return 2
end

return processor
