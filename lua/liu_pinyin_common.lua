-- liu_pinyin_common.lua
-- 拼音鍵位 → 顯示（自動分節空白、手動分節  ⁞ ；Enter 直出用空白）

local M = {}

local AUTO_DELIM = " "
local MANUAL_MARK = "MANUAL"
-- U+2009 thin space（十進位 UTF-8，相容 Lua 5.1）；U+205E ⁞
local THIN_SPACE = "\226\128\137"
local MANUAL_DISPLAY = THIN_SPACE .. "⁞" .. THIN_SPACE

local TONE_CHARS = {
    a = { "ā", "á", "ǎ", "à", "a" },
    e = { "ē", "é", "ě", "è", "e" },
    i = { "ī", "í", "ǐ", "ì", "i" },
    o = { "ō", "ó", "ǒ", "ò", "o" },
    u = { "ū", "ú", "ǔ", "ù", "u" },
    v = { "ǖ", "ǘ", "ǚ", "ǜ", "ü" },
    ["ü"] = { "ǖ", "ǘ", "ǚ", "ǜ", "ü" },
}

local function is_auto_delimiter(ch)
    return ch == " "
end

local function is_manual_delimiter(ch)
    return ch == "'" or ch == "\\"
end

local function normalize_syllable(syl)
    local s = syl:lower()
    s = s:gsub("ue$", "üe")
    s = s:gsub("v", "ü")
    return s
end

local function tone_vowel_index(syl)
    if syl:find("a", 1, true) then
        return syl:find("a", 1, true)
    end
    if syl:find("o", 1, true) then
        return syl:find("o", 1, true)
    end
    if syl:find("e", 1, true) then
        return syl:find("e", 1, true)
    end
    local iu = syl:find("iu", 1, true)
    if iu then
        return iu + 1
    end
    local ui = syl:find("ui", 1, true)
    if ui then
        return ui
    end
    for i = #syl, 1, -1 do
        local ch = syl:sub(i, i)
        if TONE_CHARS[ch] then
            return i
        end
    end
    return nil
end

local function apply_tone(syl, tone)
    if not tone or tone < 1 or tone > 5 then
        return normalize_syllable(syl)
    end

    local base = syl:gsub("[1-5]$", "")
    base = normalize_syllable(base)
    local idx = tone_vowel_index(base)
    if not idx then
        return base
    end

    local ch = base:sub(idx, idx)
    local marked = TONE_CHARS[ch] and TONE_CHARS[ch][tone] or ch
    return base:sub(1, idx - 1) .. marked .. base:sub(idx + 1)
end

local function parse_syllables_with_delim(input)
    local parts = {}
    local i = 1
    local len = #input

    while i <= len do
        local ch = input:sub(i, i)
        if is_auto_delimiter(ch) then
            parts[#parts + 1] = AUTO_DELIM
            i = i + 1
        elseif is_manual_delimiter(ch) then
            parts[#parts + 1] = MANUAL_MARK
            i = i + 1
        else
            local start = i
            while i <= len do
                local c = input:sub(i, i)
                if c:match("%l") or c:match("%u") then
                    i = i + 1
                else
                    break
                end
            end

            local letters = input:sub(start, i - 1)
            local tone = nil
            if i <= len and input:sub(i, i):match("[1-5]") then
                tone = tonumber(input:sub(i, i))
                i = i + 1
            end

            if letters ~= "" then
                parts[#parts + 1] = { letters = letters, tone = tone }
            elseif i <= len then
                i = i + 1
            end
        end
    end

    return parts
end

local function parts_to_display(parts, default_tone, manual_as_space)
    local display = {}
    for _, item in ipairs(parts) do
        if item == AUTO_DELIM then
            display[#display + 1] = AUTO_DELIM
        elseif item == MANUAL_MARK then
            -- 預輸入：手動 ' 顯示  ⁞ ；上屏：空白
            display[#display + 1] = manual_as_space and AUTO_DELIM or MANUAL_DISPLAY
        else
            local tone = item.tone
            if tone == nil and default_tone then
                tone = default_tone
            end
            display[#display + 1] = apply_tone(item.letters, tone)
        end
    end
    return table.concat(display)
end

function M.format_preedit_display(preedit)
    if not preedit or preedit == "" then
        return ""
    end

    local normalized = preedit:gsub("|", "")
    return parts_to_display(parse_syllables_with_delim(normalized), nil, false)
end

function M.keys_to_pinyin_auto_first_tone(input)
    if not input or input == "" then
        return ""
    end

    local normalized = input:gsub("|", "")
    return parts_to_display(parse_syllables_with_delim(normalized), 1, false)
end

function M.keys_to_pinyin(input)
    if not input or input == "" then
        return ""
    end

    local normalized = input:gsub("|", "")
    return parts_to_display(parse_syllables_with_delim(normalized), nil, false)
end

-- Enter 上滑上屏：自動／手動分節一律空白（不輸出 ⁞）
-- 連續音節（ni3hao3）在聲調數字後補虛擬空白，對齊預輸入顯示
function M.keys_to_pinyin_commit(input)
    if not input or input == "" then
        return ""
    end

    local normalized = input:gsub("|", "")
    -- ni3hao3 → ni3 hao3（預輸入常見；raw input 常無空白）
    normalized = normalized:gsub("([1-5])([A-Za-z])", "%1 %2")
    local text = parts_to_display(parse_syllables_with_delim(normalized), nil, true)
    text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

function M.strip_tone_digits(input)
    if not input then
        return input
    end
    return input:gsub("[1-5]", "")
end

return M
