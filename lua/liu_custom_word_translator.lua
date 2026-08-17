-- liu_custom_word_translator.lua
-- 自定詞翻譯器：讀取 openxiami_CustomWord.dict.yaml 並產生候選
-- 使用 Trie 資料結構實現高效前綴匹配，支援自動補全
-- type="custom" = 完整匹配，type="custom_completion" = 補全候選

-- Trie 資料結構
local trie = nil
local exact_matches = nil  -- 精確匹配表（保留原有功能）

-- 設定
local MIN_COMPLETION_LEN = 3  -- 最少輸入長度才觸發補全
local MAX_COMPLETION_RESULTS = 10  -- 最多補全候選數量

-- 建立 Trie 節點
local function new_node()
    return { children = {}, words = nil }
end

-- 插入編碼到 Trie
local function trie_insert(root, code, word)
    local node = root
    local code_lower = code:lower()
    
    for i = 1, #code_lower do
        local char = code_lower:sub(i, i)
        if not node.children[char] then
            node.children[char] = new_node()
        end
        node = node.children[char]
    end
    
    -- 在葉節點儲存詞條
    if not node.words then
        node.words = {}
    end
    node.words[#node.words + 1] = { text = word, code = code_lower }
end

-- 在 Trie 中查找前綴對應的節點
local function trie_find_node(root, prefix)
    local node = root
    local prefix_lower = prefix:lower()
    
    for i = 1, #prefix_lower do
        local char = prefix_lower:sub(i, i)
        if not node.children[char] then
            return nil
        end
        node = node.children[char]
    end
    
    return node
end

-- 收集節點下所有詞條（用於補全）
local function collect_words(node, results, max_count, input_len)
    if #results >= max_count then return end
    
    -- 收集當前節點的詞條
    if node.words then
        for _, item in ipairs(node.words) do
            if #results >= max_count then return end
            -- 只收集比輸入長的編碼（補全候選）
            if #item.code > input_len then
                results[#results + 1] = item
            end
        end
    end
    
    -- 遞迴收集子節點
    for _, child in pairs(node.children) do
        if #results >= max_count then return end
        collect_words(child, results, max_count, input_len)
    end
end

-- 載入字典並建立 Trie
local function load_custom_words()
    if trie then return trie, exact_matches end
    
    trie = new_node()
    exact_matches = {}
    
    local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
    local shared_dir = rime_api and rime_api.get_shared_data_dir and rime_api.get_shared_data_dir() or ""
    
    local paths = {}
    if user_dir ~= "" then paths[#paths + 1] = user_dir .. "/openxiami_CustomWord.dict.yaml" end
    if shared_dir ~= "" then paths[#paths + 1] = shared_dir .. "/openxiami_CustomWord.dict.yaml" end
    
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local in_data = false
            for raw_line in file:lines() do
                -- 移除 Windows 換行符 \r
                local line = raw_line:gsub("\r$", "")
                if line == "..." then
                    in_data = true
                elseif in_data and #line > 0 and line:byte(1) ~= 35 then  -- 35 = '#'
                    -- 支援兩欄或三欄格式（字詞 TAB 編碼 [TAB 權重]）
                    local word, code = line:match("^([^\t]+)\t([^\t]+)")
                    if word and code then
                        local code_lower = code:lower()
                        
                        -- 插入 Trie（用於補全）
                        trie_insert(trie, code_lower, word)
                        
                        -- 插入精確匹配表
                        local list = exact_matches[code_lower]
                        if not list then
                            list = {}
                            exact_matches[code_lower] = list
                        end
                        list[#list + 1] = word
                    end
                end
            end
            file:close()
            break
        end
    end
    
    return trie, exact_matches
end

-- 取得下一碼提示（只顯示一個字元）
local function get_next_char_hint(full_code, input_len)
    if #full_code > input_len then
        local next_char = full_code:sub(input_len + 1, input_len + 1)
        return "▸⟨" .. next_char .. "⟩"
    end
    return ""
end

local function translator(input, seg, env)
    if seg:has_tag("abc") or seg:has_tag("mkst") then
        local root, matches = load_custom_words()
        local input_lower = input:lower()
        local input_len = #input_lower
        local start, _end = seg.start, seg._end
        
        -- 1. 精確匹配（完整輸入）
        local exact_list = matches[input_lower]
        if exact_list then
            for i = 1, #exact_list do
                local cand = Candidate("custom", start, _end, exact_list[i], "")
                cand.quality = 999
                yield(cand)
            end
        end
        
        -- 2. 前綴匹配（補全候選）- 只在輸入長度 >= MIN_COMPLETION_LEN 時觸發
        if input_len >= MIN_COMPLETION_LEN then
            local node = trie_find_node(root, input_lower)
            if node then
                local completions = {}
                collect_words(node, completions, MAX_COMPLETION_RESULTS, input_len)
                
                for _, item in ipairs(completions) do
                    local hint = get_next_char_hint(item.code, input_len)
                    local cand = Candidate("custom_completion", start, _end, item.text, hint)
                    cand.quality = 500  -- 補全候選優先級較低
                    yield(cand)
                end
            end
        end
    end
end

return translator
