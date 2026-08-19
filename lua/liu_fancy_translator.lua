-- liu_fancy_translator.lua
-- 花式英數轉換器
-- `/ = 花式Aa, `// = 花式aa, `/// = 花式AA, `/' = 花式數字

-- 大寫字母對照表（花式AA用，13種樣式）
-- 索引：1=圈圈, 2=負圈, 3=方框, 4=負框, 5=括號, 6=全形, 7=粗體, 8=雙線, 9=等寬, 10=斜體, 11=粗斜, 12=花體, 13=哥德
local fancy_upper = {
  A = {"Ⓐ", "🅐", "🄰", "🅰", "🄐", "Ａ", "𝐀", "𝔸", "𝙰", "𝐴", "𝑨", "𝒜", "𝔄"},
  B = {"Ⓑ", "🅑", "🄱", "🅱", "🄑", "Ｂ", "𝐁", "𝔹", "𝙱", "𝐵", "𝑩", "ℬ", "𝔅"},
  C = {"Ⓒ", "🅒", "🄲", "🅲", "🄒", "Ｃ", "𝐂", "ℂ", "𝙲", "𝐶", "𝑪", "𝒞", "ℭ"},
  D = {"Ⓓ", "🅓", "🄳", "🅳", "🄓", "Ｄ", "𝐃", "𝔻", "𝙳", "𝐷", "𝑫", "𝒟", "𝔇"},
  E = {"Ⓔ", "🅔", "🄴", "🅴", "🄔", "Ｅ", "𝐄", "𝔼", "𝙴", "𝐸", "𝑬", "ℰ", "𝔈"},
  F = {"Ⓕ", "🅕", "🄵", "🅵", "🄕", "Ｆ", "𝐅", "𝔽", "𝙵", "𝐹", "𝑭", "ℱ", "𝔉"},
  G = {"Ⓖ", "🅖", "🄶", "🅶", "🄖", "Ｇ", "𝐆", "𝔾", "𝙶", "𝐺", "𝑮", "𝒢", "𝔊"},
  H = {"Ⓗ", "🅗", "🄷", "🅷", "🄗", "Ｈ", "𝐇", "ℍ", "𝙷", "𝐻", "𝑯", "ℋ", "ℌ"},
  I = {"Ⓘ", "🅘", "🄸", "🅸", "🄘", "Ｉ", "𝐈", "𝕀", "𝙸", "𝐼", "𝑰", "ℐ", "ℑ"},
  J = {"Ⓙ", "🅙", "🄹", "🅹", "🄙", "Ｊ", "𝐉", "𝕁", "𝙹", "𝐽", "𝑱", "𝒥", "𝔍"},
  K = {"Ⓚ", "🅚", "🄺", "🅺", "🄚", "Ｋ", "𝐊", "𝕂", "𝙺", "𝐾", "𝑲", "𝒦", "𝔎"},
  L = {"Ⓛ", "🅛", "🄻", "🅻", "🄛", "Ｌ", "𝐋", "𝕃", "𝙻", "𝐿", "𝑳", "ℒ", "𝔏"},
  M = {"Ⓜ", "🅜", "🄼", "🅼", "🄜", "Ｍ", "𝐌", "𝕄", "𝙼", "𝑀", "𝑴", "ℳ", "𝔐"},
  N = {"Ⓝ", "🅝", "🄽", "🅽", "🄝", "Ｎ", "𝐍", "ℕ", "𝙽", "𝑁", "𝑵", "𝒩", "𝔑"},
  O = {"Ⓞ", "🅞", "🄾", "🅾", "🄞", "Ｏ", "𝐎", "𝕆", "𝙾", "𝑂", "𝑶", "𝒪", "𝔒"},
  P = {"Ⓟ", "🅟", "🄿", "🅿", "🄟", "Ｐ", "𝐏", "ℙ", "𝙿", "𝑃", "𝑷", "𝒫", "𝔓"},
  Q = {"Ⓠ", "🅠", "🅀", "🆀", "🄠", "Ｑ", "𝐐", "ℚ", "𝚀", "𝑄", "𝑸", "𝒬", "𝔔"},
  R = {"Ⓡ", "🅡", "🅁", "🆁", "🄡", "Ｒ", "𝐑", "ℝ", "𝚁", "𝑅", "𝑹", "ℛ", "ℜ"},
  S = {"Ⓢ", "🅢", "🅂", "🆂", "🄢", "Ｓ", "𝐒", "𝕊", "𝚂", "𝑆", "𝑺", "𝒮", "𝔖"},
  T = {"Ⓣ", "🅣", "🅃", "🆃", "🄣", "Ｔ", "𝐓", "𝕋", "𝚃", "𝑇", "𝑻", "𝒯", "𝔗"},
  U = {"Ⓤ", "🅤", "🅄", "🆄", "🄤", "Ｕ", "𝐔", "𝕌", "𝚄", "𝑈", "𝑼", "𝒰", "𝔘"},
  V = {"Ⓥ", "🅥", "🅅", "🆅", "🄥", "Ｖ", "𝐕", "𝕍", "𝚅", "𝑉", "𝑽", "𝒱", "𝔙"},
  W = {"Ⓦ", "🅦", "🅆", "🆆", "🄦", "Ｗ", "𝐖", "𝕎", "𝚆", "𝑊", "𝑾", "𝒲", "𝔚"},
  X = {"Ⓧ", "🅧", "🅇", "🆇", "🄧", "Ｘ", "𝐗", "𝕏", "𝚇", "𝑋", "𝑿", "𝒳", "𝔛"},
  Y = {"Ⓨ", "🅨", "🅈", "🆈", "🄨", "Ｙ", "𝐘", "𝕐", "𝚈", "𝑌", "𝒀", "𝒴", "𝔜"},
  Z = {"Ⓩ", "🅩", "🅉", "🆉", "🄩", "Ｚ", "𝐙", "ℤ", "𝚉", "𝑍", "𝒁", "𝒵", "ℨ"},
}

