-- liu_emoji_filter.lua
-- 隨附 Emoji：萬象格式詞表 + append 獨立候選（不改寫原文）
-- 規格：liu_emoji-隨附Emoji-spec.md
-- 適用：liu_bpmf／liu_pinyin；liur 僅行內注音（phonetic）／行內拼音（pinyin）

local M_OPTION = "emoji"

-- liur 主力嘸蝦米不加；只在行內音碼段生效
local INLINE_ONLY_SCHEMAS = {
    liur = true,
}

local SKIP_TYPES = {
    emoji = true,
    letter_variant = true,
    datetime = true,
    datetime_menu = true,
    extended_menu = true,
    symbols_hint = true,
    punct = true,
}

local function resolve_emoji_path()
    local candidates = {
        "lua/data/emoji.txt",
        "lua/emoji.txt", -- 相容舊佈局
    }
    local user_dir = rime_api.get_user_data_dir()
    local shared_dir = rime_api.get_shared_data_dir()
    for _, rel in ipairs(candidates) do
        local user_path = user_dir .. "/" .. rel
        local f = io.open(user_path, "r")
        if f then
            f:close()
            return user_path
        end
        local shared_path = shared_dir .. "/" .. rel
        f = io.open(shared_path, "r")
        if f then
            f:close()
            return shared_path
        end
    end
    return user_dir .. "/" .. candidates[1]
end

local function load_emoji_map(path)
    local map = {}
    local f = io.open(path, "r")
    if not f then
        return map
    end
    for line in f:lines() do
        if line ~= "" and not line:match("^%s*#") then
            local key = nil
            local values = {}
            local first = true
            for field in line:gmatch("[^\t]+") do
                if first then
                    key = field
                    first = false
                else
                    values[#values + 1] = field
                end
            end
            if key and #values > 0 then
                -- 同鍵多行：合併並去重（保序）
                local existing = map[key]
                if not existing then
                    map[key] = values
                else
                    local seen = {}
                    for _, v in ipairs(existing) do
                        seen[v] = true
                    end
                    for _, v in ipairs(values) do
                        if not seen[v] then
                            existing[#existing + 1] = v
                            seen[v] = true
                        end
                    end
                end
            end
        end
    end
    f:close()
    return map
end

local function get_opencc_t2s()
    local ok, conv = pcall(Opencc, "t2s.json")
    if ok and conv then
        return conv
    end
    return nil
end

-- 重資料延遲到真正進入 Emoji 路徑才初始化：
-- liur 平常打蝦米時不讀 emoji.txt；即使進入音碼路徑，也只有繁體鍵查不到時
-- 才建立 Opencc("t2s.json") 做簡體 fallback。
local function ensure_emoji_map(env)
    if env.emoji_map_loaded then
        return
    end
    env.emoji_map_loaded = true
    env.emoji_map = load_emoji_map(resolve_emoji_path())
end

local function ensure_opencc_t2s(env)
    if env.opencc_t2s_loaded then
        return
    end
    env.opencc_t2s_loaded = true
    env.opencc_t2s = get_opencc_t2s()
end

local function lookup(env, text)
    if not text or text == "" then
        return nil
    end
    ensure_emoji_map(env)
    local map = env.emoji_map
    local hit = map[text]
    if hit then
        return hit
    end
    ensure_opencc_t2s(env)
    local opencc = env.opencc_t2s
    if opencc then
        local ok, simp = pcall(function()
            return opencc:convert(text)
        end)
        if ok and simp and simp ~= "" and simp ~= text then
            hit = map[simp]
            if hit then
                return hit
            end
        end
    end
    return nil
end

-- liur：僅當目前段落帶 phonetic／pinyin tag（'; 或 ;'）
local function inline_segment_active(env)
    local ok, result = pcall(function()
        local composition = env.engine.context.composition
        if not composition or composition:empty() then
            return false
        end
        local seg = composition:back()
        if not seg then
            return false
        end
        return seg:has_tag("phonetic") or seg:has_tag("pinyin")
    end)
    return ok and result
end

local function filter(input, env)
    -- 表情固定啟用（已移除 emoji 開關，避免切換方案時跳通知）；
    -- 仍只在行內音碼段／注音拼音方案生效，嘸蝦米平常打字不受影響
    local schema_id = env.engine.schema.schema_id
    if INLINE_ONLY_SCHEMAS[schema_id] and not inline_segment_active(env) then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    -- 符號清單／擴充／變體：不要在符號候選後再掛 Emoji
    local composing = env.engine.context.input or ""
    if composing:sub(1, 1) == "`" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    for cand in input:iter() do
        yield(cand)
        if not SKIP_TYPES[cand.type] then
            local emojis = lookup(env, cand.text)
            if emojis then
                local seen = { [cand.text] = true }
                for _, emoji in ipairs(emojis) do
                    if emoji ~= "" and not seen[emoji] then
                        seen[emoji] = true
                        local ec = Candidate("emoji", cand.start, cand._end, emoji, "")
                        ec.preedit = cand.preedit
                        yield(ec)
                    end
                end
            end
        end
    end
end

local function init(env)
    env.emoji_map = nil
    env.emoji_map_loaded = false
    env.opencc_t2s = nil
    env.opencc_t2s_loaded = false
end

return { init = init, func = filter }
