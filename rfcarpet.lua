-- rfcarpet.lua - SIMION Lua workbench user program for rf carpet.
--
-- There are 252 electrodes in the funnel, plus a DC electrode surrounding the carpet,
-- a push DC electrode at the upstream end, and a collection electrode behind.
-- This program controls the voltages on those electrodes.

simion.workbench_program()

-- import standard HS1 collision model from this directory.
simion.import("collision_sds.lua")
--simion.import("collision_hs1.lua")

-- adjustable variables during flight
adjustable min_rad_mm = 5.0

-- SDS parameters
adjustable SDS_pressure_torr      = 106.0        -- pressure (in Torr)
adjustable SDS_temperature_K      = 333.15      -- standard temp (in Kelvin)
adjustable SDS_collision_gas_mass_amu = 4.0   -- Mass of background gas particle (Xe gas, amu)

-- HS parameters
-- adjustable _gas_mass_amu        = 136.0      -- Mass of background gas particle (Xe gas, amu)
-- adjustable _pressure_pa         = 1.0E4      -- pressure (in Pa, 1.oE5 Pa = 1 bar)      
-- adjustable _temperature_k       = 273.15     -- standard temp (Kelvin)
-- adjustable _sigma_m2            = 3.103E-16  -- collision cross section (m2)

adjustable pe_update_each_usec  = 5.0        -- PE display update period (in usec)

adjustable ion_time_step        = 0.013     -- 1/8 RF period (in usec)

-- adjustable variables at beginning of flight

adjustable _freqency_hz         = 9.3E6    -- RF frequency of carpet (in Hz)
                                             --   CAREFUL: time-step sizes should
                                             --   be some fraction below period
adjustable _freqency_sw_hz      = 80.0E3    -- Surfing wave frequency
adjustable phase_angle_deg      = 0.0        -- entry phase angle of ion (deg)
adjustable _RF_amplitude        = 52         -- RF peak-to-ground voltage (in V)
adjustable _SW_amplitude        = 2.5        -- Surfing wave p-g voltage (in V)

adjustable _DC_offset_1         = 0.0        -- DC offset of rf carpet (in V)
adjustable _DC_push_plate       = 18.0       -- DC val of push plate at 4cm (in V)
adjustable _DC_collection       = -10.0     -- DC val of ion collection plate (Si det)

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
	omega_sw = _freqency_sw_hz * 6.28318E-6
    end

    -- Apply RF+DC to each electrode.
    local theta_surf = 0.0
    local rfvolts = sin(ion_time_of_flight * omega + theta) * _RF_amplitude
    local swvolts = sin(ion_time_of_flight * omega_sw + theta - theta_surf) * _SW_amplitude
    local dcvolts = _DC_offset_1
    -- loop over RF carpet electrodes (including inner ring)
    -- (change to n=1,251 to exclude inner ring)
    for n=1,244 do
       theta_surf = 2.0 * 3.141592 * n / 4.0
       swvolts = sin(ion_time_of_flight * omega_sw + theta - theta_surf) * _SW_amplitude
       rfvolts = -rfvolts
       adj_elect[n] = dcvolts + rfvolts + swvolts
    end
    -- uncomment next line if defining inner electrode separately
    adj_elect[245] = 0.0            -- DC val of innermost electrode
    adj_elect[246] = _DC_offset_1    -- pad around carpet set to rf carpet DC offset
    adj_elect[247] = _DC_push_plate  -- push plate at injection end
    adj_elect[248] = _DC_collection  -- ion collection plate at -0.5 cm
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
    -- splat particle inside radius min_radius
    --if sqrt(ion_py_mm^2 + ion_pz_mm^2) < min_rad_mm then
    --  ion_splat = -1
    --end
end

