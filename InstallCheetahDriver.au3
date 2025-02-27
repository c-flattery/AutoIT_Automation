;~~~~~~~~~~~~~~~~InstallCheetahDriver - Install the Cheetah USB Host Driver~~~~~~~~~~~~~~~~
Func _InstallCheetahDriver()
	#cs ===============================================================================
		Function:     _InstallCheetahDriver()
		Description:   Install the Cheetah driver
		Parameter(s): 	
		Variables(s):	$CheetahDriverLocation - File path to the installer
						$TotalPhase - Window title
						$PID - Process ID of the installer
						$InstalledVersion - Version number of the currently installed driver, pulled from the Win registry
						$CurrentVersion - Version number of the driver deployed from network drive

		Deployment Notes:	Update variables to reflect the environment of the PCs this is being run on
                        Make sure the Cheetah driver installer is in the location specified in $CheetahDriverLocation
                        Make sure the registry location is correct for the version of Windows being used
                        Make sure to run this script as an administrator
    
		Returns:      	
		Author(s):
	#ce ===============================================================================

	Local $CheetahDriverLocation = "C:\Temp\To_Deploy\Cheetah_USB_Host_Driver\TotalPhaseUSB-v2.16.exe"
    Local $RegistryLocation = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\TotalPhase"
	Local $TotalPhase = "Total Phase USB Driver 2.16 Setup"
	Local $PID = 0
	Local $InstalledVersion
	Local $CurrentVersion

	
    $CurrentVersion = FileGetVersion($CheetahDriverLocation) ;If there is a problem, it will return 0.0.0.0
    $InstalledVersion = RegRead($RegistryLocation, "VersionString")
    ConsoleWrite("About to compare Cheetah USB Host Driver, Installed: " & $InstalledVersion & " Network Copy to install: " & $CurrentVersion & @CRLF)
    If _VersionCompare($CurrentVersion, $InstalledVersion) == 1 Then ;If the installed Cheetah USB Host Driver is older than the network copy
        $PID = Run(@ComSpec & " /c " & $CheetahDriverLocation, @SystemDir, @SW_HIDE, 2) ;Run the installer in the background
        If @error Or $PID = 0 Then
            ConsoleWriteError("ERROR -- There was a problem installing Cheetah USB Host Driver as Admin " & @UserName)
            Return
        EndIf

        WinWaitActive($TotalPhase, "Welcome to Total Phase USB Driver 2.16 Setup", 10)
        If @error Then ;If there is a timeout after waiting 10 seconds...
            If WinExists($TotalPhase, "Welcome to Total Phase USB Driver 2.16 Setup") <> 1 Then ;check to see if the window exists, if it doesn't error out and return
                ConsoleWriteError("ERROR -- There was an issue installing the Cheetah USB Driver, please continue manually")
                Return
            EndIf
        Else ;If the window does exist...
            WinActivate($TotalPhase, "Welcome to the Total Phase USB Driver 2.16 Setup")
            ProgressSet($Progress + 1, "Cheetah USB Host Driver: User Input Blocked")
            BlockInput(1) ; Block user input
            Send("{ENTER}")
        EndIf
        BlockInput(0) ; Unblock user input

        WinWaitActive($TotalPhase, "License Agreement", 30) ;Wait 30 seconds for the License Agreement window to appear
        If @error Then ;If it has a timeout...
            ConsoleWriteError("ERROR -- There was a timeout installing the Cheetah USB Driver, please continue manually")
            Return
        ElseIf WinActive($TotalPhase, "License Agreement") Then ;If this window does exist, make it active and continue...
            BlockInput(1) ; Block user input
            ControlCommand($TotalPhase, "License Agreement", "[Class:Button; Instance:4]", "Check", "") ;Check the "agree" radio button
            Sleep(1000) ; Sleep for 1 seconds for the radio button to be selected
            Send("{ENTER}")
            Send("{ENTER}")
            BlockInput(0) ;Unblock user input for the long part of the installer
        Else
            BlockInput(0) ; Unblock user input
            ConsoleWriteError("ERROR -- There was an error installing the Cheetah USB Driver, please continue manually")
            Return
        EndIf

        WinWait("Windows Security", "", 900) ; Put a 15 minute timeout to catch if the install actually freezes
        If WinExists("Windows Security", "") Then ;If the Windows Security window exists...
            BlockInput(1) ; Block user input
            WinActivate("Windows Security", "")
            Send("{TAB}")
            Send("{TAB}")
            Send("{TAB}")
            Send("{ENTER}")
            BlockInput(0) ;Unlock user input
        ElseIf @error Then ;If there is a timeout after 15 minutes...
            If WinExists($TotalPhase, "Installation Complete") Then ;Check to see if the Security window was bypassed and if the Install Complete window exists
                WinActivate($TotalPhase, "Installation Complete")
                Send("{ENTER}")
               ConsoleWrite("SUCCESS -- Cheetah USB Driver install complete")
            Else
                ConsoleWriteError("ERROR -- There was a timeout installing the Cheetah USB Driver, please continue manually")
                Return
            EndIf
        Else
            BlockInput(0) ; Unblock user input
            ConsoleWriteError("ERROR -- There was a timeout installing the Cheetah USB Driver, please continue manually")
            Return
        EndIf

        WinWaitActive($TotalPhase, "Installation Complete", 100) ; If the windows security window existed, this is here to catch the last Installation Complete window
        If WinExists($TotalPhase, "Installation Complete") Then
            BlockInput(1) ;Block user input
            WinActivate($TotalPhase, "Installation Complete")
            Send("{ENTER}")
            BlockInput(0) ;Unblock user input
            ConsoleWrite("SUCCESS -- Cheetah USB Driver install complete")
        Else
            BlockInput(0) ;Unblock user input in case it's still blocked from somewhere else
            ConsoleWriteError("ERROR -- There was a timeout installing the Cheetah USB Driver, please continue manually")
            Return
        EndIf
    Else
        ConsoleWrite("SKIPPING INSTALL -- Cheetah USB Host Driver is up to date")
    EndIf
EndFunc   ;==>_InstallCheetahDriver