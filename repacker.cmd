@echo off
cls
rem *******************************
rem * Settings: General *
rem *******************************
set SCRIPTNAME=Repacking Script
set globalfuncpath=\\path\globalfunctions.cmd
setlocal enabledelayedexpansion
rem *******************************
rem * End of Settings: General *
rem *******************************

rem **************************************************************************************************************
rem Settings: Paths
rem **************************************************************************************************************
rem ***Apps***
CALL %globalfuncpath% pkzipccheck
rem ***Destination directories***
SET EDELPATH=\\output_path
SET TEMPPATH=%TEMP%\repack_temp
rem **************************************************************************************************************
rem End of Settings Paths
rem **************************************************************************************************************


Echo ************************************************
Echo Running %SCRIPTNAME%...
Echo ************************************************
Echo.
If Not exist %EDELPATH%\old (
  Echo %EDELPATH%\old is missing. Creating...
  mkdir %EDELPATH%\old
  Echo %EDELPATH%\old created. Continuing...
)
If Not exist %TEMPPATH% (
  Echo %TEMPPATH% is missing. Creating...
  mkdir %TEMPPATH%
  Echo %TEMPPATH% created. Continuing...
)
If Exist %EDELPATH%\part_?.zip (
  If Exist %EDELPATH%\old\original_old.zip (
    for /R %EDELPATH%\old %%Y in (original_old.zip) do (
      set oldFileDate=%%~tY
    )
  )
  color c0
  Echo ^^!^^!^^!WARNING^^!^^!^^!: part_?.zip files detected, if you continue, they may be overwritten^!
  call %globalfuncpath% choice "Press 1 to restore backup for !oldFileDate!, 2 to continue as is, Q to Quit: " 1 2
  if !chosen! equ 1 (
    color 07
    move /Y %EDELPATH%\old\original_old.zip %EDELPATH%\original.zip>nul
    goto archbackup
  )
  If !chosen! equ 2 (
    color 07
    goto vympcheck
  )
) ELSE (
  goto vympcheck
)

:vympcheck
If Not Exist %EDELPATH%\original.zip (
  color c0
  Echo No original.zip present. Checking if file was already unpacked...
  If Not Exist %TEMPPATH%\*.pdf (
    Echo No *.pdf files found. Checking if they were zipped...
    If Not Exist %TEMPPATH%\original.zip (
      Echo Files were not zipped. Checking backup file...
      If Exist %EDELPATH%\old\original_old.zip (
        for /R %EDELPATH%\old %%Y in (original_old.zip) do (
          set oldFileDate=%%~tY
        )
        Echo Backup for !oldFileDate! was found. Do you want to restore it?
        call %globalfuncpath% choice "Press 1 to restore, 2 or Q to Quit: " 1 2
        if !chosen! equ 1 (
          color 07
          move /Y %EDELPATH%\old\original_old.zip %EDELPATH%\original.zip>nul
          goto archbackup
        )
        If !chosen! equ 2 (
          exit
        )
      ) else (
        Echo Backup file not present. Press any key to exit
        pause>nul
        exit
      )
    ) ELSE (
      Echo Files were zipped...
      goto vympafterunpack
    )
  ) Else (
    Echo File was previously unpacked...
    goto vympafterunpack
  )
) ELSE (
  Echo %EDELPATH%\original.zip present. Moving to backup...
)

:archbackup
color 07
move /Y %EDELPATH%\original.zip %EDELPATH%\old\original_old.zip>nul&&Echo Unpacking original.zip...&&%PKZIP% -ext=update -nofix -silent=normal -over=all %EDELPATH%\old\original_old.zip %TEMPPATH%

