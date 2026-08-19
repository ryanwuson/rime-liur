# 拼音輸入法（獨立方案）

這是一套 **獨立的拼音方案**（`liu_pinyin`），適合長時間用漢語拼音打字。與嘸蝦米方案裡的 [蝦米內拼音輸入](/features/phonetic-lookup.md#蝦米內拼音輸入) 不同，這裡是完整的拼音輸入體驗。

## 切換到拼音

- **快捷鍵**：`Ctrl + Shift + ;`
- 切回嘸蝦米：`Ctrl + '`
- 也可用 <code>Ctrl + &#96;</code>（反引號）叫出方案選單選「拼音輸入法」。

## 基本操作

| 按鍵 | 功能 |
|------|------|
| 拼音字母 | 輸入漢語拼音，可連續輸入 |
| `Space` | 找字上屏（選第一個候選字） |
| `'` | 手動分節。例如「西岸」打成 `xi ⁞ an`；若不分節，會連成 `xian`，變成「現」 |

![拼音輸入法](../images/14.拼音輸入法.gif)

## 拼音文

**Enter**：以**拼音文**上屏（直接輸出拼音字母本身）。

**Shift + Enter**：以**帶音標拼音**上屏（有打 1～5 才標調，不自動補一聲）。

![拼音文](../images/14.2拼音文.gif)

## 分節

音節黏成別的字時，按 `'` 手動切開。例如「西岸」應打成 `xi ⁞ an`；若不分節，會連成 `xian`，變成「現」。

![拼音分節](../images/14.3拼音分節.gif)

## 說明

- 主詞庫與注音方案共用同一組中文大庫。
- 只打每個字的**首碼**也可組詞，例如 `p g` →「蘋果」。
- 單字候選會附上蝦米字碼，方便一邊打拼音、一邊學拆碼；詞組不提示。
- 支援繁簡、Emoji 隨附（見 [Emoji](/features/emoji.md)）。
- 與 Easy English 相同，可直接用 [符號清單](/features/symbols.md)（<code>&#96;</code>）與 [擴充模式](/features/extended.md)（<code>&#96;&#96;</code>）。

## 相關

- [方案切換與快捷鍵](/getting-started/switch-schemes.md)
- [注音輸入法（獨立方案）](/features/bopomofo.md)
- [符號清單](/features/symbols.md)
- [擴充模式與日期時間](/features/extended.md)
- [自訂設定](/getting-started/customize.md)（候選個數）
