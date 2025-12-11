-- liu_phonetic_suffix.lua
-- 選中候選字後按 ' 展開同音字
-- 
-- 優化版本 v4：用完即釋放
-- 同音字模式結束後清除大型資料，避免持續佔用記憶體

-- ============ 全局快取 ============
-- 注意：這些資料在同音字模式結束後會被清除
local groups_trad = nil      -- 繁體群組列表（字串陣列）
local groups_simp = nil      -- 簡體群組列表
local char_to_gids_trad = nil -- 繁體：字 → "gid:pos,gid:pos,..."
local char_to_gids_simp = nil -- 簡體
local code_data = nil
local opencc_s2t = nil

-- ============ 數據載入函數 ============

-- 載入群組格式的同音字資料（優化版）
local function load_phonetic_groups(is_simplified)
    local groups = {}        -- 群組列表，每個元素是原始字串
    local char_to_gids = {}  -- 字 → "gid:pos,gid:pos,..."
    
    local filename = is_simplified and "liu_phonetic_simp.txt" or "liu_phonetic.txt"
    local file = io.open(rime_api.get_user_data_dir() .. "/opencc/" .. filename, "r")
    if not file then
        file = io.open(rime_api.get_shared_data_dir() .. "/opencc/" .. filename, "r")
    end
    
    if file then
        local gid = 0
        for line in file:lines() do
            local first_char, rest = line:match("^([^\t]+)\t(.+)$")
            if first_char and rest then
                gid = gid + 1
                -- 存儲完整的群組字串（第一個字 + 空格 + 其他字）
                groups[gid] = first_char .. " " .. rest
                
                -- 記錄每個字屬於哪些群組
                local pos = 1
                for char in (first_char .. " " .. rest):gmatch("[^ ]+") do
                    local entry = gid .. ":" .. pos
                    if char_to_gids[char] then
                        char_to_gids[char] = char_to_gids[char] .. "," .. entry
                    else
                        char_to_gids[char] = entry
                    end
                    pos = pos + 1
                end
            end
        end
        file:close()
    end
    
    return groups, char_to_gids
end

