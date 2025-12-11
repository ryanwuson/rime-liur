-- liu_remove_trad_in_w2c.lua
-- 簡體模式下移除繁體標記〔xxx〕
-- 適用場景：反查模式（Ctrl+'）、萬用字元查詢
-- 注：讀音查詢模式（;;）由 liu_phonetic_override 單獨處理

-- 全局緩存
local opencc_liu_w2c = nil

local function get_opencc_liu_w2c()
    if not opencc_liu_w2c then
        opencc_liu_w2c = Opencc("liu_w2c.json")
    end
    return opencc_liu_w2c
end

local function liu_remove_trad_in_w2c(input, env)
    local context = env.engine.context
    local is_simplified = context:get_option("simplification")
    local is_w2c = context:get_option("liu_w2c")
    local input_text = context.input
    
    -- 檢查是否使用萬用字元（使用 find 比 match 更快）
    local has_wildcard = input_text and input_text:find("?", 1, true)
    
    -- 排除讀音查詢模式（使用 sub 比 match 更快）
    if input_text and input_text:sub(1, 2) == ";;" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    -- 萬用字元查詢：移除 ~ 符號（無論簡繁），並為沒有編碼的字查找編碼和排序
    if has_wildcard then
        local opencc = get_opencc_liu_w2c()
        
        for cand in input:iter() do
            local comment = cand.comment or ""
            
            -- 移除繁體標記（簡體模式）
            if is_simplified then
                comment = comment:gsub("〔[^〕]+〕", "")
            end
            
            -- 如果沒有編碼（只有 ~ 或空白），查找編碼
            local has_codes = comment:match("⟨")
            if not has_codes and opencc then
                local codes_str = opencc:convert(cand.text)
                if codes_str and codes_str ~= cand.text then
                    -- 解析編碼（保留 ⟨⟩ 格式）
                    local codes = {}
                    -- 先將 \⟩ 替換為臨時標記
                    codes_str = codes_str:gsub("\\⟩", "\x01")
                    for code in codes_str:gmatch("⟨([^⟩]+)⟩") do
                        -- 將臨時標記還原為 ⟩
                        code = code:gsub("\x01", "⟩")
                        table.insert(codes, "⟨" .. code .. "⟩")
                    end
                    if #codes > 0 then
                        comment = table.concat(codes, " ")
                    end
                end
            end
            
            -- 移除 ~ 符號
            comment = comment:gsub("~", ""):gsub("^%s+", ""):gsub("%s+", " ")
            
            -- 重新檢查是否有編碼
            has_codes = comment:match("⟨")
            
            -- 如果有編碼，進行排序
            if has_codes then
                local codes = {}
                -- 先將 \⟩ 替換為臨時標記
                local temp_comment = comment:gsub("\\⟩", "\x01")
                for code in temp_comment:gmatch("⟨([^⟩]+)⟩") do
                    -- 將臨時標記還原為 ⟩
                    code = code:gsub("\x01", "⟩")
                    table.insert(codes, code)
                end
                
                -- 分類：主要編碼和次要編碼（^V ^R ^S ^F）
                local primary = {}
                local secondary = {}
                
                for _, code in ipairs(codes) do
                    if code:match("%^[VRSF]") then
                        table.insert(secondary, code)
                    else
                        table.insert(primary, code)
                    end
                end
                
                -- 排序：按碼長優先，相同碼長按字母排序
                local sort_func = function(a, b)
                    if #a == #b then
                        return a < b
                    else
                        return #a < #b
                    end
                end
                
                table.sort(primary, sort_func)
                table.sort(secondary, sort_func)
                
                -- 重新組合編碼
                local sorted_codes = {}
                for _, code in ipairs(primary) do
                    table.insert(sorted_codes, "⟨" .. code .. "⟩")
                end
                for _, code in ipairs(secondary) do
                    table.insert(sorted_codes, "⟨" .. code .. "⟩")
                end
                
                comment = table.concat(sorted_codes, " ")
            end
            
            yield(cand:to_shadow_candidate(cand.type, cand.text, comment))
        end
        return
    end
    
    -- 簡體 + 反查模式：移除繁體標記
    if is_simplified and is_w2c then
        for cand in input:iter() do
            local comment = cand.comment or ""
            local new_comment = comment:gsub("〔[^〕]+〕", ""):gsub("^%s+", ""):gsub("%s+", " ")
            yield(cand:to_shadow_candidate(cand.type, cand.text, new_comment))
        end
        return
    end
    
    -- 其他情況：直接通過
    for cand in input:iter() do
        yield(cand)
    end
end

return liu_remove_trad_in_w2c
