-- liu_user_predict.lua
-- 聯想學習：固有 predict.db 打底 + 個人記憶疊加
--
-- 三件套（借鏡萬象，但不取代 predict.db）：
--   P processor  ：predict.db 未命中時，推入「›」佔位輸入把聯想段落叫出來
--   T translator ：認出佔位輸入，吐出學過的詞
--   F filter     ：predict.db 命中時，把學過的詞排到固定詞前面
--
-- 只改 type=predict／prediction 的聯想列，不改蝦米編碼候選（aaa 仍為鑫、龘…）
--
-- 記錄規則：連續兩次「純漢字」上屏才學（1～4 字）
-- 斷開：標點、空格、換行、英文（含中英混輸）、逾時、切英文
--
-- 效能：打碼時零分配直通；學習檔延遲寫入，不上屏就整檔重寫
local M = {}

local TIMEOUT_MS = 2000
local MAX_COMMIT_LEN = 4
local MAX_USER_ITEMS = 15
local MAX_CANDIDATES = 24
local SAVE_INTERVAL_MS = 4000
local DB_FILENAME = "liu_user_predict.txt"

-- prev → { [word] = { count = n, ts = ms } }
local memory = {}
local loaded = false
local dirty = false
local last_save_time = 0
local last_commit = ""
local last_commit_time = 0
local config_loaded = false

local function now_ms()
    if rime_api and rime_api.get_time_ms then
        return rime_api.get_time_ms()
    end
    return os.time() * 1000
end

local function is_cjk(cp)
    return (cp >= 0x4E00 and cp <= 0x9FFF)
        or (cp >= 0x3400 and cp <= 0x4DBF)
        or (cp >= 0xF900 and cp <= 0xFAFF)
        or (cp >= 0x20000 and cp <= 0x2A6DF)
        or (cp >= 0x2A700 and cp <= 0x2B73F)
        or (cp >= 0x2B740 and cp <= 0x2B81F)
        or (cp >= 0x2B820 and cp <= 0x2CEAF)
        or (cp >= 0x2F800 and cp <= 0x2FA1F)
        or (cp >= 0x30000 and cp <= 0x323AF)
end

-- 純漢字（不含英文、數字、標點、空白）
local function is_pure_chinese(text)
    if not text or text == "" or not utf8 or not utf8.codes then
        return false
    end
    local n = 0
    for _, cp in utf8.codes(text) do
        n = n + 1
        if n > MAX_COMMIT_LEN or not is_cjk(cp) then
            return false
        end
    end
    return n >= 1
end

local function db_path()
    local dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
    if dir == "" then
        return nil
    end
    return dir .. "/" .. DB_FILENAME
end

local function load_memory()
    if loaded then
        return
    end
    loaded = true
    memory = {}
    local path = db_path()
    if not path then
        return
    end
    local f = io.open(path, "r")
    if not f then
        return
    end
    for line in f:lines() do
        local prev, word, count, ts = line:match("^([^\t]+)\t([^\t]+)\t(%d+)\t(%d+)")
        if prev and word then
            local bucket = memory[prev]
            if not bucket then
                bucket = {}
                memory[prev] = bucket
            end
            bucket[word] = { count = tonumber(count) or 1, ts = tonumber(ts) or 0 }
        end
    end
    f:close()
end

local function save_memory()
    if not dirty then
        return
    end
    local path = db_path()
    if not path then
        return
    end
    local f = io.open(path, "w")
    if not f then
        return
    end
    for prev, bucket in pairs(memory) do
        for word, info in pairs(bucket) do
            f:write(prev, "\t", word, "\t", info.count, "\t", info.ts, "\n")
        end
    end
    f:close()
    dirty = false
    last_save_time = now_ms()
end

local function maybe_save(force)
    if not dirty then
        return
    end
    if force then
        save_memory()
        return
    end
    local ts = now_ms()
    if last_save_time == 0 or (ts - last_save_time) >= SAVE_INTERVAL_MS then
        save_memory()
    end
end

-- ── 佔位輸入（借鏡萬象 user_predict）─────────────────────────────
-- predict.db 沒收錄上文時，C++ predictor 不會開聯想段落，filter 也就無從加工。
-- 這裡改由 processor 推入一段使用者打不出來的佔位輸入，讓 librime 跑正常的
-- 切分／翻譯流程，再由 translator 認出佔位輸入、吐出學過的詞。

