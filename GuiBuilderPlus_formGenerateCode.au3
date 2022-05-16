; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formGenerateCode.au3
; Description ...: Create the code generation popup GUI
; ===============================================================================================================================


#Region formGenerateCode
;------------------------------------------------------------------------------
; Title...........: formGenerateCode
; Description.....:	Create the code generation GUI
;------------------------------------------------------------------------------
Func _formGenerateCode()
	Local $w = 450
	Local $h = 550

	Local $hWin = $hGUI
;~ 	If IsHWnd($hFormObjectExplorer) Then
;~ 		$hWin = $hFormObjectExplorer
;~ 	EndIf

	Local $currentWinPos = WinGetPos($hWin)
	Local $x = $currentWinPos[0] + 50
	Local $y = $currentWinPos[1] + 50

	;make sure $x is not set off screen
	Local $ixCoordMin = _WinAPI_GetSystemMetrics(76)
	Local $iyCoordMin = _WinAPI_GetSystemMetrics(77)
	Local $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	Local $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If ($x + $w) > ($ixCoordMin + $iFullDesktopWidth) Then
		$x = $iFullDesktopWidth - $w
	ElseIf $x < $ixCoordMin Then
		$x = 1
	EndIf

	$hFormGenerateCode = GUICreate("Live Generated Code", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitGenerateCode")
	Local $titleBarHeight = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + 3

	GUICtrlCreateLabel("", 0, 0, $w, $h - $titleBarHeight - 32)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	$editCodeGeneration = GUICtrlCreateEdit("", 10, 10, $w - 20, $h - $titleBarHeight - 53)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	GUICtrlSetFont(-1, 9, -1, -1, "Courier New")
	_GUICtrlEdit_SetTabStops($editCodeGeneration, 4)
	GUICtrlSetData($editCodeGeneration, _code_generation())


	GUICtrlCreateButton("Copy", $w - 20 - 75 * 2 - 5 * 1, $h - 27 - $titleBarHeight, 75, 22)
	GUICtrlSetOnEvent(-1, "_onCodeCopy")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateButton("Save to file", $w - 20 - 75 - 5, $h - 27 - $titleBarHeight, 75, 22)
	GUICtrlSetOnEvent(-1, "_onCodeSave")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
;~ 	GUICtrlCreateButton("Refresh", $w - 20 - 75 * 2 - 5, $h - 27 - $titleBarHeight, 75, 22)
;~ 	GUICtrlSetOnEvent(-1, "_onCodeRefresh")
;~ 	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
;~ 	GUICtrlCreateButton("Close", $w - 20 - 75, $h - 27 - $titleBarHeight, 75, 22)
;~ 	GUICtrlSetOnEvent(-1, "_onExitGenerateCode")
;~ 	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)

	GUISetState(@SW_SHOW, $hFormGenerateCode)
	_GUICtrlEdit_SetSel($editCodeGeneration, 0, 0)

	GUISwitch($hGUI)
EndFunc   ;==>_formGenerateCode
#EndRegion formGenerateCode


#Region events
;------------------------------------------------------------------------------
; Title...........: _onCodeRefresh
; Description.....: Update the generated code shown in the dialog
; Events..........: Refresh button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeRefresh()
	GUICtrlSetData($editCodeGeneration, _code_generation())
EndFunc   ;==>_onCodeRefresh


;------------------------------------------------------------------------------
; Title...........: _onCodeSave
; Description.....: Save the code shown in the dialog to file
; Events..........: Save button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeSave()
	_copy_code_to_output(GUICtrlRead($editCodeGeneration))
EndFunc   ;==>_onCodeSave


;------------------------------------------------------------------------------
; Title...........: _onCodeCopy
; Description.....: Copy the code shown in the dialog to the clipboard
; Events..........: Copy button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeCopy()
	ClipPut(GUICtrlRead($editCodeGeneration))
EndFunc   ;==>_onCodeCopy


;------------------------------------------------------------------------------
; Title...........: _onExitGenerateCode
; Description.....: close the GUI
; Events..........: close button or menu item
;------------------------------------------------------------------------------
Func _onExitGenerateCode()
	GUIDelete($hFormGenerateCode)
	GUICtrlSetState($menu_generateCode, $GUI_UNCHECKED)

	GUISwitch($hGUI)

	; save state to settings file
	IniWrite($sIniPath, "Settings", "ShowCode", 0)
EndFunc   ;==>_onExitGenerateCode
#EndRegion events


;------------------------------------------------------------------------------
; Title...........: _refreshGenerateCode
; Description.....: refresh code for the code generation popup GUI
; Called by.......: any time a control is changed
;------------------------------------------------------------------------------
Func _refreshGenerateCode()
	If IsHWnd($hFormGenerateCode) Then
		GUICtrlSetData($editCodeGeneration, _code_generation())
	EndIf
EndFunc   ;==>_refreshGenerateCode
