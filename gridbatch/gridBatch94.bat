@echo off

REM  =================================================================
REM   Submit a SAS job to Batch on the grid
REM
REM   - calls gridBatch.vbs
REM     - which opens EG and calls the %gridBatch macro
REM       - which submits the job with SASGSUB
REM
REM   arg1 => "fully qualified SAS program file"
REM   arg2 => "arguments passed to %gridBatch"
REM           
REM   Both arguments must be enclosed in double quotes.
REM
REM   23Jun2016  John Ingersoll  from SASBatch94.bat (aka QuickBatch)
REM   07Jul2016  John Ingersoll  update for VAL
REM  =================================================================

set WINFOLDER=C:\windows\system32

REM   If running a 32-bit process on a machine that has both 32 and 64 bit programs
REM   then use the native/64-bit csript.exe location
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
   if defined PROCESSOR_ARCHITEW6432 set WINFOLDER=C:\windows\sysnative
)

REM  arg1 - vbs script
REM  arg2 - EG profile
REM  arg3 - Grid server
REM  arg4 - SAS program filename, passed to this .bat
REM  arg5 - optional WAIT keyword, passed to this .bat

%WINFOLDER%\cscript.exe "I:\RHO_APPS\SAS Grid\GridBatch\VAL\gridBatch.vbs" "Rho VAL" "SASAppVGRD94" %1 %2

REM pause