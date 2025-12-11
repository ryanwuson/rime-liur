-- liu_quick_hint.lua
-- 快打模式：輸入 ≥4 碼時，提示可用的簡碼
-- 優化版：使用 Opencc 查詢 liu_w2c.json，關閉時釋放資源

-- Opencc 實例（延遲載入，關閉時釋放）
local opencc_liu_w2c = nil
local last_quick_mode = false

-- 獲取 Opencc 實例
local function get_opencc()
    if not opencc_liu_w2c then
        opencc_liu_w2c = Opencc("liu_w2c.json")
    end
    return opencc_liu_w2c
end

-- 清除快取（關閉快打模式時）
local function clear_cache()
    opencc_liu_w2c = nil
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
    
    -- 檢測快打模式是否剛關閉
    if last_quick_mode and not quick_mode then
        clear_cache()
    end
    last_quick_mode = quick_mode
    
    -- 快速路徑：未開啟快打模式
    if not quick_mode then
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
    
    -- 快速路徑：輸入 < 4 碼
    if input_length < 4 then
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
    
    -- 獲取 Opencc
    local opencc = get_opencc()
    if not opencc then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    local is_simplified = context:get_option("simplification")
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
                -- 用 Opencc 查詢編碼
                local lookup_char = char
                
                -- 簡體模式：從 comment 提取繁體字
                if is_simplified then
                    local comment = cand.comment
                    if comment then
                        local trad = comment:match("〔(.)〕")
                        if trad then
                            lookup_char = trad
                        end
                    end
                end
                
                local codes_str = opencc:convert(lookup_char)
                -- 如果返回值和輸入相同，表示沒有找到編碼
                if codes_str == lookup_char then
                    codes_str = nil
                end
                local shortest_codes = find_shortest_codes(codes_str, input_length)
                
                if shortest_codes then
                    -- 構建提示
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
