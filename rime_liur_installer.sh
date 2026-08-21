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
echo "1. 選擇輸入方案版本"
echo "2. 下載蝦米輸入方案檔案到 Rime 資料夾"
echo "3. 安裝所需字體"
echo "4. 部署 RIME"
echo

# 檢查鼠鬚管
if [ ! -f "$SQUIRREL_APP" ]; then
    echo -e "${RED}錯誤：尚未安裝鼠鬚管！${NC}"
    echo "請先至 https://rime.im/download/ 下載並安裝鼠鬚管"
    exit 1
fi

echo -e "${YELLOW}※ 若有自訂設定尚未備份，請按 Ctrl+C 終止${NC}"
echo

# 版本選擇
echo -e "${YELLOW}請選擇輸入方案版本：${NC}"
echo
echo "1. 完整版（中打含英文詞庫版）（推薦）"
echo "   - 完整功能，中文輸入搭配英文詞庫輔助"
echo "   - 英文詞庫支援，大小寫轉換"
echo "   - 適合日常使用、程式開發"
echo
echo "2. 基礎版（中打不含英文詞庫）"
echo "   - 專注中文輸入，不含英文詞庫"
echo "   - 減少英文候選干擾"
echo "   - 適合純中文寫作"
echo

while true; do
    read -p "請輸入選項 (1 或 2): " choice < /dev/tty
    case $choice in
        1)
            SCHEMA_VERSION="mixed"
            echo -e "${GREEN}已選擇：完整版（中打含英文詞庫版）${NC}"
            break
            ;;
        2)
            SCHEMA_VERSION="chinese-only"
            echo -e "${GREEN}已選擇：基礎版（中打不含英文詞庫）${NC}"
            break
            ;;
        *)
            echo -e "${RED}請輸入 1 或 2${NC}"
            ;;
    esac
done

echo

# 自定義設定檔選項
echo -e "${YELLOW}是否覆蓋自定義設定檔？${NC}"
echo
echo "以下檔案用於儲存您的個人設定與詞彙："
echo "• openxiami_CustomWord.dict.yaml（自定義詞庫）"
echo "• default.custom.yaml（全域設定）"
echo "• squirrel.custom.yaml（鼠鬚管外觀設定）"
echo
echo "若您已有自訂設定，建議選擇「保留」以避免遺失。"
echo
echo "1. 保留（推薦）- 保留現有的自定義設定檔"
echo "2. 覆蓋 - 下載預設設定檔（會清除您的自訂設定）"
echo

while true; do
    read -p "請輸入選項 (1 或 2): " customChoice < /dev/tty
    case $customChoice in
        1)
            KEEP_CUSTOM_FILES=true
            echo -e "${GREEN}已選擇：保留自定義設定檔${NC}"
            break
            ;;
        2)
            KEEP_CUSTOM_FILES=false
            echo -e "${GREEN}已選擇：覆蓋自定義設定檔${NC}"
            break
            ;;
        *)
            echo -e "${RED}請輸入 1 或 2${NC}"
            ;;
    esac
done

echo
for i in {3..1}; do
    printf "\r將在 %d 秒後開始..." "$i"
    sleep 1
done
echo  # 換行

echo
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
CONFIGS_FILES=()
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
    elif [[ "$file" == configs/* ]]; then
        CONFIGS_FILES+=("$file")
    elif [[ "$file" == fonts/* ]]; then
        FONT_FILES+=("$file")
    elif [[ "$file" != */* ]]; then
        ROOT_FILES+=("$file")
    fi
done <<< "$ALL_FILES"

