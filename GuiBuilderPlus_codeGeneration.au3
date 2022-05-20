; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_codeGeneration.au3
; Description ...: Code generation and management
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _code_generation
; Description.....: generate the au3 code
; Return..........: code as string
;------------------------------------------------------------------------------
Func _code_generation($x = -1, $y = -1)
	Local $controls

	;get options
	Local $bAddDpiScale = $setting_dpi_scaling
	Local $sDpiScale = ""
	If $bAddDpiScale Then
		$sDpiScale = " * $iDpiFactor"
	EndIf

	;set up the region tags
	Local $regionStart = "#Region (=== GUI generated by " & $progName & " " & $progVersion & " ===)"
	Local $regionEnd = "#EndRegion (=== GUI generated by " & $progName & " " & $progVersion & " ===)"

	;function documentation template <-- planning on making this a map eventually
	Local $mDocData[]
	$mDocData.name = "_main"
	$mDocData.description = "run the main program loop"
	Local $mainFunctionDoc = _functionDoc($mDocData) & @CRLF

	; Mod by: TheSaint - default includes
	Local $includes = "#include <Constants.au3>" & @CRLF & _
			"#include <GUIConstantsEx.au3>" & @CRLF & _
			"#include <Misc.au3>" & @CRLF & _
			"#include <WindowsConstants.au3>"
	If $bAddDpiScale Then
		$includes &= @CRLF & "#include <GDIPlus.au3>"
	EndIf

	For $oCtrl In $oCtrls.ctrls
		;generate includes
		$includes &= _generate_includes($oCtrl, $includes)

		;generate controls
		$controls &= _generate_controls($oCtrl, $sDpiScale)
	Next

	Local $sGuiFunc = "", $bGuiFunc = 0
	If $bGuiFunc Then
		$sGuiFunc = "" & _
				@TAB & "_createGUI()" & @CRLF & @CRLF
	EndIf

	Local $mainProg = "" & _
			"_main()" & @CRLF & @CRLF & _
			$mainFunctionDoc & _
			"Func _main()" & @CRLF & _
			$sGuiFunc & _
			@TAB & "While 1" & @CRLF & _
			@TAB & @TAB & "GUISetState(@SW_SHOWNORMAL)" & @CRLF & @CRLF & _
			@TAB & @TAB & "Switch GUIGetMsg()" & @CRLF & _
			@TAB & @TAB & @TAB & "Case $GUI_EVENT_CLOSE" & @CRLF & _
			@TAB & @TAB & @TAB & @TAB & "ExitLoop" & @CRLF & @CRLF & _
			@TAB & @TAB & @TAB & "Case Else" & @CRLF & _
			@TAB & @TAB & @TAB & @TAB & ";" & @CRLF & _
			@TAB & @TAB & "EndSwitch" & @CRLF & _
			@TAB & "WEnd" & @CRLF & _
			"EndFunc   ;==>_main"

	Local $w = $win_client_size[0]
	Local $h = $win_client_size[1]

	;apply the DPI scaling factor
	If $w <> -1 Then
		$w &= $sDpiScale
	EndIf

	If $h <> -1 Then
		$h &= $sDpiScale
	EndIf

	If $x <> -1 Then
		$x &= $sDpiScale
	EndIf

	If $y <> -1 Then
		$y &= $sDpiScale
	EndIf

	If $mainName = "" Then
		$mainName = "hGUI"
	EndIf

	; Mod by TheSaint
	Local $code = ""
	If $bAddDpiScale Then
		$code &= "#AutoIt3Wrapper_Res_HiDpi=y" & @CRLF & @CRLF
	EndIf
	$code &= $includes & @CRLF & @CRLF
	If $bAddDpiScale Then
		$code &= "Global $iDpiFactor = _GDIPlus_GraphicsGetDPIRatio()" & @CRLF & @CRLF
	EndIf
	$code &= $regionStart & @CRLF & _
			"Global $MainStyle = BitOR($WS_OVERLAPPED, $WS_CAPTION, $WS_SYSMENU, $WS_VISIBLE, $WS_CLIPSIBLINGS, $WS_MINIMIZEBOX)" & @CRLF & _
			"Global $" & $mainName & " = GUICreate(" & $gdtitle & ", " & $w & ", " & $h & ", " & $x & ", " & $y & ", $MainStyle)" & @CRLF & @CRLF & _
			$controls & _
			$regionEnd & @CRLF & @CRLF & _
			$mainProg & @CRLF & @CRLF
	If $bAddDpiScale Then
		$code &= @CRLF & _getCodeDpiScalingFunc()
	EndIf
	Return $code
