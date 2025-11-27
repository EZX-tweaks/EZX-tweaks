@echo off
chcp 65001 >nul
title Titan Tweaks 2.0 v1
color 0d
setlocal enabledelayedexpansion

:: ---------------- ADMIN CHECK ----------------
:: ================= MANUAL MODE =================
echo Titan Tweaks is running without forced Admin mode.
echo It is recommended to run as Administrator for full functionality.
echo.

echo Please create a Restore Point manually before using heavy tweaks.
echo Go to: System Protection > Create Restore Point
echo.
pause


:: ---------------- CONSTANTS ----------------
set BANNER===========================================================================
set PADDING=    

:: ---------------- FUNCTIONS ----------------


mode con cols=100 lines=35
color 0d
cls

echo.
echo.
echo                                ████████╗██╗████████╗ █████╗ ███╗   ██╗
echo                                ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║
echo                                   ██║   ██║   ██║   ███████║██╔██╗ ██║
echo                                   ██║   ██║   ██║   ██╔══██║██║╚██╗██║
echo                                   ██║   ██║   ██║   ██║  ██║██║ ╚████║
echo                                   ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝

echo.
echo.
echo                                   T I T A N   2 . 0
echo.
echo ===============================================================================
echo        You are using the 2.0 free ones - check out the premium on
echo                titantweaks.netlify.app
echo ===============================================================================

echo.
pause




:: ---------------- MAIN MENU ----------------
:main
cls
echo %BANNER%
echo%PADDING%               TITAN TWEAKS 2.0 v1
echo%PADDING%  You are using the 2.0 free ones check out the premium on titantweaks.netlify.app
echo %BANNER%
echo.
echo Select a tweak category by number (numbers in each submenu choose specific tweaks):
echo.
echo [ 1 ] Windows Tweaks (deep debloat, services, Appx)
echo [ 2 ] Registry Tweaks (performance & latency)
echo [ 3 ] KBM / Controller Tweaks (mouse/keyboard/controller/USB)
echo [ 4 ] BIOS & CPU Helpers (detect CPU and apply safe OS-level tweaks)
echo [ 5 ] Network Tweaks (TCP/IP, DNS, latency)
echo [ 6 ] Gaming Performance (Game Mode, DVR, GPU tweaks)
echo [ 7 ] Privacy & Telemetry (comprehensive disable)
echo [ 8 ] Visual & UI Performance (visual effects, compositor)
echo [ 9 ] Power & Battery (plans, CPU min/max, USB)
echo [10 ] System Cleanup & Uninstall (temp, WinSxS, OneDrive)
echo.
echo [0] Exit
set /p choice=Choose: 
if "%choice%"=="1" goto winTweaks
if "%choice%"=="2" goto regTweaks
if "%choice%"=="3" goto kbmTweaks
if "%choice%"=="4" goto biosTweaks
if "%choice%"=="5" goto netTweaks
if "%choice%"=="6" goto gameTweaks
if "%choice%"=="7" goto privacyTweaks
if "%choice%"=="8" goto visualTweaks
if "%choice%"=="9" goto powerTweaks
if "%choice%"=="10" goto cleanupTweaks
if "%choice%"=="0" exit
goto main

:: ---------------- WINDOWS TWEAKS ----------------
:winTweaks
cls
echo ===== WINDOWS TWEAKS =====
echo Choose a tweak group:
echo [1] Aggressive Debloat (removes common Appx and Store apps)
echo [2] Service Optimization (disable/trim background services)
echo [3] Background Apps & Tasks (disable background apps, scheduled tasks)
echo [4] Store & Xbox Removal (remove store/Xbox components)
echo [5] Process & Priority Tweaks (set game priorities, reduce background CPU)
echo [0] Back
set /p wopt=Select: 
if "%wopt%"=="0" goto main

:: Debloat group
if "%wopt%"=="1" (
    echo Running Aggressive Debloat...
    powershell -Command "Get-AppxPackage -AllUsers | Where-Object { $_.Name -notmatch 'Microsoft.WindowsCalculator|Microsoft.WindowsStore' } | ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue }"
    powershell -Command "Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -notmatch 'Microsoft.WindowsStore' } | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue }"
    echo Removing OneDrive (if present)...
    taskkill /f /im OneDrive.exe >nul 2>&1
    start /wait %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall >nul 2>&1
    echo Disabling Xbox Services...
    sc config XblAuthManager start= disabled
    sc stop XblAuthManager >nul 2>&1
    sc config XblGameSave start= disabled
    sc stop XblGameSave >nul 2>&1
    echo Completed debloat.
    goto pauseAndReturn
)

