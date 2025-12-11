-- liu_datetime.lua
-- 擴充模式下的日期時間功能
-- ``/ = 日期時間選單
-- ``/01 = 時間, ``/02 = 日期, ``/03 = 中文, etc.

-- 嘗試載入農曆模組
local lc_1_ok, lc_1 = pcall(require, "lunar_calendar/lunar_calendar_1")
local lc_2_ok, lc_2 = pcall(require, "lunar_calendar/lunar_calendar_2")
local lc_time_ok, GetLunarSichen = pcall(require, "lunar_calendar/lunar_time")

local Date2LunarDate = lc_1_ok and lc_1.Date2LunarDate or nil
local lunarJzl = lc_1_ok and lc_1.lunarJzl or nil
local GetNowTimeJq = lc_1_ok and lc_1.GetNowTimeJq or nil
local jieqi_out1 = lc_2_ok and lc_2.jieqi_out1 or nil

-- 從共用模組取得選單資料
local extended_data = require("liu_extended_data")
local DATETIME_MENU = extended_data.DATETIME_MENU

-- 分類名稱對照表
local CATEGORY_NAMES = {
  [1] = "時間", [2] = "日期", [3] = "中文", [4] = "民國", [5] = "日本",
  [6] = "英文", [7] = "農曆", [8] = "組合", [9] = "時區", [10] = "節氣",
}

-- 中文數字轉換
local CN_NUM = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
local CN_NUM_BIG = {"零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖"}

local function to_chinese_num(n)
  local s = tostring(n)
  local result = ""
  for i = 1, #s do
    local digit = tonumber(s:sub(i, i))
    result = result .. CN_NUM[digit + 1]
  end
  return result
end

-- 星期轉換
local WEEKDAYS_CN = {"日", "一", "二", "三", "四", "五", "六"}
local WEEKDAYS_EN = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local WEEKDAYS_EN_SHORT = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
local MONTHS_EN = {"January", "February", "March", "April", "May", "June", 
                   "July", "August", "September", "October", "November", "December"}
local MONTHS_EN_SHORT = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

-- 序數詞
local function ordinal(n)
  local num = tonumber(n)
  if num == 1 or num == 21 or num == 31 then return num .. "st"
  elseif num == 2 or num == 22 then return num .. "nd"
  elseif num == 3 or num == 23 then return num .. "rd"
  else return num .. "th"
  end
end

-- 去除前導零
local function strip_zero(s)
  return s:gsub("^0", "")
end

