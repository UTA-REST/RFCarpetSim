Rem @echo off

for %%R in (25 50 75 100) do (
    for %%E in (40 60 80 100 120 140 160 180 200) do (
        "C:\Program Files\SIMION-8.1\simion.exe" --nogui fly --recording-output=batch_trajectories\trajectory_p01_V%%R_Ep%%E-Xe-LoK-lom --adjustable _RF_amplitude=%%R --adjustable _DC_push_plate=%%E --recording=rfcarpet.rec --markers=0.5 --retain-trajectories=0 --trajectory-quality=0 --particles=rfcarpet.fly2 rfcarpet.iob > trajout\trajectory.log
    )
)

exit /b
