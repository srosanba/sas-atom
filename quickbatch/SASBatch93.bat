@echo off
set WINFOLDER=C:\windows\system32

REM   If running a 32-bit process on a machine that has both 32 and 64 bit programs
REM   then use the native/64-bit csript.exe location
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
   if defined PROCESSOR_ARCHITEW6432 set WINFOLDER=C:\windows\sysnative
)

%WINFOLDER%\cscript.exe "I:\RHO_APPS\SAS Grid\QuickBatch\VAL\egrun.vbs" "Rho VAL" "SASAppVGRD93" %1
REM pause