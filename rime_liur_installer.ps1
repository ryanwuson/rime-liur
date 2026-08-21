# RIME 蝦米輸入方案自動安裝工具 (Windows PowerShell)
# created by Ryan Chou
# https://github.com/ryanwuson/rime-liur

$ErrorActionPreference = "Stop"

# GitHub 相關設定
$GITHUB_REPO = "ryanwuson/rime-liur"
$GITHUB_BRANCH = "main"
$GITHUB_API = "https://api.github.com/repos/$GITHUB_REPO/git/trees/$GITHUB_BRANCH`?recursive=1"
$GITHUB_RAW = "https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH"

# 設定路徑
$RIME_FOLDER = "$env:APPDATA\Rime"
$FONT_FOLDER = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

# 排除清單（正則表達式）
$EXCLUDE_PATTERNS = @(
    "^docs/"
    "^README\.md$"
    "^LICENSE$"
    "^\.gitignore$"
    "^rime_liur_installer\.sh$"
    "^rime_liur_installer\.ps1$"
)

# 進度條函數
function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$FileName
    )
    
    $width = 20
    $percent = [math]::Floor($Current * 100 / $Total)
    $filled = [math]::Floor($Current * $width / $Total)
    $empty = $width - $filled
    
    $bar = "█" * $filled + "░" * $empty
    
    # 截斷過長的檔名（保留空間給 [skip]）
    if ($FileName.Length -gt 40) {
        $FileName = $FileName.Substring(0, 37) + "..."
    }
    
    $status = "  [$bar] $("{0,3}" -f $Current)/$Total  $($FileName.PadRight(45))"
    Write-Host "`r$status" -NoNewline
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  RIME 蝦米輸入方案 自動安裝工具" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "本工具將執行以下作業："
Write-Host "1. 選擇輸入方案版本"
Write-Host "2. 下載蝦米輸入方案檔案到 Rime 資料夾"
Write-Host "3. 安裝所需字體"
Write-Host ""
Write-Host "※ 若有自訂設定尚未備份，請按 Ctrl+C 終止" -ForegroundColor Yellow
Write-Host ""

# 版本選擇
Write-Host "請選擇輸入方案版本：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 完整版（中打含英文詞庫版）（推薦）"
Write-Host "   - 完整功能，中文輸入搭配英文詞庫輔助"
Write-Host "   - 英文詞庫支援，大小寫轉換"
Write-Host "   - 適合日常使用、程式開發"
Write-Host ""
Write-Host "2. 基礎版（中打不含英文詞庫）"
Write-Host "   - 專注中文輸入，不含英文詞庫"
Write-Host "   - 減少英文候選干擾"
Write-Host "   - 適合純中文寫作"
Write-Host ""

do {
    $choice = Read-Host "請輸入選項 (1 或 2)"
} while ($choice -ne "1" -and $choice -ne "2")

if ($choice -eq "1") {
    $SCHEMA_VERSION = "mixed"
    Write-Host "已選擇：完整版（中打含英文詞庫版）" -ForegroundColor Green
} else {
    $SCHEMA_VERSION = "chinese-only"
    Write-Host "已選擇：基礎版（中打不含英文詞庫）" -ForegroundColor Green
}

Write-Host ""

# 自定義設定檔選項
Write-Host "是否覆蓋自定義設定檔？" -ForegroundColor Yellow
Write-Host ""
Write-Host "以下檔案用於儲存您的個人設定與詞彙："
Write-Host "• openxiami_CustomWord.dict.yaml（自定義詞庫）"
Write-Host "• default.custom.yaml（全域設定）"
Write-Host "• weasel.custom.yaml（小狼毫外觀設定）"
Write-Host ""
Write-Host "若您已有自訂設定，建議選擇「保留」以避免遺失。"
Write-Host ""
Write-Host "1. 保留（推薦）- 保留現有的自定義設定檔"
Write-Host "2. 覆蓋 - 下載預設設定檔（會清除您的自訂設定）"
Write-Host ""

do {
    $customChoice = Read-Host "請輸入選項 (1 或 2)"
} while ($customChoice -ne "1" -and $customChoice -ne "2")

