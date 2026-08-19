local function processor(key, env)
    if key:repr() == "Control+equal" then
        local context = env.engine.context
        -- 先清殘碼，避免上次失敗的 Control+equal 留下「=」等，導致無法再進計算機
        context:clear()
        local schema_id = env.engine.schema.schema_id
        if schema_id == "easy_en" then
            context:push_input("cal=")
        else
            -- 蝦米／拼音／注音：Ctrl+= → ,,=
            context:push_input(",,=")
        end
        return 1 -- kAccepted
    end
    return 2 -- kNoop
end

return { init = function() end, func = processor }
