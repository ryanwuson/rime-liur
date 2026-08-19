-- liu_pinyin_preedit_filter.lua
-- 組字區：沿用 Rime 音節切分，加聲調；自動分節空白、手動分節  ⁞ 
-- 字母變化形／日期時間等擴充候選的 preedit（如《G變化》G）不可再格式化

local common = require("liu_pinyin_common")

-- 這些候選的 preedit 由各自 translator 設定，不是拼音音節
local SKIP_TYPES = {
    letter_variant = true,
    datetime = true,
    datetime_menu = true,
    extended_menu = true,
}

local function source_preedit(cand, context)
    local src = cand.preedit
    if (not src or src == "") and cand.get_genuine then
        src = cand:get_genuine().preedit
    end
    if not src or src == "" then
        src = context.input or ""
    end
    return src
end

local function should_skip(cand, src)
    if SKIP_TYPES[cand.type] then
        return true
    end
    -- 《A變化》A／``G 等擴充字串：format_preedit_display 會誤拆成 gg
    if src:match("變化") or src:match("^``") then
        return true
    end
    return false
end

local function filter(input, env)
    if env.engine.schema.schema_id ~= "liu_pinyin" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local context = env.engine.context

    for cand in input:iter() do
        local src = source_preedit(cand, context)
        local composing = context.input or ""
        if composing:sub(1, 1) ~= "`" and not should_skip(cand, src) then
            local formatted = common.format_preedit_display(src)
            if formatted ~= "" then
                cand.preedit = formatted
            end
        end
        yield(cand)
    end
end

return filter
