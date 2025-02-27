;~~~~~~~~~~~~~~~~StartService~~~~~~~~~~~~~~~~
Func _StartService($ServiceName)
	#cs ===============================================================================
	Function: _StartService
	Description: This function will start the passed in service
	Parameter(s): $ServiceName = Name of the service to start
	Variables(s): $nPID = The net.exe PID
					$PID = The SC Query PID
					$data = The output of the sc query command

	Deployment Notes: Example function call: _StartService("telegraf")
	Returns: None
	#ce ===============================================================================

	Local $PID
	Local $nPID
	Local $data

	$PID = Run("sc query " & $ServiceName, @SystemDir, @SW_HIDE, 2)
	ProcessWaitClose($PID)
	Do
		$data &= StdoutRead($PID)
	Until @error

	If StringInStr($data, "RUNNING") Then
        ConsoleWrite($ServiceName & " is running as a service" & @CRLF & $data)
		Return 1
	ElseIf StringInStr($data, "STOPPED") Then
		ConsoleWrite($ServiceName & " is stopped, starting it up again..." & @CRLF & $data)
		$nPID = Run(@SystemDir & "\net.exe start " & $ServiceName)
		ProcessWaitClose($nPID)
	Else
        ConsoleWriteError($ServiceName & " may not be installed" & @CRLF & $data)
		Return 0
	EndIf
EndFunc   ;==>_StartService

Func _StopService($ServiceName)
	#cs ===============================================================================
	Function: _StopService
	Description: This function will stop the passed in service
	Parameter(s): $ServiceName = Name of the service to stop
	Variables(s): $nPID = The net.exe PID
					$PID = The SC Query PID
					$data = The output of the sc query command

	Deployment Notes: Example function call: _StopService("telegraf")
	Returns: None
	#ce ===============================================================================

	Local $nPID
	Local $PID
	Local $data

    $nPID = Run(@SystemDir & "\net.exe stop " & $ServiceName, @SystemDir, @SW_HIDE, 2)
	ProcessWaitClose($nPID)

	If ProcessExists($ServiceName) Then ;Stop service manually if it's still running
        RunWait(@ComSpec & " /c net stop " & $ServiceName)
		Sleep(500)
	EndIf

	$PID = Run("sc query " & $ServiceName, @SystemDir, @SW_HIDE, 2)
	ProcessWaitClose($PID)
	Do
		$data &= StdoutRead($PID)
	Until @error

	If StringInStr($data, "STOPPED") Then
        ConsoleWrite($ServiceName & " is stopped" & @CRLF & $data)
	Else
        ConsoleWriteError("Something went wrong while stopping the " & $ServiceName & " service" & @CRLF)
	EndIf

EndFunc   ;==>_StopService