-- 生成各分類的候選項
local function generate_candidates(category, seg, yield)
  local Y = os.date("%Y")
  local m = os.date("%m")
  local d = os.date("%d")
  local H = os.date("%H")
  local M = os.date("%M")
  local S = os.date("%S")
  local I = os.date("%I")  -- 12小時制
  local w = tonumber(os.date("%w"))  -- 星期 0-6
  local month_num = tonumber(m)
  local day_num = tonumber(d)
  local hour_num = tonumber(H)
  local hour12_num = tonumber(I)
  local min_num = tonumber(M)
  local sec_num = tonumber(S)
  
  -- preedit 格式像符號表：[01]時間
  local cat_name = CATEGORY_NAMES[category] or ""
  local preedit = "[" .. string.format("%02d", category) .. "]" .. cat_name
  
  local function add(text)
    local cand = Candidate("datetime", seg.start, seg._end, text, "")
    cand.preedit = preedit
    yield(cand)
  end
  
  if category == 1 then  -- 時間
    add(H .. ":" .. M .. ":" .. S)
    add(H .. ":" .. M)
    add(strip_zero(H) .. "時" .. strip_zero(M) .. "分" .. strip_zero(S) .. "秒")
    add(strip_zero(H) .. "時" .. strip_zero(M) .. "分")
    local ampm = hour_num < 12 and "上午" or "下午"
    add(ampm .. strip_zero(I) .. ":" .. M .. ":" .. S)
    add(ampm .. strip_zero(I) .. "點" .. strip_zero(M) .. "分")
    
  elseif category == 2 then  -- 日期
    add(Y .. "/" .. m .. "/" .. d)
    add(Y .. "-" .. m .. "-" .. d)
    add(Y .. "." .. m .. "." .. d)
    add(Y .. m .. d)
    add(m .. "/" .. d)
    add(m .. "-" .. d)
    add("星期" .. WEEKDAYS_CN[w + 1])
    add("週" .. WEEKDAYS_CN[w + 1])
    
  elseif category == 3 then  -- 中文
    add(Y .. "年" .. strip_zero(m) .. "月" .. strip_zero(d) .. "日")
    add(strip_zero(m) .. "月" .. strip_zero(d) .. "日")
    add(to_chinese_num(Y) .. "年" .. to_chinese_num(month_num) .. "月" .. to_chinese_num(day_num) .. "日")
    add(to_chinese_num(month_num) .. "月" .. to_chinese_num(day_num) .. "日")
    
  elseif category == 4 then  -- 民國
    local minguo_year = tonumber(Y) - 1911
    add("民國" .. minguo_year .. "年" .. strip_zero(m) .. "月" .. strip_zero(d) .. "日")
    add("民國" .. to_chinese_num(minguo_year) .. "年" .. to_chinese_num(month_num) .. "月" .. to_chinese_num(day_num) .. "日")
    
  elseif category == 5 then  -- 日本
    local reiwa_year = tonumber(Y) - 2018
    if reiwa_year > 0 then
      add("令和" .. reiwa_year .. "年" .. strip_zero(m) .. "月" .. strip_zero(d) .. "日")
      add("令和" .. to_chinese_num(reiwa_year) .. "年" .. to_chinese_num(month_num) .. "月" .. to_chinese_num(day_num) .. "日")
    end
    
  elseif category == 6 then  -- 英文
    add(MONTHS_EN[month_num] .. " " .. day_num .. ", " .. Y)
    add(day_num .. " " .. MONTHS_EN[month_num] .. " " .. Y)
    add(MONTHS_EN_SHORT[month_num] .. " " .. day_num .. ", " .. Y)
    add(day_num .. " " .. MONTHS_EN_SHORT[month_num] .. " " .. Y)
    add(WEEKDAYS_EN[w + 1])
    add(WEEKDAYS_EN_SHORT[w + 1])
    add(MONTHS_EN[month_num] .. " " .. ordinal(day_num) .. ", " .. Y)
    
  elseif category == 7 then  -- 農曆
    if Date2LunarDate then
      local date_str = Y .. m .. d
      local ll_1, ll_2, ly_1, ly_2, lm, ld = Date2LunarDate(date_str)
      if ll_1 then add(ll_1) end
      if ll_2 then add(ll_2) end
      if lunarJzl then
        local All_g, Y_g, M_g, D_g, H_g = lunarJzl(Y .. m .. d .. H)
        if All_g then add(All_g) end
        if Y_g and M_g and D_g then add(Y_g .. "年" .. M_g .. "月" .. D_g .. "日") end
      end
      if lc_time_ok and GetLunarSichen then
        add(GetLunarSichen(H))
      end
    else
      add("（農曆模組載入失敗）")
    end
    
  elseif category == 8 then  -- 組合
    add(Y .. "/" .. m .. "/" .. d .. " " .. H .. ":" .. M)
    add(Y .. "/" .. m .. "/" .. d .. " " .. H .. ":" .. M .. ":" .. S)
    add(Y .. "年" .. strip_zero(m) .. "月" .. strip_zero(d) .. "日 " .. H .. ":" .. M)
    add(Y .. "/" .. m .. "/" .. d .. " (" .. WEEKDAYS_CN[w + 1] .. ")")
    add(Y .. "年" .. strip_zero(m) .. "月" .. strip_zero(d) .. "日 星期" .. WEEKDAYS_CN[w + 1])
    add(Y .. "-" .. m .. "-" .. d .. "T" .. H .. ":" .. M .. ":" .. S)
    
  elseif category == 9 then  -- 時區
    local tz_offset = os.date("%z")
    local tz_name = os.date("%Z")
    add("UTC" .. tz_offset:sub(1,3) .. ":" .. tz_offset:sub(4,5))
    add(tz_offset:sub(1,3))
    add(tz_name)
    
  elseif category == 10 then  -- 節氣
    if jieqi_out1 then
      local ok, jq_1, jq_2, jq_3, jq_4 = pcall(jieqi_out1)
      if ok and jq_1 then
        -- 前一個節氣（已過）
        add(jq_1 .. " " .. jq_2)
        -- 下一個節氣（將至）
        add(jq_3 .. " " .. jq_4)
        -- 顯示未來幾個節氣的日期
        if GetNowTimeJq then
          local ok2, nt_jqs = pcall(GetNowTimeJq, os.date("%Y%m%d"))
          if ok2 and nt_jqs and type(nt_jqs) == "table" then
            for i = 1, math.min(#nt_jqs, 4) do
              add(nt_jqs[i])
            end
          end
        end
      else
        add("（無法取得節氣資訊）")
      end
    else
      add("（節氣模組載入失敗）")
    end
  end
end

local function translator(input, seg, env)
  -- 支援兩種情況：
  -- 1. affix_segmentor 移除 prefix 後的輸入（/ 或 /XX）
  -- 2. 完整輸入（以 ``/ 開頭）
  
  local clean_input = input
  
  -- 如果是完整輸入（以 `` 開頭），移除 prefix
  if input:match("^``") then
    clean_input = input:sub(3)
  -- 如果不是 extended_mode tag，且不是 `` 開頭，則跳過
  elseif not seg:has_tag("extended_mode") then
    return
  end
  
  -- 必須以 / 開頭才是日期時間功能
  if not clean_input:match("^/") then
    return
  end
  
  -- ``/ 顯示日期時間選單
  if clean_input == "/" then
    local preedit = "《日期時間》▸"
    for _, hint in ipairs(DATETIME_MENU) do
      local cand = Candidate("datetime_menu", seg.start, seg._end, hint, "")
      cand.preedit = preedit
      yield(cand)
    end
    return
  end
  
  -- ``/01 ~ ``/10 顯示對應分類
  local category = string.match(clean_input, "^/(%d%d)$")
  if category then
    local cat_num = tonumber(category)
    if cat_num >= 1 and cat_num <= 10 then
      generate_candidates(cat_num, seg, yield)
    end
    return
  end
end

return translator
