-- rime.lua
-- 嘸蝦米輸入法 Lua 模組載入

-- 符號資料表（數字變體、字母變體）
local symbol_data = require("liu_symbol_data")
local number_symbols = symbol_data.number_symbols
local letter_symbols = symbol_data.letter_symbols

-- date_translator: 符號表變體處理（`a 字母變體，`'01 數字變體）
function date_translator(input, seg)
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

-- liu_phonetic_suffix: 嘸蝦米同音字模式（選中後按 '）
local liu_phonetic_suffix = require("liu_phonetic_suffix")
liu_phonetic_suffix_processor = liu_phonetic_suffix.processor
liu_phonetic_suffix_translator = liu_phonetic_suffix.translator
liu_phonetic_suffix_filter = liu_phonetic_suffix.filter

-- ── 注音／拼音／Easy English：切到該方案才載入 ──────────────────────
-- librime-lua 的 lua_processor@x 是在「建立元件」時才用 lua_getglobal 查全域 x，
-- 而元件只有切到掛載它的方案時才會建立。所以把這些全域改成惰性解析：
-- 只打蝦米就一路不會 require；切到注音／拼音／Easy English 才載入，
-- 之後留在 package.loaded 內，不會重複載入。
-- 查到的是模組本體，init／func／fini 行為與原本直接 require 完全相同。
-- 蝦米方案自己也掛的模組（liu_emoji_filter、liu_wildcard_*）不可放進來，
-- 那些一進蝦米就要用，惰性化沒有意義。
local LAZY_GLOBALS = {
  -- 獨立注音 v2（空白＝一聲；Enter＝中文上屏；Shift+Return＝注音文）
  select_character               = "select_character",               -- 注音、拼音共用
  liu_bpmf_tone_processor        = "liu_bpmf_tone_processor",
  liu_bpmf_backspace_processor   = "liu_bpmf_backspace_processor",
  liu_bpmf_enter_processor       = "liu_bpmf_enter_processor",       -- 連帶 liu_bpmf_common
  liu_bpmf_refresh_processor     = "liu_bpmf_refresh_processor",
  liu_bpmf_delimiter_processor   = "liu_bpmf_delimiter_processor",
  liu_bpmf_symbol_filter         = "liu_bpmf_symbol_filter",

  -- 獨立拼音（空白找字；Enter＝羅馬拼音；Shift+Return＝帶音標）
  liu_pinyin_backspace_processor = "liu_pinyin_backspace_processor",
  liu_pinyin_delimiter_processor = "liu_pinyin_delimiter_processor",
  liu_pinyin_enter_processor     = "liu_pinyin_enter_processor",     -- 連帶 liu_pinyin_common
  liu_pinyin_refresh_processor   = "liu_pinyin_refresh_processor",
  liu_pinyin_preedit_filter      = "liu_pinyin_preedit_filter",
  liu_phonetic_w2c_hint          = "liu_phonetic_w2c_hint",          -- 注音、拼音共用

  -- Easy English（英文連續輸入增強）
  easy_en_enhance_filter  = function() return require("easy_en").enhance_filter end,
}

setmetatable(_G, {
  __index = function(_, name)
    local source = LAZY_GLOBALS[name]
    if not source then
      return nil
    end
    -- lua_getglobal 沒有錯誤保護，載入失敗時把錯誤往 C 端拋可能直接讓輸入法掛掉，
    -- 所以這裡吞掉錯誤回傳 nil，librime 會在 log 記下元件建立失敗。
    local ok, module
    if type(source) == "function" then
      ok, module = pcall(source)
    else
      ok, module = pcall(require, source)
    end
    if not ok then
      if log and log.error then
        log.error("lazy global load failed: " .. name .. ": " .. tostring(module))
      end
      return nil
    end
    _G[name] = module
    return module
  end,
})

-- 行內注音／拼音隨附 Emoji：蝦米方案自己也掛，維持啟動即載入
-- （emoji.txt 與 Opencc 已由模組內部延遲到第一次查詢才讀）
liu_emoji_filter = require("liu_emoji_filter")

