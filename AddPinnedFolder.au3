Func _AddPinnedFolder($FolderToPin)
	#cs ===============================================================================
	Function: _AddPinnedFolder
	Description:	This function will use Powershell to add the folder passed in as a variable to the Quick Access Menu
	Parameter(s): 	$FolderToPin - The folder to add to the Quick Access Menu

	Returns: None
	#ce ===============================================================================

	RunWait(@SystemDir & "\WindowsPowershell\v1.0\powershell.exe $o = new-object -com shell.application; $o.Namespace('" & $FolderToPin & "').Self.InvokeVerb('pintohome')", @SystemDir, @SW_HIDE)
	ConsoleWrite($FolderToPin & " folder added to Quick Access")
EndFunc   ;==>_AddPinnedFolder