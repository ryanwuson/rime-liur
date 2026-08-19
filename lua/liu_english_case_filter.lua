-- liu_english_case_filter.lua
-- 1. 智慧大小寫轉換 (Apple -> Apple, APPLE -> APPLE, suffix ]/]])
-- 2. 大寫偵測過濾：輸入大寫字母時自動隱藏中文候選字（效能優化版）
-- 此版本已移除「智慧空白」功能，改為手動空格以獲取最大精確度

local common = require("liu_common")

local function init(env)
    -- 現在不再需要 commit_notifier
end

local function capitalize(str)
    if #str == 0 then return str end
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

local function apply_english_case(text, input)
    if not text:match("[a-zA-Z]") then return text end
    if #input == 0 then return text end
    
    local uppers = 0
    local lowers = 0
    for i = 1, #input do
        local b = input:byte(i)
        if b >= 65 and b <= 90 then uppers = uppers + 1
        elseif b >= 97 and b <= 122 then lowers = lowers + 1 end
    end
    
    if uppers == 0 then return text end
    
    local is_all_upper_input = (uppers > 0 and lowers == 0)
    local is_first_upper_input = (input:byte(1) >= 65 and input:byte(1) <= 90 and uppers == 1)
    
    if is_all_upper_input then
        return text:upper()
    elseif is_first_upper_input then
        if text:sub(2):match("%u") then return text end
        return text:sub(1,1):upper() .. text:sub(2):lower()
    else
        return text
    end
end

local function filter(input, env)
    local context = env.engine.context
    local raw_input = context.input
    local caret_pos = context.caret_pos
    
    -- extended_mode (``...) 不做任何過濾，直接放行
    -- 避免大寫偵測邏輯誤殺 ``A 產生的 Unicode 變化形候選（如 Ā Á Ǎ...）
    if raw_input:match("^``") then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    -- 1. 偵測大寫輸入 (用於過濾漢)
    local input_has_upper = raw_input:match("%u")
    
    -- 2. 處理後綴 (], ]])
    local suffix = nil
    local base_input = nil
    if raw_input:sub(-2) == "]]" then
        suffix = "]]"
        base_input = raw_input:sub(1, -3)
    elseif raw_input:sub(-1) == "]" then
        suffix = "]"
        base_input = raw_input:sub(1, -2)
    else
        base_input = raw_input
    end

    -- 平常小寫打碼：無大寫、無 ]／]] → 不掃描候選
    if not input_has_upper and not suffix then
        for cand in input:iter() do yield(cand) end
        return
    end

    local count = 0
    local found_eng = 0

    for cand in input:iter() do
        count = count + 1
        -- [效能優化]：如果是單大寫字母(如 A)且已檢查很多候選，則停止，避免卡頓
        if input_has_upper and #raw_input <= 2 and count > 100 and found_eng > 0 then
            break
        end
        -- 給予大寫模式下的檢索一個熔斷上限
        if input_has_upper and count > 300 then break end

        local text = cand.text
        -- 只要包含英文字母就算英文候選字 (解決候選字消失的問題)
        local is_eng_cand = text:find("[a-zA-Z]") ~= nil
        
        -- [需求1] 大寫偵測：輸入大寫時隱藏非英文
        if input_has_upper and not is_eng_cand then
            goto next_cand
        end
        
        if is_eng_cand then found_eng = found_eng + 1 end
        
        local final_text = text
        local changed = false
        
        -- [需求2] 大小寫轉換
        if is_eng_cand and base_input and base_input:match("^[a-zA-Z]+$") then
            -- 檢查是否為可以變換大小寫字彙格式
            if text:match("^[a-zA-Z%-%.' ]+$") then
                local case_text = apply_english_case(text, base_input)
                if case_text ~= final_text then
                    final_text = case_text
                    changed = true
                end
            end
        end
        
        -- [版本註釋] 已在此處移除智慧空白 (不再 prepend " ")
        
        if changed then
            -- 使用 ShadowCandidate 保留原始候選的所有內部屬性（包括數字選字功能）
            local new_cand = ShadowCandidate(cand, cand.type, final_text, cand.comment)
            yield(new_cand)
        else
            yield(cand)
        end
        
        ::next_cand::
    end

    -- 後綴處理 (獨立生成首字大寫/全大寫候選)
    if suffix and base_input and #base_input > 0 then
        if base_input:match("^[a-zA-Z%-%.]+$") then
            local start = context:get_preedit().sel_start
            local final_suffix_text = (suffix == "]]") and base_input:upper() or capitalize(base_input)
            local comment = (suffix == "]]") and "〔全大寫〕" or "〔首字大寫〕"
            
            yield(Candidate("en_case", start, caret_pos, final_suffix_text, comment))
        end
    end
end

return { init = init, func = filter }
