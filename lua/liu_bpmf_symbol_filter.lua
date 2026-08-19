-- liu_bpmf_symbol_filter.lua
-- 多音節找字時過濾注音符號候選（含「ㄅㄓㄉ」這類純注音拼句）
-- 單鍵聲母（如 1→ㄅ）保留 ㄅㆠㆴ

local common = require("liu_bpmf_common")

local function is_bopomofo_char(cp)
    if cp >= 0x3100 and cp <= 0x312F then
        return true
    end
    if cp >= 0x31A0 and cp <= 0x31BF then
        return true
    end
    -- 注音聲調符
    if cp == 0x02CA or cp == 0x02C7 or cp == 0x02CB or cp == 0x02D9 or cp == 0x02C9 then
        return true
    end
    return false
end

local function is_pure_bopomofo_text(text)
    if not text or text == "" then
        return false
    end
    local has_char = false
    for _, cp in utf8.codes(text) do
        if not is_bopomofo_char(cp) then
            return false
        end
        has_char = true
    end
    return has_char
end

local function filter(input, env)
    if env.engine.schema.schema_id ~= "liu_bpmf" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local code = env.engine.context.input or ""
    if code:sub(1, 1) == "`" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    local drop_symbols = common.should_filter_bpmf_symbol_candidates(code)

    for cand in input:iter() do
        if drop_symbols and is_pure_bopomofo_text(cand.text) then
            -- skip ㄅ / ㆴ / ㄅㄓㄉ 等
        else
            yield(cand)
        end
    end
end

return filter
