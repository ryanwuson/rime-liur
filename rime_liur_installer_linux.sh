#!/usr/bin/env bash
# RIME 蝦米輸入方案自動安裝工具 (Linux / fcitx5)
# based on macOS version by Ryan Chou
# adapted for Arch Linux / fcitx5-rime

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub 相關設定
GITHUB_REPO="ryanwuson/rime-liur"
GITHUB_BRANCH="main"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/git/trees/${GITHUB_BRANCH}?recursive=1"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Linux (fcitx5) 路徑設定
RIME_FOLDER="$HOME/.local/share/fcitx5/rime"
FONT_FOLDER="$HOME/.local/share/fonts"

# 排除清單（正則表達式）- 排除 macOS/Windows 專用檔案
EXCLUDE_PATTERNS="^docs/|^README\.md$|^LICENSE$|^\.gitignore$|^rime_liur_installer\.sh$|^rime_liur_installer\.ps1$|^rime_liur_installer_linux\.sh$|^fonts/Windows Only/|^squirrel\.custom\.yaml$|^weasel\.custom\.yaml$|^installation\.yaml$"

# 進度條函數
show_progress() {
    local current=$1
    local total=$2
    local filename=$3
    local width=20
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    if [ ${#filename} -gt 40 ]; then
        filename="${filename:0:37}..."
    fi

    printf "\r  [%s] %3d/%d  %-45s" "$bar" "$current" "$total" "$filename"
}

echo
echo "======================================"
echo "  RIME 蝦米輸入方案 自動安裝工具"
echo "  (Linux / fcitx5)"
echo "======================================"
echo

# 檢查 fcitx5-rime
if ! pacman -Qi fcitx5-rime &>/dev/null; then
    echo -e "${RED}錯誤：尚未安裝 fcitx5-rime！${NC}"
    echo "請先安裝："
    echo "  sudo pacman -S fcitx5-rime"
    echo
    echo "若尚未安裝 fcitx5，請先執行："
    echo "  sudo pacman -S fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool"
    exit 1
fi

echo "本工具將執行以下作業："
echo "1. 選擇輸入方案版本"
echo "2. 下載蝦米輸入方案檔案到 Rime 資料夾"
echo "3. 選擇額外輸入方案（注音、日文）"
echo "4. 安裝所需字體"
echo "5. 部署 RIME"
echo

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

# 額外輸入方案選擇
echo -e "${YELLOW}是否安裝額外輸入方案？${NC}"
echo
echo "1. 僅蝦米（不安裝額外方案）"
echo "2. 加裝注音（台灣注音 bopomofo）"
echo "3. 加裝日文（rime-japanese）"
echo "4. 加裝注音 + 日文（推薦）"
echo

INSTALL_BOPOMOFO=false
INSTALL_JAPANESE=false

while true; do
    read -p "請輸入選項 (1-4): " extraChoice < /dev/tty
    case $extraChoice in
        1)
            echo -e "${GREEN}已選擇：僅蝦米${NC}"
            break
            ;;
        2)
            INSTALL_BOPOMOFO=true
            echo -e "${GREEN}已選擇：加裝注音${NC}"
            break
            ;;
        3)
            INSTALL_JAPANESE=true
            echo -e "${GREEN}已選擇：加裝日文${NC}"
            break
            ;;
        4)
            INSTALL_BOPOMOFO=true
            INSTALL_JAPANESE=true
            echo -e "${GREEN}已選擇：加裝注音 + 日文${NC}"
            break
            ;;
        *)
            echo -e "${RED}請輸入 1-4${NC}"
            ;;
    esac
done

echo
for i in {3..1}; do
    printf "\r將在 %d 秒後開始..." "$i"
    sleep 1
done
echo

