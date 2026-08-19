-- liu_vrsf_hint.lua
-- VRSF 選字提示：當候選字有 ^V/^R/^S/^F 輔碼且與當前輸入匹配時，顯示提示
-- 例如：輸入 aaa，龘 的編碼是 AAA^V，則顯示 ▸ ⟨v⟩
-- 只在正常模式下顯示，反查模式不處理
-- 注意：w2c 中的 VRSF 編碼已經過濾，只包含「真正能用的」

-- 全局緩存
-- 全局緩存
local liu_data = require("liu_data")

-- 載入編碼字典（從共用資料中心獲取）
local function load_code_dict(is_simplified)
    return liu_data.get_w2c_data(is_simplified)
end

-- VRSF 對應表
local vrsf_map = {V = "v", R = "r", S = "s", F = "f"}

local function filter(input, env)
    local context = env.engine.context
    local input_text = context.input
    
    -- 跳過空輸入
    if not input_text or input_text == "" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    -- 反查模式：不處理（讓反查模式顯示完整編碼）
    if context:get_option("liu_w2c") then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    local first_char = input_text:sub(1, 1)
    local first_two = input_text:sub(1, 2)
    
    -- 跳過特殊模式：符號清單、讀音查詢、造詞、擴充模式等
    if first_char == "`" or 
       first_char == ";" or 
       first_two == "';" or
       first_two == ",," then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    -- 當前輸入轉大寫（用於匹配編碼）
    local input_upper = input_text:upper()
    
    -- 載入編碼字典
    local is_simplified = context:get_option("simplification")
    local code_dict = load_code_dict(is_simplified)
    if not code_dict then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    for cand in input:iter() do
        local char = cand.text
        local comment = cand.comment or ""
        
        -- 詞（多碼位，UTF-8 通常 ≥6 bytes）不看 VRSF；單個 CJK 3～4 bytes
        if char and #char > 4 then
            yield(cand)
        elseif utf8.len(char) == 1 then
            local codes = code_dict[char]
            
            if codes then
                -- 檢查是否有與當前輸入匹配的 VRSF 輔碼
                local hint_suffix = nil
                
                -- 解析原始編碼字串 "⟨AAA^V⟩⟨BBB^R⟩"
                local temp_str = codes:gsub("\\⟩", "\x01")
                for raw_code in temp_str:gmatch("⟨([^⟩]+)⟩") do
                    local code = raw_code:gsub("\x01", "⟩")
                    -- 解析編碼和輔碼，如 "AAA^V" → base="AAA", suffix="V"
                    local base, suffix = code:match("^(.+)%^([VRSF])$")
                    if base and suffix and base == input_upper then
                        hint_suffix = vrsf_map[suffix]
                        break
                    end
                end
                
                if hint_suffix then
                    -- 添加 VRSF 提示
                    local new_comment
                    if comment ~= "" then
                        new_comment = comment .. " ▸⟨" .. hint_suffix .. "⟩"
                    else
                        new_comment = "▸⟨" .. hint_suffix .. "⟩"
                    end
                    yield(cand:to_shadow_candidate(cand.type, cand.text, new_comment))
                else
                    yield(cand)
                end
            else
                yield(cand)
            end
        else
            yield(cand)
        end
    end
end

return filter
