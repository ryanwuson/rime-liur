-- liu_bpmf_common.lua
-- 注音碼 → 顯示符
-- P0：一聲內部碼為空白（use_space）；仍相容舊碼 ~ / `

local M = {}

M.TONE_MARKER = " "

local INITIAL_KEYS = {
    ["1"] = true, ["q"] = true, ["a"] = true, ["z"] = true,
    ["2"] = true, ["w"] = true, ["s"] = true, ["x"] = true,
    ["e"] = true, ["d"] = true, ["c"] = true, ["r"] = true,
    ["f"] = true, ["v"] = true, ["5"] = true, ["t"] = true,
    ["g"] = true, ["b"] = true, ["y"] = true, ["h"] = true,
    ["n"] = true,
}

local TONE_KEYS = {
    ["6"] = true, ["3"] = true, ["4"] = true, ["7"] = true,
    [" "] = true,  -- P0：空白＝一聲
    ["~"] = true,  -- 相容舊碼／grave 轉入
}

-- segment_processor 等外部模組需要
M.INITIAL_KEYS = INITIAL_KEYS
M.TONE_KEYS = TONE_KEYS

-- 可作為新音節開頭的零聲母韻母鍵（ㄧㄨㄩ；不含 i，鍵盤 i=ㄛ 為韻母續接）
local MEDIAL_VOWEL_KEYS = {
    ["u"] = true, ["j"] = true, ["m"] = true,
}

-- 聲母音節已完整、缺聲調時，下一鍵若為獨立韻母可再切一段（Enter 補 ˉ 用）
local STANDALONE_FINAL_KEYS = {
    ["8"] = true, ["9"] = true, ["0"] = true, ["p"] = true,
    ["i"] = true, ["k"] = true, [","] = true,
    ["o"] = true, ["l"] = true, ["."] = true,
    [";"] = true, ["/"] = true, ["-"] = true,
}
M.STANDALONE_FINAL_KEYS = STANDALONE_FINAL_KEYS

local CODES_BY_LEN = {
    { " ", "ˉ" },
    { "~", "ˉ" },
    { "1", "ㄅ" }, { "q", "ㄆ" }, { "a", "ㄇ" }, { "z", "ㄈ" },
    { "2", "ㄉ" }, { "w", "ㄊ" }, { "s", "ㄋ" }, { "x", "ㄌ" },
    { "e", "ㄍ" }, { "d", "ㄎ" }, { "c", "ㄏ" }, { "r", "ㄐ" },
    { "f", "ㄑ" }, { "v", "ㄒ" }, { "5", "ㄓ" }, { "t", "ㄔ" },
    { "g", "ㄕ" }, { "b", "ㄖ" }, { "y", "ㄗ" }, { "h", "ㄘ" },
    { "n", "ㄙ" }, { "u", "ㄧ" }, { "j", "ㄨ" }, { "m", "ㄩ" },
    { "8", "ㄚ" }, { "i", "ㄛ" }, { "k", "ㄜ" }, { ",", "ㄝ" },
    { "9", "ㄞ" }, { "o", "ㄟ" }, { "l", "ㄠ" }, { ".", "ㄡ" },
    { "0", "ㄢ" }, { "p", "ㄣ" }, { ";", "ㄤ" }, { "/", "ㄥ" },
    { "-", "ㄦ" },
    { "6", "ˊ" }, { "3", "ˇ" }, { "4", "ˋ" }, { "7", "˙" },
}

function M.keys_to_bpmf(input)
    if not input or input == "" then
        return ""
    end

    -- 空白＝一聲，不可剝除；僅清手動／自動分節符
    local normalized = input:gsub("|", ""):gsub("~", ""):gsub("'", ""):gsub("\\", ""):gsub("`", "~")
    local parts = {}
    local i = 1
    local len = #normalized

    while i <= len do
        if normalized:sub(i, i + 1) == "''" then
            parts[#parts + 1] = "ˉ"
            i = i + 2
        else
            local matched = false
            for _, entry in ipairs(CODES_BY_LEN) do
                local code = entry[1]
                local sym = entry[2]
                local code_len = #code
                if normalized:sub(i, i + code_len - 1) == code then
                    parts[#parts + 1] = sym
                    i = i + code_len
                    matched = true
                    break
                end
            end
            if not matched then
                i = i + 1
            end
        end
    end

    return table.concat(parts)
end

-- 手動分節預輸入：半形中點 U+FF65（字體自帶留白，不加 ASCII 空白）
local SEP = "･"

local function is_segment_delimiter(ch)
    -- ~ = 自動分節；' = 手動分節；\ = 舊手動；空白＝一聲（不是分節）
    return ch == "~" or ch == "'" or ch == "\\"
end

local function split_delimited_segments(input)
    local normalized = (input or ""):gsub("|", ""):gsub("`", "~")
    local segments = {}
    local cur = ""

    for i = 1, #normalized do
        local ch = normalized:sub(i, i)
        if is_segment_delimiter(ch) then
            if cur ~= "" then
                segments[#segments + 1] = cur
                cur = ""
            end
        else
            cur = cur .. ch
        end
    end
    if cur ~= "" then
        segments[#segments + 1] = cur
    end
    return segments
end

M.split_delimited_segments = split_delimited_segments

local function has_explicit_tone(code)
    if not code or code == "" then
        return false
    end
    local i = 1
    local len = #code
    while i <= len do
        local ch = code:sub(i, i)
        if TONE_KEYS[ch] then
            return true
        end
        i = i + 1
    end
    return false
end

local function syllable_complete(cur)
    if #cur == 0 then
        return false
    end
    if TONE_KEYS[cur[#cur]] then
        return true
    end
    if INITIAL_KEYS[cur[1]] then
        if #cur == 2 and cur[2] == "j" then
            return false
        end
        if #cur == 1 then
            return false
        end
        return #cur >= 2
    end
    return #cur >= 1
end

local function should_split_before(cur, next_ch)
    if #cur == 0 or not next_ch then
        return false
    end
    local cur_str = table.concat(cur)
    if #cur == 1 and INITIAL_KEYS[cur[1]] and INITIAL_KEYS[next_ch] then
        return true
    end
    if INITIAL_KEYS[next_ch] and syllable_complete(cur) then
        return true
    end
    if MEDIAL_VOWEL_KEYS[next_ch] and #cur > 1 and syllable_complete(cur) then
        return true
    end
    if INITIAL_KEYS[cur[1]]
        and syllable_complete(cur)
        and not has_explicit_tone(cur_str)
        and STANDALONE_FINAL_KEYS[next_ch]
    then
        if next_ch == "8" and #cur <= 2 then
            return false
        end
        if next_ch == "i" and #cur >= 2 and MEDIAL_VOWEL_KEYS[cur[2]] then
            return false
        end
        if #cur >= 3 then
            return true
        end
        if #cur == 2 and STANDALONE_FINAL_KEYS[cur[2]] then
            return true
        end
    end
    return false
end

local function split_syllables(code)
    -- 保留空白（一聲）；清自動／手動分節
    local normalized = (code or ""):gsub("|", ""):gsub("~", ""):gsub("'", ""):gsub("\\", ""):gsub("`", "~")
    if normalized == "" then
        return {}
    end

    local syllables = {}
    local cur = {}
    local i = 1
    local len = #normalized

    while i <= len do
        local ch = normalized:sub(i, i)

        -- 舊版自動分節誤插空白：音節已結束後的「空 cur + 空白」略過
        if ch == " " and #cur == 0 then
            i = i + 1
        else
            if should_split_before(cur, ch) then
                syllables[#syllables + 1] = table.concat(cur)
                cur = {}
            end

            cur[#cur + 1] = ch

            if TONE_KEYS[ch] then
                syllables[#syllables + 1] = table.concat(cur)
                cur = {}
            end

            i = i + 1
        end
    end

    if #cur > 0 then
        syllables[#syllables + 1] = table.concat(cur)
    end

    return syllables
end

-- 預輸入：自動分節 → 空白；手動分節 '/\ → ･
function M.keys_to_bpmf_preedit(input)
    if not input or input == "" then
        return ""
    end

    local normalized = input:gsub("|", ""):gsub("`", "~")
    local items = {}
    local cur = ""

    local function flush_cur()
        if cur == "" then
            return
        end
        local syllables = split_syllables(cur)
        if #syllables == 0 then
            syllables = { cur }
        end
        for _, syl in ipairs(syllables) do
            items[#items + 1] = { kind = "syl", code = syl }
        end
        cur = ""
    end

    for i = 1, #normalized do
        local ch = normalized:sub(i, i)
        if ch == "~" then
            flush_cur()
            items[#items + 1] = { kind = "auto" }
        elseif ch == "'" or ch == "\\" then
            flush_cur()
            items[#items + 1] = { kind = "manual" }
        else
            cur = cur .. ch
        end
    end
    flush_cur()

    if #items == 0 then
        return ""
    end

    local out = {}
    for _, item in ipairs(items) do
        if item.kind == "auto" then
            if #out == 0 or out[#out] == SEP then
                -- 略過開頭／手動分節符後多餘自動空白
            elseif out[#out] ~= " " then
                out[#out + 1] = " "
            end
        elseif item.kind == "manual" then
            out[#out + 1] = SEP
        else
            local text = M.keys_to_bpmf(item.code)
            if text ~= "" then
                if #out > 0 and out[#out] ~= SEP and out[#out] ~= " " then
                    out[#out + 1] = " "
                end
                out[#out + 1] = text
            end
        end
    end

    return table.concat(out)
end

-- Enter 上滑上屏：
-- 1) 手動／自動分節符（\、'）→ 空白
-- 2) 無分節符時仍依音節切開再插空白（空白鍵一聲不算分節）
function M.keys_to_bpmf_commit(input)
    if not input or input == "" then
        return ""
    end

    local segments = split_delimited_segments(input)
    if #segments == 0 then
        segments = { input or "" }
    end

    local parts = {}
    for _, seg in ipairs(segments) do
        local syllables = split_syllables(seg)
        if #syllables == 0 and seg ~= "" then
            syllables = { seg }
        end
        for _, syl in ipairs(syllables) do
            local text = M.keys_to_bpmf(syl)
            if text ~= "" then
                parts[#parts + 1] = text
            end
        end
    end
    return table.concat(parts, " ")
end

-- 注音文直出：依 \ 分節；無聲調音節補 ˉ（空白）
function M.keys_to_bpmf_auto_first_tone(input)
    local segments = split_delimited_segments(input)
    if #segments == 0 then
        segments = { input or "" }
    end

    local out = {}
    for _, seg in ipairs(segments) do
        local syllables = split_syllables(seg)
        if #syllables == 0 then
            syllables = { seg }
        end
        for _, syl in ipairs(syllables) do
            local s = syl
            if not has_explicit_tone(s) then
                s = s .. " "
            end
            out[#out + 1] = M.keys_to_bpmf(s)
        end
    end
    return table.concat(out)
end

function M.strip_tone_markers(input)
    if not input then
        return input
    end
    return input:gsub("`", "~"):gsub("~", ""):gsub(" ", ""):gsub("''", "")
end

M.split_syllables = split_syllables

-- 多音節／完整音節找字時過濾注音符號；僅單鍵聲母（如 1→b）保留 ㄅㆠㆴ
function M.should_filter_bpmf_symbol_candidates(input)
    local normalized = (input or ""):gsub("`", "~")
    if normalized == "" then
        return false
    end
    if normalized:find("~", 1, true) or normalized:find("'", 1, true) or normalized:find("\\", 1, true) then
        return true
    end

    -- 去掉一聲空白後判斷：單鍵聲母保留符號；其餘過濾
    local stripped = normalized:gsub(" ", ""):gsub("~", ""):gsub("'", ""):gsub("\\", "")
    if stripped == "" then
        return false
    end
    if #stripped == 1 and INITIAL_KEYS[stripped] then
        return false
    end
    if #stripped > 1 then
        return true
    end

    return #split_syllables(normalized) >= 2
end

return M