# 計算總檔案數
TOTAL_FILES=$((${#ROOT_FILES[@]} + ${#LUA_FILES[@]} + ${#LUA_LUNAR_FILES[@]} + ${#OPENCC_FILES[@]} + ${#CONFIGS_FILES[@]}))
echo "找到 $TOTAL_FILES 個方案檔案、${#FONT_FILES[@]} 個字體"

echo
echo "[ Step 1: 下載蝦米輸入方案檔案 ]"

# 建立資料夾
mkdir -p "$RIME_FOLDER"
mkdir -p "$RIME_FOLDER/lua"
mkdir -p "$RIME_FOLDER/lua/lunar_calendar"
mkdir -p "$RIME_FOLDER/lua/data"
mkdir -p "$RIME_FOLDER/opencc"
mkdir -p "$RIME_FOLDER/configs"

CURRENT=0

# 需要保留的自定義設定檔清單
CUSTOM_FILES=("openxiami_CustomWord.dict.yaml" "default.custom.yaml" "squirrel.custom.yaml")

# 下載主要檔案
for file in "${ROOT_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    # 檢查是否為自定義設定檔且選擇保留
    if [[ " ${CUSTOM_FILES[*]} " =~ " ${file} " ]] && [ "$KEEP_CUSTOM_FILES" = true ] && [ -f "$RIME_FOLDER/$file" ]; then
        show_progress $CURRENT $TOTAL_FILES "$file [保留]"
    else
        show_progress $CURRENT $TOTAL_FILES "$file"
        curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/$file"
    fi
done

# 下載 Lua 檔案（保留 lua/ 子目錄，例如 lua/data/emoji.txt，不可壓成 lua/emoji.txt）
for file in "${LUA_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    rel="${file#lua/}"
    dest_dir="$RIME_FOLDER/lua/$(dirname "$rel")"
    mkdir -p "$dest_dir"
    show_progress $CURRENT $TOTAL_FILES "$file"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/lua/$rel"
done

# 下載 Lua lunar_calendar 檔案
for file in "${LUA_LUNAR_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    show_progress $CURRENT $TOTAL_FILES "$filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/lua/lunar_calendar/$filename"
done

# 下載 OpenCC 檔案
for file in "${OPENCC_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    show_progress $CURRENT $TOTAL_FILES "$filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/opencc/$filename"
done

# 下載 Configs 檔案
for file in "${CONFIGS_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    show_progress $CURRENT $TOTAL_FILES "$filename"
    curl -fsSL "${GITHUB_RAW}/${file}" -o "$RIME_FOLDER/configs/$filename"
done

echo  # 換行

echo
echo "[ Step 2: 配置輸入方案版本 ]"

# 根據選擇配置對應版本
if [ "$SCHEMA_VERSION" = "mixed" ]; then
    echo "正在配置完整版（中打含英文詞庫版）..."
    cp "$RIME_FOLDER/configs/liur.schema.yaml" "$RIME_FOLDER/liur.schema.yaml"
    echo -e "${GREEN}已配置為完整版（中打含英文詞庫版）${NC}"
else
    echo "正在配置基礎版（中打不含英文詞庫）..."
    cp "$RIME_FOLDER/configs/liur.chinese-only.schema.yaml" "$RIME_FOLDER/liur.schema.yaml"
    echo -e "${GREEN}已配置為基礎版（中打不含英文詞庫）${NC}"
fi

# 清理 configs 資料夾
rm -rf "$RIME_FOLDER/configs" 2>/dev/null || true

echo
echo "[ Step 3: 安裝字體 ]"

mkdir -p "$FONT_FOLDER"

FONT_TOTAL=${#FONT_FILES[@]}
FONT_CURRENT=0

for file in "${FONT_FILES[@]}"; do
    FONT_CURRENT=$((FONT_CURRENT + 1))
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

if [ -f "$SQUIRREL_APP" ]; then
    # 終止鼠鬚管並重新啟動以觸發部署
    killall Squirrel 2>/dev/null || true
    sleep 1
    open -a Squirrel
    echo -e "${GREEN}已重新啟動鼠鬚管，正在部署中...${NC}"
else
    echo -e "${YELLOW}無法自動部署，請手動重新部署鼠鬚管${NC}"
fi

echo
echo "======================================"
echo -e "${GREEN}  蝦米輸入方案 安裝完成 可開始使用 ✨${NC}"
echo "======================================"
echo
echo "Rime 資料夾：$RIME_FOLDER"
echo "字體資料夾：$FONT_FOLDER"
echo
echo "更多資訊請參考：https://ryanwuson.github.io/rime-liur/"
