-- liu_fancy_processor.lua
-- 花式英數模式的按鍵處理器
-- 處理 `/ `// `/// `/' 模式下的輸入

local common = require("liu_common")
local get_digit = common.get_digit

local function processor(key, env)
  local context = env.engine.context
  local input = context.input
  local key_repr = key:repr()
  
  if not input then
    return 2  -- kNoop
  end
  
  -- 處理 ` 鍵：
  -- 1. 空輸入或以 ` 開頭：放行，讓 recognizer 處理符號表/擴充模式
  -- 2. 造詞模式：把 ` 轉換成 ~（delimiter）
  -- 3. 其他情況（一般輸入）：上屏當前候選，然後進入符號表
  if key_repr == "grave" then
    -- 空輸入，放行
    if input == "" then
      return 2  -- kNoop
    end
    
    -- 變體模式（`/ `// `/// `/'）：阻擋 ` 鍵
    if input:match("^`/") then
      return 1  -- kAccepted（阻擋）
    end
    
    -- 其他以 ` 開頭的模式（符號表、擴充模式等），放行
    if input:match("^`") then
      return 2  -- kNoop
    end
    
    -- 檢查是否在造詞模式
    -- 最簡單的判斷：輸入以 ; 開頭（但不是 ;; 讀音查詢、不是 ;' 注音直出）
    local is_mkst = input:match("^;[^;']") or input:match("^;$")
    
    if is_mkst then
      -- 造詞模式：把 ` 轉換成 ~（delimiter）
      context:push_input("~")
      return 1  -- kAccepted
    end
    
    -- 一般輸入模式：上屏當前候選，然後輸入 `
    local composition = context.composition
    if composition and not composition:empty() then
      local seg = composition:back()
      if seg and seg.menu and seg.menu:candidate_count() > 0 then
        local cand = seg:get_selected_candidate()
        if cand then
          env.engine:commit_text(cand.text)
          context:clear()
          context:push_input("`")
          return 1  -- kAccepted
        end
      end
    end
    -- 沒有候選或沒有 composition，直接攔截
    return 1  -- kAccepted
  end
  
  -- 排除 `` 擴充模式 - 讓 liu_extended_backspace 處理
  if input:match("^``") then
    return 2  -- kNoop
  end
  
  -- 排除符號表模式（`a, `aa, `01 等）- 讓 liu_symbols_number_processor 處理
  -- 只有 ` 後面直接接 / 才進入花式模式
  if input:match("^`[a-z]") or input:match("^`[0-9]") then
    return 2  -- kNoop
  end
  
  -- 在符號表模式下（`），攔截 / 鍵進入花式模式
  if input == "`" and key_repr == "slash" then
    context:push_input("/")
    return 1
  end
  
  -- 檢查是否在花式模式下（以 `/ 開頭）
  if not input:match("^`/") then
    return 2  -- kNoop
  end
  
  -- 判斷具體模式（基於完整 input）
  local is_number_mode = input:match("^`/'")
  local is_upper_mode = input:match("^`///")
  local is_lower_mode = input:match("^`//") and not is_upper_mode and not is_number_mode
  
  -- 處理前綴輸入階段
  if input == "`/" then
    if key_repr == "slash" then
      context:push_input("/")
      return 1
    elseif key_repr == "apostrophe" then
      context:push_input("'")
      return 1
    end
  elseif input == "`//" then
    if key_repr == "slash" then
      context:push_input("/")
      return 1
    end
  end
  
  -- 處理 BackSpace
  if key_repr == "BackSpace" then
    if #input > 2 then
      context.input = input:sub(1, -2)
      return 1
    end
    return 2
  end
  
  -- 處理 Escape：有內容時清除內容保留引導鍵，只有引導鍵時才清空
  if key_repr == "Escape" then
    -- 判斷引導鍵長度
    local prefix_len
    if is_number_mode then
      prefix_len = 3  -- `/'
    elseif is_upper_mode then
      prefix_len = 4  -- `///
    elseif is_lower_mode then
      prefix_len = 3  -- `//
    else
      prefix_len = 2  -- `/
    end
    
    if #input > prefix_len then
      -- 有內容，清除內容保留引導鍵
      context.input = input:sub(1, prefix_len)
      return 1
    else
      -- 只有引導鍵，清空
      context:clear()
      return 1
    end
  end
  
  -- 數字模式：允許 0-9、. 和 '，攔截英文字母
  -- 結尾加 ' 後，數字鍵用於選字（在下面處理）
  -- 注意：`/' 本身結尾也是 '，但這是前綴，不算「結尾加 '」
  local digit_str = get_digit(key_repr)
  if is_number_mode then
    -- 檢查是否有輸入數字後再加 '（不只是前綴 `/'）
    local has_content_then_quote = input:match("^`/'[0-9.]+") and input:match("'$")
    if digit_str then
      if has_content_then_quote then
        -- 有數字內容且結尾有 '，數字用於選字（讓下面的選字邏輯處理）
        -- 不 return，繼續往下走
      else
        context:push_input(digit_str)
        return 1
      end
    elseif key_repr == "period" then
      context:push_input(".")
      return 1
    elseif key_repr == "apostrophe" then
      context:push_input("'")
      return 1
    elseif key_repr:match("^[a-z]$") then
      -- 攔截英文字母，不加入輸入
      return 1
    end
  else
    -- 英文模式：允許 a-z 和 .，攔截數字（數字用於選字，在下面處理）
    if key_repr:match("^[a-z]$") then
      context:push_input(key_repr)
      return 1
    elseif key_repr == "period" then
      context:push_input(".")
      return 1
    end
  end
  
  -- 數字鍵用於選字（支援主鍵盤和數字小鍵盤）
  -- 英文模式：直接用數字選字
  -- 數字模式：只有輸入數字後結尾加 ' 時才能用數字選字
  local has_content_then_quote = input:match("^`/'[0-9.]+") and input:match("'$")
  local can_select_by_number = not is_number_mode or has_content_then_quote
  if digit_str and can_select_by_number then
    local composition = context.composition
    if composition and not composition:empty() then
      local seg = composition:back()
      if seg and seg.menu and seg.menu:candidate_count() > 0 then
        local digit = tonumber(digit_str)
        local page_size = env.engine.schema.page_size or 5
        local current_page = math.floor(seg.selected_index / page_size)
        local idx = current_page * page_size + digit
        if idx < seg.menu:candidate_count() then
          seg.selected_index = idx
          context:confirm_current_selection()
          return 1
        end
      end
    end
    return 1
  end
  
  return 2
end

return processor
