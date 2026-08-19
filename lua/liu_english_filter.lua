-- liu_english_filter.lua
-- 移除純 ASCII 英文候選的 comment（補全提示）
-- 帶音調的拉丁字母（如 ē、ě）保留 comment（因為有蝦米編碼）
-- 必須放在 filters 的最後面（uniquifier 之前）

-- 檢查是否為純 ASCII 英文（只包含 ASCII 可打印字元且至少有一個字母）
-- 不包含帶音調的拉丁字母
local function is_pure_ascii_english(text)
    if not text or text == "" then
        return false
    end
    local has_letter = false
    for i = 1, #text do
        local byte = string.byte(text, i)
        if byte < 32 or byte > 126 then
            return false  -- 非 ASCII，可能是帶音調的字母
        end
        if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
            has_letter = true
        end
    end
    return has_letter
end

local function filter(input, env)
    for cand in input:iter() do
        local text = cand.text
        -- 漢字（UTF-8 首 byte > 127）或 comment 已空：不必掃描、不必重建 Candidate
        if not text or text == "" or string.byte(text, 1) > 127 or (cand.comment or "") == "" then
            yield(cand)
        elseif is_pure_ascii_english(text) then
            -- 純 ASCII 英文：移除 comment（不管正常模式還是反查模式）
            local new_cand = Candidate(cand.type, cand.start, cand._end, text, "")
            new_cand.quality = cand.quality
            new_cand.preedit = cand.preedit
            yield(new_cand)
        else
            yield(cand)
        end
    end
end

return filter
