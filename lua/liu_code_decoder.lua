-- liu_code_decoder.lua
-- 編碼解碼器：將嘸蝦米編碼轉換回中文
-- 使用方式：,,x 進入解碼模式，貼上編碼（用-分隔，如 ix-v-yua-uo），按 Enter 上屏

-- Translator：處理解碼模式
local function translator(input, seg, env)
    if not seg:has_tag("code_decode") then return end
    
    -- 初始化 memory（用於查詢字典）
    if not env.mem then
        local ok, mem = pcall(function()
            return Memory(env.engine, env.engine.schema)
        end)
        if ok and mem then
            env.mem = mem
        end
    end
    
    -- 空輸入：顯示提示
    if input == "" then
        local cand = Candidate("decode_hint", seg.start, seg._end, "請貼上編碼（用-分隔，如：ix-v-yua-uo）", "")
        cand.preedit = "《解碼》"
        yield(cand)
        return
    end
    
    -- 將輸入正規化：轉小寫
    local normalized = input:lower()
    
    -- 用 - 分割編碼
    local codes = {}
    for code in normalized:gmatch("[^%-]+") do
        if code ~= "" then
            table.insert(codes, code)
        end
    end
    
    if #codes == 0 then
        local cand = Candidate("decode_hint", seg.start, seg._end, "請輸入有效的編碼", "")
        cand.preedit = "《解碼》" .. input
        yield(cand)
        return
    end
    
    -- 逐一查詢編碼
    local result_chars = {}
    local all_found = true
    
    for _, code in ipairs(codes) do
        local found = false
        
        -- 使用 Memory 查詢字典
        if env.mem then
            pcall(function()
                env.mem:dict_lookup(code, true, 1)
                for entry in env.mem:iter_dict() do
                    if entry and entry.text then
                        table.insert(result_chars, entry.text)
                        found = true
                        break  -- 只取第一個結果
                    end
                end
            end)
        end
        
        if not found then
            -- 查不到的編碼用方括號標記
            table.insert(result_chars, "[" .. code .. "]")
            all_found = false
        end
    end
    
    local result_text = table.concat(result_chars)
    local comment = all_found and "" or "（部分編碼無法識別）"
    
    -- 輸出結果
    local cand = Candidate("decoded", seg.start, seg._end, result_text, comment)
    cand.preedit = "《解碼》" .. input
    yield(cand)
    
    -- 如果有無法識別的編碼，也顯示原始輸入作為備選
    if not all_found then
        local cand2 = Candidate("original", seg.start, seg._end, input, "原始輸入")
        cand2.preedit = "《解碼》" .. input
        yield(cand2)
    end
end

return translator
