-- liu_extended_data.lua
-- 擴充模式共用資料

local M = {}

-- 擴充模式選單項目（text, comment）
M.EXTENDED_MENU = {
  {"日期時間", "〔/〕"},
  {"小寫變化", "〔a~z〕"},
  {"大寫變化", "〔A~Z〕"},
}

-- 日期時間選單項目
M.DATETIME_MENU = {
  "[01]時間  [02]日期  [03]中文  [04]民國  [05]日本",
  "[06]英文  [07]農曆  [08]組合  [09]時區  [10]節氣",
}

return M
