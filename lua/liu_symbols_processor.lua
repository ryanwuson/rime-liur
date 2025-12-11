-- liu_symbols_processor.lua
-- 符號表清單層禁用 Ctrl+' 反查功能

local function processor(key, env)
  -- 只在清單層（輸入正好是 `）時禁用 Ctrl+'
  if env.engine.context.input == "`" and key:repr() == "Control+apostrophe" then
    return 1
  end
  return 2
end

return processor
