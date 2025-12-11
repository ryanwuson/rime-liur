-- liu_extended_filter.lua
-- 擴充模式 filter：處理擴充模式候選項
-- 參考 liu_symbols_hint_filter 的做法：
-- 1. 反查模式下：直接傳遞候選項（由 liu_remove_trad_in_w2c 處理）
-- 2. 正常模式下：清理 comment（移除 ~ 和繁體標記）
-- 3. 恢復被 simplifier 破壞的選單文字

-- 從共用模組取得選單資料
local extended_data = require("liu_extended_data")
local EXTENDED_MENU = extended_data.EXTENDED_MENU
local DATETIME_MENU = extended_data.DATETIME_MENU

-- 生成擴充模式選單
local function yield_extended_menu(start_pos, end_pos)
  for _, item in ipairs(EXTENDED_MENU) do
    local cand = Candidate("extended_menu", start_pos, end_pos, item[1], item[2])
    cand.preedit = "``▸"
    yield(cand)
  end
end

-- 生成日期時間選單
local function yield_datetime_menu(start_pos, end_pos)
  for _, hint in ipairs(DATETIME_MENU) do
    local cand = Candidate("datetime_menu", start_pos, end_pos, hint, "")
    cand.preedit = "《日期時間》▸"
    yield(cand)
  end
end

-- 檢測是否為被破壞的擴充模式選單
local function is_corrupted_extended_menu(text)
  return text:find("小写变化", 1, true) or text:find("大写变化", 1, true) or 
         text:find("日期时间", 1, true) or text:find("小寫變化", 1, true) or
         text:find("大寫變化", 1, true) or text:find("日期時間", 1, true)
end

-- 檢測是否為被破壞的日期時間選單
local function is_corrupted_datetime_menu(text)
  return text:find("[01]时间", 1, true) or text:find("[01]時間", 1, true) or
         text:find("[06]英文", 1, true)
end

local function filter(input, env)
  local context = env.engine.context
  local input_text = context.input
  
  -- 只在擴充模式下處理（以 `` 開頭）
  if not (input_text and input_text:sub(1, 2) == "``") then
    for cand in input:iter() do yield(cand) end
    return
  end
  
  local is_w2c_mode = context:get_option("liu_w2c")
  local is_extended_menu = (input_text == "``")  -- 擴充模式選單
  local is_datetime_menu = (input_text == "``/")  -- 日期時間選單
  local is_datetime_item = input_text:match("^``/%d%d$")  -- 日期時間項目
  local is_letter_variant = input_text:match("^``[a-zA-Z]$")  -- 字母變化
  
  local menu_generated = false
  
  for cand in input:iter() do
    local text_str = cand.text or ""
    local comment_str = cand.comment and tostring(cand.comment) or ""
    
    -- 擴充模式選單
    if is_extended_menu then
      if not menu_generated and is_corrupted_extended_menu(text_str) then
        yield_extended_menu(cand.start, cand._end)
        menu_generated = true
      end
      -- 跳過其他候選項
      goto continue
    end
    
    -- 日期時間選單
    if is_datetime_menu then
      if not menu_generated and is_corrupted_datetime_menu(text_str) then
        yield_datetime_menu(cand.start, cand._end)
        menu_generated = true
      end
      -- 跳過其他候選項
      goto continue
    end
    
    -- 日期時間項目或字母變化：清除所有 comment，但保留 preedit
    if is_datetime_item or is_letter_variant then
      -- 不論是反查模式還是正常模式，都清除 comment
      local new_cand = Candidate(cand.type, cand.start, cand._end, text_str, "")
      new_cand.quality = cand.quality
      new_cand.preedit = cand.preedit  -- 保留原始 preedit
      yield(new_cand)
      goto continue
    end
    
    -- 其他情況直接輸出
    yield(cand)
    
    ::continue::
  end
  
  -- 如果是選單但沒有生成（fallback）
  if is_extended_menu and not menu_generated then
    yield_extended_menu(0, #input_text)
  elseif is_datetime_menu and not menu_generated then
    yield_datetime_menu(0, #input_text)
  end
end

return filter
