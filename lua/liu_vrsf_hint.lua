-- liu_vrsf_hint.lua
-- VRSF 選字提示：當候選字有 ^V/^R/^S/^F 輔碼且與當前輸入匹配時，顯示提示
-- 例如：輸入 aaa，龘 的編碼是 AAA^V，則顯示 ▸ ⟨v⟩
-- 只在正常模式下顯示，反查模式不處理

-- 全局緩存
local code_dict_cache = nil

-- 載入編碼字典
local function load_code_dict()
    if code_dict_cache then
        return code_dict_cache
    end
    
    local dict = {}
    local dict_file = io.open(rime_api.get_user_data_dir() .. "/opencc/liu_w2c.txt", "r")
    if not dict_file then
        dict_file = io.open(rime_api.get_shared_data_dir() .. "/opencc/liu_w2c.txt", "r")
    end
    
    if dict_file then
        local content = dict_file:read("*all")
        dict_file:close()
        
        for line in content:gmatch("[^\r\n]+") do
            local char, code_str = line:match("^([^\t]+)\t~(.+)$")
            if char and code_str then
                local codes = {}
                local temp_str = code_str:gsub("\\⟩", "\x01")
                for code in temp_str:gmatch("⟨([^⟩]+)⟩") do
                    code = code:gsub("\x01", "⟩")
                    codes[#codes + 1] = code
                end
                dict[char] = codes
            end
        end
    end
    
    code_dict_cache = dict
    return dict
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
    local code_dict = load_code_dict()
    if not code_dict then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    for cand in input:iter() do
        local char = cand.text
        local comment = cand.comment or ""
        
        -- 只處理單字
        if utf8.len(char) == 1 then
            local codes = code_dict[char]
            
            if codes then
                -- 檢查是否有與當前輸入匹配的 VRSF 輔碼
                local hint_suffix = nil
                
                for _, code in ipairs(codes) do
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