-- 大寫字母對照表（花式Aa用，10種樣式，移除負圈、方框、負框）
-- 索引：1=圈圈, 2=括號, 3=全形, 4=粗體, 5=雙線, 6=等寬, 7=斜體, 8=粗斜, 9=花體, 10=哥德
local fancy_upper_title = {
  A = {"Ⓐ", "🄐", "Ａ", "𝐀", "𝔸", "𝙰", "𝐴", "𝑨", "𝒜", "𝔄"},
  B = {"Ⓑ", "🄑", "Ｂ", "𝐁", "𝔹", "𝙱", "𝐵", "𝑩", "ℬ", "𝔅"},
  C = {"Ⓒ", "🄒", "Ｃ", "𝐂", "ℂ", "𝙲", "𝐶", "𝑪", "𝒞", "ℭ"},
  D = {"Ⓓ", "🄓", "Ｄ", "𝐃", "𝔻", "𝙳", "𝐷", "𝑫", "𝒟", "𝔇"},
  E = {"Ⓔ", "🄔", "Ｅ", "𝐄", "𝔼", "𝙴", "𝐸", "𝑬", "ℰ", "𝔈"},
  F = {"Ⓕ", "🄕", "Ｆ", "𝐅", "𝔽", "𝙵", "𝐹", "𝑭", "ℱ", "𝔉"},
  G = {"Ⓖ", "🄖", "Ｇ", "𝐆", "𝔾", "𝙶", "𝐺", "𝑮", "𝒢", "𝔊"},
  H = {"Ⓗ", "🄗", "Ｈ", "𝐇", "ℍ", "𝙷", "𝐻", "𝑯", "ℋ", "ℌ"},
  I = {"Ⓘ", "🄘", "Ｉ", "𝐈", "𝕀", "𝙸", "𝐼", "𝑰", "ℐ", "ℑ"},
  J = {"Ⓙ", "🄙", "Ｊ", "𝐉", "𝕁", "𝙹", "𝐽", "𝑱", "𝒥", "𝔍"},
  K = {"Ⓚ", "🄚", "Ｋ", "𝐊", "𝕂", "𝙺", "𝐾", "𝑲", "𝒦", "𝔎"},
  L = {"Ⓛ", "🄛", "Ｌ", "𝐋", "𝕃", "𝙻", "𝐿", "𝑳", "ℒ", "𝔏"},
  M = {"Ⓜ", "🄜", "Ｍ", "𝐌", "𝕄", "𝙼", "𝑀", "𝑴", "ℳ", "𝔐"},
  N = {"Ⓝ", "🄝", "Ｎ", "𝐍", "ℕ", "𝙽", "𝑁", "𝑵", "𝒩", "𝔑"},
  O = {"Ⓞ", "🄞", "Ｏ", "𝐎", "𝕆", "𝙾", "𝑂", "𝑶", "𝒪", "𝔒"},
  P = {"Ⓟ", "🄟", "Ｐ", "𝐏", "ℙ", "𝙿", "𝑃", "𝑷", "𝒫", "𝔓"},
  Q = {"Ⓠ", "🄠", "Ｑ", "𝐐", "ℚ", "𝚀", "𝑄", "𝑸", "𝒬", "𝔔"},
  R = {"Ⓡ", "🄡", "Ｒ", "𝐑", "ℝ", "𝚁", "𝑅", "𝑹", "ℛ", "ℜ"},
  S = {"Ⓢ", "🄢", "Ｓ", "𝐒", "𝕊", "𝚂", "𝑆", "𝑺", "𝒮", "𝔖"},
  T = {"Ⓣ", "🄣", "Ｔ", "𝐓", "𝕋", "𝚃", "𝑇", "𝑻", "𝒯", "𝔗"},
  U = {"Ⓤ", "🄤", "Ｕ", "𝐔", "𝕌", "𝚄", "𝑈", "𝑼", "𝒰", "𝔘"},
  V = {"Ⓥ", "🄥", "Ｖ", "𝐕", "𝕍", "𝚅", "𝑉", "𝑽", "𝒱", "𝔙"},
  W = {"Ⓦ", "🄦", "Ｗ", "𝐖", "𝕎", "𝚆", "𝑊", "𝑾", "𝒲", "𝔚"},
  X = {"Ⓧ", "🄧", "Ｘ", "𝐗", "𝕏", "𝚇", "𝑋", "𝑿", "𝒳", "𝔛"},
  Y = {"Ⓨ", "🄨", "Ｙ", "𝐘", "𝕐", "𝚈", "𝑌", "𝒀", "𝒴", "𝔜"},
  Z = {"Ⓩ", "🄩", "Ｚ", "𝐙", "ℤ", "𝚉", "𝑍", "𝒁", "𝒵", "ℨ"},
}


