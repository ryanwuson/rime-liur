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
Write-Host "1. 下載蝦米輸入方案檔案到 Rime 資料夾"
Write-Host "2. 安裝所需字體"
Write-Host ""
Write-Host "※ 若有自訂設定尚未備份，請按 Ctrl+C 終止" -ForegroundColor Yellow
Write-Host ""

for ($i = 5; $i -ge 1; $i--) {
    Write-Host "`r將在 $i 秒後開始..." -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host ""  # 換行

Write-Host ""
Write-Host "[ Step 1: 取得檔案清單 ]" -ForegroundColor Green

# 從 GitHub API 取得檔案清單
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
$TOTAL_FILES = $ROOT_FILES.Count + $LUA_FILES.Count + $LUA_LUNAR_FILES.Count + $OPENCC_FILES.Count
$TOTAL_FONTS = $FONT_FILES.Count + $FONT_FILES_WIN.Count
Write-Host "找到 $TOTAL_FILES 個方案檔案、$TOTAL_FONTS 個字體"

Write-Host ""
Write-Host "[ Step 2: 下載蝦米輸入方案檔案 ]" -ForegroundColor Green

# 建立資料夾
New-Item -ItemType Directory -Force -Path $RIME_FOLDER | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\lua\lunar_calendar" | Out-Null
New-Item -ItemType Directory -Force -Path "$RIME_FOLDER\opencc" | Out-Null

$current = 0

# 下載主要檔案
foreach ($file in $ROOT_FILES) {
    $current++
    Show-Progress -Current $current -Total $TOTAL_FILES -FileName $file
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\$file" | Out-Null
}

# 下載 Lua 檔案
foreach ($file in $LUA_FILES) {
    $current++
    $filename = Split-Path $file -Leaf
    Show-Progress -Current $current -Total $TOTAL_FILES -FileName $filename
    Invoke-WebRequest -Uri "$GITHUB_RAW/$file" -OutFile "$RIME_FOLDER\lua\$filename" | Out-Null
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

Write-Host ""  # 換行

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
Write-Host "[ Step 4: 完成 ]" -ForegroundColor Green
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