:: Services group
if "%wopt%"=="2" (
    echo Trimming unnecessary services...
    rem Set SysMain (Superfetch) to disabled
    sc config SysMain start= disabled 2>nul
    sc stop SysMain >nul 2>&1
    rem Disable Windows Search if desired (speeds some systems with HDD)
    sc config "WSearch" start= disabled >nul 2>&1
    sc stop "WSearch" >nul 2>&1
    rem Disable Windows Update Delivery Optimization
    sc config "DoSvc" start= disabled >nul 2>&1
    sc stop "DoSvc" >nul 2>&1
    rem Disable Connected User Experiences and Telemetry
    sc config "DiagTrack" start= disabled >nul 2>&1
    sc stop "DiagTrack" >nul 2>&1
    echo Services trimmed.
    goto pauseAndReturn
)

:: Background apps group
if "%wopt%"=="3" (
    echo Disabling background apps and common scheduled tasks...
    powershell -Command "Get-AppxPackage -AllUsers | ForEach-Object { Add-AppxPackage -register \"$($_.InstallLocation)\AppxManifest.xml\" -DisableDevelopmentMode }" >nul 2>&1
    rem Disable background apps globally
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Appx" /v AllowAllTrustedApps /t REG_DWORD /d 0 /f >nul 2>&1
    rem Disable Cortana via policy
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
    rem Remove prelaunch or background tasks (safe list)
    schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
    schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
    echo Background tasks disabled where safe.
    goto pauseAndReturn
)

:: Store & Xbox removal
if "%wopt%"=="4" (
    echo Removing Microsoft Store and Xbox components where possible (Store will be preserved unless specified)...
    powershell -Command "Get-AppxPackage -Name Microsoft.XboxApp -AllUsers | Remove-AppxPackage" >nul 2>&1
    powershell -Command "Get-AppxPackage -Name Microsoft.WindowsStore -AllUsers | Remove-AppxPackage" >nul 2>&1
    echo Note: Removing Store may affect app updates. Proceed with caution.
    goto pauseAndReturn
)

:: Process & priority tweaks
if "%wopt%"=="5" (
    echo Reducing background CPU overhead and setting high priority for common games (example: set for current cmd)
    rem Set current cmd to high priority -- demonstration
    wmic process where name="cmd.exe" call setpriority 128 >nul 2>&1
    rem Prevent non-essential processes from using CPU over threshold using PowerShell
    powershell -Command "Get-Process | Where-Object { $_.CPU -gt 80 } | ForEach-Object { $_.PriorityClass = 'BelowNormal' }" >nul 2>&1
    echo Priorities updated.
    goto pauseAndReturn
)

goto winTweaks

:: ---------------- REGISTRY TWEAKS ----------------
:regTweaks
cls
echo ===== REGISTRY TWEAKS =====
echo [1] Animations & Visuals (set for performance)
echo [2] Menu/Taskbar responsiveness
echo [3] Input Latency (mouse/keyboard)
echo [4] Network Tuning (TCP/IP related registry)
echo [5] File Explorer performance
echo [6] All of the above (apply batch)
echo [0] Back
set /p ropt=Select: 
if "%ropt%"=="0" goto main

if "%ropt%"=="1" (
    echo Applying Visual Performance registry tweaks...
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
    reg add "HKCU\Control Panel\Desktop" /v DragFullWindows /t REG_SZ /d 0 /f
    goto pauseAndReturn
)
if "%ropt%"=="2" (
    echo Improving Menu and Taskbar responsiveness...
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 5 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f
    goto pauseAndReturn
)
if "%ropt%"=="3" (
    echo Lowering input latency for mouse and keyboard...
    reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 6 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f
    goto pauseAndReturn
)
if "%ropt%"=="4" (
    echo Applying registry network tuning presets...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableRSS /t REG_DWORD /d 1 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 1 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v GlobalMaxTcpWindowSize /t REG_DWORD /d 131072 /f
    goto pauseAndReturn
)
if "%ropt%"=="5" (
    echo Making File Explorer faster (increase memory cache, disable thumbnail generation in folders)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ThumbnailSize /t REG_DWORD /d 32 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v DisableThumbnailCache /t REG_DWORD /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsMemoryUsage /t REG_DWORD /d 2 /f
    goto pauseAndReturn
)
if "%ropt%"=="6" (
    echo Applying all selected registry tweaks...
    goto regTweaksApplyAll
)

