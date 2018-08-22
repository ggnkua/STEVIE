@echo off

setlocal EnableDelayedExpansion

set PROJROOT=.
set PROJNAME=stevie
set OUTPUT_FOLDER=%PROJROOT%
rem set STEEMLOG=-DAGT_CONFIG_STEEM_DEBUG
rem set DEBUGCONSOLE=-DAGT_CONFIG_DEBUG_CONSOLE
rem set DEBUGRASTERS=-DTIMING_RASTERS_MAIN

set DEBUG=%STEEMLOG% %DEBUGCONSOLE% %DEBUGRASTERS%
set RELEASE=-DAGT_RELEASE_BUILD

set GCCPATH=..\brown
set GPP=!GCCPATH!\bin\m68k-ataribrownart-elf-g++
set GCC=!GCCPATH!\bin\m68k-ataribrownart-elf-gcc
set AS=!GCCPATH!\bin\m68k-ataribrownart-elf-as

set COMMONFLAGS=-c -m68000 -Ofast -fomit-frame-pointer -fstrict-aliasing -fcaller-saves -ffunction-sections -fdata-sections -fleading-underscore -Wno-unused-function -Wno-attributes %DEBUG% %RELEASE%
set CPPFLAGS=%COMMONFLAGS% -x c++ -std=c++0x -fno-rtti -fno-exceptions -fno-rtti -fno-threadsafe-statics -Wall -Wno-reorder
set CFLAGS=%COMMONFLAGS%
set INCPATH=-I.
set RMAC=bin\rmac
set ASMFLAGS=-fe +oall %DEBUG%
set ASM=%RMAC%

set PATH=%PATH%;%GCCPATH%\bin

rem if not exist obj mkdir obj
rem if not exist obj\libcxx mkdir obj\libcxx

set CPPFILES=

set CFILES=^
main     ^
edit     ^
linefunc ^
normal   ^
cmdline  ^
hexchars ^
misccmds ^
help     ^
ptrfunc  ^
search   ^
alloc    ^
mark     ^
screen   ^
fileio   ^
param    ^
regexp   ^
regsub   ^
tos      ^
libcxx\browncrt++ ^
libcxx\brownmint++

set ASMFILES=libcxx\brownboot

set GASFILES=font ^
libcxx\browncrtn

rem SETLOCAL EnableDelayedExpansion
rem for %%I in (%CPPFILES% %CFILES% %ASMFILES% %GASFILES%) do set objfiles=!objfiles! %%I.o
set objfiles=^
%GCCPATH%\m68k-ataribrownart-elf\lib\crt0.o ^
libcxx/browncrt++.o ^
libcxx/brownmint++.o ^
main.o ^
edit.o ^
linefunc.o ^
normal.o ^
cmdline.o ^
hexchars.o ^
misccmds.o ^
help.o ^
ptrfunc.o ^
search.o ^
alloc.o ^
mark.o ^
screen.o ^
fileio.o ^
param.o ^
regexp.o ^
regsub.o ^
tos.o ^
font.o ^
libcxx/browncrtn.o

if /I "%1"=="clean" goto :cleanup

del %OUTPUT_FOLDER%\%PROJNAME%.ttp 2>NUL

rem Compile cpp files
for %%I in (%CPPFILES%) do (
call :checkrun "%%I.o" "%%I.cpp" "%GPP% %CPPFLAGS% %INCPATH% -o %%I.o %%I.cpp"
if errorlevel 1 exit /b
)

rem Compile c files
for %%I in (%CFILES%) do (
call :checkrun "%%I.o" "%%I.c" "%GCC% %CFLAGS% %INCPATH% -o %%I.o %%I.c"
if errorlevel 1 exit /b
)

rem Assemble .s files
rem for %%I in (%ASMFILES%) do (
call :checkrun "%%I.o" "%%I.s" "%ASM% %ASMFLAGS% -l%%I.o.lst -o %%I.o %%I.s"
rem if errorlevel 1 exit /b
)

for %%I in (%GASFILES%) do (
call :checkrun "%%I.o" "%%I.gas" "%AS% -o %%I.o %%I.gas"
if errorlevel 1 exit /b
)

rem Compile game code
rem echo %GCC% %CPPFLAGS% %INCPATH% -o %PROJNAME%.o %PROJNAME%.cpp
rem %GCC% %CPPFLAGS% %INCPATH% -S -o %PROJNAME%.s %PROJNAME%.cpp

if errorlevel 1 exit /b

rem Link

%GCC% -o %PROJNAME%.elf %objfiles% %GCCPATH%\m68k-ataribrownart-elf\lib\m68000\libc.a %GCCPATH%\lib\gcc\m68k-ataribrownart-elf\8.2.0\m68000\libgcc.a -Wl,--emit-relocs -Wl,-e_start -Ttext=0 -nostdlib -nostartfiles -m68000 -Ofast -fomit-frame-pointer -fstrict-aliasing -fcaller-saves -ffunction-sections -fdata-sections -fleading-underscore -flto

if errorlevel 1 exit /b

rem output elf symbol map
rem %GCCPATH%\bin\m68k-ataribrown-elf-objdump -h gitsfap.elf

rem brown up the elf
bin\brownout -s -x -f -p 0 -i %PROJNAME%.elf -o %OUTPUT_FOLDER%\%PROJNAME%.ttp


echo ---------------------------------------------------------------------------------
echo BUT:
find /n "@@" *.c

exit /b

:cleanup

for %%I in (%objfiles%) do (
del /q %%I %%I.lst 2>NUL
)
del %PROJNAME%.o 2>NUL
del%PROJNAME%.elf 2>NUL
del %OUTPUT_FOLDER%\%PROJNAME%.tos 2>NUL

exit /b

rem checkrun <source_file> <file_to_generate> <command_to_run>
rem will only execute <command_to_run> when <file_to_generate> either
rem doesn't exist or is older than <source_file>
:checkrun
if not exist %1 goto run
rem @echo on
for /F %%i IN ('dir /b /OD %1 %2 ^| more +1') DO SET NEWEST=%%i
rem @echo off
rem echo "%NEWEST%"==%2
if /i "%NEWEST%"==%2 GOTO run

echo File %1 is up to date

exit /b

:run
echo %~3
%~3


exit /b



