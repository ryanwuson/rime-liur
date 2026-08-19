local is_split_sentence
local wordninja_split

local function capture(cmd)
   local f = assert(io.popen(cmd, 'r'))
   local s = assert(f:read('*a'))
   f:close()
   return s
end

local function init(env)
   is_split_sentence = env.engine.schema.config:get_bool('easy_en/split_sentence')
   if not is_split_sentence then
      wordninja_split = function(sentence)
         return sentence
      end
      return
   end

   local use_wordninja_rs_lua_module = env.engine.schema.config:get_bool('easy_en/use_wordninja_rs_lua_module')
   local use_wordninja_rs = env.engine.schema.config:get_bool('easy_en/use_wordninja_rs')
   local use_wordninja_py = env.engine.schema.config:get_bool('easy_en/use_wordninja_py')
   if (not use_wordninja_rs_lua_module) and (not use_wordninja_rs) and (not use_wordninja_py) then
      -- default use wordninja_rs_lua_module
      use_wordninja_rs_lua_module = true
   end

   if use_wordninja_rs_lua_module then
      local wordninja_rs_lua_module_path = env.engine.schema.config:get_string('easy_en/wordninja_rs_lua_module_path')
      if not string.find(package.cpath, wordninja_rs_lua_module_path, 1, true) then
         package.cpath = package.cpath .. ";" .. wordninja_rs_lua_module_path
      end
      wordninja_split = require("wordninja").split
      return
   end

   if use_wordninja_rs then
      local wordninja_rs_path = env.engine.schema.config:get_string('easy_en/wordninja_rs_path')
      wordninja_split = function(sentence)
         return capture(wordninja_rs_path .. " -n '" .. sentence .. "'")
      end
      return
   end

   if use_wordninja_py then
      wordninja_split = function(sentence)
         return capture([[python -c "import sys; import wordninja; sys.stdout.write(' '.join(wordninja.split(']] .. sentence .. [[')))"]])
      end
      return
   end
end

local function enhance_filter(input, env)
   local context = env.engine.context
   local input_text = context.input

   -- 完全跳過自定義的特殊模式（以 ` 開頭的輸入），避免 preedit 被吃掉或被加上多餘的空白
   if input_text and (input_text:match("^`") or input_text:match("^cal=")) then
      for cand in input:iter() do yield(cand) end
      return
   end

   for cand in input:iter() do
      if (cand.comment:find("☯")) then
         if (is_split_sentence) then
            local sentence = wordninja_split(cand.text)
            local lower_sentence = string.lower(sentence)

            if (not (lower_sentence == sentence)) then
               yield(Candidate("sentence", cand.start, cand._end, lower_sentence .. " ", "💡"))
            end

            yield(Candidate("sentence", cand.start, cand._end, sentence .. " ", "💡"))
         end
      else
         yield(Candidate("word", cand.start, cand._end, cand.text .. " ", cand.comment))
      end
   end
end

return { enhance_filter = { init = init, func = enhance_filter} }
