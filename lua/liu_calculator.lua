-- author: https://github.com/ChaosAlphard
-- 說明 https://github.com/gaboolic/rime-shuangpin-fuzhuma/pull/41

-- 原有功能：
-- 單個隨機數生成、三角函數、冪函數、指數函數、對數函數求值
-- 計算n次方根、平均值、方差、階乘、角度與弧度的相互轉化

-- 新增功能：
-- 求解一元一次方程、二元一次方程組、一元二次方程、一元三次方程、一元四次方程；
-- 求解一次、二次函數解析式、圓的方程；
-- 取整函數（包括向上取整和向下取整）、求餘函數；
-- 已知數列中任意兩項，求通項公式(等差或等比)；求數列的前n項和(等差或等比)；
-- 已知三角形三邊長，求面積；已知正多邊形邊數n、邊長a，求面積；
-- 判斷兩直線位置關係，給出距離或交點座標；點到點、點到直線距離求解；
-- 求解兩點間線段的垂直平分線方程；求解點繞點旋轉後的座標；
-- 組合數、排列數、最大公因數、最小公倍數求解；
-- 點關於直線的對稱點座標、直線關於直線(或點)的對稱直線方程求解；
-- 連續自然數的冪方求和，包括平方和、立方和、4次方之和；前n個奇數或偶數的平方和、立方和、4次方之和；
-- 求解勾股數、批次隨機數、質因數分解、找質數；
-- 24點計算機(姑且算一個小遊戲,霧)；
-- 常見單位間的換算；數字的進制轉換；

-- 功能引導鍵一覽：
-- cb = "連續自然數立方和(從1開始)"
-- fp = "連續自然數4次方之和(從1開始)"
-- sq = "連續自然數平方和(從1開始)"
-- tx = "已知數列的任意兩項aᵢ、aₖ及對應的項數i、k，求其通項公式"
-- avg = "平均值"
-- cos = "餘弦"
-- deg = "弧度轉換為角度"
-- dds = "頂點式求解二次函數解析式"
-- dxf = "點斜法求解一次函數解析式"
-- ecb = "前n個偶數的立方和"
-- efp = "前n個偶數的4次方之和"
-- esq = "前n個偶數的平方和"
-- exp = "返回 e^x"
-- gbs = "計算多個數的最小公倍數"
-- ggs = "求解勾股數"
-- gys = "計算多個數的最大公因數"
-- hls = "計算行列式"
-- ldf = "兩點法求解一次函數解析式"
-- ld1 = "已知兩點座標，求兩點間的距離"
-- ld2 = "已知兩點座標，求兩點間線段的垂直平分線方程"
-- ld3 = "已知兩點P(x₁, y₁)和Q(x₂, y₂)，求點P繞點Q旋轉角度a(角度制)後的P'座標"
-- log = "x作為底數的對數"
-- mod = "求餘函數"
-- msq = "計算正數的算術平方根"
-- nrt = "計算 x 開 N 次方"
-- ocb = "前n個奇數的立方和"
-- ofp = "前n個奇數的4次方之和"
-- osq = "前n個奇數的平方和"
-- pls = "計算排列數"
-- rad = "角度轉換為弧度"
-- sin = "正弦"
-- sjs = "隨機數"
-- tan = "正切"
-- tfp = "24點計算機"
-- var = "方差"
-- ybs = "一般式求解二次函數解析式"
-- zhs = "計算組合數"
-- zys = "質因數分解"
-- zzs = "找質數"
-- acos = "反餘弦"
-- asin = "反正弦"
-- atan = "反正切"
-- cesd = "已知圓上不同三點的座標，求圓方程"
-- cexl = "已知圓心和圓上不同兩點的座標求圓方程"
-- cexr = "已知圓心座標和半徑求圓的方程"
-- cosh = "雙曲餘弦"
-- dbsl = "已知等比數列的首項a₁，公比q，求指定的前n項和"
-- dcsl = "已知等差數列的首項a₁，公差d，求指定的前n項和"
-- dwhs = "單位換算，支持面積、質量、長度、體積，(數字, '原單位', '目標單位')"
-- eyyc = "求解二元一次方程組ax+by=e，cx+dy=f"
-- fact = "階乘"
-- lzx1 = "已知兩直線方程A₁x+B₁y+C₁=0和A₂x+B₂y+C₂=0，判斷它們的位置關係"
-- lzx2 = "已知直線l₁:A₁x+B₁y+C₁=0和l₂:A₂x+B₂y+C₂=0，求兩條直線以彼此為軸的對稱直線方程"
-- loge = "e作為底數的對數"
-- logt = "10作為底數的對數"
-- jzzh = "數字進制轉換，支持2~36進制，(數字, 原進制, 目標進制)"
-- psjs = "批次隨機數"
-- sinh = "雙曲正弦"
-- sjxx = "已知三角形三個頂點座標，求其“心”的座標"
-- sjx1 = "已知三角形的三邊長a、b、c，求三角形面積"
-- sjx2 = "已知三角形的三個頂點座標(x₁,y₁)，(x₂,y₂)，(x₃,y₃)，求三角形面積"
-- sqrt = "計算複數的平方根"
-- tanh = "雙曲正切"
-- tcr1 = "已知兩圓標準方程(x-x₁)²+(y-y₁)²=r₁²和(x-x₂)²+(y-y₂)²=r₂²，判斷它們的位置關係"
-- tcr2 = "已知兩圓一般方程x²+y²+D₁x+E₁y+F₁=0和x²+y²+D₂x+E₂y+F₂=0，判斷它們的位置關係"
-- yyec = "求解一元二次方程"
-- yyyc = "求解一元一次方程"
-- xsqz = "向上取整"
-- xxqz = "向下取整"
-- zdbx = "已知邊數n與邊長a計算正多邊形面積"
-- atan2 = "返回以弧度為單位的點(x,y)相對於x軸的逆時針角度"
-- dyzx1 = "已知一點座標(x₁,y₁)和直線方程Ax+By+C=0，求點到直線的距離及對稱點座標"
-- dyzx2 = "已知一點P(x₁,y₁)和直線l:Ax+By+C=0，求直線l關於點P的對稱直線l'的方程"
-- ldexp = "返回 x*2^y"
-- sjxy1 = "已知三角形三邊長，求內切圓半徑和外接圓半徑"
-- sjxy2 = "已知三角形三個頂點座標，求內切圓半徑和外接圓半徑"
-- yysc1 = "求解一元三次方程"
-- yysc2 = "求解一元四次方程"


local T = {}

function T.init(env)
    local config = env.engine.schema.config
    env.name_space = env.name_space:gsub('^*', '')
    local _calc_pat = config:get_string("recognizer/patterns/calculator") or nil
    T.prefix = _calc_pat and _calc_pat:match("%^([a-zA-Z/=,]+).*") or "="
    T.tips = config:get_string("calculator/tips") or "計算機"
end

local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

-- 函數表
local calc_methods = {
    -- e, exp(1) = e^1 = e
    e = math.exp(1),
    -- π
    pi = math.pi,
    b = 10 ^ 2,
    q = 10 ^ 3,
    k = 10 ^ 3,
    w = 10 ^ 4,
    tw = 10 ^ 5,
    m = 10 ^ 6,
    tm = 10 ^ 7,
    y = 10 ^ 8,
    g = 10 ^ 9
}

local methods_desc = {
    ["e"] = "自然常數, 歐拉數",
    ["pi"] = "圓周率 π",
    ["b"] = "百",
    ["q"] = "千",
    ["k"] = "千",
    ["w"] = "萬",
    ["tw"] = "十萬",
    ["m"] = "百萬",
    ["tm"] = "千萬",
    ["y"] = "億",
    ["g"] = "十億"
}

-- 實現計算輸入
local function replaceToFactorial(str)
    return str:gsub("([0-9]+)!", "fact(%1)")
end

-- 保留返回值的非零有效數字(返回結果為數字)
local function fn(n)
    -- 將數字轉換為字串以便處理
    local s = tostring(n)
    -- 查找小數點的位置
    local i = string.find(s, "%.")
    if i == nil then
        -- 如果沒有小數點，直接返回原數字
        return n
    end
    -- 去除小數點後的尾隨零
    local j = string.len(s)
    while j > i and string.sub(s, j, j) == "0" do
        j = j - 1
    end
    -- 如果小數點後沒有數字了，移除小數點
    if j == i then
        -- 返回整數部分
        return tonumber(string.sub(s, 1, i - 1))
    else
        -- 否則，返回處理後的數字
        return tonumber(string.sub(s, 1, j))
    end
end

-- 保留返回值的非零有效數字(返回結果為字串)
local function fs(n)
    -- 將數字轉換為字串以便處理
    local s = tostring(n)
    -- 查找小數點的位置
    local i = string.find(s, "%.")
    if i == nil then
        -- 如果沒有小數點，直接返回原數字
        return n
    end
    -- 去除小數點後的尾隨零
    local j = string.len(s)
    while j > i and string.sub(s, j, j) == "0" do
        j = j - 1
    end
    -- 如果小數點後沒有數字了，移除小數點
    if j == i then
        -- 返回整數部分
        return string.sub(s, 1, i - 1)
    else
        -- 否則，返回處理後的數字
        return string.sub(s, 1, j)
    end
end

-- 向上取整函數
local function ceil(x)
    return math.ceil(x)
end
calc_methods["xsqz"] = ceil
methods_desc["xsqz"] = "向上取整"

-- 向下取整函數
local function floor(x)
    return math.floor(x)
end
calc_methods["xxqz"] = floor
methods_desc["xxqz"] = "向下取整"

-- 四捨五入保留小數點後n位
local function round(m, n)
    local factor = 10 ^ n
    return floor(m * factor + 0.5) / factor
end

local function format_number_for_display(n)
    if type(n) ~= "number" then
        return tostring(n)
    end
    -- 分離整數部分和小數部分
    local integer_part = math.floor(math.abs(n))
    local integer_digits = #tostring(integer_part)
    
    -- 只檢查整數部分的位數
    if integer_digits > 19 then
        return "數字超限!"
    end
    -- 檢查是否為整數
    if n == math.floor(n) then
        return tostring(math.floor(n))
    end
    -- 四捨五入到12位小數
    local rounded = round(n, 12)
    -- 使用fs函數轉換為字串並去除尾隨0
    return fs(rounded)
end

-- 計算兩個數的最大公因數（GCD）
local function gcd(a, b)
    while b ~= 0 do
        local temp = b
        b = a % b
        a = temp
    end
    return a
end

-- 計算多個數的最大公因數
local function gcd_multiple(...)
    local nums, result
    nums = { ... }
    result = nums[1]
    for i = 2, #nums do
        result = gcd(result, nums[i])
    end
    return fn(result)
end
calc_methods["gys"] = gcd_multiple
methods_desc["gys"] = "計算多個數的最大公因數"

-- 計算兩個數的最小公倍數（LCM）
local function lcm(a, b)
    return a * b / gcd(a, b)
end

-- 計算多個數的最小公倍數
local function lcm_multiple(...)
    local nums, result
    nums = { ... }
    result = nums[1]
    for i = 2, #nums do
        result = lcm(result, nums[i])
    end
    return fn(result)
end
calc_methods["gbs"] = lcm_multiple
methods_desc["gbs"] = "計算多個數的最小公倍數"

-- random(m ,n) 返回m-n之間的隨機數，n為空則返回1-m之間，都為空則返回0-1之間的小數
local function random(...)
    return math.random(...)
end
-- 註冊到函數表中
calc_methods["sjs"] = random
methods_desc["sjs"] = "隨機數"

-- 計算開 N 次方
local function nth_root(x, n)
    if n % 2 == 0 and x < 0 then
        return nil -- 偶次方時負數沒有實數解
    elseif x < 0 then
        return -((-x) ^ (1 / n))
    else
        return x ^ (1 / n)
    end
end
calc_methods["nrt"] = nth_root
methods_desc["nrt"] = "計算 x 開 N 次方"

-- 正弦
local function sin(x)
    return math.sin(x)
end
calc_methods["sin"] = sin
methods_desc["sin"] = "正弦"

-- 雙曲正弦
local function sinh(x)
    return (math.exp(x) - math.exp(-x)) / 2
end
calc_methods["sinh"] = sinh
methods_desc["sinh"] = "雙曲正弦"

-- 反正弦
local function asin(x)
    return math.asin(x)
end
calc_methods["asin"] = asin
methods_desc["asin"] = "反正弦"

-- 餘弦
local function cos(x)
    return math.cos(x)
end
calc_methods["cos"] = cos
methods_desc["cos"] = "餘弦"

-- 雙曲餘弦
local function cosh(x)
    return (math.exp(x) + math.exp(-x)) / 2
end
calc_methods["cosh"] = cosh
methods_desc["cosh"] = "雙曲餘弦"

-- 反餘弦
local function acos(x)
    return math.acos(x)
end
calc_methods["acos"] = acos
methods_desc["acos"] = "反餘弦"

-- 正切
local function tan(x)
    return math.tan(x)
end
calc_methods["tan"] = tan
methods_desc["tan"] = "正切"

-- 雙曲正切
local function tanh(x)
    local e = math.exp(2 * x)
    return (e - 1) / (e + 1)
end
calc_methods["tanh"] = tanh
methods_desc["tanh"] = "雙曲正切"

-- 反正切
local function atan(x)
    return math.atan(x)
end
calc_methods["atan"] = atan
methods_desc["atan"] = "反正切"

-- 返回以弧度為單位的點(x,y)相對於x軸的逆時針角度。y是點的縱座標，x是點的橫座標
-- 返回範圍從−π到π （以弧度為單位），其中負角度表示向下旋轉，正角度表示向上旋轉
-- 它與傳統的 math.atan(y/x) 函數相比，具有更好的數學定義，因為它能夠正確處理邊界情況（例如x=0）
local function atan2(y, x)
    if x == 0 and y == 0 then
        return 0 / 0 -- 返回NaN
    elseif x == 0 and y ~= 0 then
        if y > 0 then
            return math.pi / 2
        else
            return -math.pi / 2
        end
    else
        return math.atan(y / x) + (x < 0 and math.pi or 0)
    end
end
calc_methods["atan2"] = atan2
methods_desc["atan2"] = "返回以弧度為單位的點(x,y)相對於x軸的逆時針角度"

-- 將角度從弧度轉換為度
local function deg(x)
    return math.deg(x)
end
calc_methods["deg"] = deg
methods_desc["deg"] = "弧度轉換為角度"

-- 將角度從度轉換為弧度
local function rad(x)
    return math.rad(x)
end
calc_methods["rad"] = rad
methods_desc["rad"] = "角度轉換為弧度"

-- 返回 x*2^y
local function ldexp(x, y)
    return x * 2 ^ y
end
calc_methods["ldexp"] = ldexp
methods_desc["ldexp"] = "返回 x*2^y"

-- 返回 e^x
local function exp(x)
    -- 檢查參數正確性
    if type(x) ~= "number" then
        return "參數必須是數字"
    end
    return math.exp(x)
end
calc_methods["exp"] = exp
methods_desc["exp"] = "返回 e^x"

-- 計算複數的平方根
local function sqrt(...)
    local data = {...}
    local n = #data
    local a,b
    if n == 0 then
        return "請輸入至少一個數"
    elseif n > 2 then
        return "參數數量不能超過2個"
    end
    -- 檢查參數正確性
    for i = 1, n do
        if type(data[i]) ~= "number" then
            return "參數必須是數字"
        end
    end
    if n == 1 then
        a = data[1]
        b = 0
    elseif n == 2 then
        a = data[1]
        b = data[2]
    end
    local t1 = (math.sqrt(a ^ 2 + b ^ 2) + a) / 2
    local t2 = (math.sqrt(a ^ 2 + b ^ 2) - a) / 2
    local x1, x2, y1, y2
    x1 = fn(math.sqrt(t1))
    x2 = fn(-math.sqrt(t1))
    y1 = fn(math.sqrt(t2))
    y2 = fn(-math.sqrt(t2))
    if a == 0 and b == 0 then
        return 0
    elseif a ~= 0 and b == 0 then
        if a > 0 then
            return x1 .. " , " .. x2
        else
            return y1 .. "i" .. " , " .. y2 .. "i"
        end
    elseif b ~= 0 then
        if b > 0 then
            return x1 .. "+" .. y1 .. "i" .. " , " .. x2 .. "-" .. -y2 .. "i"
        else
            return x1 .. "-" .. -y2 .. "i" .. " , " .. x2 .. "+" .. y1 .. "i"
        end
    end
