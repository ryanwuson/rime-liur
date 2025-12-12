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
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/git/trees/${GITHUB_BRANCH}?recursive=1"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"

# macOS 路徑設定
RIME_FOLDER="$HOME/Library/Rime"
FONT_FOLDER="$HOME/Library/Fonts"
SQUIRREL_APP="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"

# 排除清單（正則表達式）
EXCLUDE_PATTERNS="^docs/|^README\.md$|^LICENSE$|^\.gitignore$|^rime_liur_installer\.sh$|^rime_liur_installer\.ps1$|^fonts/Windows Only/"

# 進度條函數
show_progress() {
    local current=$1
    local total=$2
    local filename=$3
    local width=20
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # 建立進度條
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    # 截斷過長的檔名（保留空間給 [skip]）
    if [ ${#filename} -gt 40 ]; then
        filename="${filename:0:37}..."
    fi
    
    # 輸出進度（\r 回到行首覆蓋）
    printf "\r  [%s] %3d/%d  %-45s" "$bar" "$current" "$total" "$filename"
}

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
    printf "\r將在 %d 秒後開始..." "$i"
    sleep 1
done
echo  # 換行

echo
echo "[ Step 1: 取得檔案清單 ]"

# 從 GitHub API 取得檔案清單（使用 Python 解析 JSON）
echo "正在從 GitHub 取得檔案清單..."
ALL_FILES=$(curl -fsSL "$GITHUB_API" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data.get('tree', []):
        if item.get('type') == 'blob':
            print(item['path'])
except:
    pass
" 2>/dev/null)

if [ -z "$ALL_FILES" ]; then
    echo -e "${RED}[錯誤] GitHub API 連線失敗${NC}"
    echo "       請檢查網路連線，或稍後再試"
    echo "       若持續失敗，請至 GitHub 手動下載："
    echo "       https://github.com/${GITHUB_REPO}"
    exit 1
fi

# 分類檔案
ROOT_FILES=()
LUA_FILES=()
LUA_LUNAR_FILES=()
OPENCC_FILES=()
FONT_FILES=()

while IFS= read -r file; do
    [ -z "$file" ] && continue
    
    # 檢查是否要排除
    if echo "$file" | grep -qE "$EXCLUDE_PATTERNS"; then
        continue
    fi
    
    # 根據路徑分類
    if [[ "$file" == lua/lunar_calendar/* ]]; then
        LUA_LUNAR_FILES+=("$file")
    elif [[ "$file" == lua/* ]]; then
        LUA_FILES+=("$file")
    elif [[ "$file" == opencc/* ]]; then
        OPENCC_FILES+=("$file")
    elif [[ "$file" == fonts/* ]]; then
        FONT_FILES+=("$file")
    elif [[ "$file" != */* ]]; then
        ROOT_FILES+=("$file")
    fi
done <<< "$ALL_FILES"

# 計算總檔案數
TOTAL_FILES=$((${#ROOT_FILES[@]} + ${#LUA_FILES[@]} + ${#LUA_LUNAR_FILES[@]} + ${#OPENCC_FILES[@]}))
echo "找到 $TOTAL_FILES 個方案檔案、${#FONT_FILES[@]} 個字體"

echo
echo "[ Step 2: 下載蝦米輸入方案檔案 ]"

# 建立資料夾
mkdir -p "$RIME_FOLDER"
mkdir -p "$RIME_FOLDER/lua"
mkdir -p "$RIME_FOLDER/lua/lunar_calendar"
mkdir -p "$RIME_FOLDER/opencc"

CURRENT=0

# 下載主要檔案
for file in "${ROOT_FILES[@]}"; do
    ((CURRENT++))
    show_progress $CURRENT $TOTAL_FILES "$file"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/$file"
done

# 下載 Lua 檔案
for file in "${LUA_FILES[@]}"; do
    ((CURRENT++))
    filename=$(basename "$file")
    show_progress $CURRENT $TOTAL_FILES "$filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/lua/$filename"
done

# 下載 Lua lunar_calendar 檔案
for file in "${LUA_LUNAR_FILES[@]}"; do
    ((CURRENT++))
    filename=$(basename "$file")
    show_progress $CURRENT $TOTAL_FILES "$filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/lua/lunar_calendar/$filename"
done

# 下載 OpenCC 檔案
for file in "${OPENCC_FILES[@]}"; do
    ((CURRENT++))
    filename=$(basename "$file")
    show_progress $CURRENT $TOTAL_FILES "$filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/opencc/$filename"
done

echo  # 換行

echo
echo "[ Step 3: 安裝字體 ]"

mkdir -p "$FONT_FOLDER"

FONT_TOTAL=${#FONT_FILES[@]}
FONT_CURRENT=0

for file in "${FONT_FILES[@]}"; do
    ((FONT_CURRENT++))
    filename=$(basename "$file")
    if [ -f "$FONT_FOLDER/$filename" ]; then
        show_progress $FONT_CURRENT $FONT_TOTAL "$filename [skip]"
    else
        show_progress $FONT_CURRENT $FONT_TOTAL "$filename"
        curl -fsSL "${GITHUB_RAW}/${file}" -o "$FONT_FOLDER/$filename"
    fi
done

echo  # 換行

echo
echo "[ Step 4: 部署 RIME ]"

"$SQUIRREL_APP" --reload
echo -e "${GREEN}已觸發鼠鬚管重新部署，請等待 10 至 20 秒${NC}"

echo
echo "======================================"
echo -e "${GREEN}  蝦米輸入方案 安裝完成 可開始使用 ✨${NC}"
echo "======================================"
echo
echo "Rime 資料夾：$RIME_FOLDER"
echo "字體資料夾：$FONT_FOLDER"
echo
echo "更多資訊請參考：https://ryanwuson.github.io/rime-liur/"