-- 小寫字母對照表（10種樣式，移除負圈、方框、負框）
-- 索引：1=圈圈, 2=括號, 3=全形, 4=下標, 5=上標, 6=粗體, 7=雙線, 8=等寬, 9=花體, 10=哥德
-- 小寫字母對照表（10種樣式，移除負圈、方框、負框）
-- 索引：1=圈圈, 2=括號, 3=全形, 4=粗體, 5=雙線, 6=等寬, 7=斜體, 8=粗斜, 9=花體, 10=哥德
local fancy_lower = {
  a = {"ⓐ", "⒜", "ａ", "𝐚", "𝕒", "𝚊", "𝑎", "𝒂", "𝒶", "𝔞"},
  b = {"ⓑ", "⒝", "ｂ", "𝐛", "𝕓", "𝚋", "𝑏", "𝒃", "𝒷", "𝔟"},
  c = {"ⓒ", "⒞", "ｃ", "𝐜", "𝕔", "𝚌", "𝑐", "𝒄", "𝒸", "𝔠"},
  d = {"ⓓ", "⒟", "ｄ", "𝐝", "𝕕", "𝚍", "𝑑", "𝒅", "𝒹", "𝔡"},
  e = {"ⓔ", "⒠", "ｅ", "𝐞", "𝕖", "𝚎", "𝑒", "𝒆", "ℯ", "𝔢"},
  f = {"ⓕ", "⒡", "ｆ", "𝐟", "𝕗", "𝚏", "𝑓", "𝒇", "𝒻", "𝔣"},
  g = {"ⓖ", "⒢", "ｇ", "𝐠", "𝕘", "𝚐", "𝑔", "𝒈", "ℊ", "𝔤"},
  h = {"ⓗ", "⒣", "ｈ", "𝐡", "𝕙", "𝚑", "ℎ", "𝒉", "𝒽", "𝔥"},
  i = {"ⓘ", "⒤", "ｉ", "𝐢", "𝕚", "𝚒", "𝑖", "𝒊", "𝒾", "𝔦"},
  j = {"ⓙ", "⒥", "ｊ", "𝐣", "𝕛", "𝚓", "𝑗", "𝒋", "𝒿", "𝔧"},
  k = {"ⓚ", "⒦", "ｋ", "𝐤", "𝕜", "𝚔", "𝑘", "𝒌", "𝓀", "𝔨"},
  l = {"ⓛ", "⒧", "ｌ", "𝐥", "𝕝", "𝚕", "𝑙", "𝒍", "𝓁", "𝔩"},
  m = {"ⓜ", "⒨", "ｍ", "𝐦", "𝕞", "𝚖", "𝑚", "𝒎", "𝓂", "𝔪"},
  n = {"ⓝ", "⒩", "ｎ", "𝐧", "𝕟", "𝚗", "𝑛", "𝒏", "𝓃", "𝔫"},
  o = {"ⓞ", "⒪", "ｏ", "𝐨", "𝕠", "𝚘", "𝑜", "𝒐", "ℴ", "𝔬"},
  p = {"ⓟ", "⒫", "ｐ", "𝐩", "𝕡", "𝚙", "𝑝", "𝒑", "𝓅", "𝔭"},
  q = {"ⓠ", "⒬", "ｑ", "𝐪", "𝕢", "𝚚", "𝑞", "𝒒", "𝓆", "𝔮"},
  r = {"ⓡ", "⒭", "ｒ", "𝐫", "𝕣", "𝚛", "𝑟", "𝒓", "𝓇", "𝔯"},
  s = {"ⓢ", "⒮", "ｓ", "𝐬", "𝕤", "𝚜", "𝑠", "𝒔", "𝓈", "𝔰"},
  t = {"ⓣ", "⒯", "ｔ", "𝐭", "𝕥", "𝚝", "𝑡", "𝒕", "𝓉", "𝔱"},
  u = {"ⓤ", "⒰", "ｕ", "𝐮", "𝕦", "𝚞", "𝑢", "𝒖", "𝓊", "𝔲"},
  v = {"ⓥ", "⒱", "ｖ", "𝐯", "𝕧", "𝚟", "𝑣", "𝒗", "𝓋", "𝔳"},
  w = {"ⓦ", "⒲", "ｗ", "𝐰", "𝕨", "𝚠", "𝑤", "𝒘", "𝓌", "𝔴"},
  x = {"ⓧ", "⒳", "ｘ", "𝐱", "𝕩", "𝚡", "𝑥", "𝒙", "𝓍", "𝔵"},
  y = {"ⓨ", "⒴", "ｙ", "𝐲", "𝕪", "𝚢", "𝑦", "𝒚", "𝓎", "𝔶"},
  z = {"ⓩ", "⒵", "ｚ", "𝐳", "𝕫", "𝚣", "𝑧", "𝒛", "𝓏", "𝔷"},
}

