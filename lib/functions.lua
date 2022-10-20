fn = {}

-- utility to clone function (from @eigen)
function fn.clone_function(fn)
    local dumped=string.dump(fn)
    local cloned=load(dumped)
    local i=1
    while true do
      local name=debug.getupvalue(fn,i)
      if not name then
        break
      end
      debug.upvaluejoin(cloned,i,fn,i)
      i=i+1
    end
    return cloned
end
  
  
function fn.deep_copy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[fn.deep_copy(orig_key, copies)] = fn.deep_copy(orig_value, copies)
            end
            setmetatable(copy, fn.deep_copy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
    
function fn.find_closer(comparator1,comparator2,comparatee)
    comp1 = math.abs(comparator1-comparatee)
    comp2 = math.abs(comparator2-comparatee)
    
    if comp1<=comp2 then 
        return comparator1 
    else 
        return comparator2 
    end
end

function fn.get_num_decimal_places(num)
  local num_str = tostring(num)
  if type(num) == "number" and string.find(num_str,"%.") then
    local num_decimals = #num_str - string.find(num_str,"%.")
    return num_decimals
  else
    return nil
  end
end

function fn.constrain_decimals(val_to_constrain, source_val)
  if type(source_val) == "number" then
    local num_decimals = fn.get_num_decimal_places(source_val)
    local constrained_val = fn.round_decimals(val_to_constrain, num_decimals)
    return constrained_val
  else
    return val_to_constrain
  end
end

function fn.round_decimals (value_to_round, num_decimals, rounding_direction)
  local num_decimals = num_decimals and num_decimals or 2
  local rounding_direction = rounding_direction and rounding_direction or "down"
  local rounded_val
  local mult = 10^num_decimals
  if rounding_direction == "down" then
    rounded_val = math.floor(value_to_round * mult + 0.5) / mult
  else
    rounded_val = math.ceil(value_to_round * mult + 0.5) / mult
  end
  return rounded_val
end

function fn.quantize(val,quant_table)
    -- make a copy of the table to be quantized
    local qts = fn.deep_copy(quant_table)
    -- print(#quant_table)
    -- sort the copy of the table
    table.sort(qts)

    -- find the closest value in the table 
    local found_closest = false
    for i=1,#qts,1 do
        -- print(i)
        if val <= qts[i] then
            if qts[i-1] then
                local closest_val = fn.find_closer(qts[i-1],qts[i],val)
                return closest_val
            end
        end
    end
end

function fn.dirty_screen(bool)
    if bool == nil then return screen_dirty end
    screen_dirty = bool
    return screen_dirty
end

function r()
  norns.rerun()
end

return fn
