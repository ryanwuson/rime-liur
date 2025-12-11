-- liu_w2c_sorter.lua
-- 反查模式下的編碼排序和優化
-- 1. 將帶 ^V ^R ^S ^F 的編碼排到後面
-- 2. 簡體模式下不顯示繁體標記，但顯示編碼
-- 3. 按碼長和字母排序編碼
-- 4. 支援詞組的編碼查詢（簡體模式下自動轉繁體查詢）
-- 5. 日期時間候選項（datetime）直接輸出，不做反查

-- 全局緩存
local code_dict_cache = nil
local opencc_s2t_cache = nil

-- 載入編碼字典（只載入一次）- 優化版
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
        -- 一次性讀取整個文件（比逐行讀取更快）
        local content = dict_file:read("*all")
        dict_file:close()
        
        for line in content:gmatch("[^\r\n]+") do
            local char, code_str = line:match("^([^\t]+)\t~(.+)$")
            if char and code_str then
                local codes = {}
                -- 先將 \⟩ 替換為臨時標記
                local temp_str = code_str:gsub("\\⟩", "\x01")
                for code in temp_str:gmatch("⟨([^⟩]+)⟩") do
                    -- 將臨時標記還原為 ⟩
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

-- 獲取 OpenCC 實例（緩存）
local function get_opencc_s2t()
    if not opencc_s2t_cache then
        opencc_s2t_cache = Opencc("s2t.json")
    end
    return opencc_s2t_cache
end