-- 數字對照表（16種樣式）
-- 索引：1=圈圈, 2=負圈, 3=方框, 4=負框, 5=括號, 6=點數, 7=全形, 8=下標, 9=上標, 10=粗體, 11=雙線, 12=等寬, 13=無襯線, 14=無襯線粗, 15=圈漢, 16=括漢
local fancy_digits = {
  ["0"] = {"⓪", "🄋", "⓿", "⒪", "🄀", "🄁", "０", "₀", "⁰", "𝟎", "𝟘", "𝟶", "𝟢", "𝟬", "Ⓞ", "⒪"},
  ["1"] = {"①", "⓵", "❶", "⑴", "⒈", "🄂", "１", "₁", "¹", "𝟏", "𝟙", "𝟷", "𝟣", "𝟭", "㊀", "㈠"},
  ["2"] = {"②", "⓶", "❷", "⑵", "⒉", "🄃", "２", "₂", "²", "𝟐", "𝟚", "𝟸", "𝟤", "𝟮", "㊁", "㈡"},
  ["3"] = {"③", "⓷", "❸", "⑶", "⒊", "🄄", "３", "₃", "³", "𝟑", "𝟛", "𝟹", "𝟥", "𝟯", "㊂", "㈢"},
  ["4"] = {"④", "⓸", "❹", "⑷", "⒋", "🄅", "４", "₄", "⁴", "𝟒", "𝟜", "𝟺", "𝟦", "𝟰", "㊃", "㈣"},
  ["5"] = {"⑤", "⓹", "❺", "⑸", "⒌", "🄆", "５", "₅", "⁵", "𝟓", "𝟝", "𝟻", "𝟧", "𝟱", "㊄", "㈤"},
  ["6"] = {"⑥", "⓺", "❻", "⑹", "⒍", "🄇", "６", "₆", "⁶", "𝟔", "𝟞", "𝟼", "𝟨", "𝟲", "㊅", "㈥"},
  ["7"] = {"⑦", "⓻", "❼", "⑺", "⒎", "🄈", "７", "₇", "⁷", "𝟕", "𝟟", "𝟽", "𝟩", "𝟳", "㊆", "㈦"},
  ["8"] = {"⑧", "⓼", "❽", "⑻", "⒏", "🄉", "８", "₈", "⁸", "𝟖", "𝟠", "𝟾", "𝟪", "𝟴", "㊇", "㈧"},
  ["9"] = {"⑨", "⓽", "❾", "⑼", "⒐", "🄊", "９", "₉", "⁹", "𝟗", "𝟡", "𝟿", "𝟫", "𝟵", "㊈", "㈨"},
}

