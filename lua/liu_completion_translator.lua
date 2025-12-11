-- liu_completion_translator.lua
-- 排序過濾器：將日文假名和擴充漢字排到候選列表後面
-- 排序順序：一般漢字 > 日文假名 > 擴充漢字

local common = require("liu_common")
local is_kana = common.is_kana
local is_extended_charset = common.is_extended_charset

-- 檢查候選字的類型：0=一般, 1=假名, 2=擴充
local function get_char_type(text)
    for _, code in utf8.codes(text) do
        if is_extended_charset(code) then
            return 2  -- 擴充漢字優先級最低
        end
        if is_kana(code) then
            return 1  -- 假名次之
        end
    end
    return 0  -- 一般漢字優先
end

local function filter(input, env)
    local context = env.engine.context
    local input_code = context.input or ""
    
    -- 造詞模式下不重新排序，保持原始順序
    -- 檢測方式：1. 輸入以 ; 開頭（但不是 ;; 讀音查詢）
    --          2. 或者 segment 有 mkst tag
    local is_mkst = false
    if input_code:match("^;[^;]") then
        is_mkst = true
    else
        local seg = context.composition:back()
        if seg and seg:has_tag("mkst") then
            is_mkst = true
        end
    end
    
    if is_mkst then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    
    local kana_cands = {}
    local ext_cands = {}
    local show_extended = context:get_option("extended_charset")
    
    for cand in input:iter() do
        local char_type = get_char_type(cand.text)
        
        if char_type == 0 then
            -- 一般漢字：直接輸出
            yield(cand)
        elseif char_type == 1 then
            -- 假名：緩存
            table.insert(kana_cands, cand)
        else
            -- 擴充漢字：只在開啟擴充字集時緩存
            if show_extended then
                table.insert(ext_cands, cand)
            end
        end
    end
    
    -- 輸出假名
    for _, cand in ipairs(kana_cands) do
        yield(cand)
    end
    
    -- 輸出擴充漢字
    for _, cand in ipairs(ext_cands) do
        yield(cand)
    end
end

return filter
