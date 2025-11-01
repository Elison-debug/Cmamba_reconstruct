@echo off
set arg=%1

if "%arg%"=="" (
    echo using default eval_out_testing_1...
    goto :run1
)
goto :run2

:run1
echo Running plotting Gt and predict locations...
python -m refactor.core.test.plot 
goto :eof

:run2
echo Running plotting Gt and predict locations in %arg%...
python -m refactor.core.test.plot ^
  --root_dir=%arg%
goto :eof

