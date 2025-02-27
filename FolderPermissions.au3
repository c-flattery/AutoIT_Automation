Func _FolderPermissions($DirGetPermission)
	#cs ===============================================================================
	Function: _FolderPermissions
	Description: This function is used to give specified permissions to the specified folder/directory
				The command spits out a txt file that is read for success or failure
				Success creates a Registry Value DirPermission and the Directory path,
				lack of reg value prompts function to run again on next script run
				File is deleted either way as it is unnecessary to keep it
	Parameter(s): $DirGetPermission - The directory that needs permissions
	Variables(s): $iCaclsRun - The return from Run
				$ErrorCode - The return from StringInStr
				$iCaclsReturn - The return from FileRead
                $RegPath - The registry path where the value will be written
				$FolderPermissionsFile - The file that is created by icacls

	Deployment Notes: This must run as admin, we are using a function called _RunElevated to do so, as an example
                Example function call: _FolderPermissions("C:\Program Files\MyApp")
                The directory must exist before running this function
                The RunWait command should be edited to include the permissions you want to set
	Returns: None
	#ce ===============================================================================
	Local $iCaclsRun
	Local $ErrorCode
	Local $iCaclsReturn
    Local $RegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\MyApp" ;The registry path where the value will be written
	Local $FolderPermissionsFile = "C:\Temp\folderpermissions.txt" ;Whatever file name and location you want to use, this is just a placeholder

	$iCalcsRun = RunWait(@ComSpec & " /c icacls " & '"' & $DirGetPermission & '"' & " /grant Everyone:(OI)(CI)F>" & $FolderPermissionsFile, "", @SW_HIDE, 2) ;Run the command to set permissions
    ProcessWaitClose($iCaclsRun) ;it takes a second
	$iCaclsReturn = FileRead($FolderPermissionsFile) ;Read in the file that was output

	$ErrorCode = StringInStr($iCaclsReturn, "Failed processing 0 files") ;Compare strings
	If $ErrorCode > 1 Then ;StringinStr returns 0 for not found, meaning more than 1 file/directory was not modified
		ConsoleWrite("Folder permissions for " & $DirGetPermission & " have been set successfully" & @CRLF)
		RegWrite($RegPath & "\Permissions", "DirPermission", "REG_SZ", $DirGetPermission) ;Write the registry value
		FileDelete($FolderPermissionsFile)
	Else
		ConsoleWriteError("Folder permissions for " & $DirGetPermission & " have failed: " & $iCaclsReturn & @CRLF)
		FileDelete($FolderPermissionsFile)
	EndIf
EndFunc   ;==>_FolderPermissions