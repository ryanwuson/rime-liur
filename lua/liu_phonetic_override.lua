-- liu_phonetic_override.lua
-- 讀音查詢模式（;;）下移除編碼和繁體標記，顯示注音
-- 讀音優先：opencc/liu_readings.txt（繁）／liu_readings_simp.txt（簡）
-- 缺字才回退 Mount_bopomo.extended 反查；簡體缺字可再試繁體表／s2t

local liu_data = require("liu_data")

-- 全局緩存（僅反查 DB／OpenCC；讀音表由 liu_data 管理）
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
-- preserve_order=true：維持讀音表順序；false：沿用舊反查排序
local function pinyin_to_bopomofo(pinyin, preserve_order)
    if not pinyin or pinyin == "" then return "" end

    local pinyins = {}
    for py in pinyin:gmatch("%S+") do
        table.insert(pinyins, py)
    end
    if not preserve_order then
        -- 正式音在前，(通俗／非官方音) 在後；同組內依字串排序
        table.sort(pinyins, function(a, b)
            local a_paren = a:find("(", 1, true) ~= nil
            local b_paren = b:find("(", 1, true) ~= nil
            if a_paren ~= b_paren then
                return not a_paren
            end
            return a < b
        end)
    end

    local bopomofo_list = {}
    for _, py in ipairs(pinyins) do
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
        -- 舌尖元音（空韻）：zi/ci/si/zhi/chi/shi/ri 的 i 不是 ㄧ，須先去掉
        py = py:gsub("([ZCSrzcs])i", "%1")
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

-- 從讀音表查單字（簡體缺則試繁表／s2t）
local function lookup_readings(text, is_simplified)
    if not text or text == "" then
        return nil
    end
    local primary = liu_data.get_readings_data(is_simplified)
    local py = primary and primary[text]
    if py and py ~= "" then
        return py
    end
    if is_simplified then
        local trad_table = liu_data.get_readings_data(false)
        if trad_table then
            py = trad_table[text]
            if py and py ~= "" then
                return py
            end
        end
        local opencc = get_opencc_s2t()
        if opencc then
            local trad_text = opencc:convert(text)
            if trad_text and trad_text ~= text then
                if trad_table then
                    py = trad_table[trad_text]
                    if py and py ~= "" then
                        return py
                    end
                end
                -- 多字：逐字拼（僅當整詞查不到）
            end
        end
    end
    return nil
end

-- 多字候選：逐字查讀音表；任一缺則放棄（改走反查）
local function lookup_readings_chars(text, is_simplified)
    if not text or text == "" then
        return nil
    end
    if utf8.len(text) == 1 then
        return lookup_readings(text, is_simplified)
    end
    local parts = {}
    for _, cp in utf8.codes(text) do
        local ch = utf8.char(cp)
        local py = lookup_readings(ch, is_simplified)
        if not py then
            return nil
        end
        -- 多音字取第一讀，避免註解過長
        local first = py:match("%S+") or py
        table.insert(parts, first)
    end
    return table.concat(parts, " ")
end

local function liu_phonetic_override(input, env)
    local context = env.engine.context
    local input_text = context.input

    local is_liurqry = input_text and input_text:sub(1, 2) == ";;"

    if not is_liurqry then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local db = get_reverse_db()
    local is_simplified = context:get_option("simplification")
    local opencc = is_simplified and get_opencc_s2t() or nil

    for cand in input:iter() do
        local comment = cand.comment or ""

        -- 移除繁體標記 〔xxx〕
        local new_comment = comment:gsub("〔[^〕]+〕%s*", "")

        -- 移除編碼顯示 ~⟨xxx⟩ ⟨xxx⟩
        new_comment = new_comment:gsub("~%s*⟨[^⟩]+⟩%s*", "")
        new_comment = new_comment:gsub("⟨[^⟩]+⟩%s*", "")
        new_comment = new_comment:gsub("^%s+", "")

        -- ① 優先讀音表（覆蓋 Mount 反查註解）
        local from_table = lookup_readings_chars(cand.text, is_simplified)
        if from_table then
            new_comment = pinyin_to_bopomofo(from_table, true)
        elseif not new_comment:match("{") and db then
            -- ② 回退 Mount 反查
            local pinyin = db:lookup(cand.text)

            if opencc and (not pinyin or pinyin == "") then
                local trad_text = opencc:convert(cand.text)
                if trad_text ~= cand.text then
                    pinyin = db:lookup(trad_text)
                end
            end

            if pinyin and pinyin ~= "" then
                new_comment = pinyin_to_bopomofo(pinyin, false)
            end
        end

        if new_comment:match("{") and not new_comment:match("^%s") then
            new_comment = " " .. new_comment
        end

        local new_cand = cand:to_shadow_candidate(cand.type, cand.text, new_comment)
        yield(new_cand)
    end
end

return liu_phonetic_override
