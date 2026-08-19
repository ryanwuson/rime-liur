-- liu_schema_switch_processor.lua
-- 絕對跳轉時保持 ascii_mode（liur → easy_en / liu_bpmf / liu_pinyin）

_G.liu_schema_switch_state = _G.liu_schema_switch_state or {
  saved_ascii_mode = nil,
  saved_from_schema = nil,
  saved_timestamp = nil,
  pending_restore = false,
  restore_attempted = false
}

local CONFIG = {
  STATE_TIMEOUT = 300,
  TARGET_SCHEMAS = {
    liur = true,
    easy_en = true,
    liu_bpmf = true,
    liu_pinyin = true
  }
}

-- Ctrl+' 、Ctrl+; 及其 Shift／Alt 變體
-- 按 Shift 時 ' 變 "（quotedbl）、; 變 :（colon），鼠鬚管與小狼毫送法不同，兩種都要認
local TOGGLE_REPRS = {
  ["Control+apostrophe"] = true,
  ["Control+semicolon"] = true,
  ["Control+Shift+apostrophe"] = true,
  ["Control+Shift+semicolon"] = true,
  ["Control+Shift+quotedbl"] = true,
  ["Control+Shift+colon"] = true,
  ["Control+quotedbl"] = true,
  ["Control+colon"] = true,
  ["Control+Alt+apostrophe"] = true,
  ["Control+Alt+semicolon"] = true,
}

-- ' = 39、; = 59、" = 34、: = 58
local TOGGLE_KEYCODES = {
  [39] = true,
  [59] = true,
  [34] = true,
  [58] = true,
}

local function is_schema_toggle_key(key)
  if not key:ctrl() then
    return false
  end
  if TOGGLE_REPRS[key:repr()] then
    return true
  end
  return TOGGLE_KEYCODES[key.keycode] == true
end

local function is_target_schema(schema_id)
  return CONFIG.TARGET_SCHEMAS[schema_id] == true
end

local function get_ascii_mode(env)
  local ok, result = pcall(function()
    local context = env.engine.context
    if context and context.get_option then
      return context:get_option("ascii_mode")
    end
    return nil
  end)
  if ok then
    return result
  end
  return nil
end

local function set_ascii_mode(env, state)
  local ok = pcall(function()
    local context = env.engine.context
    if context and context.set_option then
      context:set_option("ascii_mode", state)
    end
  end)
  return ok
end

local function save_ascii_mode_state(env)
  local ok = pcall(function()
    local current_state = get_ascii_mode(env)
    local schema_id = env.engine.schema.schema_id
    _G.liu_schema_switch_state.saved_ascii_mode = current_state
    _G.liu_schema_switch_state.saved_from_schema = schema_id
    _G.liu_schema_switch_state.saved_timestamp = os.time()
    _G.liu_schema_switch_state.pending_restore = true
    _G.liu_schema_switch_state.restore_attempted = false
  end)
  return ok
end

local function is_saved_state_valid()
  local state = _G.liu_schema_switch_state
  if not state.pending_restore then
    return false
  end
  if state.saved_ascii_mode == nil then
    return false
  end
  if state.saved_timestamp then
    local elapsed = os.time() - state.saved_timestamp
    if elapsed > CONFIG.STATE_TIMEOUT then
      state.pending_restore = false
      state.saved_ascii_mode = nil
      return false
    end
  end
  return true
end

local function restore_ascii_mode_state(env)
  if not is_saved_state_valid() then
    return false
  end
  local state = _G.liu_schema_switch_state
  if state.restore_attempted then
    return false
  end
  local ok = pcall(function()
    -- 狀態沒變就不要 set_option，否則鼠鬚管會多跳一次「中文／英文」通知
    local current = get_ascii_mode(env)
    if current ~= state.saved_ascii_mode then
      set_ascii_mode(env, state.saved_ascii_mode)
    end
    state.pending_restore = false
    state.restore_attempted = true
  end)
  return ok
end

local function processor(key, env)
  local current_schema = env.engine.schema.schema_id

  -- 切回 liur 後，第一次按鍵時恢復 ascii_mode
  if current_schema == "liur" then
    local state = _G.liu_schema_switch_state
    if state.pending_restore and not state.restore_attempted then
      if state.saved_from_schema == "liur" then
        restore_ascii_mode_state(env)
      end
    end
  end

  if key:release() then
    return 2
  end

  if not is_schema_toggle_key(key) then
    return 2
  end

  if not is_target_schema(current_schema) then
    return 2
  end

  if current_schema == "liur" then
    save_ascii_mode_state(env)
  end

  return 2
end

return processor
