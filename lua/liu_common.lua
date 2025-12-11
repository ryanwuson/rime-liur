-- liu_common.lua
-- 共用函數和常數

local M = {}

-- 數字小鍵盤對照表
M.KEYPAD_DIGITS = {
  ["KP_0"] = "0", ["KP_1"] = "1", ["KP_2"] = "2", ["KP_3"] = "3", ["KP_4"] = "4",
  ["KP_5"] = "5", ["KP_6"] = "6", ["KP_7"] = "7", ["KP_8"] = "8", ["KP_9"] = "9",
}

-- 獲取數字（支援主鍵盤和數字小鍵盤）
function M.get_digit(key_repr)
  if key_repr:match("^[0-9]$") then
    return key_repr
  end
  return M.KEYPAD_DIGITS[key_repr]
end

-- 數字選字輔助函數
function M.select_by_digit(env, digit)
  local seg = env.engine.context.composition:back()
  if seg and seg.menu then
    local page_size = env.engine.schema.page_size or 5
    local idx = math.floor(seg.selected_index / page_size) * page_size + digit
    if idx < seg.menu:candidate_count() then
      seg.selected_index = idx
      env.engine.context:confirm_current_selection()
    end
  end
  return 1
end

-- 檢查是否為擴充漢字（CJK Extension A-G）
function M.is_extended_charset(c)
    return (c >= 0x3400 and c <= 0x4DBF) or      -- Extension A
           (c >= 0x20000 and c <= 0x2FFFF) or    -- Extension B+
           (c >= 0x2A700 and c <= 0x3134F) or    -- Extension C-G
           (c >= 0x2F800 and c <= 0x2FA1F)       -- Compatibility Supplement
end

-- 檢查是否為日文假名
function M.is_kana(c)
    return (c >= 0x3040 and c <= 0x309F) or  -- 平假名
           (c >= 0x30A0 and c <= 0x30FF)     -- 片假名
end

return M
