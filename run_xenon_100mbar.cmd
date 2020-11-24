REM @echo off

for %%P in (15.2 30.4 45.6 60.8 76.0 91.2 106.4 121.6 136.8 152.0) do (
  "C:\Program Files\SIMION-8.1\simion.exe" --nogui fly --recording-output=batch_trajectories\trajectory_p%%P_Vp10-KHe-Hamaker-3000-lowK0 --adjustable  SDS_pressure_torr=%%P --adjustable max_time=3000 --recording=rfcarpet.rec --markers=0.5 --retain-trajectories=0 --trajectory-quality=0 --particles=rfcarpet.fly2 rfcarpet.iob > trajout\trajectory.log
)

exit /b
