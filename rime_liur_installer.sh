#!/usr/bin/env bash
# RIME 蝦米輸入方案自動安裝工具 (macOS)
# created by Ryan Chou
# https://github.com/ryanwuson/rime-liur

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GitHub 相關設定
GITHUB_REPO="ryanwuson/rime-liur"
GITHUB_BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"

# macOS 路徑設定
RIME_FOLDER="$HOME/Library/Rime"
FONT_FOLDER="$HOME/Library/Fonts"
SQUIRREL_APP="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"

# 需要下載的檔案清單
FILES=(
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
LUA_FILES=(
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
LUA_LUNAR_FILES=(
    "lua/lunar_calendar/lunar_calendar_1.lua"
    "lua/lunar_calendar/lunar_calendar_2.lua"
    "lua/lunar_calendar/lunar_time.lua"
)

# OpenCC 檔案
OPENCC_FILES=(
    "opencc/liu_phonetic.json"
    "opencc/liu_phonetic.txt"
    "opencc/liu_phonetic_simp.txt"
    "opencc/liu_w2c.json"
    "opencc/liu_w2c.txt"
    "opencc/liu_w2cExt.txt"
)

# 字體檔案
FONT_FILES=(
    "fonts/MapleMonoNormal-Regular.ttf"
    "fonts/PlangothicP1-Regular.ttf"
    "fonts/PlangothicP2-Regular.ttf"
)

echo
echo "======================================"
echo "  RIME 蝦米輸入方案 自動安裝工具"
echo "======================================"
echo
echo "本工具將執行以下作業："
echo "1. 下載蝦米輸入方案檔案到 Rime 資料夾"
echo "2. 安裝所需字體"
echo "3. 部署 RIME"
echo

# 檢查鼠鬚管
if [ ! -f "$SQUIRREL_APP" ]; then
    echo -e "${RED}錯誤：尚未安裝鼠鬚管！${NC}"
    echo "請先至 https://rime.im/download/ 下載並安裝鼠鬚管"
    exit 1
fi

echo -e "${YELLOW}※ 若有自訂設定尚未備份，請按 Ctrl+C 終止${NC}"
echo
for i in {5..1}; do
    echo "將在 $i 秒後開始..."
    sleep 1
done

echo
echo "[ Step 1: 下載蝦米輸入方案檔案 ]"

# 建立資料夾
mkdir -p "$RIME_FOLDER"
mkdir -p "$RIME_FOLDER/lua"
mkdir -p "$RIME_FOLDER/lua/lunar_calendar"
mkdir -p "$RIME_FOLDER/opencc"

# 下載主要檔案
echo "下載主要設定檔..."
for file in "${FILES[@]}"; do
    echo "  下載 $file"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/$file"
done

# 下載 Lua 檔案
echo "下載 Lua 腳本..."
for file in "${LUA_FILES[@]}"; do
    filename=$(basename "$file")
    echo "  下載 $filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/lua/$filename"
done

# 下載 Lua lunar_calendar 檔案
echo "下載 lunar_calendar 腳本..."
for file in "${LUA_LUNAR_FILES[@]}"; do
    filename=$(basename "$file")
    echo "  下載 $filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/lua/lunar_calendar/$filename"
done

# 下載 OpenCC 檔案
echo "下載 OpenCC 設定..."
for file in "${OPENCC_FILES[@]}"; do
    filename=$(basename "$file")
    echo "  下載 $filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/opencc/$filename"
done

echo
echo "[ Step 2: 安裝字體 ]"

mkdir -p "$FONT_FOLDER"

echo "下載字體檔案..."
for file in "${FONT_FILES[@]}"; do
    filename=$(basename "$file")
    if [ -f "$FONT_FOLDER/$filename" ]; then
        echo "  略過 $filename（已存在）"
    else
        echo "  安裝 $filename"
        curl -fsSL "${GITHUB_RAW}/${file}" -o "$FONT_FOLDER/$filename"
    fi
done

echo
echo "[ Step 3: 部署 RIME ]"

"$SQUIRREL_APP" --reload
echo -e "${GREEN}已觸發鼠鬚管重新部署${NC}"

echo
echo "======================================"
echo -e "${GREEN}  蝦米輸入方案 安裝完成 ✨${NC}"
echo "======================================"
echo
echo "Rime 資料夾：$RIME_FOLDER"
echo "字體資料夾：$FONT_FOLDER"
echo
echo "更多資訊請參考：https://ryanwuson.github.io/rime-liur/"
