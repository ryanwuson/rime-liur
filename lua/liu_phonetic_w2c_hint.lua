-- liu_phonetic_w2c_hint.lua
-- 獨立注音／拼音：單字漢字候選顯示嘸蝦米拆碼（詞組／標點符號不加）
--
-- 簡繁字碼表已拆開：
--   simplification 開 → 只查 liu_w2c_simp.txt（鍵為簡體字，如「发」）
--   simplification 關 → 只查 liu_w2c_trad.txt（鍵為繁體字，如「發」）
-- 不做 s2t 跨表回退。
--
-- 必須掛在 simplifier 之後，且用 to_shadow_candidate 覆寫 comment：
-- simplifier tips:all 會留下〔繁〕；直接改 get_genuine().comment 無法蓋掉 shadow 上的提示。

local liu_data = require("liu_data")

local PHONETIC_SCHEMAS = {
    liu_bpmf = true,
    liu_pinyin = true,
}

local SKIP_TYPES = {
    phonetic = true,
    datetime = true,
    datetime_menu = true,
    extended_menu = true,
    letter_variant = true,
    emoji = true,
}

-- 只對漢字提示拆碼（含日文漢字）；排除「」【】等標點符號
local function is_cjk_ideograph(text)
    if not text or text == "" then
        return false
    end
    local cp = utf8.codepoint(text)
    if not cp then
        return false
    end
    -- CJK Unified Ideographs
    if cp >= 0x4E00 and cp <= 0x9FFF then
        return true
    end
    -- Extension A
    if cp >= 0x3400 and cp <= 0x4DBF then
        return true
    end
    -- Compatibility Ideographs
    if cp >= 0xF900 and cp <= 0xFAFF then
        return true
    end
    -- Extension B–G（罕用／大碼位）
    if cp >= 0x20000 and cp <= 0x2CEAF then
        return true
    end
    return false
end

local function parse_codes(raw_codes)
    local codes = {}
    if not raw_codes then
        return codes
    end
    local temp_str = raw_codes:gsub("\\⟩", "\x01")
    for code in temp_str:gmatch("⟨([^⟩]+)⟩") do
        codes[#codes + 1] = code:gsub("\x01", "⟩")
    end
    return codes
end

local function format_w2c_comment(codes, with_tilde)
    local comment = with_tilde and "~" or ""
    for i, code in ipairs(codes) do
        if i > 1 then
            comment = comment .. " "
        end
        comment = comment .. "⟨" .. code .. "⟩"
    end
    return comment
end

-- shadow 的 comment 若為 "" 會回落 genuine（〔全角〕仍會顯示）；用零寬空白強制蓋掉
local CLEAR_COMMENT = utf8.char(0x200B)

local function filter(input, env)
    local schema_id = env.engine.schema.schema_id
    if not PHONETIC_SCHEMAS[schema_id] then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local context = env.engine.context
    local is_simplified = context:get_option("simplification")
    local show_tilde = context:get_option("liu_w2c")
    -- 簡繁分表：依開關取對應表，不以 OpenCC 跨表查
    local code_dict = liu_data.get_w2c_data(is_simplified)

    for cand in input:iter() do
        if SKIP_TYPES[cand.type] then
            yield(cand)
        elseif not cand.text or utf8.len(cand.text) ~= 1 then
            yield(cand)
        elseif not is_cjk_ideograph(cand.text) then
            -- 符號：清掉 〔全角〕〔半角〕等提示，也不加拆碼
            yield(cand:to_shadow_candidate(cand.type, cand.text, CLEAR_COMMENT))
        else
            local raw_codes = code_dict and code_dict[cand.text]
            local codes = parse_codes(raw_codes)
            if #codes > 0 then
                -- 必須 shadow：才能蓋掉 simplifier 留下的〔繁〕
                yield(cand:to_shadow_candidate(
                    cand.type,
                    cand.text,
                    format_w2c_comment(codes, show_tilde)
                ))
            else
                yield(cand)
            end
        end
    end
end

return filter
