-- liu_bpmf_tone_processor.lua
-- 可選：grave/` → 併入 ~（相容舊一聲碼；主路徑已改空白＝一聲）
-- 聲調鍵 3/4/6/7 雙態由皮膚 preeditChanged 處理（空閒直出／組字送碼）

local function processor(key, env)
    if env.engine.schema.schema_id ~= "liu_bpmf" then
        return 2
    end

    if key:release() then
        return 2
    end

    if key:repr() ~= "grave" then
        return 2
    end

    local context = env.engine.context
    local input = context.input or ""
    -- 符號清單／擴充模式中，` 不再當一聲備援
    if input:sub(1, 1) == "`" then
        return 2
    end
    if input == "" then
        return 2
    end

    -- 空白已是一聲；` 仍可作備援（顯示依 preedit／common 轉 ˉ）
    context:push_input("~")
    if context.refresh_non_confirmed_composition then
        context:refresh_non_confirmed_composition()
    end
    return 1
end

return processor