-- 樣式名稱
local style_names_title = {"圈圈", "括號", "全形", "粗體", "雙線", "等寬", "斜體", "粗斜", "花體", "哥德"}  -- 花式Aa/aa用（10種）
local style_names_upper = {"圈圈", "負圈", "方框", "負框", "括號", "全形", "粗體", "雙線", "等寬", "斜體", "粗斜", "花體", "哥德"}  -- 花式AA用（13種）
local style_names_digits = {"圈圈", "負圈", "方框", "負框", "括號", "點數", "全形", "下標", "上標", "粗體", "雙線", "等寬", "無襯線", "無襯線粗", "圈漢", "括漢"}  -- 花式數字用（16種）


-- 轉換字元（花式AA用，13種樣式）
local function convert_char_upper(char, idx)
  local up = string.upper(char)
  return fancy_upper[up] and fancy_upper[up][idx] or char
end

-- 轉換字元（花式Aa/aa用，10種樣式）
local function convert_char_title(char, idx, is_upper)
  local up = string.upper(char)
  local lo = string.lower(char)
  if is_upper then
    return fancy_upper_title[up] and fancy_upper_title[up][idx] or char
  else
    return fancy_lower[lo] and fancy_lower[lo][idx] or char
  end
end

local function convert_digit(d, idx)
  return fancy_digits[d] and fancy_digits[d][idx] or d
end