if ($customChoice -eq "1") {
    $KEEP_CUSTOM_FILES = $true
    Write-Host "已選擇：保留自定義設定檔" -ForegroundColor Green
} else {
    $KEEP_CUSTOM_FILES = $false
    Write-Host "已選擇：覆蓋自定義設定檔" -ForegroundColor Green
}

Write-Host ""

for ($i = 3; $i -ge 1; $i--) {
    Write-Host "`r將在 $i 秒後開始..." -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host ""  # 換行

Write-Host ""
Write-Host "正在從 GitHub 取得檔案清單..."
try {
    $response = Invoke-RestMethod -Uri $GITHUB_API -Method Get
} catch {
    Write-Host "[錯誤] GitHub API 連線失敗" -ForegroundColor Red
    Write-Host "       請檢查網路連線，或稍後再試"
    Write-Host "       若持續失敗，請至 GitHub 手動下載："
    Write-Host "       https://github.com/$GITHUB_REPO"
    exit 1
}

if (-not $response.tree) {
    Write-Host "[錯誤] 無法解析檔案清單" -ForegroundColor Red
    Write-Host "       請稍後再試，或至 GitHub 手動下載："
    Write-Host "       https://github.com/$GITHUB_REPO"
    exit 1
}

# 過濾檔案函數
function Test-ShouldExclude {
    param([string]$FilePath)
    foreach ($pattern in $EXCLUDE_PATTERNS) {
        if ($FilePath -match $pattern) {
            return $true
        }
    }
    return $false
}

# 分類檔案
$ROOT_FILES = @()
$LUA_FILES = @()
$LUA_LUNAR_FILES = @()
$OPENCC_FILES = @()
$CONFIGS_FILES = @()
$FONT_FILES = @()
$FONT_FILES_WIN = @()

foreach ($item in $response.tree) {
    # 只處理檔案（blob），跳過資料夾（tree）
    if ($item.type -ne "blob") { continue }
    
    $filePath = $item.path
    
    # 檢查是否要排除
    if (Test-ShouldExclude $filePath) { continue }
    
    # 根據路徑分類
    if ($filePath -match "^lua/lunar_calendar/") {
        $LUA_LUNAR_FILES += $filePath
    } elseif ($filePath -match "^lua/") {
        $LUA_FILES += $filePath
    } elseif ($filePath -match "^opencc/") {
        $OPENCC_FILES += $filePath
    } elseif ($filePath -match "^configs/") {
        $CONFIGS_FILES += $filePath
    } elseif ($filePath -match "^fonts/Windows Only/") {
        $FONT_FILES_WIN += $filePath
    } elseif ($filePath -match "^fonts/") {
        $FONT_FILES += $filePath
    } elseif ($filePath -notmatch "/") {
        # 根目錄檔案（不含子資料夾）
        $ROOT_FILES += $filePath
    }
}

# 計算總檔案數
$TOTAL_FILES = $ROOT_FILES.Count + $LUA_FILES.Count + $LUA_LUNAR_FILES.Count + $OPENCC_FILES.Count + $CONFIGS_FILES.Count
$TOTAL_FONTS = $FONT_FILES.Count + $FONT_FILES_WIN.Count
Write-Host "找到 $TOTAL_FILES 個方案檔案、$TOTAL_FONTS 個字體"

Write-Host ""
Write-Host "[ Step 1: 下載蝦米輸入方案檔案 ]" -ForegroundColor Green

# 建立資料夾
New-Item -ItemType Directory -Force -Path $RIME_FOLDER | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua\lunar_calendar" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua\data" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\opencc" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\configs" | Out-Null

$current = 0

# 需要保留的自定義設定檔清單
$CUSTOM_FILES = @("openxiami_CustomWord.dict.yaml", "default.custom.yaml", "weasel.custom.yaml")

# 下載主要檔案
foreach ($file in $ROOT_FILES) {
    $current++
    # 檢查是否為自定義設定檔且選擇保留
    if ($CUSTOM_FILES -contains $file -and $KEEP_CUSTOM_FILES -and (Test-Path "$RIME_FOLDER\$file")) {
        Show-Progress -Current $current -Total $TOTAL_FILES -FileName "$file [保留]"
    } else {
        Show-Progress -Current $current -Total $TOTAL_FILES -FileName $file
        Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\$file" | Out-Null
    }
}

# 下載 Lua 檔案（保留 lua/ 子目錄，例如 lua/data/emoji.txt）
foreach ($file in $LUA_FILES) {
    $current++
    $rel = $file -replace '^lua/', ''
    $dest = Join-Path $RIME_FOLDER "lua\$rel"
    $destDir = Split-Path $dest -Parent
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    Show-Progress -Current $current -Total $TOTAL_FILES -FileName $file
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile $dest | Out-Null
}

# 下載 Lua lunar_calendar 檔案
foreach ($file in $LUA_LUNAR_FILES) {
    $current++
    $filename = Split-Path $file -Leaf
    Show-Progress -Current $current -Total $TOTAL_FILES -FileName $filename
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\lua\lunar_calendar\$filename" | Out-Null
}

# 下載 OpenCC 檔案
foreach ($file in $OPENCC_FILES) {
    $current++
    $filename = Split-Path $file -Leaf
    Show-Progress -Current $current -Total $TOTAL_FILES -FileName $filename
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\opencc\$filename" | Out-Null
}

# 下載 Configs 檔案
foreach ($file in $CONFIGS_FILES) {
    $current++
    $filename = Split-Path $file -Leaf
    Show-Progress -Current $current -Total $TOTAL_FILES -FileName $filename
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\configs\$filename" | Out-Null
}

Write-Host ""  # 換行

Write-Host ""
Write-Host "[ Step 2: 配置輸入方案版本 ]" -ForegroundColor Green

# 根據選擇配置對應版本
if ($SCHEMA_VERSION -eq "mixed") {
    Write-Host "正在配置完整版（中打含英文詞庫版）..."
    Copy-Item "$RIME_FOLDER\configs\liur.schema.yaml" "$RIME_FOLDER\liur.schema.yaml" -Force
    Write-Host "已配置為完整版（中打含英文詞庫版）" -ForegroundColor Green
} else {
    Write-Host "正在配置基礎版（中打不含英文詞庫）..."
    Copy-Item "$RIME_FOLDER\configs\liur.chinese-only.schema.yaml" "$RIME_FOLDER\liur.schema.yaml" -Force
    Write-Host "已配置為基礎版（中打不含英文詞庫）" -ForegroundColor Green
}

# 清理 configs 資料夾
Remove-Item -Recurse -Force "$RIME_FOLDER\configs" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[ Step 3: 安裝字體 ]" -ForegroundColor Green

New-Item -ItemType Directory -Force -Path $FONT_FOLDER | Out-Null

$fontCurrent = 0

# 下載共用字體
foreach ($file in $FONT_FILES) {
    $fontCurrent++
    $filename = Split-Path $file -Leaf
    if (Test-Path "$FONT_FOLDER\$filename") {
        Show-Progress -Current $fontCurrent -Total $TOTAL_FONTS -FileName "$filename [skip]"
    } else {
        Show-Progress -Current $fontCurrent -Total $TOTAL_FONTS -FileName $filename
        Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$FONT_FOLDER\$filename" | Out-Null
    }
}

# Windows 額外字體
foreach ($file in $FONT_FILES_WIN) {
    $fontCurrent++
    $filename = Split-Path $file -Leaf
    if (Test-Path "$FONT_FOLDER\$filename") {
        Show-Progress -Current $fontCurrent -Total $TOTAL_FONTS -FileName "$filename [skip]"
    } else {
        $encodedPath = $file -replace " ", "%20"
        Show-Progress -Current $fontCurrent -Total $TOTAL_FONTS -FileName $filename
        Invoke-WebRequest -Uri "$GITHUB_RAW/$encodedPath" -OutFile "$FONT_FOLDER\$filename" | Out-Null
    }
}

Write-Host ""  # 換行

Write-Host ""
Write-Host "[ Step 4: 部署 RIME ]" -ForegroundColor Green
Write-Host ""
Write-Host "請手動重新部署小狼毫（右鍵點擊系統匣圖示 → 重新部署）" -ForegroundColor Yellow
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  蝦米輸入方案 安裝完成 可開始使用 ✨" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Rime 資料夾：$RIME_FOLDER"
Write-Host "字體資料夾：$FONT_FOLDER"
Write-Host ""
Write-Host "更多資訊請參考：https://ryanwuson.github.io/rime-liur/"