local function liu_w2c_sorter(input, env)
    local context = env.engine.context
    local is_simplified = context:get_option("simplification")
    local liu_w2c_enabled = context:get_option("liu_w2c")
    local input_text = context.input
    
    -- 快速檢查萬用字元（使用 find 比 match 更快）
    local has_wildcard = input_text and input_text:find("?", 1, true)
    
    -- 正常模式 + 繁體模式：不處理
    if not is_simplified and not liu_w2c_enabled then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    local count = 0
    local max_count = 50  -- 降低處理數量以提升效能
    
    for cand in input:iter() do
        -- 同音字候選項直接輸出，不修改
        if cand.type == "phonetic" then
            yield(cand)
        -- 日期時間、擴充模式選單候選項直接輸出（由 liu_extended_filter 處理）
        elseif cand.type == "datetime" or cand.type == "datetime_menu" or cand.type == "extended_menu" or cand.type == "letter_variant" then
            yield(cand)
        elseif count >= max_count then
            yield(cand)
        else
            count = count + 1
            local comment = cand.comment
            
            if comment and comment ~= "" then
                -- 正常模式 + 簡體模式：只保留繁體字標記（但萬用字元查詢時不保留）
                if is_simplified and not liu_w2c_enabled and not has_wildcard then
                    local trad_mark = comment:match("〔[^〕]+〕")
                    local new_cand = cand:to_shadow_candidate(
                        cand.type,
                        cand.text,
                        trad_mark or ""
                    )
                    yield(new_cand)
                    goto continue
                end
                
                -- 反查模式：處理編碼
                -- 萬用字元查詢：不處理（已由 liu_wildcard_code_hint 和 liu_remove_trad_in_w2c 處理）
                if has_wildcard then
                    yield(cand)
                    goto continue
                end
                
                -- 檢查是否需要重新查詢編碼
                local has_codes = comment:match("⟨")
                local has_tilde = comment:match("~")
                local need_requery = liu_w2c_enabled and (is_simplified or (has_codes and not has_tilde) or not has_codes)
                
                if need_requery then
                    local code_dict = load_code_dict()
                    local text_len = utf8.len(cand.text)
                    local opencc = is_simplified and get_opencc_s2t() or nil
                    
                    -- 處理詞組：為每個字查找編碼
                    if text_len and text_len > 1 then
                        local char_codes = {}
                        local has_all_codes = true
                        
                        for pos, code_point in utf8.codes(cand.text) do
                            local char = utf8.char(code_point)
                            local codes = code_dict[char]
                            
                            -- 簡體模式：如果找不到編碼，嘗試查找繁體字編碼
                            if opencc and (not codes or #codes == 0) then
                                local trad_char = opencc:convert(char)
                                if trad_char ~= char then
                                    codes = code_dict[trad_char]
                                end
                            end
                            
                            if codes and #codes > 0 then
                                table.insert(char_codes, codes)
                            else
                                has_all_codes = false
                                break
                            end
                        end
                        
                        if has_all_codes and #char_codes > 0 then
                            -- 構建詞組的編碼註釋
                            local code_parts = {}
                            for _, codes in ipairs(char_codes) do
                                local code_str = ""
                                for i, code in ipairs(codes) do
                                    if i > 1 then
                                        code_str = code_str .. " "
                                    end
                                    code_str = code_str .. "⟨" .. code .. "⟩"
                                end
                                table.insert(code_parts, code_str)
                            end
                            
                            local new_comment = "~" .. table.concat(code_parts, "．")
                            yield(cand:to_shadow_candidate(cand.type, cand.text, new_comment))
                            goto continue
                        end
                    end
                    
                    -- 處理單字
                    local codes = code_dict[cand.text]
                    
                    -- 簡體模式：如果找不到編碼，嘗試查找繁體字編碼
                    if opencc and (not codes or #codes == 0) then
                        local trad_text = opencc:convert(cand.text)
                        if trad_text ~= cand.text then
                            codes = code_dict[trad_text]
                        end
                    end
                    
                    if codes and #codes > 0 then
                        -- 直接使用 liu_w2c.txt 中的順序（已排序）
                        local new_comment = "~"
                        for i, code in ipairs(codes) do
                            if i > 1 then
                                new_comment = new_comment .. " "
                            end
                            new_comment = new_comment .. "⟨" .. code .. "⟩"
                        end
                        
                        yield(cand:to_shadow_candidate(cand.type, cand.text, new_comment))
                        goto continue
                    end
                end
                
                -- 有編碼：處理排序
                -- 提取繁體字標記（如果有）
                local trad_mark = comment:match("〔[^〕]+〕")
                
                -- 檢查是否有 ~ 符號
                local has_tilde = comment:match("~")
                
                -- 設置 prefix
                local prefix = ""
                if is_simplified then
                    -- 反查模式 + 簡體模式：不顯示繁體字標記
                    if not has_tilde then
                        prefix = "~"
                    else
                        -- 移除繁體標記
                        comment = comment:gsub("〔[^〕]+〕", "")
                        prefix = comment:match("^([^⟨]+)") or ""
                    end
                elseif not is_simplified then
                    -- 反查模式 + 繁體模式：移除繁體字標記
                    comment = comment:gsub("〔[^〕]+〕", "")
                    local original_prefix = comment:match("^([^⟨]+)") or ""
                    -- 如果沒有 ~，添加它
                    if not has_tilde then
                        prefix = "~"
                    else
                        prefix = original_prefix
                    end
                end
                
                -- 檢查是否是多字詞（包含多個 ~ 前綴）
                local tilde_count = 0
                for _ in comment:gmatch("~") do
                    tilde_count = tilde_count + 1
                end
                
                if tilde_count > 1 then
                    -- 多字詞：按 ~ 分組處理
                    local groups = {}
                    local remaining = comment
                    
                    -- 提取第一個 ~ 之前的前綴
                    local first_prefix = remaining:match("^([^~]*)")
                    remaining = remaining:sub(#first_prefix + 1)
                    
                    -- 按 ~ 分割
                    for group_str in remaining:gmatch("~([^~]*)") do
                        local codes = {}
                        -- 先將 \⟩ 替換為臨時標記
                        local temp_group = group_str:gsub("\\⟩", "\x01")
                        for code in temp_group:gmatch("⟨([^⟩]+)⟩") do
                            -- 將臨時標記還原為 ⟩
                            code = code:gsub("\x01", "⟩")
                            table.insert(codes, code)
                        end
                        
                        -- 直接使用順序（已排序）
                        local group_comment = ""
                        for i, code in ipairs(codes) do
                            if i > 1 then
                                group_comment = group_comment .. " "
                            end
                            group_comment = group_comment .. "⟨" .. code .. "⟩"
                        end
                        
                        table.insert(groups, group_comment)
                    end
                    
                    -- 用 ． 連接各組，確保前面有 ~
                    local new_comment = (first_prefix ~= "" and first_prefix or "~") .. table.concat(groups, "．")
                    
                    local new_cand = cand:to_shadow_candidate(
                        cand.type,
                        cand.text,
                        new_comment
                    )
                    yield(new_cand)
                else
                    -- 單字：直接使用順序（已排序）
                    local codes = {}
                    -- 先將 \⟩ 替換為臨時標記
                    local temp_comment = comment:gsub("\\⟩", "\x01")
                    for code in temp_comment:gmatch("⟨([^⟩]+)⟩") do
                        -- 將臨時標記還原為 ⟩
                        code = code:gsub("\x01", "⟩")
                        table.insert(codes, code)
                    end
                    
                    local new_comment = prefix
                    for i, code in ipairs(codes) do
                        if i > 1 then
                            new_comment = new_comment .. " "
                        end
                        new_comment = new_comment .. "⟨" .. code .. "⟩"
                    end
                    
                    local new_cand = cand:to_shadow_candidate(
                        cand.type,
                        cand.text,
                        new_comment
                    )
                    yield(new_cand)
                end
            else
                yield(cand)
            end
            
            ::continue::
        end
    end
end

return liu_w2c_sorter
