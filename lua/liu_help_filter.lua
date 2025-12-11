-- liu_help_filter.lua
-- 按鍵說明 filter：確保說明候選項不被反查和簡體轉換影響

-- 從 liu_help.lua 取得說明項目
local liu_help = require("liu_help")
local help_items = liu_help.help_items

local function filter(input, env)
  local context = env.engine.context
  local input_text = context.input
  
  -- 只在按鍵說明模式下處理
  if input_text ~= ",,h" then
    for cand in input:iter() do yield(cand) end
    return
  end
  
  -- 丟棄所有被破壞的候選項，重新生成乾淨的候選項
  local generated = false
  for cand in input:iter() do
    if not generated then
      for _, item in ipairs(help_items) do
        yield(Candidate("help", cand.start, cand._end, item, ""))
      end
      generated = true
    end
    -- 丟棄原始候選項
  end
  
  -- 如果沒有任何候選項，也要生成
  if not generated then
    for _, item in ipairs(help_items) do
      yield(Candidate("help", 0, 3, item, ""))
    end
  end
end

return filter
