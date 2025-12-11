-- liu_symbols_number_processor.lua
-- 符號表模式下處理數字鍵：
-- 1. 符號分類：`01~`50 = 符號分類
-- 2. 字母變體：`a = 字母變體（Ⓐ ⓐ...），可以用數字選字
-- 3. 數字變體：`'1~`'50 = 數字變體（① ⓵ ❶...），可以用數字選字
-- Backspace/Escape 回到符號表選單

local common = require("liu_common")
local get_digit = common.get_digit
local select_by_digit = common.select_by_digit

local pending_digit = nil

-- 回到符號表選單
local function back_to_menu(context)
  context.input = "`"
  context:refresh_non_confirmed_composition()
  return 1
end

-- 回到數字變體選單（`'）
local function back_to_number_variant(context)
  context.input = "`'"
  context:refresh_non_confirmed_composition()
  return 1
end

local function processor(key, env)
  local context = env.engine.context
  local input = context.input
  local key_repr = key:repr()
  
  -- 檢查是否在符號表模式
  if not input or input:sub(1, 1) ~= "`" or input:sub(1, 2) == "``" then
    pending_digit = nil
    return 2
  end
  
  local input_len = #input
  
  -- 字母變體模式：`a（只有單字母）
  if input:match("^`[a-z]$") then
    pending_digit = nil
    if key_repr == "BackSpace" or key_repr == "Escape" then
      return back_to_menu(context)
    end
    local digit = get_digit(key_repr)
    if digit then
      return select_by_digit(env, tonumber(digit))
    end
    if key_repr == "grave" then return 1 end
    return 2
  end
  
  -- 數字變體模式：`'1~`'50
  if input:match("^`'%d+$") then
    pending_digit = nil
    if key_repr == "BackSpace" or key_repr == "Escape" then
      -- 回到 `'《變體數字》▸
      return back_to_number_variant(context)
    end
    -- 數字鍵：繼續輸入數字（最多2位）或選字
    local digit = get_digit(key_repr)
    if digit then
      local num_part = input:match("^`'(%d+)$")
      if #num_part < 2 then
        -- 繼續輸入數字
        context.input = input .. digit
        context:refresh_non_confirmed_composition()
        return 1
      else
        -- 已有2位數字，用於選字
        return select_by_digit(env, tonumber(digit))
      end
    end
    if key_repr == "grave" then return 1 end
    return 2
  end
  
  -- 數字變體起始：`' 等待數字（preedit 由 yaml tips 處理）
  if input == "`'" then
    pending_digit = nil
    if key_repr == "BackSpace" then
      -- 回到符號表選單
      return back_to_menu(context)
    end
    if key_repr == "Escape" then
      -- 清空
      context:clear()
      return 1
    end
    local digit = get_digit(key_repr)
    if digit then
      context.input = "`'" .. digit
      context:refresh_non_confirmed_composition()
      return 1
    end
    if key_repr == "grave" then return 1 end
    return 2
  end
  
  -- 符號分類第二層：輸入長度 >= 3（如 `01）
  if input_len >= 3 then
    pending_digit = nil
    if key_repr == "BackSpace" or key_repr == "Escape" then
      return back_to_menu(context)
    end
    if key_repr == "grave" then return 1 end
    return 2
  end
  
  -- 第一層：輸入為 ` 或 `X
  local digit = get_digit(key_repr)
  if digit then
    if input == "`" then
      pending_digit = digit
      context.input = "`" .. digit
      context:refresh_non_confirmed_composition()
      return 1
    elseif input_len == 2 and pending_digit then
      context.input = "`" .. pending_digit .. digit
      pending_digit = nil
      context:refresh_non_confirmed_composition()
      return 1
    end
  elseif key_repr == "BackSpace" and pending_digit then
    pending_digit = nil
    return back_to_menu(context)
  elseif key_repr == "Escape" then
    pending_digit = nil
    return 2
  end
  
  return 2
end

return processor
