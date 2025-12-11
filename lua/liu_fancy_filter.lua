-- liu_fancy_filter.lua
-- 變體英數模式的 filter：設置 preedit

-- preedit 配置
-- prefix: 引導鍵前綴
-- name: 模式名稱
-- start: 內容開始位置（prefix 長度 + 1）
local preedit_config = {
  number = {prefix = "`/'", name = "《變體數字》", start = 4},
  upper = {prefix = "`///", name = "《變體AA》", start = 5},
  lower = {prefix = "`//", name = "《變體aa》", start = 4},
  title = {prefix = "`/", name = "《變體Aa》", start = 3}
}

local function filter(input, env)
  local context = env.engine.context
  local input_text = context.input
  
  -- 只在花式模式下處理（以 `/ 開頭）
  if not (input_text and input_text:sub(1, 2) == "`/") then
    for cand in input:iter() do
      yield(cand)
    end
    return
  end
  
  -- 判斷模式（順序重要：長的 prefix 要先匹配）
  local mode
  if input_text:sub(1, 3) == "`/'" then
    mode = "number"
  elseif input_text:sub(1, 4) == "`///" then
    mode = "upper"
  elseif input_text:sub(1, 3) == "`//" then
    mode = "lower"
  else
    mode = "title"
  end
  
  local config = preedit_config[mode]
  local content = input_text:sub(config.start)
  -- 移除結尾的 `（誤按）
  content = content:gsub("`+$", "")
  
  -- preedit 格式：
  -- 無內容時：不設置 preedit，讓 yaml 的 tips 顯示
  -- 有內容時：《變體Aa》abc
  
  for cand in input:iter() do
    if content == "" then
      -- 無內容時不設置 preedit，讓 yaml 的 tips 顯示
      yield(cand)
    else
      local preedit = config.name .. content:gsub("%.", " ")
      local new_cand = Candidate(cand.type, cand.start, cand._end, cand.text, cand.comment or "")
      new_cand.preedit = preedit
      new_cand.quality = cand.quality
      yield(new_cand)
    end
  end
end

return filter
