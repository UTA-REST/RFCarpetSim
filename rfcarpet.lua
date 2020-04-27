-- rfcarpet.lua - SIMION Lua workbench user program for rf carpet.
--
-- There are 252 electrodes in the funnel, plus a DC electrode surrounding the carpet,
-- a push DC electrode at the upstream end, and a collection electrode behind.
-- This program controls the voltages on those electrodes.

simion.workbench_program()

-- import standard HS1 collision model from this directory.
simion.import("collision_sds.lua")

-- adjustable variables during flight

adjustable SDS_pressure_torr    = 76.0        -- pressure (in Torr)
adjustable SDS_temperature_K    = 273.15     -- standard temp (in Kelvin)
adjustable SDS_collision_gas_mass_amu = 136.0 -- Mass of background gas particle (Xe gas, amu)

adjustable pe_update_each_usec  = 0.5        -- PE display update period (in usec)

adjustable ion_time_step        = 0.0092     -- 1/8 RF period (in usec)

-- adjustable variables at beginning of flight

adjustable _freqency_hz         = 13.56E6    -- RF frequency of carpet (in Hz)
                                             --   CAREFUL: time-step sizes should
                                             --   be some fraction below period.
adjustable phase_angle_deg      = 0.0        -- entry phase angle of ion (deg)
adjustable _RF_amplitude        = 150        -- RF peak-to-ground voltage (in V)

adjustable _DC_offset_1         = 0.0        -- DC offset of rf carpet (in V)
adjustable _DC_push_plate       = 80.0       -- DC val of push plate at 4cm (in V)
adjustable _DC_collection       = -150.0     -- DC val of ion collection plate (Si det)

-- internal variables
local omega                 -- frequency in radians / usec
local theta                 -- phase offset in radians
local last_pe_update = 0.0  -- last potential energy surface update time (usec)
local dcgradient            -- DC gradient through the funnel

function segment.fast_adjust()
    -- Initialize constants once.
    if not theta then
        theta = phase_angle_deg * (3.141592 / 180)
        omega = _freqency_hz * 6.28318E-6
    end

    -- Apply RF+DC to each electrode.
    local rfvolts = sin(ion_time_of_flight * omega + theta) * _RF_amplitude
    local dcvolts = _DC_offset_1
    -- loop over RF carpet electrodes (including inner ring)
    -- (change to n=1,251 to exclude inner ring)
    for n=1,252 do
       theta_surf = 2.0 * 3.141592 * n / 4.0
       rfvolts = sin(ion_time_of_flight * omega + theta - theta_surf) * _RF_amplitude
       adj_elect[n] = dcvolts + rfvolts
    end
    -- uncomment next line if defining inner electrode separately
    --adj_elect[252] = 0.0             -- DC val of innermost electrode
    adj_elect[253] = _DC_offset_1    -- pad around carpet set to rf carpet DC offset
    adj_elect[254] = _DC_push_plate  -- push plate at injection end
    adj_elect[255] = _DC_collection  -- ion collection plate at -0.5 cm
end
      

-- This trick first runs the other_actions segment defined previously
-- by the HS1 collision model and then runs our own code.
local previous_other_actions = segment.other_actions  -- copy previously defined segment.
function segment.other_actions()
    -- Run previously defined segment.
    previous_other_actions()
    -- Now run our own code...

    -- Update PE surface display.
    if abs(ion_time_of_flight - last_pe_update) >= pe_update_each_usec then
        last_pe_update = ion_time_of_flight
        sim_update_pe_surface = 1    -- Request a PE surface display update.
    end
end

