-- liu_date_translator.lua
-- 符號表變體處理（`a 字母變體，`'01 數字變體）
-- Extracted from rime.lua for @* syntax compatibility

local symbol_data = require("liu_symbol_data")
local number_symbols = symbol_data.number_symbols
local letter_symbols = symbol_data.letter_symbols

local function translator(input, seg)
  -- 擴充模式（``）由 liu_letter_variants.lua 和 liu_datetime.lua 處理
  if seg:has_tag("extended_mode") then
    return
  end

  -- 數字變體模式（`'）
  if seg:has_tag("number_variant") then
    -- 空輸入：顯示等待提示
    if input == "" then
      yield(Candidate("number_variant_hint", seg.start, seg._end, "請輸入數字 (00~50)", ""))
      return
    end

    -- 只有1位數字：顯示等待提示
    local single_digit = string.match(input, "^(%d)$")
    if single_digit then
      local cand = Candidate("number_variant_hint", seg.start, seg._end, "請輸入第二位數字 (00~50)", "")
      cand.preedit = "《變體數字》" .. single_digit
      yield(cand)
      return
    end

    -- 數字變體：`'01 到 `'50（必須兩位數字）
    local num = string.match(input, "^(%d%d)$")
    if num then
      local num_key = tostring(tonumber(num))  -- 去掉前導零：01 → 1
      if number_symbols[num_key] then
        local preedit = "《變體" .. num_key .. "》" .. num
        for _, symbol in ipairs(number_symbols[num_key]) do
          local cand = Candidate("number_variant", seg.start, seg._end, symbol, "")
          cand.preedit = preedit
          yield(cand)
        end
      end
    end
    return
  end

  -- 符號表模式（`）- 處理字母變體（Ⓐ）
  if seg:has_tag("symbols") then
    local letter = string.match(input, "^([a-z])$")
    if letter and letter_symbols[letter] then
      local preedit = "《變體" .. letter .. "》" .. letter
      for _, symbol in ipairs(letter_symbols[letter]) do
        local cand = Candidate("letter_variant", seg.start, seg._end, symbol, "")
        cand.preedit = preedit
        yield(cand)
      end
    end
    return
  end
end

return translator
