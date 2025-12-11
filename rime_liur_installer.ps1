# RIME 蝦米輸入方案自動安裝工具 (Windows PowerShell)
# created by Ryan Chou
# https://github.com/ryanwuson/rime-liur

$ErrorActionPreference = "Stop"

# GitHub 相關設定
$GITHUB_REPO = "ryanwuson/rime-liur"
$GITHUB_BRANCH = "main"
$GITHUB_RAW = "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# 設定路徑
$RIME_FOLDER = "$env:APPDATA\Rime"
$FONT_FOLDER = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

# 需要下載的檔案清單
$FILES = @(
    "allbpm.dict.yaml"
    "allbpm.schema.yaml"
    "default.custom.yaml"
    "easy_en.custom.yaml"
    "easy_en.dict.yaml"
    "easy_en.schema.yaml"
    "easy_en.yaml"
    "essay-zh-hant-onion.txt"
    "installation.yaml"
    "liur.custom.yaml"
    "liur.extended.dict.yaml"
    "liur.schema.yaml"
    "liur_symbols.dict.yaml"
    "liur_symbols.schema.yaml"
    "Mount_bopomo.extended.dict.yaml"
    "Mount_bopomo.schema.yaml"
    "openxiami_CustomWord.dict.yaml"
    "openxiami_TCJP.dict.yaml"
    "openxiami_TradExt.dict.yaml"
    "rime.lua"
    "squirrel.custom.yaml"
    "terra_pinyin_onion.dict.yaml"
    "terra_pinyin_onion_add.dict.yaml"
    "weasel.custom.yaml"
)

# Lua 檔案
$LUA_FILES = @(
    "lua/easy_en.lua"
    "lua/liu_charset_filter.lua"
    "lua/liu_code_decoder.lua"
    "lua/liu_common.lua"
    "lua/liu_completion_translator.lua"
    "lua/liu_datetime.lua"
    "lua/liu_extended_backspace.lua"
    "lua/liu_extended_data.lua"
    "lua/liu_extended_filter.lua"
    "lua/liu_extended_segmentor.lua"
    "lua/liu_fancy_filter.lua"
    "lua/liu_fancy_processor.lua"
    "lua/liu_fancy_translator.lua"
    "lua/liu_help_filter.lua"
    "lua/liu_help.lua"
    "lua/liu_letter_variants.lua"
    "lua/liu_phonetic_hint_processor.lua"
    "lua/liu_phonetic_override.lua"
    "lua/liu_phonetic_suffix.lua"
    "lua/liu_quick_hint.lua"
    "lua/liu_quick_mode_processor.lua"
    "lua/liu_remove_trad_in_w2c.lua"
    "lua/liu_symbol_data.lua"
    "lua/liu_symbols_hint.lua"
    "lua/liu_symbols_hint_filter.lua"
    "lua/liu_symbols_number_processor.lua"
    "lua/liu_symbols_processor.lua"
    "lua/liu_vrsf_hint.lua"
    "lua/liu_w2c_sorter.lua"
    "lua/liu_wildcard_code_hint.lua"
    "lua/liu_wildcard_filter.lua"
    "lua/liu_wildcard_processor.lua"
)

# Lua lunar_calendar 檔案
$LUA_LUNAR_FILES = @(
    "lua/lunar_calendar/lunar_calendar_1.lua"
    "lua/lunar_calendar/lunar_calendar_2.lua"
    "lua/lunar_calendar/lunar_time.lua"
)

# OpenCC 檔案
$OPENCC_FILES = @(
    "opencc/liu_phonetic.json"
    "opencc/liu_phonetic.txt"
    "opencc/liu_phonetic_simp.txt"
    "opencc/liu_w2c.json"
    "opencc/liu_w2c.txt"
    "opencc/liu_w2cExt.txt"
)

# 字體檔案
$FONT_FILES = @(
    "fonts/MapleMonoNormal-Regular.ttf"
    "fonts/PlangothicP1-Regular.ttf"
    "fonts/PlangothicP2-Regular.ttf"
)

# Windows 額外字體
$FONT_FILES_WIN = @(
    "fonts/Windows Only/SourceHanSansTC-Regular.otf"
)

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  RIME 蝦米輸入方案 自動安裝工具" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "本工具將執行以下作業："
Write-Host "1. 下載蝦米輸入方案檔案到 Rime 資料夾"
Write-Host "2. 安裝所需字體"
Write-Host ""
Write-Host "※ 若有自訂設定尚未備份，請按 Ctrl+C 終止" -ForegroundColor Yellow
Write-Host ""

for ($i = 5; $i -ge 1; $i--) {
    Write-Host "將在 $i 秒後開始..."
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "[ Step 1: 下載蝦米輸入方案檔案 ]" -ForegroundColor Green

# 建立資料夾
New-Item -ItemType Directory -Force -Path $RIME_FOLDER | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua\lunar_calendar" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\opencc" | Out-Null

# 下載主要檔案
Write-Host "下載主要設定檔..."
foreach ($file in $FILES) {
    Write-Host "  下載 $file"
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\$file"
}

# 下載 Lua 檔案
Write-Host "下載 Lua 腳本..."
foreach ($file in $LUA_FILES) {
    $filename = Split-Path $file -Leaf
    Write-Host "  下載 $filename"
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\lua\$filename"
}

# 下載 Lua lunar_calendar 檔案
Write-Host "下載 lunar_calendar 腳本..."
foreach ($file in $LUA_LUNAR_FILES) {
    $filename = Split-Path $file -Leaf
    Write-Host "  下載 $filename"
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\lua\lunar_calendar\$filename"
}

# 下載 OpenCC 檔案
Write-Host "下載 OpenCC 設定..."
foreach ($file in $OPENCC_FILES) {
    $filename = Split-Path $file -Leaf
    Write-Host "  下載 $filename"
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\opencc\$filename"
}

Write-Host ""
Write-Host "[ Step 2: 安裝字體 ]" -ForegroundColor Green

New-Item -ItemType Directory -Force -Path $FONT_FOLDER | Out-Null

# 下載共用字體
Write-Host "下載字體檔案..."
foreach ($file in $FONT_FILES) {
    $filename = Split-Path $file -Leaf
    if (Test-Path "$FONT_FOLDER\$filename") {
        Write-Host "  [skip] $filename"
    } else {
        Write-Host "  安裝 $filename"
        Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$FONT_FOLDER\$filename"
    }
}

# Windows 額外字體
foreach ($file in $FONT_FILES_WIN) {
    $filename = Split-Path $file -Leaf
    if (Test-Path "$FONT_FOLDER\$filename") {
        Write-Host "  [skip] $filename"
    } else {
        $encodedPath = $file -replace " ", "%20"
        Write-Host "  安裝 $filename"
        Invoke-WebRequest -Uri "$GITHUB_RAW/$encodedPath" -OutFile "$FONT_FOLDER\$filename"
    }
}

Write-Host ""
Write-Host "[ Step 3: 完成 ]" -ForegroundColor Green
Write-Host ""
Write-Host "請手動重新部署小狼毫（右鍵點擊系統匣圖示 → 重新部署）" -ForegroundColor Yellow
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  蝦米輸入方案 安裝完成 ✨" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Rime 資料夾：$RIME_FOLDER"
Write-Host "字體資料夾：$FONT_FOLDER"
Write-Host ""
Write-Host "更多資訊請參考：https://ryanwuson.github.io/rime-liur/"