goto regTweaks

:regTweaksApplyAll
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 5 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableRSS /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsMemoryUsage /t REG_DWORD /d 2 /f
echo All registry tweaks applied.
goto pauseAndReturn

:: ---------------- KBM / CONTROLLER TWEAKS ----------------
:kbmTweaks
cls
echo ===== KBM / CONTROLLER TWEAKS =====
echo [1] Disable Mouse Acceleration & Set Raw Input
echo [2] Increase Mouse Polling / USB Performance (if supported)
echo [3] Keyboard: Lower Debounce/Input Lag settings
echo [4] Controller: Reduce Deadzone & Improve Polling
echo [5] USB: Disable selective suspend and increase power
echo [6] Apply all KBM/Controller tweaks
echo [0] Back
set /p kopt=Select: 
if "%kopt%"=="0" goto main

if "%kopt%"=="1" (
    echo Disabling mouse acceleration and enabling raw input where possible...
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 6 /f
    echo Note: Some games require in-game raw input toggle as well.
    goto pauseAndReturn
)
if "%kopt%"=="2" (
    echo Attempting to set high USB poll behavior (effective only if driver/hardware supports it)...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Usb" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f >nul 2>&1
    echo Also recommend setting device drivers to high performance in Device Manager.
    goto pauseAndReturn
)
if "%kopt%"=="3" (
    echo Applying keyboard low-latency registry values...
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
    goto pauseAndReturn
)
if "%kopt%"=="4" (
    echo Controller tweaks: adjusting HID settings and disabling controller power save.
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f
    echo Controller deadzone/curve changes must be applied in controller software/drivers.
    goto pauseAndReturn
)
if "%kopt%"=="5" (
    echo Enabling High Performance USB and disabling selective suspend...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\UsbFlags" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f
    powercfg -change -standby-timeout-ac 0 >nul 2>&1
    goto pauseAndReturn
)
if "%kopt%"=="6" (
    goto kbmAll
)

goto kbmTweaks

:kbmAll
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 6 /f
reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\UsbFlags" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f
echo KBM & Controller tweaks applied.
goto pauseAndReturn

:: ---------------- BIOS / CPU HELPERS ----------------
:biosTweaks
cls
echo Detecting CPU vendor and applying safe OS-level tweaks...
for /f "tokens=2 delims==" %%A in ('wmic cpu get name /format:list 2^>nul ^| find /i "Name"') do set CPU_NAME=%%A
echo Detected CPU: %CPU_NAME%

echo [1] Apply safe power/perf profile for detected CPU
echo [2] Toggle high performance plan and set core parking hints
echo [3] Disable C-State deep sleep hints (OS-level)
echo [4] Show CPU frequency and current power settings
echo [0] Back
set /p copt=Select: 
if "%copt%"=="0" goto main

if "%copt%"=="1" (
    echo Applying High Performance profile and recommended tweaks...
    powercfg -setactive SCHEME_MIN
    rem set processor performance boost policy (Windows 10/11 uses GUIDs; use powercfg to set minimal)
    goto pauseAndReturn
)
if "%copt%"=="2" (
    echo Setting core parking and responsiveness hints via registry (safe defaults)...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f >nul 2>&1
    echo Core parking tweaks applied (may require third-party tool for advanced control).
    goto pauseAndReturn
)
if "%copt%"=="3" (
    echo Disabling deep C-states via registry hint (this is an OS-level hint only).
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v EnergyEstimationDisabled /t REG_DWORD /d 1 /f >nul 2>&1
    goto pauseAndReturn
)
if "%copt%"=="4" (
    wmic cpu get name,CurrentClockSpeed,MaxClockSpeed /format:list
    powercfg -list
    goto pauseAndReturn
)

goto biosTweaks

:: ---------------- NETWORK TWEAKS ----------------
:netTweaks
cls
echo ===== NETWORK TWEAKS =====
echo [1] Flush DNS and reset network stack
echo [2] TCP tuning (autotune off, congestion provider)
echo [3] Increase ephemeral ports and TCP timewait reuse
echo [4] Disable Nagle for low-latency apps (per-host)
echo [5] Apply recommended GPU streaming & QoS hints
echo [0] Back
set /p nopt=Select: 
if "%nopt%"=="0" goto main

