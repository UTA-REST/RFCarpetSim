@echo off
setlocal enabledelayedexpansion

for %%R in (50) do (
    for %%E in (80) do (
        "C:\Program Files\SIMION-8.1\simion.exe" --nogui fly --recording-output=batch_trajectories\trajectoriesXenon100mbarLoKLoM_RF%%R_Ep%%E --adjustable _RF_amplitude=%%R --adjustable _DC_push_plate=%%E --recording=rfcarpet.rec --markers=0.5 --retain-trajectories=0 --trajectory-quality=0 --particles=rfcarpet.fly2 rfcarpet.iob > trajout\trajectory.log
    )
)

exit /b
