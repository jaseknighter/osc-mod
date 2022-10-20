local scroll_text = {}
scroll_text.__index = scroll_text

function scroll_text:new(text_to_scroll)
  local st={}
  setmetatable(st, scroll_text)

  st.scr_step = 1
  st.scr_step_increment = 1
  st.scr_max_length = 15 
  st.text_to_scroll = text_to_scroll .. " "
  -- st.text_to_scroll = #text_to_scroll <= st.scr_max_length and text_to_scroll or "> " .. text_to_scroll .. " "
  st.clipped_text_to_scroll = st.text_to_scroll

  if #st.text_to_scroll > st.scr_max_length then
    st.scr_step_metro = metro.init()
  end

  function st.init()
    --startup scrolling metro
    if st.scr_step_metro then
      if #st.text_to_scroll > st.scr_max_length then
        st.scr_step_metro.event = st.scroll
        st:scr_start_stop_metro()
      end
    elseif #st.text_to_scroll > st.scr_max_length then
      print("ERROR: st.scr_step_metro not found, reinit", st.scr_step_metro)
    end
  end

  function st.free_metro()
    if st.scr_step_metro and st.scr_step_metro.id then
      metro.free(st.scr_step_metro.id)
    end
  end
  
  function st.get_text()
    st.scroll()
    return st.clipped_text_to_scroll
  end

  -- scroll the text
  function st.scroll()
    if norns.menu.status() == true then
      st.scr_step = st.scr_step + st.scr_step_increment
      --scroll device name
      local scr_text = ""
      local scr_head = ""
      local scr_tail = ""

      if (#st.text_to_scroll > st.scr_max_length) then
        scr_text = st.text_to_scroll
        scr_head = string.sub(scr_text,1, 1)
        scr_tail = string.sub(scr_text,2)
        scr_text = scr_tail .. scr_head
        st.text_to_scroll = scr_text
        st.clipped_text_to_scroll = string.sub(scr_text,#scr_text-st.scr_max_length, #scr_text)
      end 
    end
  end

  function st:scr_start_stop_metro()
    if self.scr_step_metro then
      if self.scr_step_metro.is_running then
        self.scr_step_metro:stop()
      else
        self.scr_step = 0
        self.scr_step_metro:start(0.2) 
      end
    end
  end

  return st
end

return scroll_text