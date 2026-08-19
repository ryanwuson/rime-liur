-- liu_bpmf_enter_processor.lua
-- 點按 Enter = 中文上屏（放行 express_editor confirm）
-- Shift+Return = 注音文直出
--   規則：只轉成已打的碼；空白鍵一聲→ˉ；未打的聲調不補

local common = require("liu_bpmf_common")

local function should_pass_return_for_newline(context)
    if (context.input or "") ~= "" then
        return false
    end
    if context:has_menu() then
        return false
    end
    return true
end

local function commit_zhuyin_text(engine, context)
    local code = context.input or ""
    if code == "" then
        return false
    end
    -- 符號清單／擴充／計算機交給預設流程
    if code:sub(1, 1) == "`" or code:sub(1, 2) == ",," then
        return false
    end
    -- 直出已打內容；自動／手動分節都變空白（不輸出 ･）
    local text = common.keys_to_bpmf_commit(code)
    if text ~= "" then
        engine:commit_text(text)
    end
    context:clear()
    return true
end

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_bpmf" then
        return 2
    end

    if key:release() then
        return 2
    end

    local repr = key:repr()
    local engine = env.engine
    local context = engine.context

    -- 注音文：Shift+Enter（有輸入才攔截；空輸入放行給 App）
    if repr == "Shift+Return" or repr == "Shift+KP_Enter" then
        if commit_zhuyin_text(engine, context) then
            return 1
        end
        return 2
    end

    -- 普通 Enter → 放行 confirm（中文上屏）；空閒則換行
    if repr == "Return" or repr == "KP_Enter" then
        if should_pass_return_for_newline(context) then
            if context:is_composing() then
                context:clear()
            end
            return 2
        end
        return 2
    end

    return 2
end

return processor
