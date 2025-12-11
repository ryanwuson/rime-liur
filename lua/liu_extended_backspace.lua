-- liu_extended_backspace.lua
-- 在 `` 擴充模式下：
-- 1. backspace 只刪除最後一個字元，保留 ``
-- 2. 數字鍵在 ``字母 模式下用於選字（變化形）
-- 3. 數字鍵在 ``/XX 模式下用於選字（日期時間）
-- 4. ` 鍵在 ``字母 後面時，直接攔截不加入輸入
-- 5. 當只有 `` 時，添加一個空格觸發 segment（然後立即移除）

local common = require("liu_common")
local get_digit = common.get_digit
local select_by_digit = common.select_by_digit

local function processor(key, env)
  local context = env.engine.context
  local input = context.input
  local key_repr = key:repr()
  
  -- 檢查是否在 `` 擴充模式下
  if not (input and input:sub(1, 2) == "``") then
    return 2
  end
  
  -- 處理 BackSpace 鍵
  if key_repr == "BackSpace" then
    -- ``/XX（日期時間分類）：直接回到 ``/（選單層）
    if input:match("^``/%d%d$") then
      context.input = "``/"
      return 1
    end
    -- ``/X（日期時間分類第一位）：回到 ``/
    if input:match("^``/%d$") then
      context.input = "``/"
      return 1
    end
    -- 其他情況
    if #input > 2 then
      -- 有內容時只刪除最後一個字元
      context.input = input:sub(1, -2)
      return 1
    else
      -- 只有 `` 時清空整個輸入
      context:clear()
      return 1
    end
  end
  
  -- 處理 Escape 鍵：根據模式回到上一層
  if key_repr == "Escape" then
    -- 日期時間分類（``/XX）：回到日期時間選單（``/）
    if input:match("^``/%d%d$") then
      context.input = "``/"
      return 1
    end
    -- 日期時間選單（``/）或其他有內容：清除內容保留 ``
    if #input > 2 then
      context.input = "``"
      return 1
    else
      -- 只有 ``，清空
      context:clear()
      return 1
    end
  end
  
  -- 數字鍵處理（支援主鍵盤和數字小鍵盤）
  local digit_str = get_digit(key_repr)
  if digit_str then
    local digit = tonumber(digit_str)
    -- ``（只有 ``）：數字選字（選單）
    if input == "``" then
      return select_by_digit(env, digit)
    end
    -- ``字母（大小寫）：數字選字（變化形）
    if input:match("^``[a-zA-Z]$") then
      return select_by_digit(env, digit)
    end
    -- ``/XX（日期時間分類）：數字選字
    if input:match("^``/%d%d$") then
      return select_by_digit(env, digit)
    end
    -- ``/X（日期時間分類第一位）：繼續輸入數字
    if input:match("^``/%d$") then
      context:push_input(digit_str)
      return 1
    end
    -- ``/（日期時間選單）：開始輸入分類數字
    if input == "``/" then
      context:push_input(digit_str)
      return 1
    end
  end
  
  -- 攔截 ` 鍵
  if key_repr == "grave" and input:match("^``[a-zA-Z0-9/]+$") then
    return 1
  end
  
  return 2
end

return processor
