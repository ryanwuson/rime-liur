-- liu_wildcard_code_hint.lua
-- 萬用字元查詢時顯示候選字的編碼
-- 優化：關閉萬用查字模式時釋放 OpenCC 實例

local opencc_liu_w2c = nil
local last_wildcard_mode = false  -- 追蹤萬用查字模式狀態

local function get_opencc()
    if not opencc_liu_w2c then
        opencc_liu_w2c = Opencc("liu_w2c.json")
    end
    return opencc_liu_w2c
end

-- 清除 OpenCC 快取
local function clear_opencc_cache()
    opencc_liu_w2c = nil
end

local function liu_wildcard_code_hint(input, env)
    local context = env.engine.context
    local wildcard_mode = context:get_option("wildcard_mode")
    local input_code = context.input
    
    -- 檢測萬用查字模式是否剛關閉，如果是則釋放快取
    if last_wildcard_mode and not wildcard_mode then
        clear_opencc_cache()
    end
    last_wildcard_mode = wildcard_mode
    
    -- 快速路徑：未開啟萬用查字模式，直接通過
    if not wildcard_mode then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    -- 如果沒有使用萬用字元，直接通過
    if not (input_code and input_code:find("?", 1, true)) then
        for cand in input:iter() do yield(cand) end
        return
    end
    
    local opencc = get_opencc()
    
    for cand in input:iter() do
        if opencc then
            local codes_str = opencc:convert(cand.text)
            if codes_str and codes_str ~= cand.text then
                local codes = {}
                codes_str = codes_str:gsub("\\⟩", "\x01")
                for code in codes_str:gmatch("⟨([^⟩]+)⟩") do
                    codes[#codes + 1] = "⟨" .. code:gsub("\x01", "⟩") .. "⟩"
                end
                if #codes > 0 then
                    yield(cand:to_shadow_candidate(cand.type, cand.text, table.concat(codes, " ")))
                else
                    yield(cand)
                end
            else
                yield(cand)
            end
        else
            yield(cand)
        end
    end
end

return liu_wildcard_code_hint