-- 各功能模組載入
liu_w2c_sorter = require("liu_w2c_sorter")                    -- 反查編碼排序
liu_wildcard_filter = require("liu_wildcard_filter")          -- 反查模式禁用萬用字元
liu_wildcard_code_hint = require("liu_wildcard_code_hint")    -- 萬用字元顯示完整編碼
liu_phonetic_override = require("liu_phonetic_override")      -- 讀音查詢模式處理
liu_phonetic_hint_processor = require("liu_phonetic_hint_processor")  -- 讀音查詢模式屏蔽 ctrl+'
liu_remove_trad_in_w2c = require("liu_remove_trad_in_w2c")    -- 反查模式移除繁體標記
liu_charset_filter = require("liu_charset_filter")            -- 字元集過濾
liu_quick_hint = require("liu_quick_hint")                    -- 快打模式簡碼提示
liu_quick_mode_processor = require("liu_quick_mode_processor")  -- 快打模式切換

-- 符號表相關
local liu_symbols_hint_module = require("liu_symbols_hint")
liu_symbols_hint = liu_symbols_hint_module.translator
liu_symbols_hint_filter = require("liu_symbols_hint_filter")
liu_symbols_processor = require("liu_symbols_processor")
liu_symbols_number_processor = require("liu_symbols_number_processor")

-- 擴充模式（``）相關
liu_extended_backspace = require("liu_extended_backspace")
liu_extended_segmentor = require("liu_extended_segmentor")
liu_letter_variants = require("liu_letter_variants")
liu_datetime = require("liu_datetime")
liu_extended_filter = require("liu_extended_filter")

-- 萬用字元開關
liu_wildcard_processor = require("liu_wildcard_processor")

-- 變體英數模式（`/ `// `/// `/'）
liu_fancy_translator = require("liu_fancy_translator")
liu_fancy_processor = require("liu_fancy_processor")
liu_fancy_filter = require("liu_fancy_filter")

-- VRSF 選字提示
liu_vrsf_hint = require("liu_vrsf_hint")

-- 自定詞翻譯器和過濾器
liu_custom_word_translator = require("liu_custom_word_translator")
liu_custom_word_filter = require("liu_custom_word_filter")

-- 功能說明（,,h 模式）
local liu_help_module = require("liu_help")
liu_help_translator = liu_help_module.translator
liu_help_filter = require("liu_help_filter")

-- 波浪號直出處理
liu_tilde_processor = require("liu_tilde_processor")

-- 英文候選處理（移除補全提示）
liu_english_filter = require("liu_english_filter")

-- 英文大小寫轉換（word] → Word，word]] → WORD）
liu_english_case_filter = require("liu_english_case_filter")

-- 上屏後小步垃圾回收
liu_gc_processor = require("liu_gc_processor")

-- 聯想學習（預設 predict.db + 使用者調序；桌面版 schema 已註解，不掛 filter）
liu_user_predict = require("liu_user_predict")

-- 方案切換狀態保持（liur ↔ easy_en 切換時保持 ascii_mode 狀態）
liu_schema_switch_processor = require("liu_schema_switch_processor")

-- 計算機（= 引導）：延遲載入約 3500 行，平常打字不佔啟動時間
do
  local impl
  local function load_calc()
    if not impl then
      impl = require("liu_calculator")
    end
    return impl
  end
  liu_calculator = {
    init = function(env)
      env._liu_calc_need_init = true
    end,
    func = function(input, seg, env)
      if not seg:has_tag("calculator") then
        if type(input) ~= "string" or input:sub(1, 3) ~= ",,=" then
          return
        end
      end
      local m = load_calc()
      if env._liu_calc_need_init then
        env._liu_calc_need_init = false
        if m.init then m.init(env) end
      end
      return m.func(input, seg, env)
    end,
    fini = function(env)
      if impl and impl.fini then impl.fini(env) end
    end,
  }
end
liu_calculator_shortcut = require("liu_calculator_shortcut")