if "%nopt%"=="1" (
    ipconfig /flushdns
    netsh int ip reset
    netsh winsock reset
    echo Network stack reset. Reboot recommended.
    goto pauseAndReturn
)
if "%nopt%"=="2" (
    netsh int tcp set global autotuninglevel=disabled
    netsh int tcp set global chimney=enabled
    netsh int tcp set global congestionprovider=ctcp
    echo TCP tuning applied.
    goto pauseAndReturn
)
if "%nopt%"=="3" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f
    echo Ephemeral ports and timewait adjusted.
    goto pauseAndReturn
)
if "%nopt%"=="4" (
    echo Nagle algorithm tweaks need to be applied per adapter/host. Example below for illustrative purpose only.
    echo Use adapter-specific registry changes under "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\Interfaces\\<GUID>" to set TcpAckFrequency and TCPNoDelay.
    goto pauseAndReturn
)
if "%nopt%"=="5" (
    echo Enabling QoS packet scheduler for gaming is recommended in router and Windows QoS policies.
    goto pauseAndReturn
)

goto netTweaks

:: ---------------- GAMING PERFORMANCE ----------------
:gameTweaks
cls
echo ===== GAMING PERFORMANCE =====
echo [1] Disable Game Bar and Game DVR
echo [2] Set GPU priority and power plan for gaming
echo [3] Disable Fullscreen Optimizations for all apps (registry)
echo [4] Optimize paging file for gaming
echo [5] Apply all gaming tweaks
echo [0] Back
set /p gopt=Select: 
if "%gopt%"=="0" goto main

if "%gopt%"=="1" (
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v value /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
    echo Game Bar and DVR disabled.
    goto pauseAndReturn
)
if "%gopt%"=="2" (
    powercfg -setactive SCHEME_MIN
    echo Ensure GPU drivers are set to high performance in respective control panels (NVIDIA/AMD).
    goto pauseAndReturn
)
if "%gopt%"=="3" (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f >nul 2>&1
    echo To disable fullscreen optimizations per exe, use properties on the executable and check 'Disable fullscreen optimizations'.
    goto pauseAndReturn
)
if "%gopt%"=="4" (
    echo Optimizing pagefile: setting system managed size (recommended) or custom.
    wmic pagefile list /format:list >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagingFiles /t REG_MULTI_SZ /d "C:\pagefile.sys 0 0" /f >nul 2>&1
    goto pauseAndReturn
)
if "%gopt%"=="5" (
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
    powercfg -setactive SCHEME_MIN
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
    echo All gaming tweaks applied.
    goto pauseAndReturn
)

goto gameTweaks

:: ---------------- PRIVACY & TELEMETRY ----------------
:privacyTweaks
cls
echo ===== PRIVACY & TELEMETRY =====
echo [1] Disable Telemetry Services & Tasks
echo [2] Disable Advertising ID & Suggestions
echo [3] Remove Diagnostic Tracking and DataCollection
echo [4] Disable Feedback & Problem Reporting
echo [5] Apply all privacy tweaks
echo [0] Back
set /p popt=Select: 
if "%popt%"=="0" goto main

if "%popt%"=="1" (
    sc config DiagTrack start= disabled >nul 2>&1
    sc stop DiagTrack >nul 2>&1
    schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
    echo Telemetry services disabled where possible.
    goto pauseAndReturn
)
if "%popt%"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
    goto pauseAndReturn
)
if "%popt%"=="3" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    goto pauseAndReturn
)
if "%popt%"=="4" (
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoSMHelp /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
    goto pauseAndReturn
)
if "%popt%"=="5" (
    sc config DiagTrack start= disabled >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
    echo All privacy tweaks applied.
    goto pauseAndReturn
)

goto privacyTweaks

:: ---------------- VISUAL & UI PERFORMANCE ----------------
:visualTweaks
cls
echo ===== VISUAL & UI PERFORMANCE =====
echo [1] Set Windows for best performance (visual effects)
echo [2] Disable Transparency & Blur
echo [3] Reduce Animations and Effects
echo [4] Optimize Explorer and Taskbar
echo [5] Apply All Visual Tweaks
echo [0] Back
set /p vopt=Select: 
if "%vopt%"=="0" goto main