local PH_CHAR = "›"
local PH_TAG = "user_predict"
local MAX_ROUNDS = 3
-- 讓編碼區「完全空白」的候選 preedit。
-- librime 的 Composition::GetPreedit 會把候選 preedit 裡的 \t 當成游標位置，
-- \t 之前是編碼區文字、之後是提示字串；只放一個 \t，兩邊都是空的。
-- 但它本身不是空字串，所以不會退回顯示原始輸入的佔位字元。
-- 結果與 predict.db 命中時的零長度段落一致：前端不會進入組字（底線）狀態。
local EMPTY_PREEDIT = "\t"

local ph_round = 0       -- 連續聯想第幾輪，同時決定佔位字元長度
local ph_input = ""      -- 目前預期的佔位輸入，用來偵測輸入被污染
local ph_pending = nil   -- 本輪要吐出的學習詞
local ph_need_push = false

local function ph_reset()
    ph_round = 0
    ph_input = ""
    ph_pending = nil
    ph_need_push = false
end

local function ph_active(ctx)
    local input = ctx.input
    return input ~= "" and input:find(PH_CHAR, 1, true) ~= nil
end

local function reset_chain()
    last_commit = ""
    last_commit_time = 0
    ph_reset()
end

local function bucket_size(bucket)
    local n = 0
    for _ in pairs(bucket) do
        n = n + 1
    end
    return n
end