:vympafterunpack
call :archivecreator original.zip -S 10
call :archivecreator part_1.zip -S 10
call :archivecreator part_2.zip -S 10
call :archivecreator part_3.zip -S 10
call :archivecreator part_4.zip -S 10
call :archivecreator part_5.zip -S 10
call :archivemover original.zip
call :archivemover part_1.zip
call :archivemover part_2.zip
call :archivemover part_3.zip
call :archivemover part_4.zip
call :archivemover part_5.zip
call :archivechecker %EDELPATH%\original.zip %EDELPATH%\old\original_old.zip
call :archivechecker %EDELPATH%\part_1.zip %EDELPATH%\old\original_old.zip
call :archivechecker %EDELPATH%\part_2.zip %EDELPATH%\old\original_old.zip
call :archivechecker %EDELPATH%\part_3.zip %EDELPATH%\old\original_old.zip
call :archivechecker %EDELPATH%\part_4.zip %EDELPATH%\old\original_old.zip
call :archivechecker %EDELPATH%\part_5.zip %EDELPATH%\old\original_old.zip

rem pdf check
Echo.
if exist %TEMPPATH%\*.pdf (
  color c0
  Echo ^^!^^!^^!WARNING^^!^^!^^!: There are .pdf files left after splitting^^!
  pause
) ELSE (
  Echo All .pdf files were packed
)
color 07

:sizecheck
rem filesize check
Echo.
Echo Splitting completed, checking sizes...
Echo.
set issue=no
for /R %EDELPATH% %%F in (*.zip) do (
  set filename=%%~nxF
  set size=%%~zF
  set /a size=!size!/1048576
  if !size! GEQ 100 (
    if "!filename!" EQU "original.zip" (
      set issue=yes
      Echo ^^!^^!^^!WARNING^^!^^!^^!: !filename! is !size! Mbs, which is close to or over the limit^^!
    )
    if "!filename!" EQU "part_1.zip" (
      set issue=yes
      Echo ^^!^^!^^!WARNING^^!^^!^^!: !filename! is !size! Mbs, which is close to or over the limit^^!
    )
    if "!filename!" EQU "part_2.zip" (
      set issue=yes
      Echo ^^!^^!^^!WARNING^^!^^!^^!: !filename! is !size! Mbs, which is close to or over the limit^^!
    )
    if "!filename!" EQU "part_3.zip" (
      set issue=yes
      Echo ^^!^^!^^!WARNING^^!^^!^^!: !filename! is !size! Mbs, which is close to or over the limit^^!
    )
    if "!filename!" EQU "part_4.zip" (
      set issue=yes
      Echo ^^!^^!^^!WARNING^^!^^!^^!: !filename! is !size! Mbs, which is close to or over the limit^^!
    )
    if "!filename!" EQU "part_5.zip" (
      set issue=yes
      Echo ^^!^^!^^!WARNING^^!^^!^^!: !filename! is !size! Mbs, which is close to or over the limit^^!
    )
  )
)
if "!issue!" EQU "yes" (
  color c0
) else (
  color 20
)
Echo.
Echo Script has ended
pause
exit


