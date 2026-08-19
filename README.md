# 蝦米輸入法 Rime 方案

基於 Rime 輸入法引擎的蝦米輸入法方案，提供多元之輸入體驗，包含豐富的功能和仿 macOS 原生風格的候選字框主題。

## 主要特色

- 🚀 **蝦米功能**：包含標準字碼、簡碼及 VRSF 選擇等等完整功能
- 🎨 **精美主題**：仿 macOS 原生輸入法風格，支援淺色/深色主題自動切換
- 📝 **智慧造詞**：支援臨時造詞和自訂詞庫編輯
- 🔍 **多種查詢模式**：字碼查詢、讀音查詢、同音字查詢、萬用字元查詢
- 🎯 **快打模式**：提示可用簡碼，幫助學習和提升輸入效率
- 🔤 **豐富符號**：50+ 分類符號清單、變體英數、字母變化形
- 📅 **日期時間**：多格式日期時間輸出
- 🎵 **注音**：獨立注音輸入法；嘸蝦米內亦可注音輸入、注音直出、讀音查詢
- 🔠 **拼音**：獨立拼音輸入法；嘸蝦米內亦可以漢語拼音輸入（支援數字聲調）
- 🌐 **英文詞庫**：完整版包含英文詞庫，支援自動補全和大小寫轉換（`]`/`]]`）

## 版本選擇

本方案提供兩個版本供使用者選擇：

- **基礎版（中打不含英文詞庫）**：專注中文輸入，不含英文詞庫，減少英文候選干擾
- **完整版（中打含英文詞庫版）**：包含英文詞庫，支援英文自動補全和大小寫轉換

安裝腳本會自動提示選擇版本。

## 快速開始

### 安裝需求

- **macOS**: 鼠鬚管 ([Squirrel](https://github.com/rime/squirrel/releases))
- **Windows**: 小狼毫 ([Weasel](https://github.com/rime/weasel/releases))

### 手動安裝步驟

1. 下載本專案所有檔案
2. 將檔案複製到 Rime 使用者資料夾：
   - **macOS**: `~/Library/Rime/`
   - **Windows**: `%AppData%\Rime\`
3. 選擇版本：
   - **基礎版（中打不含英文詞庫）**：從 `configs` 資料夾複製 `liur.chinese-only.schema.yaml` 到 Rime 使用者資料夾，並重新命名為 `liur.schema.yaml`
   - **完整版（中打含英文詞庫版）**：從 `configs` 資料夾複製 `liur.schema.yaml` 到 Rime 使用者資料夾
4. 重新部署 Rime

### 指令安裝步驟

#### macOS

打開終端機 (Terminal)，輸入以下指令：
```bash
curl -fsSL https://raw.githubusercontent.com/ryanwuson/rime-liur/main/rime_liur_installer.sh | bash
```

腳本會自動下載所需檔案並安裝字體

![readme-mac](docs/images/readme-mac.png)

#### Windows

打開 PowerShell，輸入以下指令：
```powershell
irm https://raw.githubusercontent.com/ryanwuson/rime-liur/main/rime_liur_installer.ps1 | iex
```

腳本會自動下載所需檔案並安裝字體

![readme-win](docs/images/readme-win.png)

### 基本使用

- 直接輸入蝦米字碼，按 `Space` 或數字鍵選字
- 按 `Ctrl + /` 開啟查碼模式，學習字碼拆解
- 輸入 `,,sp` 開啟快打模式，輸入時顯示簡碼提示
- 輸入 `;` 進入造詞模式

## 方案切換

記法：`'` 族＝蝦米／注音；`;` 族＝英文／拼音；`/`＝查碼。舊版的 `Ctrl + /` 切英文、`Ctrl + '` 查碼，現已對調。

四套方案可直接互相跳轉：

| 快捷鍵 | 跳到 |
|:-------|:-----|
| `Ctrl + '` | 嘸蝦米 |
| `Ctrl + Shift + '` | 注音輸入法 |
| `Ctrl + ;` | Easy English（英文） |
| `Ctrl + Shift + ;` | 拼音輸入法 |
| <code>Ctrl + &#96;</code> | 叫出方案選單 |

## 主要功能

| 功能 | 快捷鍵/引導鍵 | 說明 |
|:-----|:-------------|:-----|
| 查碼模式 | `Ctrl + /` | 顯示字碼，學習拆字 |
| 造詞模式 | `;` | 臨時造詞 |
| 刪除臨時造詞 | `Ctrl + K` | 刪除目前這條臨時造詞／詞組記憶（macOS 也可 `Fn + Shift + Delete`） |
| 同音選字 | `'` | 選中候選字後按 `'`，顯示同音字 |
| 讀音查詢 | `;;` | 輸入字碼查讀音 |
| 蝦米內注音 | `';` | 在嘸蝦米內以注音找中文 |
| 蝦米內拼音 | `;'` | 在嘸蝦米內以漢語拼音找中文 |
| 符號清單 | `` ` `` | 50+ 分類符號（四套方案皆可） |
| 快打模式 | `,,sp` | 提示可用簡碼 |
| 萬用查字 | `,,wc` + `?` | 模糊查詢字碼 |
| 計算機 | `Ctrl + =` | 四套方案皆可；嘸蝦米也可輸入 `,,=` |
| 按鍵說明 | `,,h` | 顯示所有快捷鍵說明 |

## 文件

- 📖 **[完整使用說明](https://ryanwuson.github.io/rime-liur/)** - 詳細功能介紹和使用方法
- 🎨 **主題設定** - 字體安裝和候選字框自訂
- ⚙️ **進階設定** - 自訂詞庫和個人化配置

## 系統需求

### 字體需求

為確保候選字框顯示最佳，請安裝以下字體（macOS／Windows 相同）：

- MapleMonoNormal-Regular.ttf
- PlangothicP1-Regular.ttf
- PlangothicP2-Regular.ttf

## 授權

本專案基於開源授權發佈，歡迎使用和改進。

## 致謝

自使用RIME輸入法以來，用過不少人提供的方案，也從中獲取相關靈感及檔案，進行後續的重整、規劃及建置，特此感謝。

-  [onion](https://github.com/oniondelta/Onion_Rime_Files)
-  [Ryan.Chou](https://github.com/hsuanyi-chou/rime-liur)
-  [hftsai256](https://github.com/hftsai256/rime-liur-lua)
-  [ianzhuo](https://github.com/ianzhuo/rime-liur)