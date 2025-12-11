-- liu_help.lua
-- 按鍵說明（,,h）：顯示所有功能的快捷鍵說明

local M = {}

M.help_items = {
    "同音選字 ▸ 字尾 + '",
    "注音輸入 ▸ ';",
    "注音直出 ▸ ';'",
    "讀音查詢 ▸ ;;",
    "造詞功能 ▸ ;",
    "符號清單 ▸ `",
    "簡繁切換 ▸ Ctrl + .",
    "查碼功能 ▸ Ctrl + '",
    "英文輸入 ▸ Ctrl + /",
    "英數變體 ▸ `/",
    "日期時間 ▸ ``/",
    "字母變化 ▸ `` + a~z",
    "快打模式 ▸ ,,sp",
    "萬用查字 ▸ ,,wc",
    "擴充字集 ▸ Ctrl + ,",
}

function M.translator(input, seg, env)
    -- 直接檢查完整輸入是否為 ,,h
    local context_input = env.engine.context.input
    if context_input ~= ",,h" then return end
    
    -- 顯示說明
    for _, item in ipairs(M.help_items) do
        yield(Candidate("help", seg.start, seg._end, item, ""))
    end
end

return M
