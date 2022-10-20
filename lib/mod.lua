--
-- require the `mods` module to gain access to hooks, menu, and other utility
-- functions.
--

local mod = require 'core/mods'

--
-- [optional] a mod is like any normal lua module. local variables can be used
-- to hold any state which needs to be accessible across hooks, the menu, and
-- any api provided by the mod itself.
--
-- here a single table is used to hold some x/y values
--

local state = {
  sel_param = 1,
  mod_displaying = false,
  k1_active = false
}

--------------------------
-- osc functions
--------------------------

-- receiver 
function osc.event(path,args,from)
  local param = string.sub(path,2)
  local val = args[1]
  -- local param = params:lookup_param(param)

  -- param types
  -- 0: separator
  -- 1: number
  -- 2: options
  -- 3: control
  -- 5: taper
  -- 6: trigger
  -- 7: group
  -- 8: text

  local type = params:t(param)
  local min, max, mapped_val

  if type == 1 then      -- 1: number
    min = params:get_range(param)[1]
    max = params:get_range(param)[2]
    mapped_val = util.linlin(1,127,min,max,val)
    params:set(param, mapped_val)
  elseif type == 2 then  -- 2: options
    min = 1
    max = params:lookup_param(param).count
    params:set(param, val)
  elseif type == 3 or type == 5 then  -- 3: control/ 5: taper
    -- local raw = param.raw
    -- min = param.controlspec.minval
    -- max = param.controlspec.maxval
    -- mapping for control/taper params
    local pre_mapped_val = util.linlin(1,127,0,1,val)
    mapped_val = params:lookup_param(param).controlspec:map(pre_mapped_val)
    params:set(param, mapped_val)
    print(param, mapped_val)
  elseif type == 6 then  -- 6: trigger
    if val == 127 then
      params:set(param, 1)
    end
  end     

  
end

-- function osc.event(path,args,from)
--   if path == "/x" then
--     -- params:set("x_axis",args[1])
--     print("touched pin #: ", args[1])
--   elseif path == "/y" then
--     print("/y", args[1])
--     -- params:set("y_axis",args[1])
--   elseif path == "send" then
--     print("external IP "..from[1])
--     external_osc_IP = from[1]
--   end
-- end

-- sender




--
-- [optional] hooks are essentially callbacks which can be used by multiple mods
-- at the same time. each function registered with a hook must also include a
-- name. registering a new function with the name of an existing function will
-- replace the existing function. using descriptive names (which include the
-- name of the mod itself) can help debugging because the name of a callback
-- function will be printed out by matron (making it visible in maiden) before
-- the callback function is called.
--
-- here we have dummy functionality to help confirm things are getting called
-- and test out access to mod level state via mod supplied fuctions.
--

mod.hook.register("system_post_startup", "osc-mod startup", function()
  state.system_post_startup = true
  p_list = include('osc-mod/lib/p_list') 
end)

mod.hook.register("script_pre_init", "osc-mod init", function()
    
    -- tweak global environment here ahead of the script `init()` function being called
    local og_init = init
    init = function()
      og_init()
      print(">>>>init from mod")
      p_list.init()

      clock.run( function()
        while true do
          if state.mod_displaying == true then
            -- tell the menu system to redraw, which in turn calls the mod's menu redraw function
            mod.menu.redraw()
          end
          clock.sleep(1/5)
        end
      end)

    end
end)


--
-- [optional] menu: extending the menu system is done by creating a table with
-- all the required menu functions defined.
--

local m = {}

m.key = function(n, z)
  if n == 1 and z == 1 then
    state.k1_active = true
  elseif n == 1 and z == 0 then
    state.k1_active = false
  elseif n == 2 and z == 1 then
    -- return to the mod selection menu
    mod.menu.exit()
  elseif n == 3 and z == 0 and state.k1_active and norns.state.name ~= "none" then
    p_list:write_params()
  end
end

  
m.enc = function(n, d)
  if n == 2 then 
    if state.k1_active then
      local found_separator_sub_menu = false
      while found_separator_sub_menu == false and state.k1_active do
        state.sel_param =  util.wrap(state.sel_param+d,1,#p_list.lookup)
        local p_name = p_list.lookup[state.sel_param].name
        local p_id = p_list.lookup[state.sel_param].id
        -- if string.find(p_name,"<<") == 1 and string.find(p_name,">>") == #p_name-1 then
        if string.find(p_name,">>") ~= nil and params:lookup_param(p_id).t == 7 then
          -- print("input separator: ",p_name)
          found_separator_sub_menu = true
        end
      end
    else
      state.sel_param = util.wrap(state.sel_param + d, 1, #p_list.lookup)  
    end
  end
end

m.redraw = function()
  screen.clear()
  screen.level(15)
  if #p_list.lookup > 0 then
    screen.aa(0)
    if state.sel_param then
      p_list:display(state.sel_param)
    end

  else
    screen.move(64,40)
    screen.text_center("no params found")
  end 
  screen.update()
end

m.init = function() 
  -- print("menu entry")
  state.mod_displaying = true
end -- on menu entry, ie, if you wanted to start timers

m.deinit = function() 
  state.mod_displaying = false
end -- on menu exit

-- register the mod menu
--
-- NOTE: `mod.this_name` is a convienence variable which will be set to the name
-- of the mod which is being loaded. in order for the menu to work it must be
-- registered with a name which matches the name of the mod in the dust folder.
--
mod.menu.register(mod.this_name, m)


--
-- [optional] returning a value from the module allows the mod to provide
-- library functionality to scripts via the normal lua `require` function.
--
-- NOTE: it is important for scripts to use `require` to load mod functionality
-- instead of the norns specific `include` function. using `require` ensures
-- that only one copy of the mod is loaded. if a script were to use `include`
-- new copies of the menu, hook functions, and state would be loaded replacing
-- the previous registered functions/menu each time a script was run.
--
-- here we provide a single function which allows a script to get the mod's
-- state table. using this in a script would look like:
--
-- local mod = require 'name_of_mod/lib/mod'
-- local the_state = mod.get_state()
--
local api = {}

api.get_state = function()
  return state
end

return api