-- 轉換文字（花式AA用）
local function convert_text_upper(text, idx)
  local result = {}
  for i = 1, #text do
    local c = text:sub(i, i)
    if c == "." then
      table.insert(result, " ")
    elseif c:match("[a-zA-Z]") then
      table.insert(result, convert_char_upper(c, idx))
    else
      table.insert(result, c)
    end
  end
  return table.concat(result)
end

-- 轉換文字（花式Aa/aa用）
local function convert_text_title(text, idx, mode)
  local result = {}
  local word_start = true
  for i = 1, #text do
    local c = text:sub(i, i)
    if c == "." then
      table.insert(result, " ")
      word_start = true
    elseif c:match("[a-zA-Z]") then
      local is_upper = (mode == "title" and word_start) or (mode == "lower" and false) or (mode == "upper" and true)
      if mode == "lower" then
        is_upper = false
      elseif mode == "title" then
        is_upper = word_start
      end
      table.insert(result, convert_char_title(c, idx, is_upper))
      word_start = false
    else
      table.insert(result, c)
    end
  end
  return table.concat(result)
end

local function convert_numbers(text, idx)
  local result = {}
  for i = 1, #text do
    local c = text:sub(i, i)
    if c == "." then
      table.insert(result, " ")
    elseif c:match("[0-9]") then
      table.insert(result, convert_digit(c, idx))
    else
      table.insert(result, c)
    end
  end
  return table.concat(result)
end


local function parse_input(input)
  -- prefix `/ 已被移除，所以 input 不包含 `/
  -- `/' → input 以 ' 開頭
  -- `/// → input 以 // 開頭
  -- `// → input 以 / 開頭
  -- `/ → input 直接是內容
  if input:match("^'") then return "number", input:sub(2) end
  if input:match("^//") then return "upper", input:sub(3) end
  if input:match("^/") then return "lower", input:sub(2) end
  -- 預設是 title 模式（首字母大寫）
  return "title", input
end

local function translator(input, seg, env)
  -- 判斷模式（根據 tag）
  local mode, preedit_prefix, preedit_name
  if seg:has_tag("fancy_title") then
    mode = "title"
    preedit_prefix = "`/"
    preedit_name = "《花式Aa》"
  elseif seg:has_tag("fancy_lower") then
    mode = "lower"
    preedit_prefix = "`//"
    preedit_name = "《花式aa》"
  elseif seg:has_tag("fancy_upper") then
    mode = "upper"
    preedit_prefix = "`///"
    preedit_name = "《花式AA》"
  elseif seg:has_tag("fancy_number") then
    mode = "number"
    preedit_prefix = "`/'"
    preedit_name = "《花式數字》"
  else
    return
  end
  
  -- input 是移除 prefix 後的內容
  local content = input
  
  -- 只有前綴時不生成候選字（由 tips 處理）
  if content == "" then
    return
  end
  
  -- 生成各種字體樣式的候選
  local preedit = preedit_prefix .. preedit_name .. content:gsub("%.", " ")
  
  if mode == "number" then
    -- 數字模式：16 種樣式
    -- 移除結尾的 '（用於數字選字的標記）
    local num_content = content:gsub("'$", "")
    for idx = 1, #style_names_digits do
      local converted = convert_numbers(num_content, idx)
      local cand = Candidate("fancy", seg.start, seg._end, converted, "")
      cand.preedit = preedit
      yield(cand)
    end
  elseif mode == "upper" then
    -- 花式AA：13 種樣式
    for idx = 1, #style_names_upper do
      local converted = convert_text_upper(content, idx)
      local cand = Candidate("fancy", seg.start, seg._end, converted, "")
      cand.preedit = preedit
      yield(cand)
    end
  else
    -- 花式Aa、花式aa：10 種樣式
    for idx = 1, #style_names_title do
      local converted = convert_text_title(content, idx, mode)
      local cand = Candidate("fancy", seg.start, seg._end, converted, "")
      cand.preedit = preedit
      yield(cand)
    end
  end
end

return translator
