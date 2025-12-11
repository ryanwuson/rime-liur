-- liu_symbols_hint.lua
-- 嘸蝦米符號表提示

-- 符號表提示文字（共用）
local HINTS = {
  "[01]一般  [02]括號  [03]引號  [04]豎標  [05]數學",
  "[06]單位  [07]貨幣  [08]分數  [09]上標  [10]下標",
  "[11]注音  [12]拼音  [13]音標  [14]平假  [15]片假",
  "[16]韓文  [17]藏文  [18]希臘  [19]俄語  [20]合字",
  "[21]部首  [22]月份  [23]日期  [24]時間  [25]性別",
  "[26]圈英  [27]圈數  [28]圈漢  [29]圈日  [30]圈韓",
  "[31]括英  [32]括數  [33]括漢  [34]括韓  [35]框英",
  "[36]框數  [37]框漢  [38]點數  [39]羅馬  [40]箭頭",
  "[41]線段  [42]框線  [43]圓形  [44]三角  [45]方形",
  "[46]星星  [47]八卦  [48]易經  [49]音樂  [50]圖案",
}

local function translator(input, seg, env)
  -- 注意：input 是去掉 prefix (`) 後的內容
  -- 所以 ` 對應 input=""，`' 對應 input="'"
  if input == "" then
    for _, hint in ipairs(HINTS) do
      yield(Candidate("symbols_hint", seg.start, seg._end, hint, ""))
    end
  end
  -- `' 等待數字輸入：不產生候選項，preedit 由 yaml preedit_format 處理
end

-- 導出提示文字供其他模組使用
return {
  translator = translator,
  HINTS = HINTS
}