echo
echo "正在從 GitHub 取得檔案清單..."
ALL_FILES=$(curl -fsSL --connect-timeout 10 --max-time 30 "$GITHUB_API" 2>/dev/null | python3 -c "
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
echo

# 建立資料夾
mkdir -p "$RIME_FOLDER"
mkdir -p "$RIME_FOLDER/lua"
mkdir -p "$RIME_FOLDER/lua/lunar_calendar"
mkdir -p "$RIME_FOLDER/opencc"
mkdir -p "$RIME_FOLDER/configs"

# 建立共用 rime 預設檔案的符號連結（fcitx5-rime 需要這些）
RIME_SHARED="/usr/share/rime-data"
for preset in default.yaml key_bindings.yaml punctuation.yaml; do
    if [ -f "$RIME_SHARED/$preset" ]; then
        ln -sf "$RIME_SHARED/$preset" "$RIME_FOLDER/$preset"
    fi
done

CURRENT=0

# 需要保留的自定義設定檔清單
CUSTOM_FILES=("openxiami_CustomWord.dict.yaml" "default.custom.yaml")

# 下載單一檔案的函數
download_file() {
    local url="$1"
    local dest="$2"
    local name="$3"
    local current="$4"
    local total="$5"

    printf "  [%d/%d] %s ... " "$current" "$total" "$name"
    if curl -fsSL --connect-timeout 10 --max-time 120 "$url" -o "$dest"; then
        echo -e "${GREEN}ok${NC}"
    else
        echo -e "${RED}failed${NC}"
    fi
}

# 下載主要檔案
for file in "${ROOT_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    if [[ " ${CUSTOM_FILES[*]} " =~ " ${file} " ]] && [ "$KEEP_CUSTOM_FILES" = true ] && [ -f "$RIME_FOLDER/$file" ]; then
        echo "  [${CURRENT}/${TOTAL_FILES}] $file ... [保留]"
    else
        download_file "${GITHUB_RAW}/${file}" "$RIME_FOLDER/$file" "$file" $CURRENT $TOTAL_FILES
    fi
done

# 下載 Lua 檔案
for file in "${LUA_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    download_file "${GITHUB_RAW}/${file}" "$RIME_FOLDER/lua/$filename" "$filename" $CURRENT $TOTAL_FILES
done

# 下載 Lua lunar_calendar 檔案
for file in "${LUA_LUNAR_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    download_file "${GITHUB_RAW}/${file}" "$RIME_FOLDER/lua/lunar_calendar/$filename" "$filename" $CURRENT $TOTAL_FILES
done

# 下載 OpenCC 檔案
for file in "${OPENCC_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    download_file "${GITHUB_RAW}/${file}" "$RIME_FOLDER/opencc/$filename" "$filename" $CURRENT $TOTAL_FILES
done

# 下載 Configs 檔案
for file in "${CONFIGS_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    download_file "${GITHUB_RAW}/${file}" "$RIME_FOLDER/configs/$filename" "$filename" $CURRENT $TOTAL_FILES
done

echo

echo
echo "[ Step 2: 配置輸入方案版本 ]"

if [ "$SCHEMA_VERSION" = "mixed" ]; then
    echo "正在配置完整版（中打含英文詞庫版）..."
    cp "$RIME_FOLDER/configs/liur.schema.yaml" "$RIME_FOLDER/liur.schema.yaml"
    echo -e "${GREEN}已配置為完整版（中打含英文詞庫版）${NC}"
else
    echo "正在配置基礎版（中打不含英文詞庫）..."
    cp "$RIME_FOLDER/configs/liur.chinese-only.schema.yaml" "$RIME_FOLDER/liur.schema.yaml"
    echo -e "${GREEN}已配置為基礎版（中打不含英文詞庫）${NC}"
fi

rm -rf "$RIME_FOLDER/configs" 2>/dev/null || true

STEP=3

# 安裝注音（條件式）
if [ "$INSTALL_BOPOMOFO" = true ]; then
    echo
    echo "[ Step $STEP: 安裝注音輸入法（台灣注音） ]"
    STEP=$((STEP + 1))

    if pacman -Qi rime-bopomofo &>/dev/null; then
        echo -e "${GREEN}rime-bopomofo（注音）已安裝${NC}"
    else
        echo "正在安裝 rime-bopomofo（台灣注音）..."
        sudo pacman -S --noconfirm rime-bopomofo
        echo -e "${GREEN}rime-bopomofo 安裝完成${NC}"
    fi

    # 移除不需要的中國輸入方案（若已安裝）
    CHINA_SCHEMAS=("rime-cangjie" "rime-pinyin-simp" "rime-stroke" "rime-wubi")
    for pkg in "${CHINA_SCHEMAS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo -e "${YELLOW}移除不需要的方案：${pkg}${NC}"
            sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null || true
        fi
    done
fi

# 安裝日文（條件式）
if [ "$INSTALL_JAPANESE" = true ]; then
    echo
    echo "[ Step $STEP: 安裝日文輸入方案 ]"
    STEP=$((STEP + 1))

    JAPANESE_SCHEMA_REPO="gkovacs/rime-japanese"
    JAPANESE_RAW="https://raw.githubusercontent.com/${JAPANESE_SCHEMA_REPO}/master"

    echo "正在下載日文輸入方案 (rime-japanese)..."

    JAPANESE_FILES=(
        "japanese.schema.yaml"
        "japanese.dict.yaml"
        "japanese.mozc.dict.yaml"
        "japanese.jmdict.dict.yaml"
        "japanese.kana.dict.yaml"
    )

    for jfile in "${JAPANESE_FILES[@]}"; do
        echo -n "  下載 $jfile ... "
        if curl -fsSL --connect-timeout 10 --max-time 120 "${JAPANESE_RAW}/${jfile}" -o "$RIME_FOLDER/$jfile" 2>/dev/null; then
            echo -e "${GREEN}完成${NC}"
        else
            echo -e "${RED}失敗（請檢查網路連線）${NC}"
        fi
    done

    echo -e "${GREEN}日文輸入方案安裝完成${NC}"
fi

echo
echo "[ Step $STEP: 配置 default.custom.yaml ]"
STEP=$((STEP + 1))

# 根據選擇建立 schema_list
EXTRA_SCHEMAS=""
EXTRA_SCHEMA_HINTS=""
if [ "$INSTALL_BOPOMOFO" = true ]; then
    EXTRA_SCHEMAS="${EXTRA_SCHEMAS}        - schema: bopomofo_tw
"
    EXTRA_SCHEMA_HINTS="${EXTRA_SCHEMA_HINTS}        - schema: bopomofo_tw
"
fi
if [ "$INSTALL_JAPANESE" = true ]; then
    EXTRA_SCHEMAS="${EXTRA_SCHEMAS}        - schema: japanese
"
    EXTRA_SCHEMA_HINTS="${EXTRA_SCHEMA_HINTS}        - schema: japanese
"
fi

if [ "$KEEP_CUSTOM_FILES" = false ] || [ ! -f "$RIME_FOLDER/default.custom.yaml" ]; then
    cat > "$RIME_FOLDER/default.custom.yaml" << YAML
__patch:
  - patch:
      menu:
        alternative_select_keys: "0123456789"	#重碼選擇鍵，從 0 開始
        page_size: 5	#選單 每頁 顯示 個數
      ascii_composer:
        good_old_caps_lock: true
        switch_key: {Caps_Lock: clear, Control_L: noop, Control_R: noop, Eisu_toggle: clear, Shift_L: commit_code, Shift_R: commit_code}
      switcher/hotkeys:
        - Control+grave
        - Control+Shift+grave

  - patch/+:
      schema_list:
        - schema: liur
        - schema: easy_en
${EXTRA_SCHEMAS}      switcher/fix_schema_list_order: true
  - patch/key_binder/bindings/+:
    - { when: always, accept: 'Control+slash', select: liur }
    - { accept: period, send: period, when: has_menu }      # 輸入.
    - { accept: "Control+period", toggle: simplification, when: always }    #進行簡繁切換
    - { accept: "Control+apostrophe", toggle: liu_w2c, when: always }   #顯示字碼
    - { accept: "Control+comma", toggle: extended_charset, when: always}
    - { accept: "Shift+space", toggle: full_shape, when: always}
    # 數字小鍵盤選字（從 0 開始，與主鍵盤一致）
    - { accept: KP_0, send: 0, when: has_menu }
    - { accept: KP_1, send: 1, when: has_menu }
    - { accept: KP_2, send: 2, when: has_menu }
    - { accept: KP_3, send: 3, when: has_menu }
    - { accept: KP_4, send: 4, when: has_menu }
    - { accept: KP_5, send: 5, when: has_menu }
    - { accept: KP_6, send: 6, when: has_menu }
    - { accept: KP_7, send: 7, when: has_menu }
    - { accept: KP_8, send: 8, when: has_menu }
    - { accept: KP_9, send: 9, when: has_menu }
    - { when: composing, accept: Control+k, send: Shift+Delete }
YAML
    echo -e "${GREEN}default.custom.yaml 已配置${NC}"
else
    echo -e "${YELLOW}default.custom.yaml 已保留${NC}"
    if [ -n "$EXTRA_SCHEMA_HINTS" ]; then
        echo -e "${YELLOW}請手動加入以下方案到 schema_list：${NC}"
        echo -n "$EXTRA_SCHEMA_HINTS"
    fi
fi

echo
echo "[ Step $STEP: 安裝字體 ]"
STEP=$((STEP + 1))

mkdir -p "$FONT_FOLDER"

FONT_TOTAL=${#FONT_FILES[@]}
FONT_CURRENT=0

for file in "${FONT_FILES[@]}"; do
    FONT_CURRENT=$((FONT_CURRENT + 1))
    filename=$(basename "$file")
    if [ -f "$FONT_FOLDER/$filename" ]; then
        echo "  [${FONT_CURRENT}/${FONT_TOTAL}] $filename ... [skip]"
    else
        download_file "${GITHUB_RAW}/${file}" "$FONT_FOLDER/$filename" "$filename" $FONT_CURRENT $FONT_TOTAL
    fi
done

# 更新字體快取
echo "正在更新字體快取..."
fc-cache -f "$FONT_FOLDER" 2>/dev/null || true
echo -e "${GREEN}字體快取已更新${NC}"

echo
echo "[ Step $STEP: 部署 RIME ]"

if command -v fcitx5-remote &>/dev/null; then
    echo "正在重新部署 fcitx5-rime..."
    fcitx5-remote -r 2>/dev/null || true
    sleep 1
    # 觸發 rime 重新部署
    if command -v rime_deployer &>/dev/null; then
        rime_deployer --build "$RIME_FOLDER" "$RIME_SHARED" 2>/dev/null || true
    fi
    fcitx5-remote -r 2>/dev/null || true
    echo -e "${GREEN}已重新部署 fcitx5-rime${NC}"
else
    echo -e "${YELLOW}無法自動部署，請手動重新啟動 fcitx5${NC}"
    echo "  可嘗試：fcitx5 -r -d"
fi

echo
echo "======================================"
echo -e "${GREEN}  蝦米輸入方案 安裝完成 可開始使用${NC}"
echo "======================================"
echo
echo "Rime 資料夾：$RIME_FOLDER"
echo "字體資料夾：$FONT_FOLDER"
echo
echo "可用的輸入方案："
echo "  - liur（蝦米）"
echo "  - easy_en（英文）"
[ "$INSTALL_BOPOMOFO" = true ] && echo "  - bopomofo_tw（台灣注音）"
[ "$INSTALL_JAPANESE" = true ] && echo "  - japanese（日文）"
echo
echo "切換方案：Ctrl+\` 或 Ctrl+Shift+\`"
echo
echo "更多資訊請參考：https://ryanwuson.github.io/rime-liur/"
