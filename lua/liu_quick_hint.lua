-- liu_quick_hint.lua
-- 快打模式：輸入 ≥3 碼時，提示可用的簡碼
-- 支援兩種模式：
-- 1. quick_mode（快打提示）：只提示簡碼
-- 2. force_quick_mode（強制快打）：提示簡碼並阻止非簡碼上屏
-- 優化版：Opencc 實例統一由 liu_data 管理，上屏後自動釋放

local liu_data = require("liu_data")
local last_quick_mode = false
local last_force_quick_mode = false

-- 清除快取（關閉快打模式時）- 現在只需通知 liu_data
local function clear_cache()
    -- Opencc 實例由 liu_data 統一管理，不需要在這裡釋放
    -- liu_gc_processor 的 commit_notifier 會在上屏後統一釋放
end

-- 從 Opencc 返回的編碼字串中找最短的簡碼（可能有多個同長度）
-- 輸入格式："⟨e⟩ ⟨f^v⟩ ⟨abc⟩"
-- 返回：所有最短簡碼組成的字串，或 nil
-- 注意：只考慮「第一候選」的編碼（沒有 ^ 的），不考慮需要選字的編碼
local function find_shortest_codes(codes_str, max_len)
    if not codes_str or codes_str == "" then
        return nil
    end
    
    local all_codes = {}  -- {code, len}
    local min_len = max_len
    
    -- 解析 ⟨code⟩ 格式的編碼
    -- 先處理跳脫的 ⟩
    codes_str = codes_str:gsub("\\⟩", "\x01")
    for code in codes_str:gmatch("⟨([^⟩]+)⟩") do
        code = code:gsub("\x01", "⟩")
        
        -- 只考慮「第一候選」的編碼（沒有 ^ 的）
        -- 有 ^ 的是選字輔碼，不算簡碼
        if code:find("^", 1, true) then
            -- 跳過需要選字的編碼
        else
            local len = #code
            if len < max_len then
                all_codes[#all_codes + 1] = {code = code, len = len}
                if len < min_len then
                    min_len = len
                end
            end
        end
    end
    
    -- 收集所有最短長度的編碼
    local shortest_codes = {}
    for _, item in ipairs(all_codes) do
        if item.len == min_len then
            shortest_codes[#shortest_codes + 1] = item.code
        end
    end
    
    if #shortest_codes == 0 then
        return nil
    end
    
    return table.concat(shortest_codes, "⟩⟨")
end

-- 快打提示 filter
local function filter(input, env)
    local context = env.engine.context
    local quick_mode = context:get_option("quick_mode")
    local force_quick_mode = context:get_option("force_quick_mode")
    
    -- 檢測快打模式是否剛關閉
    if (last_quick_mode and not quick_mode) or (last_force_quick_mode and not force_quick_mode) then
        clear_cache()
    end
    last_quick_mode = quick_mode
    last_force_quick_mode = force_quick_mode
    
    -- 快速路徑：未開啟任何快打模式
    if not quick_mode and not force_quick_mode then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    -- 獲取當前輸入
    local input_text = context.input
    if not input_text then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    local input_length = #input_text
    
    -- 快速路徑：輸入 < 3 碼（2碼簡碼不需要提示）
    if input_length < 3 then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    -- 快速路徑：特殊模式
    local first_char = input_text:sub(1, 1)
    if first_char == ";" or first_char == "`" or first_char == "'" or first_char == "," then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    -- 快速路徑：反查模式
    if context:get_option("liu_w2c") then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    -- 獲取 Opencc（從 liu_data 統一取用）
    local is_simplified = context:get_option("simplification")
    local opencc = liu_data.get_opencc_w2c(is_simplified)
    if not opencc then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    local count = 0
    
    for cand in input:iter() do
        count = count + 1
        
        -- 只處理前 10 個候選
        if count > 10 then
            yield(cand)
        else
            local char = cand.text
            
            -- 只處理單字
            if utf8.len(char) ~= 1 then
                yield(cand)
            else
                -- 直接用 Opencc 查詢編碼（已經根據簡繁模式使用正確的資料文件）
                local codes_str = opencc:convert(char)
                -- 如果返回值和輸入相同，表示沒有找到編碼
                if codes_str == char then
                    codes_str = nil
                end
                local shortest_codes = find_shortest_codes(codes_str, input_length)
                
                if shortest_codes then
                    -- 檢查是否使用了簡碼（用於強制快打模式）
                    local is_using_short_code = false
                    if force_quick_mode then
                        for code in shortest_codes:gmatch("[^⟩⟨]+") do
                            if input_text:upper() == code:upper() then
                                is_using_short_code = true
                                break
                            end
                        end
                    end
                    
                    -- 統一使用「簡碼」提示
                    local hint = "▸簡碼⟨" .. shortest_codes:upper() .. "⟩"
                    
                    local comment = cand.comment or ""
                    
                    -- 簡體模式移除繁體標記
                    if is_simplified and comment:find("〔", 1, true) then
                        comment = comment:gsub("〔.〕", "")
                    end
                    
                    local new_comment = comment == "" and hint or (comment .. " " .. hint)
                    yield(cand:to_shadow_candidate(cand.type, char, new_comment))
                else
                    yield(cand)
                end
            end
        end
    end
end

return filter