-- 解析 gid:pos 字串
local function parse_gid_entries(str)
    local entries = {}
    for entry in str:gmatch("[^,]+") do
        local gid, pos = entry:match("(%d+):(%d+)")
        if gid and pos then
            entries[#entries + 1] = {gid = tonumber(gid), pos = tonumber(pos)}
        end
    end
    return entries
end

-- 即時查詢同音字
local function get_phonetics_for_char(char, is_simplified)
    local groups, char_to_gids
    
    if is_simplified then
        if not groups_simp then
            groups_simp, char_to_gids_simp = load_phonetic_groups(true)
        end
        groups = groups_simp
        char_to_gids = char_to_gids_simp
    else
        if not groups_trad then
            groups_trad, char_to_gids_trad = load_phonetic_groups(false)
        end
        groups = groups_trad
        char_to_gids = char_to_gids_trad
    end
    
    local gid_str = char_to_gids[char]
    if not gid_str then
        return nil
    end
    
    -- 解析並排序
    local entries = parse_gid_entries(gid_str)
    table.sort(entries, function(a, b) return a.pos < b.pos end)
    
    -- 收集同音字
    local result = {}
    local seen = {[char] = true}
    
    for _, entry in ipairs(entries) do
        local group_str = groups[entry.gid]
        if group_str then
            for w in group_str:gmatch("[^ ]+") do
                if not seen[w] then
                    seen[w] = true
                    result[#result + 1] = w
                end
            end
        end
    end
    
    return #result > 0 and result or nil
end

-- 載入編碼資料（優化：使用字串存儲）
local function load_code_data()
    local data = {}
    
    local function process_file(filepath)
        local file = io.open(filepath, "r")
        if not file then
            return false
        end
        
        for line in file:lines() do
            local char, codes_str = line:match("^([^\t]+)\t~(.+)$")
            if char and codes_str then
                -- 直接存儲原始字串，不預先解析
                if not data[char] then
                    data[char] = codes_str
                else
                    data[char] = data[char] .. codes_str
                end
            end
        end
        file:close()
        return true
    end
    
    local user_dir = rime_api.get_user_data_dir()
    local shared_dir = rime_api.get_shared_data_dir()
    
    if not process_file(user_dir .. "/opencc/liu_w2c.txt") then
        process_file(shared_dir .. "/opencc/liu_w2c.txt")
    end
    if not process_file(user_dir .. "/opencc/liu_w2cExt.txt") then
        process_file(shared_dir .. "/opencc/liu_w2cExt.txt")
    end
    
    return data
end

-- 解析編碼字串（即時解析）
local function parse_codes(codes_str)
    if not codes_str then
        return nil
    end
    
    local primary = {}
    local secondary = {}
    
    local temp_str = codes_str:gsub("\\⟩", "\x01")
    for code in temp_str:gmatch("⟨([^⟩]+)⟩") do
        code = code:gsub("\x01", "⟩"):upper()
        if code:match("%^[VRSF]") then
            secondary[#secondary + 1] = code
        else
            primary[#primary + 1] = code
        end
    end
    
    -- 排序
    local sort_func = function(a, b)
        local la, lb = #a, #b
        return la == lb and a < b or la < lb
    end
    if #primary > 1 then table.sort(primary, sort_func) end
    if #secondary > 1 then table.sort(secondary, sort_func) end
    
    return {primary = primary, secondary = secondary}
end

-- ============ 簡繁轉換 ============

local function get_opencc_s2t()
    if not opencc_s2t then
        opencc_s2t = Opencc("s2t.json")
    end
    return opencc_s2t
end

local function get_char_codes(char, is_simplified)
    if not code_data then
        return nil
    end
    
    local codes_str = code_data[char]
    if codes_str then
        return parse_codes(codes_str)
    end
    
    if is_simplified then
        local opencc = get_opencc_s2t()
        if opencc then
            local trad_char = opencc:convert(char)
            if trad_char and trad_char ~= char then
                codes_str = code_data[trad_char]
                if codes_str then
                    return parse_codes(codes_str)
                end
            end
        end
    end
    
    return nil
end

-- ============ 輔助函數 ============

local function format_code_comment(base_comment, codes, liu_w2c_enabled)
    local parts = {base_comment}
    
    if codes and (codes.primary or codes.secondary) then
        if liu_w2c_enabled then
            parts[#parts + 1] = "~"
        end
        
        local has_primary = codes.primary and #codes.primary > 0
        
        if has_primary then
            for i, code in ipairs(codes.primary) do
                if i > 1 then
                    parts[#parts + 1] = " "
                end
                parts[#parts + 1] = "⟨"
                parts[#parts + 1] = code
                parts[#parts + 1] = "⟩"
            end
        end
        
        if codes.secondary then
            for i, code in ipairs(codes.secondary) do
                -- 只有在有 primary codes 或是第二個以上的 secondary 時才加空格
                if has_primary or i > 1 then
                    parts[#parts + 1] = " "
                end
                parts[#parts + 1] = "⟨"
                parts[#parts + 1] = code
                parts[#parts + 1] = "⟩"
            end
        end
    else
        parts[#parts + 1] = "⟨?⟩"
    end
    
    return table.concat(parts)
end

-- 確保編碼資料已載入
local function ensure_code_data()
    if not code_data then
        code_data = load_code_data()
    end
    return code_data
end

-- ============ 運行時狀態 ============
local selected_char = nil
local is_showing_phonetics = false
local original_input = ""
local cached_candidates = nil

-- 清除所有快取（同音字模式結束時調用）
local function clear_all_cache()
    selected_char = nil
    is_showing_phonetics = false
    original_input = ""
    cached_candidates = nil
    -- 釋放大型資料
    groups_trad = nil
    groups_simp = nil
    char_to_gids_trad = nil
    char_to_gids_simp = nil
    code_data = nil
    -- opencc_s2t 保留，因為其他模組也可能用到
end

-- ============ Processor ============

local function liu_phonetic_suffix_processor(key, env)
    local engine = env.engine
    local context = engine.context
    local input = context.input
    local input_len = input:len()
    
    -- 輸入為空時，清除狀態和快取
    if input_len == 0 then
        if is_showing_phonetics then
            clear_all_cache()
        end
        return 2  -- kNoop
    end
    
    local key_repr = key:repr()
    
    -- 處理 Backspace
    if key_repr == "BackSpace" and is_showing_phonetics then
        if input_len == 0 and original_input ~= "" then
            context.input = original_input
            clear_all_cache()
            return 1
        end
    end
    
    -- 屏蔽簡繁切換
    if is_showing_phonetics then
        if key_repr == "Control+period" or key_repr == "Control+comma" then
            return 1
        end
    end
    
    -- 按 ' 展開同音字
    if key_repr == "apostrophe" then
        local composition = context.composition
        if composition:empty() or input_len == 0 or input:find("'", 1, true) then
            return 2
        end
        
        local segment = composition:back()
        local selected_index = segment.selected_index
        local menu = segment.menu
        
        if selected_index >= 0 and selected_index < menu:candidate_count() then
            local selected_cand = menu:get_candidate_at(selected_index)
            local original_char = selected_cand.text
            local is_simplified = context:get_option("simplification")
            
            local phonetics = get_phonetics_for_char(original_char, is_simplified)
            
            if phonetics and #phonetics > 0 then
                selected_char = original_char
                original_input = input
                cached_candidates = nil
                context:clear()
                is_showing_phonetics = true
                context.input = original_input .. "'"
                return 1
            end
        end
    end
    
    return 2
end

-- ============ Translator ============

local function liu_phonetic_suffix_translator(input, seg, env)
    if not selected_char or not is_showing_phonetics then
        return
    end
    
    if not input:find("'", 1, true) then
        return
    end
    
    local context = env.engine.context
    local liu_w2c_enabled = context:get_option("liu_w2c")
    local is_simplified = context:get_option("simplification")
    
    -- 使用快取
    if cached_candidates and cached_candidates.char == selected_char 
       and cached_candidates.simplified == is_simplified 
       and cached_candidates.w2c == liu_w2c_enabled then
        for _, cand_data in ipairs(cached_candidates.list) do
            yield(Candidate("phonetic", seg.start, seg._end, cand_data.char, cand_data.comment))
        end
        return
    end
    
    ensure_code_data()
    
    local phonetics = get_phonetics_for_char(selected_char, is_simplified)
    
    if not phonetics or #phonetics == 0 then
        return
    end
    
    local base_comment = "〔" .. selected_char .. "〕"
    local candidates = {}
    local max_candidates = 50
    
    for i = 1, math.min(#phonetics, max_candidates) do
        local phonetic_char = phonetics[i]
        local codes = get_char_codes(phonetic_char, is_simplified)
        local comment = format_code_comment(base_comment, codes, liu_w2c_enabled)
        
        candidates[#candidates + 1] = {
            char = phonetic_char,
            comment = comment
        }
    end
    
    cached_candidates = {
        char = selected_char,
        simplified = is_simplified,
        w2c = liu_w2c_enabled,
        list = candidates
    }
    
    for _, cand_data in ipairs(candidates) do
        yield(Candidate("phonetic", seg.start, seg._end, cand_data.char, cand_data.comment))
    end
end

-- ============ Filter ============

local function liu_phonetic_suffix_filter(input, env)
    -- 快速路徑：不在同音字模式時，直接通過
    if not is_showing_phonetics then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    local context = env.engine.context
    local input_text = context.input
    local input_len = input_text:len()
    
    -- 輸入為空，清除狀態
    if input_len == 0 then
        clear_all_cache()
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    -- 同音字模式中
    if selected_char and input_text:find("'", 1, true) then
        if cached_candidates and cached_candidates.char == selected_char then
            for _, cand_data in ipairs(cached_candidates.list) do
                yield(Candidate("phonetic", 0, input_len, cand_data.char, cand_data.comment))
            end
        end
        return
    end
    
    -- 輸入不含 '，表示已離開同音字模式
    if not input_text:find("'", 1, true) then
        clear_all_cache()
    end
    
    for cand in input:iter() do
        yield(cand)
    end
end

-- ============ 導出 ============

return {
    processor = liu_phonetic_suffix_processor,
    translator = liu_phonetic_suffix_translator,
    filter = liu_phonetic_suffix_filter,
    get_selected_char = function() return selected_char end
}
