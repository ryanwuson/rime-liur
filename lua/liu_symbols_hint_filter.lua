-- liu_symbols_hint_filter.lua
-- 符號清單提示 filter：處理符號清單候選項

local symbols_hint = require("liu_symbols_hint")
local HINTS = symbols_hint.HINTS

-- 生成提示候選項
local function yield_hints(start_pos, end_pos)
  for _, hint in ipairs(HINTS) do
    yield(Candidate("symbols_hint", start_pos, end_pos, hint, ""))
  end
end

-- 檢測被破壞的提示候選項
local function is_corrupted_hint(text)
  return text:find("%[%d%d%]", 1) ~= nil
end

local function filter(input, env)
  local context = env.engine.context
  local input_text = context.input
  
  -- 只在符號清單模式下處理
  if not (input_text and input_text:sub(1, 1) == "`") then
    for cand in input:iter() do yield(cand) end
    return
  end
  
  -- 排除花式、擴充、數字變體模式
  local first_two = input_text:sub(1, 2)
  if first_two == "`/" or first_two == "``" or first_two == "`'" then
    for cand in input:iter() do yield(cand) end
    return
  end
  
  local is_w2c_mode = context:get_option("liu_w2c")
  local is_first_level = (input_text == "`")
  local hint_generated = false
  
  -- 字母變體 preedit
  local variant_preedit
  local single_letter = input_text:match("^`([a-z])$")
  if single_letter then
    variant_preedit = "《變體" .. single_letter .. "》" .. single_letter
  end
  
  for cand in input:iter() do
    local text_str = cand.text or ""
    local comment_str = cand.comment and tostring(cand.comment) or ""
    
    -- 變體候選項
    if cand.type == "letter_variant" or cand.type == "number_variant" then
      if variant_preedit then
        local new_cand = Candidate(cand.type, cand.start, cand._end, cand.text, cand.comment or "")
        new_cand.preedit = variant_preedit
        yield(new_cand)
      else
        yield(cand)
      end
    -- 提示候選項
    elseif (cand.type == "symbols_hint") or (is_first_level and is_corrupted_hint(text_str)) then
      if is_first_level and not hint_generated then
        yield_hints(cand.start, cand._end)
        hint_generated = true
      end
    elseif not is_first_level then
      if variant_preedit then
        local new_cand = Candidate(cand.type, cand.start, cand._end, cand.text, cand.comment or "")
        new_cand.preedit = variant_preedit
        yield(new_cand)
      else
        yield(cand)
      end
    else
      -- 第一層非提示：清理 comment
      if not is_w2c_mode then
        local clean = comment_str:gsub("^~%s*", ""):gsub("〔[^〕]+〕", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if clean ~= comment_str then
          local new_cand = Candidate(cand.type, cand.start, cand._end, text_str, clean)
          new_cand.quality = cand.quality
          yield(new_cand)
        else
          yield(cand)
        end
      else
        yield(cand)
      end
    end
  end
  
  if is_first_level and not hint_generated then
    yield_hints(0, #input_text)
  end
end

return filter
