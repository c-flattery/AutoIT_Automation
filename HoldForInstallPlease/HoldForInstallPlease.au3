#include <AutoItConstants.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <Misc.au3>

Global $HotKeyPressed = False

_HoldForInstallPlease(1)

Func _HoldForInstallPlease($BlockInput)
	#cs ===============================================================================
	    Function: HoldForInstallPlease
	    Description: Create and display a GUI to indicate that the user must wait while a process/install/etc runs
	    Parameter(s): $BlockInput - If called within an installer function or script, pass in the parameter to block input
	                1 - Block
	                0 - Unblock
	    Variables(s):
	        $LoopCount - Controls the main loop execution
	        $ImagePath - Path to the folder containing the images for the animation
	        $GUIName - Title of the GUI window
	        $MainWindow - Handle to the main GUI window
	        $ImgLoad - Path to the current image being displayed
	        $IMG - Handle to the loaded image
	        $ImgWidth - Width of the current image
	        $ImgHeight - Height of the current image
	        $ImageIndex - Index of the current image in the animation sequence
	        $Timer - Timer handle used to control the image update interval
	    Deployment Notes:
	    Returns: $BlockInput
	#ce ===============================================================================

	Local $LoopCount = 0
	Local $ImagePath = "C:\Temp\HoldForInstallPlease\Images\" ;Edit this string for folder changes
	Local $GUIName = "Please Wait while the program installs"
	HotKeySet("{End}", "_ExitScript")
	AutoItSetOption("GUIOnEventMode", 1)

	;MainWindow will run in the middle of the screen, on top of all other windows
	$MainWindow = GUICreate($GUIName, 320, 250, -1, -1, BitOR($WS_CAPTION, $WS_POPUP), BitOR($WS_EX_TOPMOST, $WS_EX_DLGMODALFRAME))
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ExitScript")

	GUISetState(@SW_SHOW)
	_GDIPlus_Startup()

	$ImgLoad = $ImagePath & "giphy5.jpg" ;Pick the image to start the animation
	$IMG = _GDIPlus_ImageLoadFromFile($ImgLoad)

	;Calculate the pixel dimension of the image
	$ImgWidth = _GDIPlus_ImageGetWidth($IMG)
	$ImgHeight = _GDIPlus_ImageGetHeight($IMG)
	_GDIPlus_ImageDispose($IMG)
	_GDIPlus_Shutdown()

	;Set position and dimensions of the GUI
	GUICtrlCreatePic($ImgLoad, 320, 250, $ImgWidth, $ImgHeight)
	GUISetState(@SW_SHOW)

	;Block the user's input while the loop runs, based on parameter from function call, defaults to not blocking input
	If $BlockInput = 1 Then
		BlockInput(1)
	EndIf

	$LoopCount = 1
	Local $ImageIndex = 4
	Local $Timer = TimerInit()
	While $LoopCount = 1
		_ClickCheck()
		Sleep(50)

		;Update the image every 300ms to simulate a gif
		If Mod(TimerDiff($Timer), 300) < 50 Then
			$ImgLoad = $ImagePath & "giphy" & $ImageIndex & ".jpg"
			GUICtrlCreatePic($ImgLoad, '', '', $ImgWidth, $ImgHeight)
			$ImageIndex -= 1
			If $ImageIndex < 1 Then $ImageIndex = 5
		EndIf
	WEnd
	Return $BlockInput
EndFunc   ;==>_HoldForInstallPlease

Func _ExitScript()
	;Add this function call to the installer script once the installation is validated
	BlockInput(0) ; Unblock the user's input once the installer is completed
	Exit
EndFunc   ;==>_ExitScript

Func _ClickCheck()
	;Check if the left mouse button is pressed
	If _IsPressed("01") Then
		Local $MousePosition = MouseGetPos()
		SplashTextOn("Uh Uh Uh", "Uh uh uh," & @CRLF & "you didn't say the magic word", 250, 70, $MousePosition[0], $MousePosition[1], $DLG_NOTITLE)
	EndIf
EndFunc   ;==>_ClickCheck