if "%vopt%"=="1" (
    echo Launching Performance Options UI - select 'Adjust for best performance' or use registry change.
    SystemPropertiesPerformance.exe
    goto pauseAndReturn
)
if "%vopt%"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
    goto pauseAndReturn
)
if "%vopt%"=="3" (
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 5 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f
    goto pauseAndReturn
)
if "%vopt%"=="4" (
    echo Clearing icon cache and restarting explorer to apply UI tweaks.
    taskkill /f /im explorer.exe >nul 2>&1
    start explorer.exe
    goto pauseAndReturn
)
if "%vopt%"=="5" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 5 /f
    echo Visual tweaks applied.
    goto pauseAndReturn
)

goto visualTweaks

:: ---------------- POWER & BATTERY ----------------
:powerTweaks
cls
echo ===== POWER & BATTERY =====
echo [1] Set High Performance Plan
echo [2] Disable USB selective suspend
echo [3] Set minimum processor state high for gaming
echo [4] Restore balanced and default settings
echo [5] Apply aggressive power tweaks
echo [0] Back
set /p popt2=Select: 
if "%popt2%"=="0" goto main

if "%popt2%"=="1" (
    powercfg -setactive SCHEME_MIN
    echo High performance plan set.
    goto pauseAndReturn
)
if "%popt2%"=="2" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Usb" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f >nul 2>&1
    echo USB selective suspend disabled.
    goto pauseAndReturn
)
if "%popt2%"=="3" (
    powercfg -setacvalueindex SCHEME_MIN SUB_PROCESSOR PROCTHROTTLEMIN 100
    powercfg -setactive SCHEME_MIN
    echo Processor minimum state set high (100%%) for AC power.
    goto pauseAndReturn
)
if "%popt2%"=="4" (
    powercfg -restoredefaultschemes
    echo Power plans restored to defaults.
    goto pauseAndReturn
)
if "%popt2%"=="5" (
    powercfg -setactive SCHEME_MIN
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v EnergyEstimationDisabled /t REG_DWORD /d 1 /f >nul 2>&1
    echo Aggressive power tweaks applied.
    goto pauseAndReturn
)

goto powerTweaks

:: ---------------- CLEANUP & UNINSTALL ----------------
:cleanupTweaks
cls
echo ===== CLEANUP & UNINSTALL =====
echo [1] Clear Temp, Windows Temp, and prefetch
echo [2] Clean Windows Update and WinSxS (staged cleanup)
echo [3] Uninstall OneDrive, Print 3D, and other common bloat
echo [4] Reset Microsoft Store cache and repair store
echo [5] Full cleanup script (combine safe steps)
echo [0] Back
set /p copt2=Select: 
if "%copt2%"=="0" goto main

if "%copt2%"=="1" (
    echo Clearing temp files...
    del /s /f /q %temp%\* >nul 2>&1
    del /s /f /q C:\Windows\Temp\* >nul 2>&1
    echo Cleaning Prefetch (do not overuse on SSDs)
    del /s /f /q C:\Windows\Prefetch\* >nul 2>&1
    goto pauseAndReturn
)
if "%copt2%"=="2" (
    echo Cleaning Windows Update components and running DISM cleanup.
    net stop wuauserv >nul 2>&1
    net stop bits >nul 2>&1
    dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
    net start bits >nul 2>&1
    net start wuauserv >nul 2>&1
    echo WinSxS cleanup attempted. Reboot recommended.
    goto pauseAndReturn
)
if "%copt2%"=="3" (
    echo Uninstalling OneDrive and common bloat apps...
    taskkill /f /im OneDrive.exe >nul 2>&1
    start /wait %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall >nul 2>&1
    powershell -Command "Get-AppxPackage *3dbuilder* -AllUsers | Remove-AppxPackage" >nul 2>&1
    echo Uninstalls attempted.
    goto pauseAndReturn
)
if "%copt2%"=="4" (
    echo Resetting Microsoft Store cache...
    wsreset.exe
    goto pauseAndReturn
)
if "%copt2%"=="5" (
    del /s /f /q %temp%\* >nul 2>&1
    dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
    wsreset.exe
    echo Combined cleanup complete.
    goto pauseAndReturn
)

goto cleanupTweaks

:: ---------------- END ----------------
:EOF
endlocal
exit /b 0