:archivecreator
rem %1 - archive name
rem %2 - order
rem %3 - compression (-1 to disable)
set archivename=%1
set order=%2
set compres=%3
if exist %TEMPPATH%\*.pdf (
  if "!order!" EQU "-S" (
    set /a zipsize=0
  )
  FOR /F "tokens=*" %%G IN ('dir /b /O:%order% %TEMPPATH%\*.pdf') DO (
    set filename=%%~nxG
    Echo Predicting size of !filename!...
    if "%compres%" neq "-1" (
      FOR /F "tokens=4" %%D IN ('%PKZIP% %EDELPATH%\old\original_old.zip !filename!') DO (
        set defrat=%%D
        if "!defrat:~-1!" equ "%%" (
          for /F "tokens=1,2 delims=.," %%a in ("!defrat!") do (
            set mainrat=%%a
            set /a mainrat=!mainrat!+%compres%
            set addrat=%%b
            set addrat=!addrat:~0,-1!
            set addrat=!addrat:~0,1!
          )
        )
      )
    )
    for /R %TEMPPATH% %%F in (!filename!) do (
      set size=%%~zF
      if "%compres%" neq "-1" (
        set /a size=!size!/100*!mainrat!+!size!/100/10*!addrat!
      ) else (
        set /a size=!size!
      )
      set /a sizeafter=!zipsize!+!size!
      if !sizeafter! LSS 104857599 (
        Echo Zipping !filename! into !archivename!...
        %PKZIP% -add=update -lzma -level=9 -nofix -silent=normal -temp=%TEMPPATH% %TEMPPATH%\!archivename! %TEMPPATH%\!filename!
        for /R %TEMPPATH% %%Z in (!archivename!) do (
          set zipsize=%%~zZ
        )
        if !zipsize! GEQ 104857600 (
          Echo Deleting !filename! from !archivename!...
          %PKZIP% -delete -nofix -silent=normal -temp=%TEMPPATH% %TEMPPATH%\!archivename! !filename!
          for /R %TEMPPATH% %%X in (!archivename!) do (
            set zipsize=%%~zX
          )
          if %compres% equ 10 (
            set compres=0
          )
          if %compres% equ 0 (
            set compres=-1
          )
          if "%compres%" equ "-1" (
            if "!order!" EQU "-S" (
              call :archivecreator !archivename! S 10
              exit /b
            ) else (
              exit /b
            )
          )
        ) else (
          Echo Removing !filename!...
          del /Q /F %TEMPPATH%\!filename! >nul
        )
      )
    )
  )
)
exit /b

:archivemover
rem %1 - archive name
set archivenamem=%1
if exist %TEMPPATH%\%archivenamem% (
  Echo Moving %archivenamem%...
  move /Y %TEMPPATH%\%archivenamem% %EDELPATH%\%archivenamem%>nul&&Echo Testing %archivenamem%...&&%PKZIP% -test -nofix -silent=normal %EDELPATH%\%archivenamem%
)
exit /b

:archivechecker
rem %1 - archive name
rem %2 - archvie to check against
set archivenamec=%1
set archivenameco=%2
if exist %archivenamec% (
  Echo Checking %archivenamec%...
  FOR /F "tokens=7,9" %%A IN ('%PKZIP% %archivenamec%') DO (
    set filenamec=%%B
    set checksum=%%A
    if "!filenamec:~-4!" equ ".pdf" (
      FOR /F "tokens=7,9" %%C IN ('%PKZIP% %archivenameco% !filenamec!') DO (
        set filenameco=%%D
        set checksumo=%%C
        if "!filenameco!" equ "!filenamec!" (
          if "!checksum!" equ "!checksumo!" (
            Echo File !filenamec! validated...
          ) else (
            call :validfailclean
            color c0
            echo.
            Echo ^^!^^!^^!WARNING^^!^^!^^!: file !filenamec! from %archivenamec% failed validation^^!
            Echo.
            Echo Original CRC: !checksumo!; detected CRC: !checksum!
            Echo.
            Echo All temporary files and newly created archvies were removed^^!
            Echo.
            Echo Press any key to terminate
            pause>nul
            exit
          )
        )
      )
    )
  )
)
exit /b

:validfailclean
if exist %EDELPATH%\original.zip (
  del /Q /F %EDELPATH%\original.zip >nul
)
if exist %EDELPATH%\part_1.zip (
  del /Q /F %EDELPATH%\part_1.zip >nul
)
if exist %EDELPATH%\part_2.zip (
  del /Q /F %EDELPATH%\part_2.zip >nul
)
if exist %EDELPATH%\part_3.zip (
  del /Q /F %EDELPATH%\part_3.zip >nul
)
if exist %EDELPATH%\part_4.zip (
  del /Q /F %EDELPATH%\part_4.zip >nul
)
if exist %EDELPATH%\part_5.zip (
  del /Q /F %EDELPATH%\part_5.zip >nul
)
if exist %TEMPPATH%\*.* (
  del /Q /F %TEMPPATH%\*.* >nul
)
exit /b