local function prune_bucket(bucket)
    if bucket_size(bucket) <= MAX_USER_ITEMS then
        return
    end
    local items = {}
    for word, info in pairs(bucket) do
        items[#items + 1] = { word = word, ts = info.ts }
    end
    table.sort(items, function(a, b)
        return a.ts > b.ts
    end)
    for i = MAX_USER_ITEMS + 1, #items do
        bucket[items[i].word] = nil
    end
end

local function record_pair(prev, word, ts)
    local bucket = memory[prev]
    if not bucket then
        bucket = {}
        memory[prev] = bucket
    end
    local info = bucket[word]
    if info then
        info.count = info.count + 1
        info.ts = ts
    else
        bucket[word] = { count = 1, ts = ts }
        prune_bucket(bucket)
    end
    dirty = true
end

-- 分數：次數為主 + 近因略加分（剛用過最多 +2.5，無法一次翻盤）
-- 例：量×10 ≈ 10+；定剛打 1 次 ≈ 3.5 → 量仍在前
local RECENCY_BONUS = 2.5
local RECENCY_DECAY = 0.85

local function rank_score(info, now)
    local age_days = 0
    if info.ts and info.ts > 0 and now > info.ts then
        age_days = (now - info.ts) / 86400000.0
    end
    return (info.count or 1) + RECENCY_BONUS * (RECENCY_DECAY ^ age_days)
end

local function user_words_for(prev)
    local bucket = memory[prev]
    if not bucket then
        return nil
    end
    local now = now_ms()
    local items = {}
    for word, info in pairs(bucket) do
        items[#items + 1] = {
            word = word,
            count = info.count,
            ts = info.ts,
            score = rank_score(info, now),
        }
    end
    table.sort(items, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.count ~= b.count then
            return a.count > b.count
        end
        return a.ts > b.ts
    end)
    return items
end

-- 打太快時 commit_notifier 可能晚到，get_commit_text() 已空；改從歷史補。
-- 空通知不可當「非漢字」清掉上文，否則「有時候」會漏記 有→時。
local function get_committed_text(ctx)
    local text = ctx:get_commit_text()
    if text and text ~= "" then
        return text, false
    end
    local ok, hist = pcall(function()
        return ctx.commit_history and ctx.commit_history:back()
    end)
    if ok and hist and hist ~= "" then
        return hist, true
    end
    return nil, false
end

local function on_commit(ctx)
    local text, from_history = get_committed_text(ctx)
    local ts = now_ms()

    -- 空通知：忽略，保留上文
    if not text or text == "" then
        return
    end

    -- 遲到的空通知補到歷史時，常是「剛記過的同一個字」，不要重記成疊字
    if from_history and text == last_commit then
        return
    end

    if last_commit ~= "" and last_commit_time > 0 and (ts - last_commit_time) > TIMEOUT_MS then
        reset_chain()
    end

    if not is_pure_chinese(text) then
        reset_chain()
        maybe_save(false)
        return
    end

    -- 允許疊字（看→看＝看看）；萬象防折返不適用一字一上屏的嘸蝦米
    if last_commit ~= "" then
        record_pair(last_commit, text, ts)
    end

    last_commit = text
    last_commit_time = ts
    ph_need_push = true
    maybe_save(false)
end

-- 連線管理有兩個互相衝突的要求：
--   一、同一份模組會同時掛成 processor／translator／filter，各有獨立的 env，
--       若每個 env 都連一次，一次上屏會被記成三次。
--   二、Lua 模組狀態在整個行程裡持續存在，但切換方案會建立新的 Context；
--       若只在第一次連線就不再處理，切過方案後就會一直連在死掉的舊 Context 上，
--       從此什麼都學不到。
-- 解法：每次元件初始化都「重綁」，全程只保留一條連線，且一定指向當前 Context。
local commit_conn = nil
local bind_gen = 0

local function ensure_init(env)
    if config_loaded then
        return
    end
    config_loaded = true
    load_memory()
    local config = env.engine.schema.config
    if config then
        TIMEOUT_MS = config:get_int("user_predict/timeout_ms") or TIMEOUT_MS
        MAX_COMMIT_LEN = config:get_int("user_predict/max_commit_len") or MAX_COMMIT_LEN
        MAX_USER_ITEMS = config:get_int("user_predict/max_user_items") or MAX_USER_ITEMS
        MAX_CANDIDATES = config:get_int("predictor/max_candidates") or MAX_CANDIDATES
        MAX_ROUNDS = config:get_int("user_predict/max_rounds") or MAX_ROUNDS
    end
end

local function bind_commit(env)
    ensure_init(env)
    if commit_conn then
        commit_conn:disconnect()
        commit_conn = nil
    end
    bind_gen = bind_gen + 1
    env.bind_gen = bind_gen
    commit_conn = env.engine.context.commit_notifier:connect(on_commit)
    reset_chain()
end

-- 打字途中的保險：只有在完全沒有連線時才補綁，不會每按一鍵就重綁
local function ensure_commit_hook(env)
    ensure_init(env)
    if not commit_conn then
        bind_commit(env)
    end
end

function M.init(env)
    bind_commit(env)
end

-- 清除全部聯想學習（,,clean + 空白）
function M.clear()
    memory = {}
    dirty = false
    loaded = true
    reset_chain()
    local path = db_path()
    if path then
        os.remove(path)
    end
end
function M.fini(env)
    maybe_save(true)
    -- 切換方案時，舊引擎的 fini 有可能晚於新引擎的 init 才跑；
    -- 只有當這條連線確實是自己綁的（世代相符）才拆，否則會把新連線拆掉。
    if commit_conn and env.bind_gen == bind_gen then
        commit_conn:disconnect()
        commit_conn = nil
    end
end

function M.func(input, env)
    ensure_commit_hook(env)
    local ctx = env.engine.context
    local composing = ctx.input

    -- 打碼中：零分配直通，不碰聯想合併
    if composing and composing ~= "" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    if not ctx:get_option("prediction") or last_commit == "" then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local predict_cands = {}
    local other_cands = {}
    local start_pos, end_pos = 0, 0
    local saw_predict = false

    for cand in input:iter() do
        local ctype = cand.type
        if ctype == "predict" or ctype == "prediction" then
            saw_predict = true
            if #predict_cands == 0 then
                start_pos = cand.start
                end_pos = cand._end
            end
            predict_cands[#predict_cands + 1] = cand
        else
            other_cands[#other_cands + 1] = cand
        end
    end

    if not saw_predict then
        for i = 1, #other_cands do
            yield(other_cands[i])
        end
        return
    end

    local learned = user_words_for(last_commit)
    if not learned or #learned == 0 then
        for i = 1, #predict_cands do
            yield(predict_cands[i])
        end
        for i = 1, #other_cands do
            yield(other_cands[i])
        end
        return
    end

    local seen = {}
    local merged = {}
    local default_by_text = {}
    for i = 1, #predict_cands do
        default_by_text[predict_cands[i].text] = predict_cands[i]
    end

    local function add_word(word, src_cand)
        if not word or word == "" or seen[word] then
            return
        end
        seen[word] = true
        if src_cand then
            merged[#merged + 1] = src_cand
        else
            merged[#merged + 1] = Candidate("predict", start_pos, end_pos, word, "")
        end
    end

    for i = 1, #learned do
        local word = learned[i].word
        add_word(word, default_by_text[word])
    end
    for i = 1, #predict_cands do
        add_word(predict_cands[i].text, predict_cands[i])
    end

    local limit = MAX_CANDIDATES
    if limit <= 0 then
        limit = #merged
    elseif limit > #merged then
        limit = #merged
    end
    for i = 1, limit do
        yield(merged[i])
    end
    for i = 1, #other_cands do
        yield(other_cands[i])
    end
end

-- ── P：聯想 processor（注入佔位輸入）─────────────────────────────
-- 掛載位置必須在 predictor 之後、speller 之前：
--   在 predictor 之後 → update_notifier 的回呼順序才會是 C++ 先跑，
--     命中 predict.db 時它已建好零長度聯想段落，我們就不重複注入。
--   在 speller 之前   → 佔位輸入還沒被下一個按鍵接上去之前先清場。
local P = {}

local ph_updating = false

local function on_update(ctx)
    if ph_updating then
        return
    end
    ph_updating = true

    local input = ctx.input

    if ph_need_push and input == "" then
        ph_need_push = false
        -- composition 非空代表 predict.db 命中、C++ 已開段落，交給 filter 合併
        local comp = ctx.composition
        local db_hit = comp and not comp:empty()
        local learned = nil
        if not db_hit
            and ctx:get_option("prediction")
            and last_commit ~= ""
            and ph_round < MAX_ROUNDS then
            learned = user_words_for(last_commit)
            if learned and #learned > 0 then
                ph_round = ph_round + 1
                ph_pending = learned
                ph_input = string.rep(PH_CHAR, ph_round)
                ctx:push_input(ph_input)
                ctx.caret_pos = #ph_input
            end
        end
    elseif input ~= "" and input:find(PH_CHAR, 1, true) and input ~= ph_input then
        -- 佔位輸入被別的按鍵接上了（P.func 沒攔到的漏網之魚），清乾淨重來
        local clean = input:gsub(PH_CHAR, "")
        ph_reset()
        ctx:clear()
        if clean ~= "" then
            ctx:push_input(clean)
        end
    end

    ph_updating = false
end

function P.init(env)
    bind_commit(env)
    if env.update_connection then
        env.update_connection:disconnect()
    end
    env.update_connection = env.engine.context.update_notifier:connect(on_update)
end

function P.fini(env)
    if env.update_connection then
        env.update_connection:disconnect()
        env.update_connection = nil
    end
    ph_reset()
end

local XK_BACKSPACE = 0xff08
local XK_RETURN = 0xff0d
local XK_ESCAPE = 0xff1b

function P.func(key, env)
    local ctx = env.engine.context
    if not ph_active(ctx) or key:release() then
        return 2
    end
    if key:ctrl() or key:alt() then
        return 2
    end

    local code = key.keycode
    if code == XK_ESCAPE or code == XK_BACKSPACE then
        ph_reset()
        ctx:clear()
        return 1
    end
    if code == XK_RETURN then
        -- TODO：佔位聯想狀態下按 Enter，現行做法會先清掉佔位段落再把 Enter
        -- 放行給應用程式，因此桌面端可能輸入換行；依需求先保留現況，
        -- 日後需決定 Enter 應上屏候選、送出原字或只關閉聯想。
        ph_reset()
        ctx:clear()
        return 2
    end
    -- 數字（選字）、空白（選首選）、方向鍵與翻頁鍵原樣放行；
    -- 其餘可見字元代表使用者要開始打新的一碼，先清掉佔位輸入再交給 speller。
    if code > 0x20 and code < 0x7f and not (code >= 0x30 and code <= 0x39) then
        ph_reset()
        ctx:clear()
        return 2
    end
    return 2
end

-- ── T：聯想 translator（把學過的詞吐進佔位段落）──────────────────
local T = {}

function T.init(env)
    bind_commit(env)
end

function T.fini(env) end

function T.func(input, seg, env)
    if not seg:has_tag(PH_TAG) then
        return
    end
    if not ph_pending or #ph_pending == 0 then
        return
    end
    if not env.engine.context:get_option("prediction") then
        return
    end
    local limit = MAX_CANDIDATES
    if limit <= 0 or limit > #ph_pending then
        limit = #ph_pending
    end
    for i = 1, limit do
        local cand = Candidate("predict", seg.start, seg._end, ph_pending[i].word, "")
        cand.preedit = EMPTY_PREEDIT
        yield(cand)
    end
end

M.P = P
M.T = T

return M
