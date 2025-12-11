-- liu_phonetic_override.lua
-- 讀音查詢模式（;;）下移除編碼和繁體標記，顯示注音
-- 簡體模式下自動轉繁體查詢注音

-- 全局緩存
local reverse_db = nil
local opencc_s2t_cache = nil

local function get_reverse_db()
    if not reverse_db then
        reverse_db = ReverseDb("build/Mount_bopomo.extended.reverse.bin")
    end
    return reverse_db
end

local function get_opencc_s2t()
    if not opencc_s2t_cache then
        opencc_s2t_cache = Opencc("s2t.json")
    end
    return opencc_s2t_cache
end

-- 將拼音轉換為注音
local function pinyin_to_bopomofo(pinyin)
    if not pinyin or pinyin == "" then return "" end
    
    -- 處理多個讀音（用空格分隔）
    local pinyins = {}
    for py in pinyin:gmatch("%S+") do
        table.insert(pinyins, py)
    end
    
    local bopomofo_list = {}
    for _, py in ipairs(pinyins) do
        -- 拼音轉注音的規則
        py = py:gsub("e?r5$", "er5")
        py = py:gsub("iu", "iou")
        py = py:gsub("ui", "uei")
        py = py:gsub("ong", "ung")
        py = py:gsub("yi?", "i")
        py = py:gsub("wu?", "u")
        py = py:gsub("iu", "v")
        py = py:gsub("([jqx])u", "%1v")
        py = py:gsub("([iuv])n", "%1en")
        py = py:gsub("zh", "Z")
        py = py:gsub("ch", "C")
        py = py:gsub("sh", "S")
        py = py:gsub("ai", "A")
        py = py:gsub("ei", "I")
        py = py:gsub("ao", "O")
        py = py:gsub("ou", "U")
        py = py:gsub("ang", "K")
        py = py:gsub("eng", "G")
        py = py:gsub("an", "M")
        py = py:gsub("en", "N")
        py = py:gsub("er", "R")
        py = py:gsub("eh", "E")
        py = py:gsub("([iv])e", "%1E")
        py = py:gsub("1", "")
        
        -- 轉換為注音符號
        local map = {
            b="ㄅ", p="ㄆ", m="ㄇ", f="ㄈ", d="ㄉ", t="ㄊ", n="ㄋ", l="ㄌ",
            g="ㄍ", k="ㄎ", h="ㄏ", j="ㄐ", q="ㄑ", x="ㄒ", Z="ㄓ", C="ㄔ",
            S="ㄕ", r="ㄖ", z="ㄗ", c="ㄘ", s="ㄙ", i="ㄧ", u="ㄨ", v="ㄩ",
            a="ㄚ", o="ㄛ", e="ㄜ", E="ㄝ", A="ㄞ", I="ㄟ", O="ㄠ", U="ㄡ",
            M="ㄢ", N="ㄣ", K="ㄤ", G="ㄥ", R="ㄦ", ["2"]="ˊ", ["3"]="ˇ", ["4"]="ˋ", ["5"]="˙"
        }
        
        local result = ""
        for char in py:gmatch(".") do
            result = result .. (map[char] or char)
        end
        
        table.insert(bopomofo_list, "{" .. result .. "}")
    end
    
    return " " .. table.concat(bopomofo_list, " ")
end

local function liu_phonetic_override(input, env)
    local context = env.engine.context
    local input_text = context.input
    
    -- 檢查是否在讀音查詢模式（使用 sub 比 match 更快）
    local is_liurqry = input_text and input_text:sub(1, 2) == ";;"
    
    -- 如果不是讀音查詢模式，直接通過
    if not is_liurqry then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    -- 讀音查詢模式：移除編碼和繁體標記，顯示注音
    local db = get_reverse_db()
    local is_simplified = context:get_option("simplification")
    local opencc = is_simplified and get_opencc_s2t() or nil
    
    for cand in input:iter() do
        local comment = cand.comment or ""
        
        -- 移除繁體標記 〔xxx〕
        local new_comment = comment:gsub("〔[^〕]+〕%s*", "")
        
        -- 移除編碼顯示 ~⟨xxx⟩ ⟨xxx⟩（反查功能的編碼）
        new_comment = new_comment:gsub("~%s*⟨[^⟩]+⟩%s*", "")  -- 移除 ~⟨xxx⟩
        new_comment = new_comment:gsub("⟨[^⟩]+⟩%s*", "")      -- 移除 ⟨xxx⟩
        new_comment = new_comment:gsub("^%s+", "")               -- 移除開頭空格
        
        -- 如果沒有注音，查詢注音
        if not new_comment:match("{") and db then
            local pinyin = db:lookup(cand.text)
            
            -- 簡體模式：如果找不到，嘗試查繁體字
            if opencc and (not pinyin or pinyin == "") then
                local trad_text = opencc:convert(cand.text)
                if trad_text ~= cand.text then
                    pinyin = db:lookup(trad_text)
                end
            end
            
            if pinyin and pinyin ~= "" then
                new_comment = pinyin_to_bopomofo(pinyin)
            end
        end
        
        -- 統一格式：確保注音前有空格
        if new_comment:match("{") and not new_comment:match("^%s") then
            new_comment = " " .. new_comment
        end
        
        local new_cand = cand:to_shadow_candidate(cand.type, cand.text, new_comment)
        yield(new_cand)
    end
end

return liu_phonetic_override
