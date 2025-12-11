-- liu_extended_segmentor.lua
-- 擴充模式 segmentor
-- 當輸入是 `` 開頭時，產生 extended_mode segment

local function segmentor(segmentation, env)
  local context = env.engine.context
  local input = context.input
  
  -- 檢查是否以 `` 開頭
  if not input:match("^``") then
    return true  -- 繼續處理
  end
  
  -- 創建 segment
  local seg = Segment(0, #input)
  seg.tags = { extended_mode = true }
  segmentation:add_segment(seg)
  
  return false  -- 停止處理
end

return segmentor