EndFunc   ;==>_code_generation


;------------------------------------------------------------------------------
; Title...........: _functionDoc
; Description.....: generate the function doc based on template
;------------------------------------------------------------------------------
Func _functionDoc($mDocData)
	If Not IsMap($mDocData) Then Return ""

	Local $sFileData = FileRead(@ScriptDir & "\storage\templateFunctionDoc.au3")
	If @error Then Return ""

	$sFileData = StringRegExpReplace($sFileData, "\%\%name\%\%", $mDocData.name)
	$sFileData = StringRegExpReplace($sFileData, "\%\%description\%\%", $mDocData.description)

	Return $sFileData
EndFunc   ;==>_functionDoc


;------------------------------------------------------------------------------
; Title...........: _generate_controls
; Description.....: generate the code for the controls
;------------------------------------------------------------------------------
Func _generate_controls(Const $oCtrl, $sDpiScale)
	;apply the DPI scaling factor
	Local $left = $oCtrl.Left
	If $left <> -1 Then
		$left &= $sDpiScale
	EndIf

	Local $top = $oCtrl.Top
	If $top <> -1 Then
		$top &= $sDpiScale
	EndIf

	Local $width = $oCtrl.Width
	If $width <> -1 Then
		$width &= $sDpiScale
	EndIf

	Local $height = $oCtrl.Height
	If $height <> -1 Then
		$height &= $sDpiScale
	EndIf

	Local Const $ltwh = $left & ", " & $top & ", " & $width & ", " & $height

	; The general template is GUICtrlCreateXXX( "text", left, top [, width [, height [, style [, exStyle]]] )
	; but some controls do not use this.... Avi, Icon, Menu, Menuitem, Progress, Tabitem, TreeViewitem, updown
	Local $mControls

	Switch StringStripWS($oCtrl.Name, $STR_STRIPALL) <> ''
		Case True
			$mControls = "Global $" & $oCtrl.Name & " = "
	EndSwitch

	Switch $oCtrl.Type
		Case "Progress", "Slider", "TreeView" ; no text field
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '(' & $ltwh & ")" & @CRLF

		Case "Icon" ; extra iconid [set to zero]
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("' & $oCtrl.Text & '", 0, ' & $ltwh & ")" & @CRLF

		Case "Tab"
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '(' & $ltwh & ')' & @CRLF

			For $oTab In $oCtrl.Tabs
				$mControls &= "Global $" & $oTab.Name & " = "
				$mControls &= 'GUICtrlCreateTabItem("' & $oTab.Text & '")' & @CRLF
				$mControls &= 'GUICtrlCreateTabItem("")' & @CRLF
			Next

		Case "Updown"
			$mControls &= "GUICtrlCreateInput" & '("' & $oCtrl.Text & '", ' & $ltwh & ")" & @CRLF
			$mControls &= "GUICtrlCreateUpdown(-1)" & @CRLF

		Case "Pic"
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("", ' & $ltwh & ")" & @CRLF
			$mControls &= "GUICtrlSetImage(-1, " & '"' & $samplebmp & '")' & @CRLF

		Case Else
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("' & $oCtrl.Text & '", ' & $ltwh & ")" & @CRLF
	EndSwitch

	If $oCtrl.Color <> -1 Then
		$mControls &= "GUICtrlSetColor(-1, 0x" & Hex($oCtrl.Color, 6) & ")" & @CRLF
	EndIf
	If $oCtrl.Background <> -1 Then
		$mControls &= "GUICtrlSetBkColor(-1, 0x" & Hex($oCtrl.Background, 6) & ")" & @CRLF
	EndIf

	Return $mControls
EndFunc   ;==>_generate_controls


;------------------------------------------------------------------------------
; Title...........: _generate_includes
; Description.....: generate the code for the includes
;------------------------------------------------------------------------------
Func _generate_includes(Const $oCtrl, Const $includes)
	Switch $oCtrl.Type
		Case "Button", "Checkbox", "Group", "Radio"
			If Not StringInStr($includes, "<ButtonConstants.au3>") Then
				Return @CRLF & "#include <ButtonConstants.au3>"
			EndIf

		Case "Tab"
			If Not StringInStr($includes, "<GUITab.au3>") Then
				Return @CRLF & "#include <GUITab.au3>"
			EndIf

		Case "Date"
			If Not StringInStr($includes, "<DateTimeConstants.au3>") Then
				Return @CRLF & "#include <DateTimeConstants.au3>"
			EndIf

		Case "Edit", "Input"
			If Not StringInStr($includes, "<EditConstants.au3>") Then
				Return @CRLF & "#include <EditConstants.au3>"
			EndIf

		Case "Icon", "Label", "Pic"
			If Not StringInStr($includes, "<StaticConstants.au3>") Then
				Return @CRLF & "#include <StaticConstants.au3>"
			EndIf

		Case "List"
			If Not StringInStr($includes, "<ListBoxConstants.au3>") Then
				Return @CRLF & "#include <ListBoxConstants.au3>"
			EndIf

		Case "Progress", "Slider", "TreeView", "Combo"
			If Not StringInStr($includes, '<' & $oCtrl.Type & "Constants.au3>") Then
				Return @CRLF & "#include <" & $oCtrl.Type & "Constants.au3>"
			EndIf
	EndSwitch

	Return ""
EndFunc   ;==>_generate_includes

;------------------------------------------------------------------------------
; Title...........: _save_code
; Description.....: generate the au3 code and save to file
;------------------------------------------------------------------------------
Func _save_code()
	Local $code = _code_generation()
	_copy_code_to_output($code)
EndFunc   ;==>_save_code


;------------------------------------------------------------------------------
; Title...........: _copy_code_to_output
; Description.....: Save generated code to file
; Author..........: TheSaint
; Modified By.....: KurtyKurtyBoy
;------------------------------------------------------------------------------
Func _copy_code_to_output(Const $code)
	Switch StringInStr($CmdLineRaw, "/StdOut")
		Case True
			ConsoleWrite("#region ; --- " & $progName & " generated code Start ---" & @CRLF & _
					StringReplace($code, @CRLF, @LF) & @CRLF & _
					"#endregion ; --- " & $progName & " generated code End ---" & @CRLF)

		Case False
			If $mygui = "" Then
				$mygui = "MyGUI.au3"
			EndIf

			Local Const $destination = FileSaveDialog("Save GUI to file?", "", "AutoIt (*.au3)", BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), $mygui)

			If @error = 1 Or Not $destination Then
				ClipPut($code)
				$bStatusNewMessage = True
				_GUICtrlStatusBar_SetText($hStatusbar, "Script copied to clipboard")
			Else
				FileDelete($destination)

				FileWrite($destination, $code)

				$bStatusNewMessage = True
				_GUICtrlStatusBar_SetText($hStatusbar, "Saved to file")
			EndIf
	EndSwitch
EndFunc   ;==>_copy_code_to_output


Func _getCodeDpiScalingFunc()
	Local $code = '' & _
			'; #FUNCTION# ====================================================================================================================' & @CRLF & _
			'; Name ..........: _GDIPlus_GraphicsGetDPIRatio' & @CRLF & _
			'; Description ...:' & @CRLF & _
			'; Syntax ........: _GDIPlus_GraphicsGetDPIRatio([$iDPIDef = 96])' & @CRLF & _
			'; Parameters ....: $iDPIDef             - [optional] An integer value. Default is 96.' & @CRLF & _
			'; Return values .: Scaling value for control sizes and positions' & @CRLF & _
			'; Author ........: UEZ' & @CRLF & _
			'; Modified by....: KurtyKurtyBoy' & @CRLF & _
			'; Link ..........: http://www.autoitscript.com/forum/topic/159612-dpi-resolution-problem/?hl=%2Bdpi#entry1158317' & @CRLF & _
			'; ===============================================================================================================================' & @CRLF & _
			'Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)' & @CRLF & _
			@TAB & '_GDIPlus_Startup()' & @CRLF & _
			@TAB & 'Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)' & @CRLF & _
			@TAB & 'If @error Then Return SetError(1, @extended, 0)' & @CRLF & _
			@TAB & 'Local $aResult' & @CRLF & _
			@TAB & '#forcedef $__g_hGDIPDll, $ghGDIPDll' & @CRLF & _
			@CRLF & _
			@TAB & '$aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)' & @CRLF & _
			@CRLF & _
			@TAB & 'If @error Then Return SetError(2, @extended, 0)' & @CRLF & _
			@TAB & 'Local $iDPI = $aResult[2]' & @CRLF & _
			@TAB & 'Local $aresults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]' & @CRLF & _
			@TAB & '_GDIPlus_GraphicsDispose($hGfx)' & @CRLF & _
			@TAB & '_GDIPlus_Shutdown()' & @CRLF & _
			@CRLF & _
			@TAB & 'Return $aresults[1]' & @CRLF & _
			'EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio' & @CRLF

	Return $code
EndFunc   ;==>_getCodeDpiScalingFunc
