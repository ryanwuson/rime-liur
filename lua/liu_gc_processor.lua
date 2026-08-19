-- liu_gc_processor.lua
-- 記憶體管理與垃圾回收處理器
-- 13／14 共用同一支；閾值與「上屏是否釋放 w2c」由 schema 的 gc: 決定
--   手機（預設）：15MB／30MB；桌面：100MB／150MB
--   兩端上屏都不清表，避免下一碼重讀；只有週期檢查超過門檻才釋放資料。

local liu_data = require("liu_data")

local key_count = 0

local function cfg_int(cfg, key, default)
    local v = cfg:get_int(key)
    if v == nil then return default end
    return v
end

-- YAML bool 用字串讀較穩（未設定時 get_bool 在部分 librime 會變成 false）
local function cfg_bool(cfg, key, default)
    local s = cfg:get_string(key)
    if s == nil or s == "" then
        return default
    end
    s = string.lower(s)
    if s == "false" or s == "0" or s == "no" then
        return false
    end
    if s == "true" or s == "1" or s == "yes" then
        return true
    end
    return default
end

local function load_gc_config(env)
    if env.gc_loaded then return end
    env.gc_loaded = true
    local cfg = env.engine.schema.config
    env.gc_check_interval = cfg_int(cfg, "gc/check_interval", 20)
    env.gc_memory_threshold = cfg_int(cfg, "gc/memory_threshold_kb", 15 * 1024)
    env.gc_aggressive_threshold = cfg_int(cfg, "gc/aggressive_threshold_kb", 30 * 1024)
    env.gc_free_on_commit = cfg_bool(cfg, "gc/free_on_commit", false)
end

local function cleanup_memory(env, force)
    local mem_usage = collectgarbage("count")
    local threshold = env.gc_memory_threshold or (15 * 1024)

    if force or mem_usage > threshold then
        liu_data.free_data(force)
        collectgarbage("collect")
    else
        collectgarbage("step")
    end
end

local function init(env)
    load_gc_config(env)
    local context = env.engine.context
    if not env.commit_connection then
        env.commit_connection = context.commit_notifier:connect(function(ctx)
            if env.gc_free_on_commit then
                cleanup_memory(env, true)
            else
                collectgarbage("step")
            end
        end)
    end
end

local function fini(env)
    if env.commit_connection then
        env.commit_connection:disconnect()
        env.commit_connection = nil
    end
end

local function processor(key, env)
    load_gc_config(env)

    local interval = env.gc_check_interval or 20
    local memory_threshold = env.gc_memory_threshold or (15 * 1024)
    local aggressive_gc_threshold = env.gc_aggressive_threshold or (30 * 1024)

    key_count = key_count + 1
    if key_count >= interval then
        key_count = 0
        local mem_usage = collectgarbage("count")

        if mem_usage > aggressive_gc_threshold then
            liu_data.free_data(false)
            collectgarbage("collect")
        elseif mem_usage > memory_threshold then
            liu_data.free_data(false)
            collectgarbage("step", 100)
        else
            collectgarbage("step")
        end
    end

    return 2 -- kNoop
end

return { init = init, func = processor, fini = fini }
