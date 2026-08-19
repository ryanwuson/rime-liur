-- liu_pinyin_enter_processor.lua
-- 點按 Enter = 羅馬拼音／英文上屏（去聲調數字，維持原行為）
-- Shift+Return = 帶音標拼音文（有打 1–5 才標調，不自動補一聲）

local common = require("liu_pinyin_common")

local function should_pass_return_for_newline(context)
    if (context.input or "") ~= "" then
        return false
    end
    if context:has_menu() then
        return false
    end
    return true
end

local function commit_ascii_pinyin(engine, context)
    local code = context.input or ""
    if code == "" then
        return false
    end
    -- 擴充模式（``）交給預設流程
    if code:sub(1, 1) == "`" then
        return false
    end
    local text = common.strip_tone_digits(code)
    if text ~= "" then
        engine:commit_text(text)
    end
    context:clear()
    return true
end

local function commit_toned_pinyin(engine, context)
    local code = context.input or ""
    if code == "" then
        return false
    end
    if code:sub(1, 1) == "`" or code:sub(1, 2) == ",," then
        return false
    end
    -- 帶音標；自動／手動分節都變空白（不輸出 ⁞）
    local text = common.keys_to_pinyin_commit(code)
    if text ~= "" then
        engine:commit_text(text)
    end
    context:clear()
    return true
end

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_pinyin" then
        return 2
    end

    if key:release() then
        return 2
    end

    local repr = key:repr()
    local engine = env.engine
    local context = engine.context

    -- Shift+Enter → 帶音標拼音（有輸入才攔截；空輸入放行給 App）
    if repr == "Shift+Return" or repr == "Shift+KP_Enter" then
        if commit_toned_pinyin(engine, context) then
            return 1
        end
        return 2
    end

    -- 點按 Enter → 羅馬拼音／英文上屏（原行為）
    if repr == "Return" or repr == "KP_Enter" then
        if should_pass_return_for_newline(context) then
            if context:is_composing() then
                context:clear()
            end
            return 2
        end
        if commit_ascii_pinyin(engine, context) then
            return 1
        end
        return 2
    end

    return 2
end

return processor
