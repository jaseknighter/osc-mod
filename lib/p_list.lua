-- //https://github.com/p3r7/osc-cast/blob/main/lib/mod.lua

-- todo: fix mappings when input/output spans positive & negative for types other than control
          -- note: see how controlspec maping/unmaping appears to address this????

local p_list              = {}
p_list.lookup             = {}
p_list.params             = {}
p_list.prev_sel_param          = nil
------------------------
-- p_list init
------------------------

function p_list.init()
  p_list:enrich_param_actions()
  print("p_list inited")
end
 

function p_list:enrich_param_actions()
  
  for p_id, p_ix in pairs(params.lookup) do
    local p = params.params[p_ix]
    if p ~= nil  then -- edge case where sync issue between `params.lookup` & `params.params`
      p.og_action = fn.clone_function(p.action)
      p.action = function(x)
        -- do something
        p.og_action(x)
        self:process_updated_param(p_id)
      end
    end
  end

  -- table.insert(self.lookup,{name="-------",id=nil})
  print(">>>>>>>>num params", #params.params)
  for i=1,#params.params,1 do
    local name = params.params[i].name
    local id = params.params[i].id
    local ix = i
    if (   
      -- params.params[i].id ~= nil and 
      params.hidden[i] == false and 
      -- params.params[i].t ~= 8 and -- text
      -- params.params[i].t ~= 7 and -- group
      -- params.params[i].t ~= 6 and -- trigger
      params.params[i].t ~= 4 and -- file
      -- params.params[i].t ~= 0 and -- separator
      (id and string.find(id,"pat_lab")) == nil
    ) 
    then

      if params.params[i].t == 7 and #name > 0 then
        table.insert(self.lookup,{name=">>"..name.."<<",id=id})
        -- print(">>"..name.."<<")
      elseif params.params[i].t == 0 and name ~= "" then
        table.insert(self.lookup,{name="--"..name.."--",id=id})
        -- print("--"..name.."--")
      elseif name ~= "" then
        table.insert(self.lookup,{name=name,id=id})
        table.insert(self.params,{name=name,id=id,ix=ix})
        -- print(ix,name,id)
      end
    end
  end
end

function p_list.enc(n, d)
  if n==1 then

  elseif n==2 then
    --[[
    if p_list.active_gui_sector == 1 or k1_active then
      p_list.active_input = util.clamp(p_list.active_input+d,1,p_list.num_inputs)
    elseif p_list.active_gui_sector == 2 then
      if p_list.selecting_param == "in" then
        local input = p_list.inputs[p_list.active_input]
        if k2_active then
          local found_separator_sub_menu = false
          while found_separator_sub_menu == false do
            local input_name = p_list.lookup[input].name
            input =  util.wrap(input+d,1,#p_list.lookup)
            input_name = p_list.lookup[input].name
            -- if string.find(input_name,"%-%-") ~= nil or string.find(input_name,">>") ~= nil then
            if string.find(input_name,">>") ~= nil then
              print("input separator: ",input_name)
              found_separator_sub_menu = true
            end
          end
        else
          input =  util.wrap(input+d,1,#p_list.lookup)
        end
        p_list.inputs[p_list.active_input] = input
        for i=1,#p_list.output_labels do
          if p_list.patch_points[p_list.active_input][i] then
            p_list.patch_points[p_list.active_input][i].enabled = 1
          end
        end
      end
      p_list.selecting_param = "in"
    elseif p_list.active_gui_sector == 3 then
      p_list.active_pp_option = util.clamp(p_list.active_pp_option+d,1,#p_list.default_pp_option_selections)
    elseif p_list.active_gui_sector == 4 then
      p_list.active_crow_pp_option = util.clamp(p_list.active_crow_pp_option+d,1,#p_list.default_crow_option_selections)
    elseif p_list.active_gui_sector == 5 then
      p_list.active_midi_pp_option = util.clamp(p_list.active_midi_pp_option+d,1,#p_list.default_midi_option_selections)
    end
    ]]
  elseif n==3 then
  end
end

function p_list.key(n,z)
  if n == 1 then
  end
  if n == 2 then
  end
  if n == 3 then
  end
end

-------------------------------------------
--- mod matrix process
-------------------------------------------
function p_list:get_param_props(param)
    --types
    -- 0: separator
    -- 1: number
    -- 2: options
    -- 3: control
    -- 5: taper
    -- 6: trigger
    -- 7: group
    -- 8: text
    local type = param.t
    local val = params:get(param.id)
    local min, max
    if type == 1 then      -- 1: number
      min = param.min
      max = param.max
    elseif type == 2 then  -- 2: options
      min = 1
      max = param.count
    elseif type == 3 then  -- 3: control
      -- local raw = param.raw
      min = param.controlspec.minval
      max = param.controlspec.maxval
    elseif type == 5 then  -- 5: taper
      min = param.min
      max = param.max
    end     
    return {val=val,min=min,max=max,type=param.t}
end

function p_list:process_updated_param(id)
  -- do something when param is updated 
  -- print("process id: ", id)
end


-------------------------------------------
--- gui
-------------------------------------------
function p_list.init_scrolling_text_name(self,name)
  -- clock.sleep(0.2)
  if self.scrolling_name then
    self.scrolling_name.free_metro()
  end
  self.scrolling_name = scroll_text:new(name)    
  self.scrolling_name.init()
end

function p_list.init_scrolling_text_addr(self,name)
  -- clock.sleep(0.2)
  if self.scrolling_addr then
    self.scrolling_addr.free_metro()
  end
  self.scrolling_addr = scroll_text:new(name)    
  self.scrolling_addr.init()
end

function p_list:display(s_param)
  local sel_param = s_param or 1
  local param_id = p_list.lookup[sel_param].id and p_list.lookup[sel_param].id 
  local param = param_id and params:lookup_param(param_id)
  -- local pvals = param and p_list:get_param_props(param)
  local param_value = (param and param.t ~= 0 and param.t ~= 7) and params:get(param.id) or "n/a"
  param_value = type(param_value) == "number" and fn.round_decimals (param_value, 4) or param_value
  
  local param_name = p_list.lookup[sel_param].name
  param_id = (param_id ~= nil and param_id ~= "separator") and param_id or "n/a"
  local param_addr = "/" .. param_id

  if self.prev_sel_param == nil or (self.prev_sel_param and self.prev_sel_param ~= s_param) then
    if self.scrolling_name_init_clock and self.scrolling_name_init_clock > 0 then clock.cancel(self.scrolling_name_init_clock) end
    self.scrolling_name_init_clock = p_list.init_scrolling_text_name(self,param_name)

    if self.scrolling_addr_init_clock and self.scrolling_addr_init_clock > 0 then clock.cancel(self.scrolling_addr_init_clock) end
    self.scrolling_addr_init_clock = p_list.init_scrolling_text_addr(self,param_addr)
  end
  
  self.prev_sel_param = s_param
  

  local param_type
  local param_min, param_max
  local min, max

  if param then
    if param.t == 0 then
      param_type = "separator"
      param_addr = "n/a"
    elseif param.t == 1 then
      param_type = "number"
    elseif param.t == 2 then
      param_type = "options"
    elseif param.t == 3 then
      param_type = "control"
    elseif param.t == 6 then
      param_type = "trigger"
    elseif param.t == 7 then
      param_type = "group"
      param_addr = "n/a"
    elseif param.t == 8 then
      param_type = "text"
    else
      param_type = "n/a"
    end

    if param.t == 1 then      -- 1: number
      min = param.min
      max = param.max
    elseif param.t == 2 then  -- 2: options
      min = 1
      max = param.count
    elseif param.t == 3 then  -- 3: control
      -- local raw = param.raw
      min = param.controlspec.minval
      max = param.controlspec.maxval
    elseif param.t == 5 then  -- 5: taper
      min = param.min
      max = param.max
    end     
  else
    param_type = ""
  end

  
  if min and max then 
    param_min = min
    param_max = max
  else
    param_min = "n/a"
    param_max = "n/a"
  end


  screen.move(4,10)
  screen.text("params: " .. sel_param .. " of " .. #p_list.lookup )
  screen.level(5)
  screen.rect(99,6,26,5)
  screen.stroke()
  screen.level(15)
  
  local progress_bar_x = 100+math.floor(24 * (sel_param / #p_list.lookup))
  screen.move(progress_bar_x,6)
  screen.line_rel(0,4)
  screen.stroke()
  screen.update()
  screen.rect(2,14,123,52)
  screen.fill()
  screen.stroke()
  screen.update()
  screen.level(0)
  screen.move(4,22)
  screen.text("name: ")
  screen.move(123,22)
  -- screen.text_right(param_name)
  local p_name = self.scrolling_name.get_text()
  screen.text_right(p_name)

  screen.move(4,30)
  screen.text("osc addr: ")
  screen.move(123,30)

  -- screen.text_right(param_addr)
  screen.text_right(self.scrolling_addr.get_text())
  
  screen.move(4,38)
  screen.text("type: ")
  screen.move(123,38)
  screen.text_right(param_type)
  screen.move(4,46)
  screen.text("min:")
  screen.move(123,46)
  screen.text_right(param_min)
  screen.move(4,54)
  screen.text("max:")
  screen.move(123,54)
  screen.text_right(param_max)
  screen.move(4,62)
  screen.text("curr val:")
  screen.move(123,62)
  screen.text_right(param_value)
end

return p_list