end
calc_methods["sqrt"] = sqrt
methods_desc["sqrt"] = "計算複數的平方根"

-- 計算正數的算術平方根
local function msq(x)
    -- 檢查參數正確性
    if type(x) ~= "number" then
        return "參數必須是數字"
    end
    if x < 0 then
        return "參數必須是非負數"
    end
    return fn(math.sqrt(x))
end
calc_methods["msq"] = msq
methods_desc["msq"] = "計算正數的算術平方根"

-- x為底的對數， log(10, 100) = log(100) / log(10) = 2
local function log(x, y)
    -- 不能為負數或0
    if x <= 0 or y <= 0 then
        return nil
    end
    return math.log(y) / math.log(x)
end
calc_methods["log"] = log
methods_desc["log"] = "x作為底數的對數"

-- 自然數e為底的對數
local function loge(x)
    -- 不能為負數或0
    if x <= 0 then
        return nil
    end
    return math.log(x)
end
calc_methods["loge"] = loge
methods_desc["loge"] = "e作為底數的對數"

-- 10為底的對數
local function logt(x)
    -- 不能為負數或0
    if x <= 0 then
        return nil
    end
    return math.log(x) / math.log(10)
end
calc_methods["logt"] = logt
methods_desc["logt"] = "10作為底數的對數"

-- 平均值
local function avg(...)
    local data, n, sum
    data = { ... }
    n = #data
    sum = 0
    -- 樣本數量不能為0
    if n == 0 then
        return nil
    end
    -- 計算總和
    for _, value in ipairs(data) do
        sum = sum + value
    end
    return fn(sum / n)
end
calc_methods["avg"] = avg
methods_desc["avg"] = "平均值"

-- 方差
local function variance(...)
    local data, n, sum, mean, sum_squared_diff
    data = { ... }
    n = #data
    sum = 0
    sum_squared_diff = 0
    -- 樣本數量不能為0
    if n == 0 then
        return nil
    end
    -- 計算均值
    for _, value in ipairs(data) do
        sum = sum + value
    end
    mean = sum / n
    -- 計算方差
    for _, value in ipairs(data) do
        sum_squared_diff = sum_squared_diff + (value - mean) ^ 2
    end
    return fn(sum_squared_diff / n)
end
calc_methods["var"] = variance
methods_desc["var"] = "方差"

-- 階乘
local function factorial(x)
    -- 不能為負數
    if x < 0 then
        return nil
    elseif x == 0 or x == 1 then
        return 1
    end
    local result = 1
    for i = 1, x do
        result = result * i
    end
    return fn(result)
end
calc_methods["fact"] = factorial
methods_desc["fact"] = "階乘"

-- 計算行列式
local function hls(...)
    local args, n1, sqrt_n, matrix, index, side_length
    args = { ... }
    n1 = #args
    sqrt_n = math.sqrt(n1)
    -- 判斷n1是否為完全平方數，如果是，則將輸入的元素重新排列成一個方陣
    if sqrt_n == math.floor(sqrt_n) then
        matrix = {}
        index = 1
        side_length = math.floor(sqrt_n)
        for i = 1, side_length do
            matrix[i] = {}
            for j = 1, side_length do
                matrix[i][j] = args[index]
                index = index + 1
            end
        end
    else
        return "給出的元素不能組成一個方陣。"
    end
    -- 遞歸計算行列式的函數
    local function determinant(matrix)
        local n, det, sign, row, sub_matrix
        n = #matrix
        det = 0
        -- 二階行列式的邊界條件
        if n == 2 then
            return matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]
        end
        -- 遞歸計算行列式
        for j = 1, n do
            sub_matrix = {}
            for i = 2, n do
                row = {}
                for k = 1, n do
                    if k ~= j then
                        table.insert(row, matrix[i][k])
                    end
                end
                table.insert(sub_matrix, row)
            end
            sign = (-1) ^ (1 + j)
            det = det + sign * matrix[1][j] * determinant(sub_matrix)
        end
        return fn(det)
    end
    return determinant(matrix)
end
calc_methods["hls"] = hls
methods_desc["hls"] = "計算行列式"

-- 取餘函數
local function remainder(x, y)
    -- 使用math.fmod函數計算餘數
    local result = math.fmod(x, y)
    -- 如果x是負數，math.fmod會返回負數，需要調整為正數
    if result < 0 then
        result = result + y
    end
    return fn(result)
end
calc_methods["mod"] = remainder
methods_desc["mod"] = "求餘函數"

