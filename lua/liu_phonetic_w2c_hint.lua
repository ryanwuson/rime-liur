-- liu_phonetic_w2c_hint.lua
-- 獨立注音／拼音：單字候選顯示嘸蝦米拆碼（詞組不加）
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
