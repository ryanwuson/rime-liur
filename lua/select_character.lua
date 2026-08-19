-- 以词定字（雾凇拼音 / rime-ice）
-- 原脚本 https://github.com/BlindingDark/rime-lua-select-character

local select = {}

function select.init(env)
    local config = env.engine.schema.config
    env.first_key = config:get_string('key_binder/select_first_character')
    env.last_key = config:get_string('key_binder/select_last_character')
end

function select.func(key, env)
    local engine = env.engine
    local context = env.engine.context

    if
        not key:release()
        and (context:is_composing() or context:has_menu())
        and (env.first_key or env.last_key)
    then
        local input = context.input
        local selected_candidate = context:get_selected_candidate()
        selected_candidate = selected_candidate and selected_candidate.text or input

        local selected_char
        if (key:repr() == env.first_key) then
            selected_char = selected_candidate:sub(1, utf8.offset(selected_candidate, 2) - 1)
        elseif (key:repr() == env.last_key) then
            selected_char = selected_candidate:sub(utf8.offset(selected_candidate, -1))
        else
            return 2
        end

        local commit_text = context:get_commit_text()
        local _, end_pos = commit_text:find(selected_candidate)
        local caret_pos = context.caret_pos

        local part1 = commit_text:sub(1, end_pos):gsub(selected_candidate, selected_char)
        local part2 = commit_text:sub(end_pos + 1)

        engine:commit_text(part1)
        context:clear()
        if caret_pos ~= #input then
            part2 = part2 .. input:sub(caret_pos + 1)
        end
        if part2 ~= "" then
            context:push_input(part2)
        end
        return 1
    end
    return 2
end

return select