-- 連續自然數平方和(從1開始)
local function sum_of_squares(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算平方和
    local result = n * (n + 1) * (2 * n + 1) / 6
    return fn(result)
end
calc_methods["sq"] = sum_of_squares
methods_desc["sq"] = "連續自然數平方和(從1開始)"

-- 連續自然數立方和(從1開始)
local function sum_of_cubes(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算立方和
    local result = (n * (n + 1)) ^ 2 / 4
    return fn(result)
end
calc_methods["cb"] = sum_of_cubes
methods_desc["cb"] = "連續自然數立方和(從1開始)"

-- 連續自然數4次方之和(從1開始)
local function sum_of_fourth_powers(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算4次方和
    local result = n * (n + 1) * (2 * n + 1) * (3 * n ^ 2 + 3 * n - 1) / 30
    return fn(result)
end
calc_methods["fp"] = sum_of_fourth_powers
methods_desc["fp"] = "連續自然數4次方之和(從1開始)"

-- 前n個奇數的平方和
local function sum_of_odd_squares(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算平方和
    local result = n * (4 * n ^ 2 - 1) / 3
    return fn(result)
end
calc_methods["osq"] = sum_of_odd_squares
methods_desc["osq"] = "前n個奇數的平方和"

-- 前n個偶數的平方和
local function sum_of_even_squares(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算平方和
    local result = 2 * n * (n + 1) * (2 * n + 1) / 3
    return fn(result)
end
calc_methods["esq"] = sum_of_even_squares
methods_desc["esq"] = "前n個偶數的平方和"

-- 前n個奇數的立方和
local function sum_of_odd_cubes(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算立方和
    local result = n ^ 2 * (2 * n ^ 2 - 1)
    return fn(result)
end
calc_methods["ocb"] = sum_of_odd_cubes
methods_desc["ocb"] = "前n個奇數的立方和"

-- 前n個偶數的立方和
local function sum_of_even_cubes(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算立方和
    local result = 2 * (n * (n + 1)) ^ 2
    return fn(result)
end
calc_methods["ecb"] = sum_of_even_cubes
methods_desc["ecb"] = "前n個偶數的立方和"

-- 前n個奇數的4次方之和
local function sum_of_odd_fourth_powers(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算4次方和
    local result = (48 * n ^ 5 - 40 * n ^ 3 + 7 * n) / 15
    return fn(result)
end
calc_methods["ofp"] = sum_of_odd_fourth_powers
methods_desc["ofp"] = "前n個奇數的4次方之和"

-- 前n個偶數的4次方之和
local function sum_of_even_fourth_powers(n)
    -- 檢查參數
    if type(n) ~= "number" or n < 1 or n ~= floor(n) then
        return "錯誤：參數必須為正整數"
    end
    -- 計算4次方和
    local result = 8 * n * (n + 1) * (2 * n + 1) * (3 * n ^ 2 + 3 * n - 1) / 15
    return fn(result)
end
calc_methods["efp"] = sum_of_even_fourth_powers
methods_desc["efp"] = "前n個偶數的4次方之和"

-- 圓的標準方程的表達式優化
local function CircleStandardEquation(h, k, r_squared)
    local standardEquation
    if h == 0 then
        if k > 0 then
            standardEquation = "x²+(y-" .. k .. ")²=" .. r_squared
        elseif k == 0 then
            standardEquation = "x²+y²=" .. r_squared
        else
            standardEquation = "x²+(y+" .. -k .. ")²=" .. r_squared
        end
    elseif k == 0 then
        if h > 0 then
            standardEquation = "(x-" .. h .. ")²+y²=" .. r_squared
        elseif h == 0 then
            standardEquation = "x²+y²=" .. r_squared
        else
            standardEquation = "(x+" .. -h .. ")²+y²=" .. r_squared
        end
    else
        if h > 0 and k > 0 then
            standardEquation = "(x-" .. h .. ")²+(y-" .. k .. ")²=" .. r_squared
        elseif h > 0 and k < 0 then
            standardEquation = "(x-" .. h .. ")²+(y+" .. -k .. ")²=" .. r_squared
        elseif h < 0 and k > 0 then
            standardEquation = "(x+" .. -h .. ")²+(y-" .. k .. ")²=" .. r_squared
        else
            standardEquation = "(x+" .. -h .. ")²+(y+" .. -k .. ")²=" .. r_squared
        end
    end
    return standardEquation
end

-- 圓的一般方程表達式優化
local function CircleGeneralEquation(D, E, F)
    local generalEquation = "x²+y²"
    -- 處理D項
    if D ~= 0 then
        if D == -1 then
            generalEquation = generalEquation .. "-x"
        elseif D == 1 then
            generalEquation = generalEquation .. "+x"
        elseif D > 0 then
            generalEquation = generalEquation .. "+" .. D .. "x"
        else
            generalEquation = generalEquation .. "-" .. -D .. "x"
        end
    end
    -- 處理E項
    if E ~= 0 then
        if E == -1 then
            generalEquation = generalEquation .. "-y"
        elseif E == 1 then
            generalEquation = generalEquation .. "+y"
        elseif E > 0 then
            generalEquation = generalEquation .. "+" .. E .. "y"
        else
            generalEquation = generalEquation .. "-" .. -E .. "y"
        end
    end
    -- 處理F項
    if F ~= 0 then
        if F > 0 then
            generalEquation = generalEquation .. "+" .. F .. "=0"
        else
            generalEquation = generalEquation .. "-" .. -F .. "=0"
        end
    end
    return generalEquation
end

-- 直線方程(斜截式)表達式優化
local function LineEquation(x1, y1, k)
    local equation, b
    -- 特殊情況
    if k == nil then
        return "x=" .. x1
    else
        equation = "y="
    end
    if k == 0 then
        equation = equation .. y1
        return equation
    end
    -- 計算截距b
    b = fn(y1 - k * x1)
    -- 優化k的表示
    if k == -1 then
        equation = equation .. "-x"
    elseif k == 1 then
        equation = equation .. "x"
    else
        if k > 0 then
            equation = equation .. k .. "x"
        else
            equation = equation .. "-" .. -k .. "x"
        end
    end
    -- 優化b的表示
    if b ~= 0 then
        if b > 0 then
            equation = equation .. "+" .. b
        else
            equation = equation .. "-" .. -b
        end
    end
    return equation
end

-- 直線方程(一般式)表達式優化
local function LineGeneralEquation(A, B, C)
    -- 檢查參數正確性
    if A == 0 and B == 0 then
        return "錯誤：直線方程系數A和B不能同時為0"
    end
    -- 求最大公約數，簡化系數
    local s, result
    s = gcd_multiple(math.abs(A), math.abs(B), math.abs(C))
    if A < 0 then
        A = -A
        B = -B
        C = -C
    end
    A = fn(A / s)
    B = fn(B / s)
    C = fn(C / s)
    if A ~= 0 and B == 0 and C == 0 then
        result = "x=0"
    end
    if A ~= 0 and B == 0 and C ~= 0 then
        result = "x=" .. fn(-C / A)
    end
    if A == 0 and B ~= 0 and C == 0 then
        result = "y=0"
    end
    if A == 0 and B ~= 0 and C ~= 0 then
        result = "y=" .. fn(-C / B)
    end
    if A ~= 0 and B ~= 0 then
        if A == 1 then
            result = "x"
        else
            result = A .. "x"
        end
        if B == 1 then
            result = result .. "+y"
        elseif B == -1 then
            result = result .. "-y"
        elseif B > 0 then
            result = result .. "+" .. B .. "y"
        else
            result = result .. "-" .. -B .. "y"
        end
        if C ~= 0 then
            if C > 0 then
                result = result .. "+" .. C .. "=0"
            else
                result = result .. "-" .. -C .. "=0"
            end
        else
            result = result .. "=0"
        end
    end
    return result
end

-- 二次函數表達式優化
local function QuadraticEquation(a, b, c)
    local result = "y="
    -- 格式化a的值
    if a ~= 0 then
        if a == 1 then
            result = result .. "x²"
        elseif a == -1 then
            result = result .. "-x²"
        else
            result = result .. a .. "x²"
        end
    end
    -- 格式化b的值
    if b ~= 0 then
        if b == 1 then
            result = result .. "+x"
        elseif b == -1 then
            result = result .. "-x"
        elseif b > 0 then
            result = result .. "+" .. b .. "x"
        else
            result = result .. "-" .. -b .. "x"
        end
    end
    -- 格式化c的值
    if c ~= 0 then
        if c > 0 then
            result = result .. "+" .. c
        else
            result = result .. "-" .. -c
        end
    end
    return result
end

-- 已知正多邊形邊數n和邊長a，計算正多邊形面積
local function calculateRegularPolygonArea(n, a)
    -- 檢查參數正確性
    if type(n) ~= "number" or type(a) ~= "number" or n ~= floor(n) or n < 1 or a <= 0 then
        return "錯誤：邊數n必須為正整數，邊長a必須為正數"
    end
    -- 計算正多邊形的面積
    local s = (n * a ^ 2) / (4 * math.tan(math.pi / n))
    return fn(s)
end
calc_methods["zdbx"] = calculateRegularPolygonArea
methods_desc["zdbx"] = "已知邊數n與邊長a計算正多邊形面積"

-- 已知等比數列的首項a₁，公比q，求指定的前n項和
local function geometricSeriesSum(a1, q, n)
    -- 檢查參數正確性
    if type(a1) ~= "number" or type(q) ~= "number" or type(n) ~= "number" or n ~= floor(n) or n < 1 then
        return "錯誤：a₁、q、n必須為數字且n是正整數"
    end
    -- 計算前n項和
    if a1 == 0 then
        return 0
    elseif q == 0 and a1 ~= 0 then
        return a1
    elseif q == 1 then
        return a1 * n
    else
        local s = a1 * (1 - q ^ n) / (1 - q)
        return fn(s)
    end
end
calc_methods["dbsl"] = geometricSeriesSum
methods_desc["dbsl"] = "已知等比數列的首項a₁，公比q，求指定的前n項和"

-- 已知等差數列的首項a₁，公差d，求指定的前n項和
local function ArithmeticSeriesSum(a1, d, n)
    -- 檢查參數正確性
    if type(a1) ~= "number" or type(d) ~= "number" or type(n) ~= "number" or n ~= floor(n) or n < 1 then
        return "錯誤：a₁、d、n必須為數字且n是正整數"
    end
    -- 計算前n項和
    if a1 == 0 and d == 0 then
        return 0
    elseif a1 ~= 0 and d == 0 then
        return a1 * n
    else
        local s = n * a1 + n * (n - 1) * d / 2
        return fn(s)
    end
end
calc_methods["dcsl"] = ArithmeticSeriesSum
methods_desc["dcsl"] = "已知等差數列的首項a₁，公差d，求指定的前n項和"

-- 已知數列中任意兩項aᵢ、aₖ，求通項公式
-- 對應項數分別為i、k
-- b=0為等差數列，b=1為等比數列
local function findSequenceFormula(i, ai, k, ak, b)
    -- 檢查參數正確性
    if type(i) ~= "number" or i ~= floor(i) or i < 1 or type(k) ~= "number" or k ~= floor(k) or k < 1 then
        return "錯誤：i 和 k 必須是正整數"
    end
    if ai == ak and i == k then
        return "錯誤：aᵢ、aₖ 和對應的項數不能同時相等"
    elseif ai ~= ak and i == k then
        return "錯誤：同一項數對應不同的項值"
    end
    -- 計算等差數列的通項公式
    local function arithmeticSequence(i, ai, k, ak)
        local d, a1, s
        d = fn((ak - ai) / (k - i))
        a1 = ai - (i - 1) * d
        s = fn(a1 - d)
        if d == 0 then
            return "aₙ=" .. a1
        elseif d == 1 then
            if s == 0 then
                return "aₙ=n"
            elseif s > 0 then
                return "aₙ=n+" .. s
            else
                return "aₙ=n-" .. -s
            end
        elseif d == -1 then
            if s == 0 then
                return "aₙ=-n"
            elseif s > 0 then
                return "aₙ=-n+" .. s
            else
                return "aₙ=-n-" .. -s
            end
        else
            if s == 0 then
                return "aₙ=" .. d .. "n"
            elseif s > 0 then
                return "aₙ=" .. d .. "n+" .. s
            else
                return "aₙ=" .. d .. "n-" .. -s
            end
        end
    end
    -- 計算等比數列的通項公式
    local function geometricSequence(i, ai, k, ak)
        if ai == 0 or ak == 0 then
            return "錯誤：等比數列中不能有0項"
        end
        local s, q, n, a1
        s = fn(ak / ai)
        n = fn(k - i)
        if s < 0 and n % 2 == 0 then
            return "無法求解通項公式"
        end
        q = fn(nth_root(s, n))
        a1 = fn(ai / (q ^ (i - 1)))
        if a1 == q then
            if q == 1 then
                return "aₙ=" .. q
            elseif q > 0 then
                return "aₙ=" .. q .. "ⁿ"
            elseif q < 0 then
                return "aₙ=(" .. q .. ")ⁿ"
            end
        elseif a1 == -q then
            if q == 1 then
                return "aₙ=-" .. q
            elseif q == -1 then
                return "aₙ=(" .. q .. ")ⁿ⁻¹"
            elseif q > 0 then
                return "aₙ=-" .. q .. "ⁿ"
            else
                return "aₙ=-(" .. q .. ")ⁿ"
            end
        else
            if q > 0 then
                if a1 == 1 then
                    return "aₙ=" .. q .. "ⁿ⁻¹"
                elseif a1 == -1 then
                    return "aₙ=-" .. q .. "ⁿ⁻¹"
                else
                    return "aₙ=" .. a1 .. "×" .. q .. "ⁿ⁻¹"
                end
            else
                if a1 == 1 then
                    return "aₙ=(" .. q .. ")ⁿ⁻¹"
                elseif a1 == -1 then
                    return "aₙ=-(" .. q .. ")ⁿ⁻¹"
                else
                    return "aₙ=" .. a1 .. "×(" .. q .. ")ⁿ⁻¹"
                end
            end
        end
    end
    -- 根據b值返回通項公式
    if b == 0 then
        return arithmeticSequence(i, ai, k, ak)
    elseif b == 1 then
        return geometricSequence(i, ai, k, ak)
    else
        return "錯誤：參數b必須是0或1"
    end
end
calc_methods["tx"] = findSequenceFormula
methods_desc["tx"] = "已知數列的任意兩項aᵢ、aₖ及對應的項數i、k，求其通項公式"

-- 已知圓心座標(h,k)和半徑r，求圓的標準方程和一般方程
local function CircleEquationsxr(h, k, r)
    -- 檢查半徑是否為正數
    if r <= 0 then
        return "錯誤：半徑必須大於0"
    end
    -- 圓的標準方程
    local r_squared, se, ge, D, E, F
    r_squared = fn(r ^ 2)
    se = CircleStandardEquation(h, k, r_squared)
    -- 圓的一般方程
    D = fn(-2 * h)
    E = fn(-2 * k)
    F = fn(h ^ 2 + k ^ 2 - r ^ 2)
    ge = CircleGeneralEquation(D, E, F)
    -- 返回兩個方程
    return "標準方程: " .. se .. "\n一般方程: " .. ge
end
calc_methods["cexr"] = CircleEquationsxr
methods_desc["cexr"] = "已知圓心座標和半徑求圓的方程"

-- 已知圓心座標(h,k)和圓上不同兩點(x₁,y₁),(x₂,y₂)，求圓的標準方程和一般方程
local function CircleEquationsxl(h, k, x1, y1, x2, y2)
    -- 檢查三個座標中是否有任意兩個點座標完全相同
    if (x1 == x2 and y1 == y2) or (x1 == h and y1 == k) or (x2 == h and y2 == k) then
        return "錯誤：三個座標中不能有任意兩個點座標完全相同"
    end
    local distance1, distance2, r, r_squared, se, ge, D, E, F
    -- 計算兩點到圓心的距離，並檢查是否相等
    distance1 = math.sqrt((x1 - h) ^ 2 + (y1 - k) ^ 2)
    distance2 = math.sqrt((x2 - h) ^ 2 + (y2 - k) ^ 2)
    if distance1 ~= distance2 then
        return "錯誤：給定的圓心座標和兩個點無法構成圓"
    end
    -- 圓的標準方程
    r = distance1
    r_squared = fn(r ^ 2)
    se = CircleStandardEquation(h, k, r_squared)
    -- 圓的一般方程
    D = fn(-2 * h)
    E = fn(-2 * k)
    F = fn(h ^ 2 + k ^ 2 - r_squared)
    ge = CircleGeneralEquation(D, E, F)
    -- 返回兩個方程
    return "標準方程: " .. se .. "\n一般方程: " .. ge
end
calc_methods["cexl"] = CircleEquationsxl
methods_desc["cexl"] = "已知圓心和圓上不同兩點的座標求圓方程"

-- 已知不共線的三點(x₁,y₁)，(x₂,y₂)，(x₃,y₃)，求過它們的圓的方程
local function CircleEquationssd(x1, y1, x2, y2, x3, y3)
    local determinant, A, B, detA, detAD, detAE, detAF, D, E, F, ge, se, r_squared, h, k
    -- 檢查三個點是否共線
    determinant = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)
    if determinant == 0 then
        return "錯誤：三個點共線或重合，無法構成圓"
    end
    -- 構建系數矩陣A和常數矩陣B
    A = {
        { x1, y1, 1 },
        { x2, y2, 1 },
        { x3, y3, 1 }
    }
    B = {
        (-x1 ^ 2 - y1 ^ 2),
        (-x2 ^ 2 - y2 ^ 2),
        (-x3 ^ 2 - y3 ^ 2)
    }
    -- 計算系數矩陣A的行列式detA
    detA = hls(A[1][1], A[1][2], A[1][3], A[2][1], A[2][2], A[2][3], A[3][1], A[3][2], A[3][3])
    -- 計算D、E、F的行列式
    detAD = hls(B[1], A[1][2], A[1][3], B[2], A[2][2], A[2][3], B[3], A[3][2], A[3][3])
    detAE = hls(A[1][1], B[1], A[1][3], A[2][1], B[2], A[2][3], A[3][1], B[3], A[3][3])
    detAF = hls(A[1][1], A[1][2], B[1], A[2][1], A[2][2], B[2], A[3][1], A[3][2], B[3])
    -- 計算系數D、E、F
    D = fn(detAD / detA)
    E = fn(detAE / detA)
    F = fn(detAF / detA)
    -- 圓的一般方程
    ge = CircleGeneralEquation(D, E, F)
    -- 圓的標準方程
    h = fn(-D / 2)
    k = fn(-E / 2)
    r_squared = fn(h ^ 2 + k ^ 2 - F)
    se = CircleStandardEquation(h, k, r_squared)
    -- 返回兩個方程
    return "標準方程: " .. se .. "\n一般方程: " .. ge
end
calc_methods["cesd"] = CircleEquationssd
methods_desc["cesd"] = "已知圓上不同三點的座標，求圓方程"

-- 求解一元一次方程:ax+b=0
local function solveLinearEquation(a, b)
    -- 檢查a是否為0，因為如果a為0，方程將不再是一元一次方程
    if a == 0 then
        if b == 0 then
            return "方程有無數解"
        else
            return "方程無解"
        end
    else
        -- 計算x的值
        local x = fn(-b / a)
        return "x=" .. x
    end
end
calc_methods["yyyc"] = solveLinearEquation
methods_desc["yyyc"] = "求解一元一次方程"

-- 求解二元一次方程組：ax+by=e，cx+dy=f
local function solveLinearSystem(a, b, c, d, e, f)
    local D, x, y
    -- 計算行列式D
    D = a * d - b * c
    -- 檢查方程組是否有解
    if D == 0 then
        if (a * f - c * e) == 0 and (b * e - d * f) == 0 then
            return "方程組有無窮多解"
        else
            return "方程組無解"
        end
    end
    -- 計算x和y
    x = fn((d * e - b * f) / D)
    y = fn((a * f - c * e) / D)
    -- 返回解的字元串表示
    return "x=" .. x .. "\ny=" .. y
end
calc_methods["eyyc"] = solveLinearSystem
methods_desc["eyyc"] = "求解二元一次方程組ax+by=e，cx+dy=f"

-- 點斜法求解一次函數解析式
-- 定義函數，輸入斜率k和點的座標(x₁, y₁)
local function pointSlopeForm(k, x1, y1)
    local le = LineEquation(x1, y1, k)
    return "直線方程: " .. le
end
calc_methods["dxf"] = pointSlopeForm
methods_desc["dxf"] = "點斜法求解一次函數解析式"

-- 兩點法求解一次函數解析式
-- 定義函數，輸入兩點座標(x₁, y₁)、(x₂,y₂)
local function twoPointsForm(x1, y1, x2, y2)
    -- 檢查兩點是否相同
    if x1 == x2 and y1 == y2 then
        return "錯誤：兩點座標完全相同，無法確定直線方程"
    end
    local k, le
    -- 計算斜率k
    if x1 == x2 then
        k = nil
    else
        k = (y2 - y1) / (x2 - x1)
        k = fn(k)
    end
    le = LineEquation(x1, y1, k)
    return "直線方程: " .. le
end
calc_methods["ldf"] = twoPointsForm
methods_desc["ldf"] = "兩點法求解一次函數解析式"

-- 求解一元二次方程ax²+bx+c=0
local function solveQuadraticEquation(a, b, c)
    -- 檢查參數正確性
    if type(a) ~= "number" or type(b) ~= "number" or type(c) ~= "number" then
        return "錯誤：系數必須是數字"
    end
    if a == 0 then
        return "錯誤：二次項系數不能為0"
    end
    local Delta, x1, x2, P, Q
    Delta = b ^ 2 - 4 * a * c
    P = fn(-b / (2 * a))
    if Delta == 0 then
        x1 = P
        return "x₁=x₂=" .. x1
    elseif Delta > 0 then
        Q = fn(math.sqrt(Delta) / (2 * a))
        x1 = P + Q
        x2 = P - Q
    else
        Q = fn(math.sqrt(-Delta) / (2 * a))
        if P == 0 then
            if Q == 1 then
                x1 = "i"
                x2 = "-i"
            elseif Q == -1 then
                x1 = "-i"
                x2 = "i"
            else
                x1 = Q .. "i"
                x2 = -Q .. "i"
            end
        else
            if Q == 1 then
                x1 = P .. "+i"
                x2 = P .. "-i"
            elseif Q == -1 then
                x1 = P .. "-i"
                x2 = P .. "+i"
            elseif Q > 0 then
                x1 = P .. "+" .. Q .. "i"
                x2 = P .. "-" .. Q .. "i"
            else
                x1 = P .. "-" .. -Q .. "i"
                x2 = P .. "+" .. -Q .. "i"
            end
        end
    end
    return "x₁=" .. x1 .. "\nx₂=" .. x2
end
calc_methods["yyec"] = solveQuadraticEquation
methods_desc["yyec"] = "求解一元二次方程"

-- 求解一元三次方程ax³+bx²+cx+d=0
local function solveCubicEquation(a, b, c, d)
    -- 檢查參數正確性
    if type(a) ~= "number" or type(b) ~= "number" or type(c) ~= "number" or type(d) ~= "number" then
        return "錯誤：系數必須是數字"
    end
    if a == 0 then
        return "錯誤：系數a不能為零"
    end
    -- 計算重根判別式
    local A, B, C, Delta
    A = b ^ 2 - 3 * a * c
    B = b * c - 9 * a * d
    C = c ^ 2 - 3 * b * d
    -- 計算總判別式
    Delta = B ^ 2 - 4 * A * C
    -- 根據盛金公式進行求解
    -- 情況1：A = B = 0，方程有一個三重實根
    if A == 0 and B == 0 then
        local x = fn(-b / (3 * a))
        return "x₁=x₂=x₃=" .. x
        -- 情況2：Delta > 0，方程有一個實根和一對共軛虛根
    elseif Delta > 0 then
        local Y1, Y2, y1, y2, x1, x2, x3, P, Q
        Y1 = A * b + 3 * a * (-B + math.sqrt(Delta)) / 2
        Y2 = A * b + 3 * a * (-B - math.sqrt(Delta)) / 2
        y1 = nth_root(Y1, 3)
        y2 = nth_root(Y2, 3)
        x1 = fn((-b - y1 - y2) / (3 * a))
        P = fn((-b + 0.5 * (y1 + y2)) / (3 * a))
        Q = fn((0.5 * math.sqrt(3) * (y1 - y2)) / (3 * a))
        if P == 0 then
            if Q == 1 then
                x2 = "i"
                x3 = "-i"
            elseif Q == -1 then
                x2 = "-i"
                x3 = "i"
            else
                x2 = Q .. "i"
                x3 = -Q .. "i"
            end
        elseif P ~= 0 and Q == 1 then
            x2 = P .. "+i"
            x3 = P .. "-i"
        elseif P ~= 0 and Q == -1 then
            x2 = P .. "-i"
            x3 = P .. "+i"
        elseif P ~= 0 and Q > 0 then
            x2 = P .. "+" .. Q .. "i"
            x3 = P .. "-" .. Q .. "i"
        elseif P ~= 0 and Q < 0 then
            x2 = P .. "-" .. -Q .. "i"
            x3 = P .. "+" .. -Q .. "i"
        end
        return "x₁=" .. x1 .. "\nx₂=" .. x2 .. "\nx₃=" .. x3
        -- 情況3：Delta = 0，方程有三個實根，其中有一個兩重根
    elseif Delta == 0 and A ~= 0 then
        local K, x1, x2
        K = B / A
        x1 = fn(-b / a + K)
        x2 = fn(-0.5 * K)
        return "x₁=" .. x1 .. "\nx₂=x₃=" .. x2
    elseif Delta < 0 and A > 0 then
        -- 情況4：Delta < 0，方程有三個不相等的實根
        local T, M, S, R, x1, x2, x3
        T = (2 * A * b - 3 * a * B) / (2 * math.sqrt(A ^ 3))
        M = acos(T)
        S = cos(M / 3)
        R = sin(M / 3)
        x1 = fn((-b - 2 * math.sqrt(A) * S) / (3 * a))
        x2 = fn((-b + math.sqrt(A) * (S + math.sqrt(3) * R)) / (3 * a))
        x3 = fn((-b + math.sqrt(A) * (S - math.sqrt(3) * R)) / (3 * a))
        return "x₁=" .. x1 .. "\nx₂=" .. x2 .. "\nx₃=" .. x3
    end
end
calc_methods["yysc1"] = solveCubicEquation
methods_desc["yysc1"] = "求解一元三次方程"

-- 求解一元四次方程ax⁴+bx³+cx²+dx+e=0
local function solveQuarticEquation(a, b, c, d, e)
    -- 檢查參數正確性
    if type(a) ~= "number" or type(b) ~= "number" or type(c) ~= "number" or type(d) ~= "number" or type(e) ~= "number" then
        return "錯誤：系數必須是數字"
    end
    if a == 0 then
        return "錯誤：系數a不能為零"
    end
    -- 計算重根判別式
    local D, E, F, A, B, C, Delta
    D = 3 * b ^ 2 - 8 * a * c
    E = -b ^ 3 + 4 * a * b * c - 8 * a ^ 2 * d
    F = 3 * b ^ 4 + 16 * a ^ 2 * c ^ 2 - 16 * a * b ^ 2 * c + 16 * a ^ 2 * b * d - 64 * a ^ 3 * e
    A = D ^ 2 - 3 * F
    B = D * F - 9 * E ^ 2
    C = F ^ 2 - 3 * D * E ^ 2
    -- 計算總判別式
    Delta = B ^ 2 - 4 * A * C
    -- 符號因子函數
    local function sgn(x)
        if x == 0 then
            return 0
        else
            return fn(math.abs(x) / x)
        end
    end
    -- 根據天珩公式求解四次方程
    -- 情況1:當D=E=F=0時，方程有一個四重實根
    if D == 0 and E == 0 and F == 0 then
        local x
        x = fn(-b / (4 * a))
        return "x₁=x₂=x₃=x₄=" .. x
    end
    -- 情況2:當DEF≠0，A=B=C=0時，方程有四個實根，其中有一個三重根
    if (D * E * F ~= 0) and (A == 0 and B == 0 and C == 0) then
        local x1, x2
        x1 = fn((-b * D + 9 * E) / (4 * a * D))
        x2 = fn((-b * D - 3 * E) / (4 * a * D))
        return "x₁=" .. x1 .. "\nx₂=x₃=x₄=" .. x2
    end
    -- 情況3:當E=F=0，D≠0時，方程有兩對二重根；若D＞0，根為實數；若D＜0，根為虛數
    if E == 0 and F == 0 and D ~= 0 then
        local x1, x2, P, Q
        if D > 0 then
            x1 = fn((-b + math.sqrt(D)) / (4 * a))
            x2 = fn((-b - math.sqrt(D)) / (4 * a))
        else
            P = fn(-b / (4 * a))
            Q = fn(math.sqrt(-D) / (4 * a))
            if P == 0 then
                if Q == 1 then
                    x1 = "i"
                    x2 = "-i"
                elseif Q == -1 then
                    x1 = "-i"
                    x2 = "i"
                else
                    x1 = Q .. "i"
                    x2 = -Q .. "i"
                end
            else
                if Q == 1 then
                    x1 = P .. "+i"
                    x2 = P .. "-i"
                elseif Q == -1 then
                    x1 = P .. "-i"
                    x2 = P .. "+i"
                elseif Q > 0 then
                    x1 = P .. "+" .. Q .. "i"
                    x2 = P .. "-" .. Q .. "i"
                else
                    x1 = P .. "-" .. -Q .. "i"
                    x2 = P .. "+" .. -Q .. "i"
                end
            end
        end
        return "x₁=x₂=" .. x1 .. "\nx₃=x₄=" .. x2
    end
    -- 情況4:當ABC≠0，Δ=0時，方程有一對二重實根；
    -- 若AB＞0，則其餘兩根為不等實根；若AB＜0，則其餘兩根為共軛虛根
    if (A * B * C ~= 0) and (Delta == 0) then
        local P, Q, R, x1, x2, x3
        P = -b / (4 * a)
        Q = 2 * A * E / (4 * a * B)
        x1 = fn(P - Q)
        if A * B > 0 then
            R = math.sqrt(2 * B / A) / (4 * a)
            x2 = fn(P + Q + R)
            x3 = fn(P + Q - R)
        else
            R = fn(math.sqrt(-2 * B / A) / (4 * a))
            if (P + Q) == 0 then
                if R == 1 then
                    x2 = "i"
                    x3 = "-i"
                elseif R == -1 then
                    x2 = "-i"
                    x3 = "i"
                else
                    x2 = R .. "i"
                    x3 = -R .. "i"
                end
            else
                if R == 1 then
                    x2 = fn(P + Q) .. "+i"
                    x3 = fn(P + Q) .. "-i"
                elseif R == -1 then
                    x2 = fn(P + Q) .. "-i"
                    x3 = fn(P + Q) .. "+i"
                elseif R > 0 then
                    x2 = fn(P + Q) .. "+" .. R .. "i"
                    x3 = fn(P + Q) .. "-" .. R .. "i"
                else
                    x2 = fn(P + Q) .. "-" .. -R .. "i"
                    x3 = fn(P + Q) .. "+" .. -R .. "i"
                end
            end
        end
        return "x₁=x₂=" .. x1 .. "\nx₃=" .. x2 .. "\nx₄=" .. x3
    end
    -- 情況5:當Δ>0時，方程有兩個不等實根和一對共軛虛根
    if Delta > 0 then
        local z, z1, z2, z3, x1, x2, x3, x4, P, Q, R1, R2
        z1 = A * D + 3 * ((-B + math.sqrt(Delta)) / 2)
        z2 = A * D + 3 * ((-B - math.sqrt(Delta)) / 2)
        z3 = nth_root(z1, 3) + nth_root(z2, 3)
        z = D ^ 2 - D * z3 + z3 ^ 2 - 3 * A
        P = -b / (4 * a)
        Q = sgn(E) * math.sqrt((D + z3) / 3) / (4 * a)
        R1 = math.sqrt((2 * D - z3 + 2 * math.sqrt(z)) / 3) / (4 * a)
        R2 = fn(math.sqrt((-2 * D + z3 + 2 * math.sqrt(z)) / 3) / (4 * a))
        x1 = fn(P + Q + R1)
        x2 = fn(P + Q - R1)
        if (P - Q) == 0 then
            if R2 == 1 then
                x3 = "i"
                x4 = "-i"
            elseif R2 == -1 then
                x3 = "-i"
                x4 = "i"
            else
                x3 = R2 .. "i"
                x4 = -R2 .. "i"
            end
        else
            if R2 == 1 then
                x3 = fn(P - Q) .. "+i"
                x4 = fn(P - Q) .. "-i"
            elseif R2 == -1 then
                x3 = fn(P - Q) .. "-i"
                x4 = fn(P - Q) .. "+i"
            elseif R2 > 0 then
                x3 = fn(P - Q) .. "+" .. R2 .. "i"
                x4 = fn(P - Q) .. "-" .. R2 .. "i"
            else
                x3 = fn(P - Q) .. "-" .. -R2 .. "i"
                x4 = fn(P - Q) .. "+" .. -R2 .. "i"
            end
        end
        return "x₁=" .. x1 .. "\nx₂=" .. x2 .. "\nx₃=" .. x3 .. "\nx₄=" .. x4
    end
    -- 情況6:當Δ<0時，若D與F均為正數，則方程有四個不等實根；否則方程有兩對不等共軛虛根
    if Delta < 0 then
        local T, M, N, O, y1, y2, y3, x1, x2, x3, x4, P, Q1, Q2, Q3
        T = (3 * B - 2 * A * D) / (2 * A * math.sqrt(A))
        M = acos(T)
        N = cos(M / 3)
        O = sin(M / 3)
        y1 = (D - 2 * math.sqrt(A) * N) / 3
        y2 = (D + math.sqrt(A) * (N + math.sqrt(3) * O)) / 3
        y3 = (D + math.sqrt(A) * (N - math.sqrt(3) * O)) / 3
        -- 情況6.1:若E=0,D>0,F>0,方程有四實根
        if E == 0 and D > 0 and F > 0 then
            x1 = fn((-b + math.sqrt(D + 2 * math.sqrt(F))) / (4 * a))
            x2 = fn((-b - math.sqrt(D + 2 * math.sqrt(F))) / (4 * a))
            x3 = fn((-b + math.sqrt(D - 2 * math.sqrt(F))) / (4 * a))
            x4 = fn((-b - math.sqrt(D - 2 * math.sqrt(F))) / (4 * a))
            -- 情況6.2:若E=0,D<0,F>0,方程有兩對共軛虛根
        elseif E == 0 and D < 0 and F > 0 then
            P = fn(-b / (4 * a))
            Q1 = fn(math.sqrt(-D + 2 * math.sqrt(F)) / (4 * a))
            Q2 = fn(math.sqrt(-D - 2 * math.sqrt(F)) / (4 * a))
            if P == 0 then
                if Q1 == 1 then
                    x1 = "i"
                    x2 = "-i"
                elseif Q1 == -1 then
                    x1 = "-i"
                    x2 = "i"
                else
                    x1 = Q1 .. "i"
                    x2 = -Q1 .. "i"
                end
                if Q2 == 1 then
                    x3 = "i"
                    x4 = "-i"
                elseif Q2 == -1 then
                    x3 = "-i"
                    x4 = "i"
                else
                    x3 = Q2 .. "i"
                    x4 = -Q2 .. "i"
                end
            else
                if Q1 == 1 then
                    x1 = P .. "+i"
                    x2 = P .. "-i"
                elseif Q1 == -1 then
                    x1 = P .. "-i"
                    x2 = P .. "+i"
                elseif Q1 > 0 then
                    x1 = P .. "+" .. Q1 .. "i"
                    x2 = P .. "-" .. Q1 .. "i"
                else
                    x1 = P .. "-" .. -Q1 .. "i"
                    x2 = P .. "+" .. -Q1 .. "i"
                end
                if Q2 == 1 then
                    x3 = P .. "+i"
                    x4 = P .. "-i"
                elseif Q2 == -1 then
                    x3 = P .. "-i"
                    x4 = P .. "+i"
                elseif Q2 > 0 then
                    x3 = P .. "+" .. Q2 .. "i"
                    x4 = P .. "-" .. Q2 .. "i"
                else
                    x3 = P .. "-" .. -Q2 .. "i"
                    x4 = P .. "+" .. -Q2 .. "i"
                end
            end
            -- 情況6.3:若E=0,F<0,方程有兩對共軛虛根
        elseif E == 0 and F < 0 then
            P = -b / (4 * a)
            Q1 = math.sqrt(2 * D + 2 * math.sqrt(A - F)) / (8 * a)
            Q2 = fn(math.sqrt(-2 * D + 2 * math.sqrt(A - F)) / (8 * a))
            if (P + Q1) == 0 then
                if Q2 == 1 then
                    x1 = "i"
                    x2 = "-i"
                elseif Q2 == -1 then
                    x1 = "-i"
                    x2 = "i"
                else
                    x1 = Q2 .. "i"
                    x2 = -Q2 .. "i"
                end
            else
                if Q2 == 1 then
                    x1 = fn(P + Q1) .. "+i"
                    x2 = fn(P + Q1) .. "-i"
                elseif Q2 == -1 then
                    x1 = fn(P + Q1) .. "-i"
                    x2 = fn(P + Q1) .. "+i"
                elseif Q2 > 0 then
                    x1 = fn(P + Q1) .. "+" .. Q2 .. "i"
                    x2 = fn(P + Q1) .. "-" .. Q2 .. "i"
                else
                    x1 = fn(P + Q1) .. "-" .. -Q2 .. "i"
                    x2 = fn(P + Q1) .. "+" .. -Q2 .. "i"
                end
            end
            if (P - Q1) == 0 then
                if Q2 == 1 then
                    x3 = "i"
                    x4 = "-i"
                elseif Q2 == -1 then
                    x3 = "-i"
                    x4 = "i"
                else
                    x3 = Q2 .. "i"
                    x4 = -Q2 .. "i"
                end
            else
                if Q2 == 1 then
                    x3 = fn(P - Q1) .. "+i"
                    x4 = fn(P - Q1) .. "-i"
                elseif Q2 == -1 then
                    x3 = fn(P - Q1) .. "-i"
                    x4 = fn(P - Q1) .. "+i"
                elseif Q2 > 0 then
                    x3 = fn(P - Q1) .. "+" .. Q2 .. "i"
                    x4 = fn(P - Q1) .. "-" .. Q2 .. "i"
                else
                    x3 = fn(P - Q1) .. "-" .. -Q2 .. "i"
                    x4 = fn(P - Q1) .. "+" .. -Q2 .. "i"
                end
            end
            -- 情況6.4:若E≠0,當D與F均為正時，方程有四實根；否則方程有兩對共軛虛根
        elseif E ~= 0 then
            if D > 0 and F > 0 then
                P = -b / (4 * a)
                Q1 = sgn(E) * math.sqrt(y1) / (4 * a)
                Q2 = (math.sqrt(y2) + math.sqrt(y3)) / (4 * a)
                Q3 = (math.sqrt(y2) - math.sqrt(y3)) / (4 * a)
                x1 = fn(P + Q1 + Q2)
                x2 = fn(P + Q1 - Q2)
                x3 = fn(P - Q1 + Q3)
                x4 = fn(P - Q1 - Q3)
            else
                P = -b / (4 * a)
                Q1 = math.sqrt(y2) / (4 * a)
                Q2 = sgn(E) * math.sqrt(-y1) / (4 * a)
                Q3 = math.sqrt(-y3) / (4 * a)
                if (P - Q1) == 0 then
                    if (Q2 + Q3) == 1 then
                        x1 = "i"
                        x2 = "-i"
                    elseif (Q2 + Q3) == -1 then
                        x1 = "-i"
                        x2 = "i"
                    else
                        x1 = fn(Q2 + Q3) .. "i"
                        x2 = -fn(Q2 + Q3) .. "i"
                    end
                else
                    if fn(Q2 + Q3) == 1 then
                        x1 = fn(P - Q1) .. "+i"
                        x2 = fn(P - Q1) .. "-i"
                    elseif fn(Q2 + Q3) == -1 then
                        x1 = fn(P - Q1) .. "-i"
                        x2 = fn(P - Q1) .. "+i"
                    elseif fn(Q2 + Q3) > 0 then
                        x1 = fn(P - Q1) .. "+" .. fn(Q2 + Q3) .. "i"
                        x2 = fn(P - Q1) .. "-" .. fn(Q2 + Q3) .. "i"
                    else
                        x1 = fn(P - Q1) .. "-" .. -fn(Q2 + Q3) .. "i"
                        x2 = fn(P - Q1) .. "+" .. -fn(Q2 + Q3) .. "i"
                    end
                end
                if (P + Q1) == 0 then
                    if fn(Q2 - Q3) == 1 then
                        x3 = "i"
                        x4 = "-i"
                    elseif fn(Q2 - Q3) == -1 then
                        x3 = "-i"
                        x4 = "i"
                    else
                        x3 = fn(Q2 - Q3) .. "i"
                        x4 = -fn(Q2 - Q3) .. "i"
                    end
                else
                    if fn(Q2 - Q3) == 1 then
                        x3 = fn(P + Q1) .. "+i"
                        x4 = fn(P + Q1) .. "-i"
                    elseif fn(Q2 - Q3) == -1 then
                        x3 = fn(P + Q1) .. "-i"
                        x4 = fn(P + Q1) .. "+i"
                    elseif fn(Q2 - Q3) > 0 then
                        x3 = fn(P + Q1) .. "+" .. fn(Q2 - Q3) .. "i"
                        x4 = fn(P + Q1) .. "-" .. fn(Q2 - Q3) .. "i"
                    else
                        x3 = fn(P + Q1) .. "-" .. -fn(Q2 - Q3) .. "i"
                        x4 = fn(P + Q1) .. "+" .. -fn(Q2 - Q3) .. "i"
                    end
                end
            end
        end
        return "x₁=" .. x1 .. "\nx₂=" .. x2 .. "\nx₃=" .. x3 .. "\nx₄=" .. x4
    end
end
calc_methods["yysc2"] = solveQuarticEquation
methods_desc["yysc2"] = "求解一元四次方程"

-- 頂點式求解二次函數解析式：y=a(x-h)²+k
-- (x₁,y₁)為頂點座標，(x₂,y₂)為其函數圖像上除頂點座標外任意一點座標
local function getQuadraticEquationdd(x1, y1, x2, y2)
    -- 檢查兩個點是否相同
    if x1 == x2 or y1 == y2 then
        return "錯誤：兩個點的橫座標不能相同"
    end
    local a, b, c, qe
    a = fn((y2 - y1) / (x2 - x1) ^ 2)
    b = fn(-2 * a * x1)
    c = fn(y1 + a * x1 ^ 2)
    qe = QuadraticEquation(a, b, c)
    return "二次函數解析式為：" .. qe
end
calc_methods["dds"] = getQuadraticEquationdd
methods_desc["dds"] = "頂點式求解二次函數解析式"

-- 一般式求解二次函數解析式
local function getQuadraticEquationy(x1, y1, x2, y2, x3, y3)
    local A, B, detA, detAx, detAy, detAz, a, b, c, qe, determinant
    -- 檢查三個點是否共線
    determinant = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)
    if determinant == 0 then
        return "錯誤：三個點共線或重合，無法求解二次函數解析式"
    end
    -- 構建方程組的系數矩陣和常數矩陣
    A = {
        { x1 ^ 2, x1, 1 },
        { x2 ^ 2, x2, 1 },
        { x3 ^ 2, x3, 1 }
    }
    B = {
        (y1),
        (y2),
        (y3)
    }
    -- 計算系數矩陣A的行列式detA
    detA = hls(A[1][1], A[1][2], A[1][3], A[2][1], A[2][2], A[2][3], A[3][1], A[3][2], A[3][3])
    -- 計算行列式detAx，detAy，detAz
    detAx = hls(B[1], A[1][2], A[1][3], B[2], A[2][2], A[2][3], B[3], A[3][2], A[3][3])
    detAy = hls(A[1][1], B[1], A[1][3], A[2][1], B[2], A[2][3], A[3][1], B[3], A[3][3])
    detAz = hls(A[1][1], A[1][2], B[1], A[2][1], A[2][2], B[2], A[3][1], A[3][2], B[3])
    -- 計算系數a，b，c
    a = fn(detAx / detA)
    b = fn(detAy / detA)
    c = fn(detAz / detA)
    qe = QuadraticEquation(a, b, c)
    return "二次函數解析式為：" .. qe
end
calc_methods["ybs"] = getQuadraticEquationy
methods_desc["ybs"] = "一般式求解二次函數解析式"

-- 已知三角形的三邊a、b、c，求三角形面積
local function calculateTriangleArea(a, b, c)
    -- 檢查是否能構成三角形
    if a + b <= c or a + c <= b or b + c <= a then
        return "錯誤：不能構成三角形"
    end
    local p, s
    -- 計算半周長
    p = (a + b + c) / 2
    -- 使用海倫公式計算面積
    s = math.sqrt(p * (p - a) * (p - b) * (p - c))
    return fn(s)
end
calc_methods["sjx1"] = calculateTriangleArea
methods_desc["sjx1"] = "已知三角形的三邊長a、b、c，求三角形面積"

-- 已知三角形的三個頂點座標(x₁, y₁)，(x₂, y₂)，(x₃, y₃)，求三角形面積
local function calculateTriangleArea2(x1, y1, x2, y2, x3, y3)
    -- 檢查參數正確性
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" or type(x3) ~= "number" or type(y3) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    local determinant, s
    determinant = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)
    -- 檢查是否能構成三角形
    if determinant == 0 then
        return "錯誤：三個點重合或共線，不能構成三角形"
    end
    -- 計算三角形面積
    s = fn(math.abs(determinant / 2))
    return s
end
calc_methods["sjx2"] = calculateTriangleArea2
methods_desc["sjx2"] = "已知三角形的三個頂點座標(x₁,y₁)，(x₂,y₂)，(x₃,y₃)，求三角形面積"

-- 已知一點(x₁, y₁)和直線方程Ax+By+C=0，求點到直線的距離和它關於直線的對稱點座標
local function dyzx1(x1, y1, A, B, C)
    -- 檢查參數正確性
    if type(x1) ~= "number" or type(y1) ~= "number" or type(A) ~= "number" or type(B) ~= "number" or type(C) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    if A == 0 and B == 0 then
        return "錯誤：直線方程的系數不能同時為零"
    end
    local S, D, s, x, y
    -- 判斷點是否在直線上
    S = A * x1 + B * y1 + C
    if S == 0 then
        return "點在直線上，距離為0，無法求解對稱點座標"
    end
    -- 計算點到直線的距離
    D = fn(math.abs(S) / math.sqrt(A ^ 2 + B ^ 2))
    -- 計算對稱點座標
    s = S / (A ^ 2 + B ^ 2)
    x = fn(x1 - 2 * A * s)
    y = fn(y1 - 2 * B * s)
    return "點到直線距離為" .. D .. "\n點關於直線的對稱點座標為(" .. x .. "," .. y .. ")"
end
calc_methods["dyzx1"] = dyzx1
methods_desc["dyzx1"] = "已知一點座標(x₁, y₁)和直線方程Ax+By+C=0，求點到直線的距離及對稱點座標"

-- 已知兩點(x₁, y₁)和(x₂, y₂)，求兩點間的距離
local function ld1(x1, y1, x2, y2)
    -- 檢查參數正確性
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    -- 判斷兩點是否重合
    if x1 == x2 and y1 == y2 then
        return "兩點重合，距離為0"
    end
    -- 計算兩點間的距離
    local D = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    return fn(D)
end
calc_methods["ld1"] = ld1
methods_desc["ld1"] = "已知兩點座標，求兩點間的距離"

-- 已知兩點(x₁, y₁)和(x₂, y₂)，求兩點連線的垂直平分線方程
local function ld2(x1, y1, x2, y2)
    -- 檢查參數正確性
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    if x1 == x2 and y1 == y2 then
        return "錯誤：兩點重合，無法求解垂直平分線方程"
    end
    local x3, y3, k, kl, se
    -- 兩點所成線段的中點座標
    x3 = fn((x1 + x2) / 2)
    y3 = fn((y1 + y2) / 2)
    if x1 == x2 then
        k = nil
        kl = 0
    else
        k = (y2 - y1) / (x2 - x1)
        if k == 0 then
            kl = nil
        else
            kl = -1 / k
            kl = fn(kl)
        end
    end
    se = LineEquation(x3, y3, kl)
    return "垂直平分線方程為：" .. se
end
calc_methods["ld2"] = ld2
methods_desc["ld2"] = "已知兩點座標，求兩點間線段的垂直平分線方程"

-- 已知兩點P(x₁, y₁)和Q(x₂, y₂)，求點P繞點Q旋轉角度a(角度制)後的P'座標
-- 逆時針時a為正，順時針時a為負
local function ld3(x1, y1, x2, y2, a)
    -- 檢查參數正確性
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" or type(a) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    -- 計算旋轉角度的弧度值
    local a1, x, y
    a1 = rad(a)
    -- 計算旋轉後的點座標
    x = fn(x2 + (x1 - x2) * cos(a1) - (y1 - y2) * sin(a1))
    y = fn(y2 + (x1 - x2) * sin(a1) + (y1 - y2) * cos(a1))
    return "點P(" .. x1 .. "," .. y1 .. ")繞點Q(" .. x2 .. "," .. y2 .. ")旋轉" .. a .. "°後的P'座標為(" .. x .. "," .. y .. ")"
end
calc_methods["ld3"] = ld3
methods_desc["ld3"] = "已知兩點P(x₁, y₁)和Q(x₂, y₂)，求點P繞點Q旋轉角度a(角度制)後的P'座標"

-- 已知兩條直線方程 A₁x+B₁y+C₁=0和 A₂x+B₂y+C₂=0，判斷它們的位置關係
local function lines_relationship(A1, B1, C1, A2, B2, C2)
    -- 參數正確性檢查
    if (A1 == 0 and B1 == 0) or (A2 == 0 and B2 == 0) then
        return "錯誤：直線方程的系數不能同時為零"
    end
    local px, ch, D, x, y, k
    -- 判斷兩直線是否平行或重合的條件
    px = (A1 * B2 == A2 * B1) and (A1 * C2 ~= A2 * C1)
    ch = (A1 * B2 == A2 * B1) and (C1 * B2 == C2 * B1) and (C1 * A2 == C2 * A1)
    -- 兩直線重合
    if ch then
        return "兩直線重合，距離為0"
        -- 兩直線平行但不重合，計算距離
    elseif px then
        if B1 ~= B2 then
            k = math.max(B1, B2) / math.min(B1, B2)
            if B1 < B2 then
                A1 = A1 * k
                B1 = B1 * k
                C1 = C1 * k
            else
                C2 = C2 * k
            end
        end
        D = fn(math.abs(C2 - C1) / math.sqrt(A1 ^ 2 + B1 ^ 2))
        return "兩直線平行，距離為" .. D
        -- 兩直線相交，計算交點座標
    else
        x = fn((B1 * C2 - B2 * C1) / (A1 * B2 - A2 * B1))
        y = fn((C1 * A2 - C2 * A1) / (A1 * B2 - A2 * B1))
        return "兩直線相交，交點座標為(" .. x .. "," .. y .. ")"
    end
end
calc_methods["lzx1"] = lines_relationship
methods_desc["lzx1"] = "已知兩直線方程A₁x+B₁y+C₁=0和A₂x+B₂y+C₂=0，判斷它們的位置關係"

-- 已知三角形的三邊a、b、c，求內切圓半徑和外接圓半徑
local function triangle_circles(a, b, c)
    -- 參數正確性檢查
    if a <= 0 or b <= 0 or c <= 0 then
        return "錯誤：邊長必須為正數"
    end
    -- 檢查能否構成三角形
    if a + b <= c or a + c <= b or b + c <= a then
        return "錯誤：給定的邊長不能構成三角形"
    end
    local s, A, r, R
    -- 計算半周長
    s = (a + b + c) / 2
    -- 計算面積
    A = math.sqrt(s * (s - a) * (s - b) * (s - c))
    -- 計算內切圓半徑
    r = fn(A / s)
    -- 計算外接圓半徑
    R = fn((a * b * c) / (4 * A))
    return "內切圓半徑為" .. r .. "\n外接圓半徑為" .. R
end
calc_methods["sjxy1"] = triangle_circles
methods_desc["sjxy1"] = "已知三角形三邊長，求內切圓半徑和外接圓半徑"

-- 已知三角形三個頂點座標(x₁,y₁)，(x₂,y₂)，(x₃,y₃)，求其內切圓半徑和外接圓半徑
local function triangle_circles_by_points(x1, y1, x2, y2, x3, y3)
    -- 參數正確性檢查
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" or type(x3) ~= "number" or type(y3) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    local a, b, c
    -- 檢查三個點是否共線
    if x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2) == 0 then
        return "錯誤：三個點共線或重合，無法構成三角形"
    end
    -- 計算三邊長
    a = ld1(x1, y1, x2, y2)
    b = ld1(x2, y2, x3, y3)
    c = ld1(x1, y1, x3, y3)
    -- 調用已知三邊長的函數計算內切圓半徑和外接圓半徑
    return triangle_circles(a, b, c)
end
calc_methods["sjxy2"] = triangle_circles_by_points
methods_desc["sjxy2"] = "已知三角形三個頂點座標，求內切圓半徑和外接圓半徑"

-- 已知三角形三個頂點座標A(x₁,y₁)，B(x₂,y₂)，C(x₃,y₃)，求其“心”的座標
local function triangle_centers(x1, y1, x2, y2, x3, y3)
    -- 參數正確性檢查
    if type(x1) ~= "number" or type(y1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" or type(x3) ~= "number" or type(y3) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    local determinant, a, b, c, xg, yg, xn, yn, xw, yw, xc, yc, d1, s1, s2
    -- 檢查三個點是否共線
    determinant = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)
    if determinant == 0 then
        return "錯誤：三個點共線或重合，無法構成三角形"
    end
    -- 計算三邊長
    a = ld1(x2, y2, x3, y3)
    b = ld1(x1, y1, x3, y3)
    c = ld1(x1, y1, x2, y2)
    -- 計算重心座標
    xg = fn((x1 + x2 + x3) / 3)
    yg = fn((y1 + y2 + y3) / 3)
    -- 計算內心座標
    xn = fn((a * x1 + b * x2 + c * x3) / (a + b + c))
    yn = fn((a * y1 + b * y2 + c * y3) / (a + b + c))
    -- 計算外心座標
    d1 = 2 * determinant
    xw = fn(((x1 ^ 2 + y1 ^ 2) * (y2 - y3) + (x2 ^ 2 + y2 ^ 2) * (y3 - y1) + (x3 ^ 2 + y3 ^ 2) * (y1 - y2)) / d1)
    yw = fn(((x1 ^ 2 + y1 ^ 2) * (x3 - x2) + (x2 ^ 2 + y2 ^ 2) * (x1 - x3) + (x3 ^ 2 + y3 ^ 2) * (x2 - x1)) / d1)
    -- 計算垂心座標
    s1 = x1 * (x2 * (y1 - y2) + x3 * (y3 - y1)) + (y2 - y3) * (x2 * x3 + (y1 - y2) * (y1 - y3))
    s2 = x1 ^ 2 * (x2 - x3) + x1 * (x3 ^ 2 - x2 ^ 2 + y1 * y2 - y1 * y3) + x2 ^ 2 * x3 -
        x2 * (x3 ^ 2 + y1 * y2 - y2 * y3) +
        x3 * y3 * (y1 - y2)
    xc = fn(s1 / -determinant)
    yc = fn(s2 / determinant)
    return "重心(" .. xg .. "," .. yg .. ")\n內心(" .. xn .. "," .. yn .. ")\n外心(" .. xw ..
        "," .. yw .. ")\n垂心(" .. xc .. "," .. yc .. ")"
end
calc_methods["sjxx"] = triangle_centers
methods_desc["sjxx"] = "已知三角形三個頂點座標，求其“心”的座標"

-- 計算排列數
local function permutation(n, r)
    -- 參數檢查
    if type(n) ~= "number" or type(r) ~= "number" then
        return "錯誤：參數必須為數字"
    end
    if n < 0 or r < 0 or n ~= math.floor(n) or r ~= math.floor(r) then
        return "錯誤：參數必須為非負整數"
    end
    if r > n then
        return "錯誤：第二個參數不能大於第一個參數"
    end
    -- 特殊情況處理
    if r == 0 then return 1 end
    if r == 1 then return n end
    -- 創建分子和分母的因數數組
    local numerator_factors = {}
    local denominator_factors = {}
    -- 填充分子因數 (1 到 n)
    for i = 1, n do
        table.insert(numerator_factors, i)
    end
    -- 填充分母因數 (1 到 n-r)
    for i = 1, n-r do
        table.insert(denominator_factors, i)
    end
    -- 約分過程
    for i = 1, #denominator_factors do
        local d = denominator_factors[i]
        for j = 1, #numerator_factors do
            local n = numerator_factors[j]
            local gcd_value = gcd(n, d)
            if gcd_value > 1 then
                numerator_factors[j] = n / gcd_value
                denominator_factors[i] = d / gcd_value
                d = denominator_factors[i] -- 更新d值
            end
        end
    end
    -- 計算最終結果（此時分母應全部為1）
    local result = 1
    for _, v in ipairs(numerator_factors) do
        result = result * v
    end
    return result
end
calc_methods["pls"] = permutation
methods_desc["pls"] = "計算排列數"

-- 計算組合數
local function combination(n, r)
    -- 參數檢查
    if type(n) ~= "number" or type(r) ~= "number" then
        return "錯誤：參數必須為數字"
    end
    if n < 0 or r < 0 or n ~= math.floor(n) or r ~= math.floor(r) then
        return "錯誤：參數必須為非負整數"
    end
    if r > n then
        return "錯誤：第二個參數不能大於第一個參數"
    end
    -- 使用組合數性質 C(n,r) = C(n,n-r) 減少計算量
    r = math.min(r, n - r)
    if r == 0 or r == n then return 1 end
    if r == 1 or r == n-1 then return n end
    -- 創建分子和分母的因數數組
    local numerator_factors = {}
    local denominator_factors = {}
    -- 填充分子因數 (n-r+1 到 n)
    for i = n - r + 1, n do
        table.insert(numerator_factors, i)
    end
    -- 填充分母因數 (1 到 r)
    for i = 1, r do
        table.insert(denominator_factors, i)
    end
    -- 約分過程
    for i = 1, #denominator_factors do
        local d = denominator_factors[i]
        for j = 1, #numerator_factors do
            local n = numerator_factors[j]
            local gcd_value = gcd(n, d)
            if gcd_value > 1 then
                numerator_factors[j] = n / gcd_value
                denominator_factors[i] = d / gcd_value
                d = denominator_factors[i] -- 更新d值
            end
        end
    end
    -- 計算最終結果（此時分母應全部為1）
    local result = 1
    for _, v in ipairs(numerator_factors) do
        result = result * v
    end
    return result
end
calc_methods["zhs"] = combination
methods_desc["zhs"] = "計算組合數"

-- 已知直線l₁:A₁x+B₁y+C₁=0和l₂:A₂x+B₂y+C₂=0，求兩條直線以彼此為軸的對稱直線方程
local function symmetry_line(A1, B1, C1, A2, B2, C2)
    -- 檢查參數正確性
    if type(A1) ~= "number" or type(B1) ~= "number" or type(C1) ~= "number" or type(A2) ~= "number" or type(B2) ~= "number" or type(C2) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    if (A1 == 0 and B1 == 0) or (A2 == 0 and B2 == 0) then
        return "錯誤：直線方程的系數不能同時為零"
    end
    -- 計算對稱直線方程的系數
    local a1, a2, b, A3, B3, C3, A4, B4, C4, ge1, ge2
    a1 = A2 ^ 2 + B2 ^ 2
    b = 2 * (A1 * A2 + B1 * B2)
    A3 = a1 * A1 - b * A2
    B3 = a1 * B1 - b * B2
    C3 = a1 * C1 - b * C2
    a2 = A1 ^ 2 + B1 ^ 2
    A4 = a2 * A2 - b * A1
    B4 = a2 * B2 - b * B1
    C4 = a2 * C2 - b * C1
    ge1 = LineGeneralEquation(A3, B3, C3)
    ge2 = LineGeneralEquation(A4, B4, C4)
    return "直線l₁關於l₂的對稱直線l₃的方程為：" .. ge1 .. "\n直線l₂關於l₁的對稱直線l₄的方程為：" .. ge2
end
calc_methods["lzx2"] = symmetry_line
methods_desc["lzx2"] = "已知直線l₁:A₁x+B₁y+C₁=0和l₂:A₂x+B₂y+C₂=0，求兩條直線以彼此為軸的對稱直線方程"

-- 已知一點P(x₁,y₁)和直線l:Ax+By+C=0，求直線l關於點P的對稱直線l'的方程
local function dyzx2(x1, y1, A, B, C)
    -- 檢查參數正確性
    if type(x1) ~= "number" or type(y1) ~= "number" or type(A) ~= "number" or type(B) ~= "number" or type(C) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    if A == 0 and B == 0 then
        return "直線方程的系數不能同時為零"
    end
    local A1, B1, C1, ge
    -- 計算對稱直線方程的系數
    A1 = A
    B1 = B
    C1 = -(2 * A * x1 + 2 * B * y1 + C)
    ge = LineGeneralEquation(A1, B1, C1)
    return "直線l關於點P的對稱直線l'的方程為：" .. ge
end
calc_methods["dyzx2"] = dyzx2
methods_desc["dyzx2"] = "已知一點P(x₁,y₁)和直線l:Ax+By+C=0，求直線l關於點P的對稱直線l'的方程"

-- 已知兩圓標準方程(x-x₁)²+(y-y₁)²=r₁²和(x-x₂)²+(y-y₂)²=r₂²，判斷它們的位置關係
local function tcr1(x1, y1, r1, x2, y2, r2)
    -- 參數正確性檢查
    if type(x1) ~= "number" or type(y1) ~= "number" or type(r1) ~= "number" or type(x2) ~= "number" or type(y2) ~= "number" or type(r2) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    if r1 <= 0 or r2 <= 0 then
        return "錯誤：半徑必須為正數"
    end
    -- 特殊情況:兩圓重合
    if x1 == x2 and y1 == y2 and r1 == r2 then
        return "兩圓重合"
    end
    local d, a, h, m, n, xj1, xj2, yj1, yj2, dj, e
    -- 計算兩圓圓心距
    d = fn(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))
    -- 判斷位置關係
    -- 兩圓相離
    if d > (r1 + r2) then
        return "兩圓外離，圓心距為" .. d .. "，無交點"
    elseif d < math.abs(r1 - r2) then
        return "兩圓內含，圓心距為" .. d .. "，無交點"
    end
    -- 兩圓相交或相切，先計算相關參數
    a = (r1 ^ 2 - r2 ^ 2 + d ^ 2) / (2 * d)
    h = math.sqrt(r1 ^ 2 - a ^ 2)
    m = (x2 - x1) / d
    n = (y2 - y1) / d
    -- 計算交點座標
    xj1 = fn(x1 + a * m + h * n)
    yj1 = fn(y1 + a * n - h * m)
    xj2 = fn(x1 + a * m - h * n)
    yj2 = fn(y1 + a * n + h * m)
    e = 1e-8
    -- 精度控制，防止浮點數誤差導致結果不准確
    if math.abs(xj1) < e then
        xj1 = 0
    end
    if math.abs(yj1) < e then
        yj1 = 0
    end
    if math.abs(xj2) < e then
        xj2 = 0
    end
    if math.abs(yj2) < e then
        yj2 = 0
    end
    -- 計算相交弦弦長
    dj = fn(math.sqrt((xj2 - xj1) ^ 2 + (yj2 - yj1) ^ 2))
    -- 判斷相切或相交，並給出交點座標、圓心距和相交弦長
    if d == (r1 + r2) then
        return "兩圓外切，圓心距為" .. d .. "\n交點座標為(" .. xj1 .. "," .. yj1 .. ")"
    elseif d == math.abs(r1 - r2) then
        return "兩圓內切，圓心距為" .. d .. "\n交點座標為(" .. xj1 .. "," .. yj1 .. ")"
    elseif math.abs(r1 - r2) < d and d < (r1 + r2) then
        return "兩圓相交，圓心距為" .. d .. "\n交點座標為(" .. xj1 .. "," .. yj1 .. ")和(" .. xj2 .. "," .. yj2 .. ")\n相交弦弦長為" .. dj
    end
end
calc_methods["tcr1"] = tcr1
methods_desc["tcr1"] = "已知兩圓標準方程(x-x₁)²+(y-y₁)²=r₁²和(x-x₂)²+(y-y₂)²=r₂²，判斷它們的位置關係"

-- 已知兩圓一般方程x²+y²+D₁x+E₁y+F₁=0和x²+y²+D₂x+E₂y+F₂=0，判斷它們的位置關係
local function tcr2(D1, E1, F1, D2, E2, F2)
    -- 參數正確性檢查
    if type(D1) ~= "number" or type(E1) ~= "number" or type(F1) ~= "number" or type(D2) ~= "number" or type(E2) ~= "number" or type(F2) ~= "number" then
        return "錯誤：參數必須是數字"
    end
    local x1, y1, x2, y2, r1, r2
    -- 計算兩圓圓心，半徑，圓心距
    x1 = -D1 / 2
    y1 = -E1 / 2
    x2 = -D2 / 2
    y2 = -E2 / 2
    r1 = math.sqrt(x1 ^ 2 + y1 ^ 2 - F1)
    r2 = math.sqrt(x2 ^ 2 + y2 ^ 2 - F2)
    -- 調用函數輸出結果
    return tcr1(x1, y1, r1, x2, y2, r2)
end
calc_methods["tcr2"] = tcr2
methods_desc["tcr2"] = "已知兩圓一般方程x²+y²+D₁x+E₁y+F₁=0和x²+y²+D₂x+E₂y+F₂=0，判斷它們的位置關係"

-- 求解勾股數
local function ggs(...)
    local args = { ... }
    local n = #args
    if n == 0 then
        return "請輸入至少一個數"
    elseif n > 2 then
        return "最多只能輸入2個數"
    end
    local function generateTriplets(a_param)
        local results = {}
        -- 生成作為直角邊的解
        if a_param % 2 == 1 then
            local c = (a_param ^ 2 - 1) / 2
            local d = (a_param ^ 2 + 1) / 2
            local triplet = { a_param, c, d }
            table.sort(triplet)
            table.insert(results, triplet)
        else
            local c = (a_param ^ 2) / 4 - 1
            local d = (a_param ^ 2) / 4 + 1
            local triplet = { a_param, c, d }
            table.sort(triplet)
            table.insert(results, triplet)
        end
        return results
    end
    local function findHypotenuseTriplets(m)
        local results = {}
        local m_squared = m * m
        local max_a = math.floor(m / math.sqrt(2))
        for a = 1, max_a do
            local b_squared = m_squared - a * a
            if b_squared < 0 then break end
            local b = math.sqrt(b_squared)
            if b == math.floor(b) and b > a then
                local triplet = { a, b, m }
                table.sort(triplet)
                table.insert(results, triplet)
            end
        end
        return results
    end
    local function ggs1(a)
        if type(a) ~= "number" or a < 1 or a ~= math.floor(a) then
            return "參數必須是正整數"
        end
        if a % 2 == 1 and a < 3 then
            return "輸入1個參數時,奇數須大於等於3"
        elseif a % 2 == 0 and a < 4 then
            return "輸入1個參數時,偶數須大於等於4"
        end
        local results = {}
        -- 生成直角邊解
        local legTriplets = generateTriplets(a)
        for _, t in ipairs(legTriplets) do
            table.insert(results, t)
        end
        -- 生成斜邊解
        local hypoTrplets = findHypotenuseTriplets(a)
        for _, t in ipairs(hypoTrplets) do
            table.insert(results, t)
        end
        -- 去重
        local seen = {}
        local unique = {}
        for _, t in ipairs(results) do
            local key = table.concat(t, ',')
            if not seen[key] then
                seen[key] = true
                table.insert(unique, t)
            end
        end
        if #unique == 0 then
            return "無解"
        else
            local parts = {}
            for _, t in ipairs(unique) do
                table.insert(parts, string.format("(%d,%d,%d)", t[1], t[2], t[3]))
            end
            return "勾股數為: " .. table.concat(parts, " 和 ")
        end
    end
    local function ggs2(a, b)
        if type(a) ~= "number" or a < 1 or a ~= math.floor(a) or
            type(b) ~= "number" or b < 1 or b ~= math.floor(b) then
            return "參數必須是正整數"
        end
        if a == b then
            return "兩個參數不能相等"
        end
        local results = {}
        -- 兩數作為直角邊求斜邊
        local sum_sq = a ^ 2 + b ^ 2
        local c = math.sqrt(sum_sq)
        if c == math.floor(c) then
            local triplet = { a, b, c }
            table.sort(triplet)
            table.insert(results, triplet)
        end
        -- 小數作為直角邊,大數作為斜邊求另一直角邊
        local sq = math.abs(a ^ 2 - b ^ 2)
        local d = math.sqrt(sq)
        if d == math.floor(d) then
            local triplet = { a, b, d }
            table.sort(triplet)
            table.insert(results, triplet)
        end
        -- 作為生成元求三元組
        local part1 = math.abs(a ^ 2 - b ^ 2)
        local part2 = 2 * a * b
        local hypo = a ^ 2 + b ^ 2
        local triplet = { part1, part2, hypo }
        table.sort(triplet)
        table.insert(results, triplet)
        -- 去重邏輯
        local seen = {}
        local unique = {}
        for _, t in ipairs(results) do
            local key = table.concat(t, ",")
            if not seen[key] then
                seen[key] = true
                table.insert(unique, t)
            end
        end
        if #unique == 0 then
            return "無解"
        else
            local parts = {}
            for _, t in ipairs(unique) do
                table.insert(parts, string.format("(%d,%d,%d)", t[1], t[2], t[3]))
            end
            return "勾股數為: " .. table.concat(parts, " 和 ")
        end
    end
    return (n == 1) and ggs1(args[1]) or ggs2(args[1], args[2])
end
calc_methods["ggs"] = ggs
methods_desc["ggs"] = "求解勾股數"

-- 批次隨機數生成器
-- 參數模式1（3個參數）：digits（位數）、count（數量）、unique（是否唯一，0為true/1為false）
-- 參數模式2（4個參數）：min（最小值）、max（最大值）、count（數量）、unique（是否唯一）
local function generateRandomNumbers(...)
    local args = { ... }
    local min, max, count, unique
    -- 驗證參數數量
    if #args ~= 3 and #args ~= 4 then
        return "參數數量必須為3或4"
    end
    -- 解析參數模式
    if #args == 3 then
        local digits, count_arg, unique_arg = args[1], args[2], args[3]
        -- 驗證參數類型和範圍
        if type(digits) ~= "number" or type(count_arg) ~= "number" or type(unique_arg) ~= "number" then
            return "位數、數量和唯一性參數必須為數字"
        elseif digits < 1 or digits ~= math.floor(digits) then
            return "位數必須為正整數"
        elseif digits > 18 then
            return "位數不能超過18位"
        end
        min = 10 ^ (digits - 1)
        max = 10 ^ digits - 1
        if digits == 1 then min = 1 end -- 一位數的特殊情況
        count = count_arg
        unique = unique_arg
    else
        min, max, count, unique = args[1], args[2], args[3], args[4]
        -- 驗證參數合法性
        if type(min) ~= "number" or type(max) ~= "number" or type(count) ~= "number" then
            return "最小值、最大值和數量必須為數字"
        elseif min ~= math.floor(min) or max ~= math.floor(max) then
            return "最小值、最大值必須為整數"
        end
    end
    -- 通用參數驗證
    if min > max then
        min, max = max, min -- 自動交換順序
    end
    if count < 1 or count ~= math.floor(count) then
        return "數量必須為正整數"
    elseif unique ~= 0 and unique ~= 1 then
        return "控制唯一性的參數必須為0或1"
    elseif unique == 0 and count > (max - min + 1) then
        return "唯一性要求下，數量不能超過範圍大小"
    end
    -- 存儲隨機數的表
    local result = {}
    -- 生成隨機數
    if unique == 0 then
        local used = {} -- 記錄已生成的隨機數
        for i = 1, count do
            local num
            repeat
                num = math.random(min, max)
            until not used[num]
            used[num] = true
            result[i] = num
        end
    else
        -- 非唯一情況，直接填充結果表
        for i = 1, count do
            result[i] = math.random(min, max)
        end
    end
    -- 格式化輸出
    local formatted = {}
    for i = 1, #result do
        if i > 1 and (i - 1) % 10 == 0 then
            table.insert(formatted, "\n")
        end
        table.insert(formatted, tostring(result[i]))
        if i < #result and i % 10 ~= 0 then
            table.insert(formatted, ",")
        end
    end
    return table.concat(formatted)
end
calc_methods["psjs"] = generateRandomNumbers
methods_desc["psjs"] = "批次隨機數"

-- 質因數分解（帶優化輸出格式）
local function prime_factorization(n)
    -- 參數檢查與位數限制
    if type(n) ~= "number" or n <= 0 or math.floor(n) ~= n then
        return "參數必須是正整數"
    end
    local digits = #tostring(n)
    if digits > 18 then
        return "數字超限! 最大支持18位數字的質因數分解。"
    end
    -- 處理特殊情況
    if n == 1 then return "1" end
    local factors = {}
    -- 處理2的因子
    while n % 2 == 0 do
        factors[2] = (factors[2] or 0) + 1
        n = math.floor(n / 2)
    end
    -- 處理奇數因子
    local divisor = 3
    local max_divisor = math.floor(math.sqrt(n))
    while divisor <= max_divisor and n > 1 do
        while n % divisor == 0 do
            factors[divisor] = (factors[divisor] or 0) + 1
            n = math.floor(n / divisor)
            max_divisor = math.floor(math.sqrt(n))
        end
        divisor = divisor + 2
    end
    -- 如果n仍然大於1，則n本身是一個質數
    if n > 1 then
        factors[n] = (factors[n] or 0) + 1
    end
    -- 優化的指數符號表（僅包含0-9）
    local superscript_digits = {
        ["0"] = "⁰",
        ["1"] = "¹",
        ["2"] = "²",
        ["3"] = "³",
        ["4"] = "⁴",
        ["5"] = "⁵",
        ["6"] = "⁶",
        ["7"] = "⁷",
        ["8"] = "⁸",
        ["9"] = "⁹"
    }
    -- 轉換數字為上標形式（支持任意位數）
    local function to_superscript(num)
        local s = tostring(num)
        local result = ""
        for i = 1, #s do
            local c = s:sub(i, i)
            result = result .. (superscript_digits[c] or c)
        end
        return result
    end
    -- 生成輸出字元串
    local output = {}
    for factor, count in pairs(factors) do
        local str = tostring(factor)
        if count > 1 then
            str = str .. to_superscript(count)
        end
        table.insert(output, str)
    end
    -- 按質因數從小到大排序
    table.sort(output, function(a, b)
        local fa = tonumber(a:match("^%d+"))
        local fb = tonumber(b:match("^%d+"))
        return fa < fb
    end)
    return table.concat(output, "×")
end
calc_methods["zys"] = prime_factorization
methods_desc["zys"] = "質因數分解"

-- 找質數（歐拉篩法）
local function sieve_of_eratosthenes(n)
    if type(n) ~= "number" or n <= 1 or math.floor(n) ~= n then
        return "參數必須是大於1的正整數"
    end
    if n > 26338 then
        return "數字超限!"
    end
    local is_prime = {}
    local primes = {}
    -- 初始化數組，默認所有數都是質數
    for i = 2, n do
        is_prime[i] = true
    end
    -- 歐拉篩法核心邏輯
    for i = 2, n do
        if is_prime[i] then
            table.insert(primes, i)
        end
        -- 遍歷已找到的質數，標記合數
        for j = 1, #primes do
            local p = primes[j]
            local composite = i * p
            if composite > n then break end
            is_prime[composite] = false
            -- 關鍵優化：確保每個合數只被其最小質因數標記一次
            if i % p == 0 then break end
        end
    end
    -- 格式化輸出
    local output = {}
    for i = 1, #primes do
        table.insert(output, tostring(primes[i]))
        if (i % 10 == 0) or (i == #primes) then
            table.insert(output, "\n")
        else
            table.insert(output, ",")
        end
    end
    -- 如果最後一個元素是換行符，則移除它
    if #output > 0 and output[#output] == "\n" then
        output[#output] = nil
    end
    return table.concat(output)
end
calc_methods["zzs"] = sieve_of_eratosthenes
methods_desc["zzs"] = "找質數"

-- 24點計算機（含去重邏輯）
local function solve24(...)
    -- 檢查表中是否包含某個值
    local function table_contains(tab, val)
        for _, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
        return false
    end
    -- 生成隨機數的函數
    local function generate_numbers()
        math.randomseed(os.time())
        local numbers = {}
        local magic_numbers = {} -- 新增：魔術字數組
        for i = 1, 4 do
            numbers[i] = math.random(1, 13)
            -- 生成魔術字，1的魔術字固定為1
            if numbers[i] == 1 then
                magic_numbers[i] = 1
            else
                local newrd = math.random(1, 40)
                -- 確保魔術字不重復
                while table_contains(magic_numbers, newrd) do
                    newrd = math.random(1, 40)
                end
                magic_numbers[i] = newrd
            end
        end
        -- 如果數字有重復，魔術字也做同樣的重復
        for i = 1, 4 do
            for j = i + 1, 4 do
                if numbers[i] == numbers[j] then
                    magic_numbers[j] = magic_numbers[i]
                end
            end
        end
        return numbers, magic_numbers
    end
    -- 去重用的魔術字解決方案記錄
    local hash_solutions = {}
    local solutions = {}
    -- 判斷兩個數是否接近（處理浮點數精度問題）
    local function is_close(a, b)
        return math.abs(a - b) < 1e-9
    end
    -- 基本計算函數
    local function compute(a, b, op)
        if op == '+' then
            return a + b
        elseif op == '-' then
            return a - b
        elseif op == '*' then
            return a * b
        elseif op == '/' then
            if b == 0 then return nil end
            return a / b
        end
    end
    -- 計算魔術字
    local function compute_magic(a, b, op, magic_a, magic_b)
        if op == '+' then
            return magic_a + magic_b
        elseif op == '-' then
            return magic_a - magic_b
        elseif op == '*' then
            return magic_a * magic_b
        elseif op == '/' then
            if magic_b == 0 then return 999999999 end -- 避免除以0
            return magic_a / magic_b
        end
    end
    -- 排列組合函數
    local function permute(t)
        local result = {}
        local function permute_helper(current, remaining)
            if #remaining == 0 then
                table.insert(result, { table.unpack(current) })
            else
                for i = 1, #remaining do
                    local new_current = { table.unpack(current) }
                    table.insert(new_current, remaining[i])
                    local new_remaining = {}
                    for j = 1, #remaining do
                        if j ~= i then
                            table.insert(new_remaining, remaining[j])
                        end
                    end
                    permute_helper(new_current, new_remaining)
                end
            end
        end
        permute_helper({}, t)
        return result
    end
    -- 用於添加解決方案並去重
    local function add_solution(expr, value, magic_value)
        if is_close(value, 24) then
            -- 檢查魔術字是否已存在
            local is_duplicate = false
            local replace_index = -1
            for i, hash in ipairs(hash_solutions) do
                if math.abs(magic_value - hash) / (math.abs(magic_value) + 1e-9) < 1e-3 then
                    is_duplicate = true
                    replace_index = i
                    break
                end
            end
            if not is_duplicate then
                -- 新解決方案，添加到列表
                table.insert(solutions, expr)
                table.insert(hash_solutions, magic_value)
            else
                -- 檢查是否需要替換為更優的解決方案
                local need_replace = false
                local existing_expr = solutions[replace_index]
                -- 比較括號數量
                local current_brackets = expr:gsub("[^%(%)]", ""):len()
                local existing_brackets = existing_expr:gsub("[^%(%)]", ""):len()
                if current_brackets < existing_brackets then
                    need_replace = true
                    -- 括號數量相同，比較減號數量
                elseif current_brackets == existing_brackets then
                    local current_minus = expr:gsub("[^-]", ""):len()
                    local existing_minus = existing_expr:gsub("[^-]", ""):len()
                    if current_minus < existing_minus then
                        need_replace = true
                        -- 減號數量相同，比較除號數量
                    elseif current_minus == existing_minus then
                        local current_div = expr:gsub("[^/÷]", ""):len()
                        local existing_div = existing_expr:gsub("[^/÷]", ""):len()
                        if current_div < existing_div then
                            need_replace = true
                            -- 除號數量相同，比較表達式字典序
                        elseif current_div == existing_div and expr < existing_expr then
                            need_replace = true
                        end
                    end
                end
                if need_replace then
                    solutions[replace_index] = expr
                    hash_solutions[replace_index] = magic_value
                end
            end
        end
    end
    -- 核心解決24點問題的函數
    local function solve_24_with_magic(numbers, magic_numbers)
        local operators = { '+', '-', '*', '/' }
        local perms = permute(numbers)
        local magic_perms = permute(magic_numbers) -- 魔術字的排列組合
        -- 遍歷所有數字和魔術字的排列組合
        for i, nums in ipairs(perms) do
            local magics = magic_perms[i]
            if magics then
                for _, op1 in ipairs(operators) do
                    for _, op2 in ipairs(operators) do
                        for _, op3 in ipairs(operators) do
                            -- 情況1: ((a op1 b) op2 c) op3 d
                            local v1 = compute(nums[1], nums[2], op1)
                            local m1 = compute_magic(nums[1], nums[2], op1, magics[1], magics[2])
                            if v1 and m1 then
                                local v2 = compute(v1, nums[3], op2)
                                local m2 = compute_magic(v1, nums[3], op2, m1, magics[3])
                                if v2 and m2 then
                                    local v3 = compute(v2, nums[4], op3)
                                    local m3 = compute_magic(v2, nums[4], op3, m2, magics[4])
                                    if v3 and m3 then
                                        local expr = string.format("((%d%s%d)%s%d)%s%d", nums[1], op1, nums[2], op2,
                                            nums[3], op3, nums[4])
                                        add_solution(expr, v3, m3)
                                    end
                                end
                            end
                            -- 情況2: (a op1 (b op2 c)) op3 d
                            local v1 = compute(nums[2], nums[3], op2)
                            local m1 = compute_magic(nums[2], nums[3], op2, magics[2], magics[3])
                            if v1 and m1 then
                                local v2 = compute(nums[1], v1, op1)
                                local m2 = compute_magic(nums[1], v1, op1, magics[1], m1)
                                if v2 and m2 then
                                    local v3 = compute(v2, nums[4], op3)
                                    local m3 = compute_magic(v2, nums[4], op3, m2, magics[4])
                                    if v3 and m3 then
                                        local expr = string.format("(%d%s(%d%s%d))%s%d", nums[1], op1, nums[2], op2,
                                            nums[3], op3, nums[4])
                                        add_solution(expr, v3, m3)
                                    end
                                end
                            end
                            -- 情況3: a op1 ((b op2 c) op3 d)
                            local v1 = compute(nums[2], nums[3], op2)
                            local m1 = compute_magic(nums[2], nums[3], op2, magics[2], magics[3])
                            if v1 and m1 then
                                local v2 = compute(v1, nums[4], op3)
                                local m2 = compute_magic(v1, nums[4], op3, m1, magics[4])
                                if v2 and m2 then
                                    local v3 = compute(nums[1], v2, op1)
                                    local m3 = compute_magic(nums[1], v2, op1, magics[1], m2)
                                    if v3 and m3 then
                                        local expr = string.format("%d%s((%d%s%d)%s%d)", nums[1], op1, nums[2], op2,
                                            nums[3], op3, nums[4])
                                        add_solution(expr, v3, m3)
                                    end
                                end
                            end
                            -- 情況4: a op1 (b op2 (c op3 d))
                            local v1 = compute(nums[3], nums[4], op3)
                            local m1 = compute_magic(nums[3], nums[4], op3, magics[3], magics[4])
                            if v1 and m1 then
                                local v2 = compute(nums[2], v1, op2)
                                local m2 = compute_magic(nums[2], v1, op2, magics[2], m1)
                                if v2 and m2 then
                                    local v3 = compute(nums[1], v2, op1)
                                    local m3 = compute_magic(nums[1], v2, op1, magics[1], m2)
                                    if v3 and m3 then
                                        local expr = string.format("%d%s(%d%s(%d%s%d))", nums[1], op1, nums[2], op2,
                                            nums[3], op3, nums[4])
                                        add_solution(expr, v3, m3)
                                    end
                                end
                            end
                            -- 情況5: (a op1 b) op2 (c op3 d)
                            local v1 = compute(nums[1], nums[2], op1)
                            local m1 = compute_magic(nums[1], nums[2], op1, magics[1], magics[2])
                            local v2 = compute(nums[3], nums[4], op3)
                            local m2 = compute_magic(nums[3], nums[4], op3, magics[3], magics[4])
                            if v1 and m1 and v2 and m2 then
                                local v3 = compute(v1, v2, op2)
                                local m3 = compute_magic(v1, v2, op2, m1, m2)
                                if v3 and m3 then
                                    local expr = string.format("(%d%s%d)%s(%d%s%d)", nums[1], op1, nums[2], op2, nums[3],
                                        op3, nums[4])
                                    add_solution(expr, v3, m3)
                                end
                            end
                        end
                    end
                end
            end
        end
        return solutions
    end
    -- 處理函數參數
    local arg = { ... }
    if #arg == 0 then
        -- 無參數，生成隨機數
        local numbers, magic_numbers = generate_numbers()
        return "生成的隨機數: " .. table.concat(numbers, ", ")
    elseif #arg == 4 then
        -- 檢查輸入的四個參數是否都在1到13之間且為整數
        for i, num in ipairs(arg) do
            if type(num) ~= "number" or num < 1 or num > 13 or num ~= math.floor(num) then
                return "錯誤：請輸入4個1到13之間的整數。"
            end
        end
        -- 為輸入的數字生成魔術字
        local magic_numbers = {}
        for i, num in ipairs(arg) do
            if num == 1 then
                magic_numbers[i] = 1
            else
                local newrd = math.random(1, 40)
                while table_contains(magic_numbers, newrd) do
                    newrd = math.random(1, 40)
                end
                magic_numbers[i] = newrd
            end
        end
        -- 處理數字重復的情況
        for i = 1, 4 do
            for j = i + 1, 4 do
                if arg[i] == arg[j] then
                    magic_numbers[j] = magic_numbers[i]
                end
            end
        end
        -- 求解24點
        local solutions = solve_24_with_magic(arg, magic_numbers)
        if #solutions == 0 then
            return "沒有找到解決方案。"
        else
            return "共找到" .. #solutions .. "種解決方案:\n" .. table.concat(solutions, "\n")
        end
    else
        return "錯誤：請輸入4個數字或者不輸入參數以生成隨機數。"
    end
end
calc_methods["tfp"] = solve24
methods_desc["tfp"] = "24點計算機"

-- 單位換算腳本
-- 注意：單位是作為字串類型參數傳入的，所以輸入時應加引號（單雙均可，但不能混用）
-- 否則會因參數類型錯誤而無法輸出正確結果
local function dwhs(value, from_unit, to_unit)
    -- 單位轉換係數表
    local conversion_factors = {
        -- 長度 (相對於米)
        ai = 1e-10,          -- 埃
        nm = 1e-9,           -- 奈米
        wm = 1e-6,           -- 微米
        mm = 1e-3,           -- 毫米
        cm = 0.01,           -- 公分
        dm = 0.1,            -- 分米
        m = 1,               -- 米
        km = 1e3,            -- 公里
        li = 500,            -- 里
        yc = 0.0254,         -- 英吋
        ft = 0.3048,         -- 英尺
        mile = 1609.344,     -- 英里
        nmi = 1852,          -- 海裡
        zhang = 10 / 3,      -- 丈
        chi = 1 / 3,         -- 尺
        cun = 1 / 30,        -- 寸
        fen = 1 / 300,       -- 分
        -- 面積 (相對於平方公尺)
        mm2 = 1e-6,          -- 平方毫米
        cm2 = 1e-4,          -- 平方公分
        dm2 = 1e-2,          -- 平方分米
        m2 = 1,              -- 平方公尺
        km2 = 1e6,           -- 平方公里
        pfyl = 2589988.1103, -- 平方英里
        hm2 = 1e4,           -- 公頃
        sq = 2e5 / 3,        -- 市頃
        acre = 4046.8648,    -- 英畝
        sm = 2000 / 3,       -- 市畝
        gm = 100,            -- 公畝
        -- 體積 (相對於立方公尺)
        wl = 1e-9,           -- 微升
        mm3 = 1e-9,          -- 立方毫米
        ml = 1e-6,           -- 毫升
        cm3 = 1e-6,          -- 立方公分
        cl = 1e-5,           -- 釐升
        dl = 1e-4,           -- 分升
        l = 1e-3,            -- 升
        dm3 = 1e-3,          -- 立方分米
        hl = 0.1,            -- 公石
        m3 = 1,              -- 立方公尺
        ygl = 4.5461e-3,     -- 英制加侖
        mgl = 3.78541e-3,    -- 美制加侖
        km3 = 1e9,           -- 立方公里
        -- 質量 (相對於克)
        wg = 1e-6,           -- 微克
        mg = 1e-3,           -- 毫克
        g = 1,               -- 克
        kg = 1e3,            -- 公斤
        t = 1e6,             -- 公噸
        lb = 453.59237,      -- 磅
        oz = 28.349523125,   -- 盎司
        ct = 0.2,            -- 克拉
        gd = 1e5,            -- 公擔
        sd = 5e4,            -- 市擔
        jin = 500,           -- 斤
        liang = 50,          -- 兩
        qian = 5,            -- 錢
        dr = 1.771845195,    -- 打蘭
        gr = 0.06479891,     -- 格令
    }
    -- 檢查數值有效性
    if type(value) ~= "number" or value <= 0 then
        return "錯誤: 第一個參數必須是有效的正數"
    end
    -- 檢查單位有效性
    if not conversion_factors[from_unit] then
        return "錯誤: 未知的原單位 '" .. tostring(from_unit) .. "'"
    end
    if not conversion_factors[to_unit] then
        return "錯誤: 未知的目標單位 '" .. tostring(to_unit) .. "'"
    end
    -- 將數字轉換為上標字元
    local function to_superscript(num)
        local superscripts = { "⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹" }
        local minus = "⁻"
        local str = tostring(num)
        local result = ""
        -- 處理負號
        if str:sub(1, 1) == "-" then
            result = minus
            str = str:sub(2)
        end
        -- 移除前導零（除非是單獨的0）
        str = str:gsub("^0+(%d)", "%1")
        if str == "" then str = "0" end
        -- 轉換數字
        for digit in str:gmatch("%d") do
            result = result .. superscripts[tonumber(digit) + 1]
        end
        return result
    end
    -- 格式化科學記號輸出為上標形式
    local function format_scientific(num)
        local formatted = string.format("%.6e", num)
        local mantissa, exponent = string.match(formatted, "^(.-)e([%+%-]%d+)$")
        mantissa = mantissa:gsub("%.?0+$", ""):gsub("%.$", "")
        -- 移除指數前的+號
        exponent = exponent:gsub("^%+", "")
        return mantissa .. "×10" .. to_superscript(exponent)
    end
    -- 判斷是否應該使用科學計數法
    local function should_use_scientific(num)
        local abs_num = math.abs(num)
        -- 對於大於等於1e5或小於等於1e-3的數字使用科學計數法
        if abs_num >= 1e5 or (abs_num <= 1e-3 and abs_num > 0) then
            return true
        end
        -- 檢查整數部分位數
        local int_part = math.floor(abs_num)
        if int_part == 0 then
            -- 檢查小數部分前導零的數量
            local decimal_str = string.format("%.10f", abs_num - int_part)
            local leading_zeros = 0
            for i = 3, #decimal_str do
                if decimal_str:sub(i, i) == "0" then
                    leading_zeros = leading_zeros + 1
                else
                    break
                end
            end
            return leading_zeros >= 3
        else
            return (math.log10(int_part) + 1) > 4
        end
    end
    -- 格式化數字輸出
    local function format_number(num)
        if should_use_scientific(num) then
            return format_scientific(num)
        else
            return string.format("%.6f", num):gsub("%.?0+$", ""):gsub("%.$", "")
        end
    end
    -- 執行轉換
    local result = value * (conversion_factors[from_unit] / conversion_factors[to_unit])
    -- 格式化輸出
    local formatted_result = format_number(result)
    -- 顯示結果
    return formatted_result
end
calc_methods["dwhs"] = dwhs
methods_desc["dwhs"] = "單位換算，支持面積、質量、長度、體積"

-- 數字進制轉換
-- 注意：在輸入有字母的非10進制數時，需加上引號（單雙均可，但不能混用）
-- 否則無法輸出結果
local function convertBase(...)
    local args = { ... }
    local number, fromBase, toBase
    -- 參數數量處理
    if #args == 3 then
        number, fromBase, toBase = args[1], args[2], args[3]
    elseif #args == 2 then
        number, toBase = args[1], args[2]
        fromBase = 10 -- 默認原進制為十進制
    else
        return "參數數量必須為2或3"
    end
    -- 進制合法性檢查
    if type(fromBase) ~= "number" or type(toBase) ~= "number" then
        return "進制必須是數字類型"
    end
    if fromBase < 2 or fromBase > 36 or toBase < 2 or toBase > 36 then
        return "進制範圍必須在2到36之間"
    end
    local number = tostring(number)
    -- 檢查是否為有效數字格式
    local sign = 1
    local integerPart, fractionalPart
    -- 處理符號
    if string.sub(number, 1, 1) == '-' then
        sign = -1
        number = string.sub(number, 2)
    elseif string.sub(number, 1, 1) == '+' then
        number = string.sub(number, 2)
    end
    -- 分離整數和小數部分
    local dotPos = string.find(number, '%.')
    if dotPos then
        integerPart = string.sub(number, 1, dotPos - 1)
        fractionalPart = string.sub(number, dotPos + 1)
    else
        integerPart = number
        fractionalPart = ""
    end
    -- 定義數字字元集
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    -- 輔助函數：字元轉數值
    local function charToValue(c)
        return string.find(digits, string.upper(c), 1, true) - 1
    end
    -- 輔助函數：數值轉字元
    local function valueToChar(v)
        return string.sub(digits, v + 1, v + 1)
    end
    -- 整數部分轉換：原進制轉十進制
    local decimalInteger = 0
    for i = 1, #integerPart do
        local c = string.sub(integerPart, i, i)
        local v = charToValue(c)
        if v == -1 or v >= fromBase then
            return "數字中包含無效字元或超出原進制範圍"
        end
        decimalInteger = decimalInteger * fromBase + v
    end
    -- 小數部分轉換：原進制轉十進制
    local decimalFraction = 0
    local multiplier = 1 / fromBase
    for i = 1, #fractionalPart do
        local c = string.sub(fractionalPart, i, i)
        local v = charToValue(c)
        if v == -1 or v >= fromBase then
            return "數字中包含無效字元或超出原進制範圍"
        end
        decimalFraction = decimalFraction + v * multiplier
        multiplier = multiplier / fromBase
    end
    -- 整數部分：十進制轉目標進制
    local targetInteger = {}
    local n = math.abs(decimalInteger)
    if n == 0 then
        targetInteger[1] = '0'
    else
        local i = 0
        while n > 0 do
            i = i + 1
            targetInteger[i] = valueToChar(n % toBase)
            n = math.floor(n / toBase)
        end
        -- 反轉數組
        for j = 1, math.floor(i / 2) do
            targetInteger[j], targetInteger[i - j + 1] = targetInteger[i - j + 1], targetInteger[j]
        end
    end
    -- 小數部分：十進制轉目標進制（精度限制為10位）
    local targetFraction = {}
    local f = decimalFraction
    local maxFractionDigits = 10
    if f > 0 then
        targetFraction[1] = '.'
        local i = 1
        while f > 0 and i <= maxFractionDigits do
            f = f * toBase
            local intPart = math.floor(f)
            targetFraction[i + 1] = valueToChar(intPart)
            f = f - intPart
            i = i + 1
        end
    end
    -- 組合結果
    local result = {}
    if sign == -1 then
        result[#result + 1] = '-'
    end
    for i = 1, #targetInteger do
        result[#result + 1] = targetInteger[i]
    end
    for i = 1, #targetFraction do
        result[#result + 1] = targetFraction[i]
    end
    return table.concat(result)
end
calc_methods["jzzh"] = convertBase
methods_desc["jzzh"] = "數字進制轉換，支持2~36進制"

-- 執行普通計算的輔助函數
local function execute_normal_calculation(input, seg, express, env)
    if (string.len(express) < 2) and (not calc_methods[express]) then return end
    if (string.len(express) == 2) and (express:match("^%d[^%!]$")) then return end
    
    -- 計算 preedit 顯示格式
    local preedit_text
    if input == T.prefix then
        preedit_text = "《計算機》▸"
    else
        local content = input:gsub("^" .. T.prefix, "")
        preedit_text = "《計算機》" .. content
    end
    
    local code = replaceToFactorial(express)
    local loaded_func, load_error = load("return " .. code, "calculate", "t", calc_methods)
    if loaded_func then
        local success, result = pcall(loaded_func)
        if success then
            local display_value
            if type(result) == "number" then
                display_value = format_number_for_display(result)
            else
                display_value = tostring(result)
            end
            -- 為每個候選詞設置 preedit
            local cand1 = Candidate("calculator", seg.start, seg._end, display_value, "")
            cand1.preedit = preedit_text
            yield(cand1)
            
            local cand2 = Candidate("calculator", seg.start, seg._end, express .. "=" .. display_value, "")
            cand2.preedit = preedit_text
            yield(cand2)
        else
            local cand = Candidate("calculator", seg.start, seg._end, express, "執行錯誤")
            cand.preedit = preedit_text
            yield(cand)
        end
    else
        local cand = Candidate("calculator", seg.start, seg._end, express, "解析失敗")
        cand.preedit = preedit_text
        yield(cand)
    end
end

-- 執行函數調用的輔助函數
local function execute_function_call(input, seg, func_name, params, env)
    -- 計算 preedit 顯示格式
    local preedit_text
    if input == T.prefix then
        preedit_text = "《計算機》▸"
    else
        local content = input:gsub("^" .. T.prefix, "")
        preedit_text = "《計算機》" .. content
    end
    
    -- 檢查函數是否存在
    if not calc_methods[func_name] then
        local cand = Candidate("calculator", seg.start, seg._end, "錯誤: 函數 " .. func_name .. " 不存在", "")
        cand.preedit = preedit_text
        yield(cand)
        return
    end
    local func = calc_methods[func_name]

    -- 獲取函數的參數數量
    local function get_function_param_count(func)
        if type(func) ~= "function" then
            return nil  -- 不是函數，返回nil
        end
        -- 獲取函數的字元串表示，從中提取參數信息
        local func_str = string.dump(func)
        if not func_str then return nil end
        -- 從函數的調試信息中獲取參數數量（更可靠的方法）
        local info = debug.getinfo(func)
        if info and info.nparams then
            return info.nparams
        end
        return nil  -- 無法確定參數數量
    end

    -- 獲取函數的參數數量
    local expected_param_count = get_function_param_count(func)
    -- 如果有明確的參數數量要求，進行驗證
    if expected_param_count and expected_param_count > 0 then
        if #params ~= expected_param_count then
            local cand = Candidate("calculator", seg.start, seg._end, 
                "錯誤: 函數 " .. func_name .. " 需要 " .. expected_param_count .. " 個參數，但提供了 " .. #params .. " 個", "")
            cand.preedit = preedit_text
            yield(cand)
            return
        end
    end

    local function smart_quote_params(param_list, fn_name)
        -- 判斷哪些函數需要特殊處理其字元串參數
        -- key: 函數名, value: 需要加引號的參數索引表
        local string_param_funcs = {
            jzzh = {1}, -- jzzh函數的第1個參數（要轉換的數字）可能需要引號
            dwhs = {2, 3} -- dwhs函數的第2（原單位）和第3（目標單位）個參數需要引號
        }
        local indices_to_quote = string_param_funcs[fn_name]
        if not indices_to_quote then
            -- 如果這個函數不需要特殊處理，直接返回原參數列表
            return param_list
        end
        local processed_params = {}
        for i, param in ipairs(param_list) do
            local p = param
            -- 檢查當前參數索引是否需要被引號包裹
            for _, idx in ipairs(indices_to_quote) do
                if i == idx then
                    -- 檢查這個參數：如果它不是純數字，也不是一個已經被引號括起來的字元串，則為其加上引號
                    if not p:match("^%d+$") and not p:match("^['\"].*['\"]$") then
                        p = "'" .. p .. "'"
                    end
                    break -- 找到匹配的索引後就跳出內層循環
                end
            end
            table.insert(processed_params, p)
        end
        return processed_params
    end

    local success, result
    -- 關鍵修改：正確處理無參數情況
    if #params > 0 then
        -- 有參數的情況：構建函數調用字元串
        -- 在處理參數之前，先進行智能引號處理
        local processed_params = smart_quote_params(params, func_name)
        local param_str = table.concat(processed_params, ", ")
        local call_str = func_name .. "(" .. param_str .. ")"
        local loaded_func, load_error = load("return " .. call_str, "calculate", "t", calc_methods)
        if loaded_func then
            success, result = pcall(loaded_func)
        else
            success = false
            result = "函數調用語法錯誤: " .. tostring(load_error)
        end
    else
        -- 無參數情況：直接調用函數
        if type(func) == "function" then
            success, result = pcall(func)
        else
            -- 如果不是函數，可能是其他類型的值
            success = true
            result = func
        end
    end
    -- 顯示結果
    if success then
        -- 關鍵修改：正確處理函數返回值
        if type(result) == "function" then
            -- 如果結果是函數，說明需要執行它
            success, result = pcall(result)
            if not success then
                local cand = Candidate("calculator", seg.start, seg._end, "錯誤: 函數執行失敗: " .. tostring(result), "")
                cand.preedit = preedit_text
                yield(cand)
                return
            end
        end
        local display_value
        if type(result) == "number" then
            display_value = format_number_for_display(result)
        else
            display_value = tostring(result)
        end
        -- 顯示當前結果
        local cand1 = Candidate("calculator", seg.start, seg._end, display_value, "")
        cand1.preedit = preedit_text
        yield(cand1)
        
        -- 顯示完整調用
        local param_display = #params > 0 and table.concat(params, ", ") or ""
        local call_display = func_name .. "(" .. param_display .. ")"
        local cand2 = Candidate("calculator", seg.start, seg._end, call_display .. " = " .. display_value, "")
        cand2.preedit = preedit_text
        yield(cand2)
    else
        -- 顯示錯誤信息
        local cand = Candidate("calculator", seg.start, seg._end, "錯誤: " .. tostring(result), "")
        cand.preedit = preedit_text
        yield(cand)
    end
end

function T.func(input, seg, env)
    local composition = env.engine.context.composition
    if composition:empty() then return end
    local segment = composition:back()
    if startsWith(input, T.prefix) or (seg:has_tag("calculator")) then
        -- 設置標籤
        segment.tags = segment.tags + Set({ "calculator" })
        
        -- 計算 preedit 顯示格式
        local preedit_text
        if input == T.prefix then
            -- 只有 = 時顯示 ▸
            preedit_text = "《計算機》▸"
        else
            -- 有內容時不顯示 ▸
            local content = input:gsub("^" .. T.prefix, "")
            preedit_text = "《計算機》" .. content
        end
        
        -- 追蹤是否已生成候選詞
        local candidates_generated = false
        
        -- 提取算式
        local express = input:gsub(T.prefix, ""):gsub("^/vs", "")

        local code = replaceToFactorial(express)
        local loaded_func, load_error = load("return " .. code, "calculate", "t", calc_methods)
        if loaded_func and (type(methods_desc[code]) == "string") then
            local cand = Candidate("calculator_desc", seg.start, seg._end, express .. ":" .. methods_desc[code], "")
            cand.preedit = preedit_text
            yield(cand)
            candidates_generated = true
        end

        -- 檢查是否是單個全局變量（不包含運算符的純標識符）
        if express:match("^[a-zA-Z][a-zA-Z0-9_]*$") then
            local identifier = express
            local value = calc_methods[identifier]
            -- 如果是已定義的數值常量，直接顯示其值
            if type(value) == "number" then
                local formatted_result = format_number_for_display(value)
                local description = methods_desc[identifier] or ""
                
                -- 創建候選詞，設置 preedit 格式
                local cand1 = Candidate("calculator", seg.start, seg._end, formatted_result, description)
                cand1.preedit = preedit_text
                yield(cand1)
                
                -- 同時顯示帶變量名的完整表達式結果
                local cand2 = Candidate("calculator", seg.start, seg._end, 
                    identifier .. " = " .. formatted_result, description)
                cand2.preedit = preedit_text
                yield(cand2)
                candidates_generated = true
                return
            end
        -- 讓全局變量可以參與運算
        elseif express:match("^([a-zA-Z][a-zA-Z0-9_]*)") then
            local identifier = express:match("^([a-zA-Z][a-zA-Z0-9_]*)")
            if identifier then
                local value = calc_methods[identifier]
                -- 如果是已定義的數值常量，按普通計算處理
                if type(value) == "number" then
                    execute_normal_calculation(input, seg, express, env)
                    candidates_generated = true
                    return
                end
            end
        end

        -- 檢查是否是函數調用（英文字母開頭且不包含括號）
        if express:match("^[a-zA-Z]") and not express:find("[()]") then
            -- 嘗試按免括號方式處理函數調用
            local func_name = nil
            local param_part = ""
        
            -- 從長到短嘗試匹配函數名
            for i = #express, 1, -1 do
                local potential_name = express:sub(1, i)
                if calc_methods[potential_name] ~= nil then
                    func_name = potential_name
                    param_part = express:sub(i + 1)
                    break
                end
            end
        
            if func_name then
                -- 如果找到函數名，提取參數部分
                local params = {}
                if param_part and param_part ~= "" then
                    local current_param = ""
                    local in_quotes = false
                    local quote_char = ""
            
                    for i = 1, #param_part do
                        local char = param_part:sub(i, i)
                
                        if in_quotes then
                            if char == quote_char then
                                in_quotes = false
                                table.insert(params, current_param)
                                current_param = ""
                            else
                                current_param = current_param .. char
                            end
                        else
                            if char == '"' or char == "'" then
                                in_quotes = true
                                quote_char = char
                                if current_param ~= "" then
                                    table.insert(params, current_param)
                                    current_param = ""
                                end
                            elseif char == "," then
                                if current_param ~= "" then
                                    table.insert(params, current_param)
                                    current_param = ""
                                end
                            else
                                current_param = current_param .. char
                            end
                        end
                    end
            
                    if current_param ~= "" then
                        table.insert(params, current_param)
                    end
                end
                -- 清理參數
                for i, param in ipairs(params) do
                    params[i] = param:match("^%s*(.-)%s*$")
                end
                -- 執行函數
                execute_function_call(input, seg, func_name, params, env)
                candidates_generated = true
                return
            end
        end

        -- 其他情況執行普通計算
        -- 檢查是否會生成候選詞（根據 execute_normal_calculation 的條件）
        local will_generate_candidates = false
        if express ~= "" then
            -- 複製 execute_normal_calculation 的條件判斷
            if not ((string.len(express) < 2) and (not calc_methods[express])) and
               not ((string.len(express) == 2) and (express:match("^%d[^%!]$"))) then
                will_generate_candidates = true
            end
        end
        
        execute_normal_calculation(input, seg, express, env)
        
        if will_generate_candidates then
            candidates_generated = true
        end
        
        -- 只有在沒有生成任何候選詞時，才添加輸入顯示候選詞
        -- 這樣可以保證從一開始輸入就顯示《計算機》前綴，但不會與計算結果重複
        if not candidates_generated and express ~= "" then
            local cand = Candidate("calculator_input", seg.start, seg._end, express, "")
            cand.preedit = preedit_text
            yield(cand)
        end
    end
end

return T
