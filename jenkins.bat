cd ..
cd ..
cd tetra
rake test:%1 CI_REPORTS=%WORKSPACE%
set %ERRORLEVEL% = 0