# 自訂設定

改完請 **重新部署 Rime**。請改 **Rime 使用者資料夾**裡的檔案，不是安裝包裡那一份。

| 平台 | 資料夾 |
|------|--------|
| macOS | `~/Library/Rime/`（鼠鬚管選單 →「用戶設定」） |
| Windows | `%AppData%\Rime\`（小狼毫圖示 →「用戶文件夾」） |

重新部署：macOS 按 <code>Ctrl + Option + &#96;</code>；Windows 右鍵輸入法圖示 →「重新部署」。

?> 重新安裝或覆蓋方案檔後，下列數字／開關可能被蓋回預設，需再改一次。

## 候選字每頁幾個

預設每頁 **5** 個（選字鍵 `0`～`4`）。若要改成 **7** 或 **9**，把下面的 `5` 改成對應數字即可。選字鍵已是 `0`～`9`（從 `0` 開始），改成 7 後用 `0`～`6`，改成 9 後用 `0`～`8`。

嘸蝦米與 Easy English 跟著第一個檔；獨立注音、獨立拼音各有自己的設定，**三處都要改** 才會四處一致。

### 嘸蝦米（含 Easy English）

開啟 `default.custom.yaml`，在 `menu:` 裡找到：

```yaml
        page_size: 5	#選單 每頁 顯示 個數
```

把 `5` 改成 `7` 或 `9`。

### 獨立注音

開啟 `liu_bpmf.custom.yaml`，找到：

```yaml
  menu/page_size: 5
```

把 `5` 改成 `7` 或 `9`。

### 獨立拼音

開啟 `liu_pinyin.custom.yaml`，找到：

```yaml
  menu/page_size: 5
```

把 `5` 改成 `7` 或 `9`。

## 快打／強制快打常駐

`,,sp`、`,,sf` 預設每次部署後會回到「關閉」。若要一開機（重新部署後）就常開，改 `liur.schema.yaml` 的 `switches:` 區段。

### 快打提示常駐（`,,sp`）

尋找 `name: quick_mode`，把 `reset: 0` 改成 `reset: 1`：

```yaml
  - name: quick_mode
    reset: 1
    states: [ 正常, 快打提示 ]
```

### 強制快打常駐（`,,sf`）

尋找 `name: force_quick_mode`，把 `reset: 0` 改成 `reset: 1`：

```yaml
  - name: force_quick_mode
    reset: 1
    states: [ 正常, 強制快打 ]
```

兩者可依習慣擇一常駐，不必同時開。功能說明見 [快打與強制快打](/features/quick-mode.md)。

## 相關

- [蝦米字碼輸入](/features/basic-input.md)
- [快打與強制快打](/features/quick-mode.md)
- [注音輸入法（獨立方案）](/features/bopomofo.md)
- [拼音輸入法（獨立方案）](/features/pinyin.md)
