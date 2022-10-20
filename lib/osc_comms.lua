-- references 
-- osc

--------------------------

-- require built-in norns libs
-- Lattice = require ("lattice")
-- s = require("sequins")
-- MusicUtil = require("musicutil")

-- set variables
local osc_comms = {}
osc_comms.external_osc_IP = nil -- to track the external device's IP

-- process received osc events
function osc_comms.process_event(path,args,from)

end


return osc_comms