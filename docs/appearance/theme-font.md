# 主題與字體設定

## 主題說明

本方案提供仿 macOS 原生輸入法風格的候選字框主題，含淺色（macos_light）與深色（macos_dark），會自動跟隨系統主題切換。

<img src="../images/15.亮暗主題.png" alt="亮暗主題" style="zoom:67%;" />

## 設定檔位置

| 平台 | 輸入法 | 設定檔 |
|:----:|:------:|:-------|
| macOS | 鼠鬚管 Squirrel | `squirrel.custom.yaml` |
| Windows | 小狼毫 Weasel | `weasel.custom.yaml` |

## 字體大小調整

### macOS 鼠鬚管

| 項目 | 參數 | 預設 | 說明 |
|:----:|:-----|:----:|:-----|
| 候選字大小 | `font_point` | 26 | 候選字字體大小 |
| 序號大小 | `label_font_point` | 14 | 候選序號字體大小 |
| 註解大小 | `comment_font_point` | 18 | 編碼提示等註解字體大小 |

### Windows 小狼毫

| 項目 | 參數 | 預設 | 說明 |
|:----:|:-----|:----:|:-----|
| 候選字大小 | `font_point` | 16 | 候選字字體大小 |
| 序號大小 | `label_font_point` | 9 | 候選序號字體大小 |
| 註解大小 | `comment_font_point` | 11 | 編碼提示等註解字體大小 |

## 必裝字體

為確保候選字框顯示最佳，請安裝以下字體：

| 字體檔案 | 用途 |
|:---------|:-----|
| `MapleMonoNormal-Regular.ttf` | 英文數字等寬顯示 |
| `PlangothicP1-Regular.ttf` | CJK 擴充字集黑體 |
| `PlangothicP2-Regular.ttf` | CJK 擴充字集黑體 |

## 字體說明

- **Maple Mono Normal**：等寬字體，讓英文、數字、符號對齊，候選字框更整齊。
- **Plangothic（遍黑體）**：支援 CJK 擴充字集的黑體，取代過往花園明朝體。
