Func _AddDesktopShortcuts()
	#cs ===============================================================================
	Function: _AddDesktopShortcuts()
	Description: This function is used to add the shortcuts to the desktop for various websites
	Parameter(s): None
	Variables(s): $ChromePath = Path to Chrome.exe
					$Shell32 = Path to Shell32.dll
					$aWebsite = Array of the URL for the specified site
					$aShortcut = Array of the name of the actual desktop shortcut
					$aIconNum = Array of the Shell32 icon number references see here: https://help4windows.com/windows_7_shell32_dll.shtml

	Deployment Notes: If it's a lab PC, create the icon to chrome in incognito mode, otherwise normal chrome
					According to the help file, using FileCreateShortcut will overwrite the icons if the name is the same
                    Replace the ConsoleWrite functions with any custom logging function you use
	Returns: None
	#ce ===============================================================================
	Local $ChromePath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe", "") ;Path to Chrome.exe or the registry location
	Local $Shell32 = "C:\Windows\system32\SHELL32.dll"
	Local $aWebsite[4]     ;URL for the specified site, replace with the actual URL you want to use
	$aWebsite[0] = "https://website1"
	$aWebsite[1] = "https://website2"
	$aWebsite[2] = "https://website3"
	$aWebsite[3] = "https://website4"
	Local $aShortcut[4]     ;Name of the actual desktop shortcut, replace with the actual shortcut name
	$aShortcut[0] = "Link1Shortcut.lnk"
	$aShortcut[1] = "\Link2Shortcut.lnk"
	$aShortcut[2] = "\Link3Shortcut.lnk"
	$aShortcut[3] = "\Link4Shortcut.lnk"
	Local $aIconNum[4]     ;These are the Shell32 icon numbers, for reference see here: https://web.archive.org/web/20210603104325/https://help4windows.com/windows_7_shell32_dll.shtml
	$aIconNum[0] = 210
	$aIconNum[1] = 218
	$aIconNum[2] = 12
	$aIconNum[3] = 161

	ConsoleWrite("Adding shortcuts to desktop...")
	If UBound($aWebsite) = UBound($aShortcut) Then
		For $i = 0 To UBound($aWebsite) - 1
			If _DetermineIfLabPC() == True Then     ;If it's a lab PC: Add additional assignment of incognito flag
				FileCreateShortcut($ChromePath, @DesktopDir & $aShortcut[$i], @WindowsDir, "-incognito " & $aWebsite[$i], "", $Shell32, "", $aIconNum[$i])
				EnvUpdate() ;Refresh the desktop so the FileExists check works
			Else
				;Create the shortcut, with the additional assignment of the --incognito flag, without it for user's PCs
				FileCreateShortcut($ChromePath, @DesktopDir & $aShortcut[$i], @WindowsDir, $aWebsite[$i], "", $Shell32, "", $aIconNum[$i])
				EnvUpdate() ;Refresh the desktop
			EndIf
			;Now check to see if the link to the shortcut was created successfully
			If FileExists(@DesktopDir & $aShortcut[$i]) == 0 Then
                ConsoleWriteError($aShortcut[$i] & " shortcut was not placed on User's desktop" & @CRLF)
			Else
                ConsoleWrite($aShortcut[$i] & " shortcut successfully placed on User's desktop" & @CRLF)
			EndIf
		Next
	EndIf

EndFunc   ;==>_AddDesktopShortcuts

Func _AddDesktopShortcutsCustomIcon($WebsiteLink, $ShortcutLink, $IconLink)
	#cs ===============================================================================
	Function: _AddDesktopShortcutsCustomIcon
	Description: Creates a shortcut on the desktop with a custom icon
	Parameter(s): $WebsiteLink - The URL for the specified site
					$ShortcutLink - The name of the actual desktop shortcut
					$IconLink - The path to the icon to be used
	Variables(s): $ChromePath - Path to Chrome.exe

	Deployment Notes: Icon link must be a .ico file
	Returns: None
	Author(s): Chelsea Flattery - Chelsea.Flattery@gm.com
	#ce ===============================================================================

	$ChromePath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe", "") ;Path to Chrome.exe or the registry location
	If @error <> 0 Then
		ConsoleWriteError("Could not set Chrome Path")
		Return
	Else
		ConsoleWrite("Chrome path = " & $ChromePath)
	EndIf

	If _DetermineIfLabPC() == True Then
		FileCreateShortcut($ChromePath, @DesktopDir & $ShortcutLink, @WindowsDir, "-incognito " & $WebsiteLink, "", $IconLink, "", "", "")
        EnvUpdate() ;Refresh the desktop so the FileExists check works
	Else
		FileCreateShortcut($ChromePath, @DesktopDir & $ShortcutLink, @WindowsDir, $WebsiteLink, "", $IconLink, "", "", "")
        EnvUpdate() ;Refresh the desktop
	EndIf

	If FileExists(@DesktopDir & $ShortcutLink) == 0 Then
        ConsoleWriteError($ShortcutLink & " shortcut was not placed on User's desktop" & @CRLF)
	Else
        ConsoleWrite($ShortcutLink & " shortcut successfully placed on User's desktop" & @CRLF)
	EndIf

EndFunc   ;==>_AddDesktopShortcutsCustomIcon

Func _DetermineIfLabPC()
	#cs ===============================================================================
	Function: 	_DetermineIfLabPC()
	Description: 	Determines if the PC running the script is a lab PC.  Otherwise it's likely a laptop for our use case.
	Parameter(s): 	None
	Variables(s): $users - This will return an Array of all domain PC users only, variable 1 returns local, 2 returns domain, and 0 returns both

	Deployment Notes: Use the _SystemUsers function created by Danny35d to get the list of users on the PC 
                    https://www.autoitscript.com/forum/topic/112619-get-list-of-all-windows-users/#comment-789136
                    Replace the username with the actual lab PC naming convention
                    Example function call: _DetermineIfLabPC()
	Returns: True if it's a lab PC, False if it's not
	#ce ===============================================================================

	Local $users = _SystemUsers(2) ;Get the list of users on the PC using the _SystemUsers function created by Danny35d
	_ArraySearch($users, "labPC_username", 1, $users[0], 0, 1) ;Replace the username with the actual lab PC naming convention
	If @error Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_DetermineIfLabPC