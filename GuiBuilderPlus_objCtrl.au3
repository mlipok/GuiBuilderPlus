; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objCtrl.au3
; Description ...: Create and manage objects for control components
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _objCtrls
; Description.....:	Main container for all controls, a wrapper for linked list
;					with additional properties and methods
;------------------------------------------------------------------------------
Func _objCtrls($isSelection = False)
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "count", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "mode", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "CurrentType", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "menuCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "hasMenu", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "isSelection", $ELSCOPE_PUBLIC, $isSelection)
	;actual list of controls
	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, LinkedList())

	Local $oTypeCountList = LinkedList()
	$oTypeCountList.add(_CreateListItem("Button", 0))
	$oTypeCountList.add(_CreateListItem("Group", 0))
	$oTypeCountList.add(_CreateListItem("Checkbox", 0))
	$oTypeCountList.add(_CreateListItem("Radio", 0))
	$oTypeCountList.add(_CreateListItem("Edit", 0))
	$oTypeCountList.add(_CreateListItem("Input", 0))
	$oTypeCountList.add(_CreateListItem("Label", 0))
	$oTypeCountList.add(_CreateListItem("List", 0))
	$oTypeCountList.add(_CreateListItem("Combo", 0))
	$oTypeCountList.add(_CreateListItem("Date", 0))
	$oTypeCountList.add(_CreateListItem("Slider", 0))
	$oTypeCountList.add(_CreateListItem("Tab", 0))
	$oTypeCountList.add(_CreateListItem("Menu", 0))
	$oTypeCountList.add(_CreateListItem("TreeView", 0))
	$oTypeCountList.add(_CreateListItem("Updown", 0))
	$oTypeCountList.add(_CreateListItem("Progress", 0))
	$oTypeCountList.add(_CreateListItem("Pic", 0))
	$oTypeCountList.add(_CreateListItem("Avi", 0))
	$oTypeCountList.add(_CreateListItem("Icon", 0))
	_AutoItObject_AddProperty($oObject, "typeCounts", $ELSCOPE_PUBLIC, $oTypeCountList)

	_AutoItObject_AddMethod($oObject, "createNew", "_objCtrls_createNew")
	_AutoItObject_AddMethod($oObject, "add", "_objCtrls_add")
	_AutoItObject_AddMethod($oObject, "remove", "_objCtrls_remove")
	_AutoItObject_AddMethod($oObject, "removeAll", "_objCtrls_removeAll")
	_AutoItObject_AddMethod($oObject, "get", "_objCtrls_get")
	_AutoItObject_AddMethod($oObject, "getFirst", "_objCtrls_getFist")
	_AutoItObject_AddMethod($oObject, "getLast", "_objCtrls_getLast")
	_AutoItObject_AddMethod($oObject, "getCopy", "_objCtrls_getCopy")
	_AutoItObject_AddMethod($oObject, "exists", "_objCtrls_exists")
	_AutoItObject_AddMethod($oObject, "incTypeCount", "_objCtrls_incTypeCount")
	_AutoItObject_AddMethod($oObject, "decTypeCount", "_objCtrls_decTypeCount")
	_AutoItObject_AddMethod($oObject, "getTypeCount", "_objCtrls_getTypeCount")
	_AutoItObject_AddMethod($oObject, "moveUp", "_objCtrls_moveUp")
	_AutoItObject_AddMethod($oObject, "moveDown", "_objCtrls_moveDown")

	Return $oObject
EndFunc   ;==>_objCtrls

Func _objCtrls_createNew($oSelf)
	#forceref $oSelf
	Local $oObject = _objCtrl($oSelf)

	Return $oObject
EndFunc   ;==>_objCtrls_createNew

Func _objCtrls_add($oSelf, $objCtrl)
	#forceref $oSelf

	If $oSelf.isSelection Then
		_AutoItObject_AddProperty($objCtrl, "grippies", $ELSCOPE_PUBLIC, _objGrippies($objCtrl))
	EndIf
	$oSelf.ctrls.add($objCtrl)
	$oSelf.count = $oSelf.count + 1

	If $objCtrl.Type = "Menu" Then
		$oSelf.menuCount = $oSelf.menuCount + 1
		$oSelf.hasMenu = True
	EndIf

	Return $oSelf.count
EndFunc   ;==>_objCtrls_add

Func _objCtrls_remove($oSelf, $Hwnd)
	#forceref $oSelf

	Local $i, $bFoundItem = False
	For $oItem In $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			$bFoundItem = True
			ExitLoop
		EndIf
		$i += 1
	Next

	If $bFoundItem Then
		If $oSelf.ctrls.at($i).Type = "Menu" Then
			$oSelf.menuCount = $oSelf.menuCount - 1
			If $oSelf.menuCount >= 1 Then
				$oSelf.hasMenu = True
			Else
				$oSelf.hasMenu = False
			EndIf
		EndIf
		Local $thisCtrl = $oSelf.ctrls.at($i)
		If $oSelf.isSelection Then
			$thisCtrl.grippies.delete()
		EndIf
		$oSelf.ctrls.remove($i)
	EndIf

	If Not @error Then
		$oSelf.count = $oSelf.count - 1
		Return $oSelf.count
	Else
		Return -1
	EndIf

EndFunc   ;==>_objCtrls_remove

Func _objCtrls_removeAll($oSelf)
	#forceref $oSelf

	;loop through and delete all the grippies
	For $oItem In $oSelf.ctrls
		If $oSelf.isSelection Then
			$oItem.grippies.delete()
		EndIf
	Next

	$oSelf.ctrls = 0
	$oSelf.ctrls = LinkedList()
	$oSelf.count = 0
	$oSelf.menuCount = 0
	$oSelf.hasMenu = False
EndFunc   ;==>_objCtrls_removeAll

Func _objCtrls_get($oSelf, $Hwnd)
	#forceref $oSelf

	For $oItem In $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			Return $oItem
		EndIf
		If $oItem.Type = "Menu" Then
			For $oMenuItem In $oItem.MenuItems
				If $oMenuItem.Hwnd = $Hwnd Then
					Return $oMenuItem
				EndIf
			Next
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_get

Func _objCtrls_getFist($oSelf)
	#forceref $oSelf

	If $oSelf.count > 0 Then
		Return $oSelf.ctrls.at(0)
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getFist

Func _objCtrls_getLast($oSelf)
	#forceref $oSelf

	If $oSelf.count > 0 Then
		Return $oSelf.ctrls.at($oSelf.count - 1)
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getLast

Func _objCtrls_getCopy($oSelf, $Hwnd)
	#forceref $oSelf

	Local $oCtrl = $oSelf.get($Hwnd)
	If IsObj($oCtrl) Then
		Return _AutoItObject_Create($oCtrl)
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getCopy

Func _objCtrls_exists($oSelf, $Hwnd)
	#forceref $oSelf

	For $oItem In $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			Return True
		EndIf
		If $oItem.Type = "Menu" Then
			For $oMenuItem In $oItem.MenuItems
				If $oMenuItem.Hwnd = $Hwnd Then
					Return True
				EndIf
			Next
		EndIf
	Next

	Return False
EndFunc   ;==>_objCtrls_exists

Func _objCtrls_incTypeCount($oSelf, $sType)
	#forceref $oSelf

	For $oItem In $oSelf.typeCounts
		If $oItem.Name = $sType Then
			$oItem.Value = $oItem.Value + 1
			Return $oItem.Value
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_incTypeCount

Func _objCtrls_decTypeCount($oSelf, $sType)
	#forceref $oSelf

	For $oItem In $oSelf.typeCounts
		If $oItem.Name = $sType Then
			$oItem.Value = $oItem.Value - 1
			If $oItem.Value < 0 Then
				$oItem.Value = 0
			EndIf
			Return $oItem.Value
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_decTypeCount

Func _objCtrls_getTypeCount($oSelf, $sType)
	#forceref $oSelf

	For $oItem In $oSelf.typeCounts
		If $oItem.Name = $sType Then
			Return $oItem.Value
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_getTypeCount

Func _objCtrls_moveUp($oSelf, $oCtrlStart)
	#forceref $oSelf

	;find start and end index
	Local $iStart = -1
	Local $i = 0
	For $oCtrl In $oSelf.ctrls
		If $oCtrl.Hwnd = $oCtrlStart.Hwnd Then
			$iStart = $i
			$iEnd = $iStart - 1
			ExitLoop
		EndIf

		$i += 1
	Next

;~ 	ConsoleWrite("Start " & $iStart & " end " & $iEnd & @CRLF)
;~ 	Return

	If $iStart = -1 Or $iEnd > $oSelf.count - 1 Or $iEnd < 0 Then Return 1

	Local $oCtrlsTemp = LinkedList()

	;loop through items, creating new order in temp list
	$i = 0
	For $oCtrl In $oSelf.ctrls
		If $i <> $iStart Then
			If $i = $iEnd Then
				$oCtrlsTemp.add($oCtrlStart)
			EndIf
			$oCtrlsTemp.add($oCtrl)
		EndIf
		$i += 1
	Next

	;clear ctrls list
	$oSelf.ctrls = 0

	;move temp list to our list
	$oSelf.ctrls = $oCtrlsTemp

	Return $oCtrlStart
EndFunc   ;==>_objCtrls_moveUp


Func _objCtrls_moveDown($oSelf, $oCtrlStart)
	#forceref $oSelf

	;find start and end index
	Local $iStart = -1
	Local $i = 0
	For $oCtrl In $oSelf.ctrls
		If $oCtrl.Hwnd = $oCtrlStart.Hwnd Then
			$iStart = $i
			$iEnd = $iStart + 1
			ExitLoop
		EndIf

		$i += 1
	Next

;~ 	ConsoleWrite("Start " & $iStart & " end " & $iEnd & @CRLF)
;~ 	Return

	If $iStart = -1 Or $iEnd > $oSelf.count - 1 Or $iEnd < 0 Then Return 1

	Local $oCtrlsTemp = LinkedList()

	;loop through items, creating new order in temp list
	$i = 0
	For $oCtrl In $oSelf.ctrls
		If $i <> $iStart Then
			$oCtrlsTemp.add($oCtrl)
			If $i = $iEnd Then
				$oCtrlsTemp.add($oCtrlStart)
			EndIf
		EndIf
		$i += 1
	Next

	;clear ctrls list
	$oSelf.ctrls = 0

	;move temp list to our list
	$oSelf.ctrls = $oCtrlsTemp

	Return $oCtrlStart
EndFunc   ;==>_objCtrls_moveDown


;------------------------------------------------------------------------------
; Title...........: _objCtrl
; Description.....:	Ctrl object
;------------------------------------------------------------------------------
Func _objCtrl($oParent)
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "parent", $ELSCOPE_PUBLIC, $oParent)
	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Hwnd1", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Hwnd2", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "HwndCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Type", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "Visible", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "Enabled", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "Focus", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "OnTop", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "DropAccepted", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "DefButton", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "Color", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "TabCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Tabs", $ELSCOPE_PUBLIC, LinkedList())
	_AutoItObject_AddProperty($oObject, "MenuItems", $ELSCOPE_PUBLIC, LinkedList())

	Return $oObject
EndFunc   ;==>_objCtrl


Func _objCreateRect()
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "Left", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Top", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Width", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Height", $ELSCOPE_PUBLIC, 0)

	Return $oSelf
EndFunc   ;==>_objCreateRect


;example by ProgAndy
Func _CreateListItem($name, $value)
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "Name", $ELSCOPE_PUBLIC, $name)
	_AutoItObject_AddProperty($oSelf, "Value", $ELSCOPE_PUBLIC, $value)

	Return $oSelf
EndFunc   ;==>_CreateListItem





;------------------------------------------------------------------------------
; Title...........: _objMain
; Description.....:	Main GUI object
;------------------------------------------------------------------------------
Func _objMain()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Title", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "AppName", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "AppVersion", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "DefaultCursor", $ELSCOPE_PUBLIC, 0)

	Return $oObject
EndFunc   ;==>_objMain




;------------------------------------------------------------------------------
; Title...........: _objGrippies
; Description.....:	Grippies (selection handles) for a control
;------------------------------------------------------------------------------
Func _objGrippies($oParent)
	Local $oObject = _AutoItObject_Create()

	;add parent as property
	_AutoItObject_AddProperty($oObject, "parent", $ELSCOPE_PUBLIC, $oParent)

	;create the labels to represent the grippy handles
	Local $grippy_size = 5
	Local $NW = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $N = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $NE = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $W = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $East = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $SW = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $S = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
	Local $SE = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)

	;set mouse cursor for each grippy
	GUICtrlSetCursor($NW, $SIZENWSE)
	GUICtrlSetCursor($N, $SIZENS)
	GUICtrlSetCursor($NE, $SIZENESW)
	GUICtrlSetCursor($East, $SIZEWS)
	GUICtrlSetCursor($SE, $SIZENWSE)
	GUICtrlSetCursor($S, $SIZENS)
	GUICtrlSetCursor($SW, $SIZENESW)
	GUICtrlSetCursor($W, $SIZEWS)

	;set events for each grippy
	GUICtrlSetOnEvent($NW, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($N, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($NE, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($SW, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($S, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($SE, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($W, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($East, "_objGrippies_mouseClickEvent")

	;add the label IDs to object properties
	_AutoItObject_AddProperty($oObject, "size", $ELSCOPE_PUBLIC, $grippy_size)
	_AutoItObject_AddProperty($oObject, "NW", $ELSCOPE_PUBLIC, $NW)
	_AutoItObject_AddProperty($oObject, "N", $ELSCOPE_PUBLIC, $N)
	_AutoItObject_AddProperty($oObject, "NE", $ELSCOPE_PUBLIC, $NE)
	_AutoItObject_AddProperty($oObject, "SW", $ELSCOPE_PUBLIC, $SW)
	_AutoItObject_AddProperty($oObject, "S", $ELSCOPE_PUBLIC, $S)
	_AutoItObject_AddProperty($oObject, "SE", $ELSCOPE_PUBLIC, $SE)
	_AutoItObject_AddProperty($oObject, "W", $ELSCOPE_PUBLIC, $W)
	_AutoItObject_AddProperty($oObject, "East", $ELSCOPE_PUBLIC, $East)

	;add methods to object
	_AutoItObject_AddMethod($oObject, "mouseClick", "_objGrippies_mouseClick")
	_AutoItObject_AddMethod($oObject, "show", "_objGrippies_show")
	_AutoItObject_AddMethod($oObject, "hide", "_objGrippies_hide")
	_AutoItObject_AddMethod($oObject, "delete", "_objGrippies_delete")
	_AutoItObject_AddMethod($oObject, "resizing", "_objGrippies_resizing")

	;set the event handler to reference this object
	_objGrippies_mouseClickEvent($oObject)

	Return $oObject
EndFunc   ;==>_objGrippies


;------------------------------------------------------------------------------
; Title...........: _objGrippies_mouseClickEvent
; Description.....:	when a grippy is clicked, this event handler passes the ctrlID
;					to the object method
; Credits.........: IsDeclared technique by TheDcoder
; Link............: https://www.autoitscript.com/forum/topic/139260-autoit-snippets/?do=findComment&comment=1373669
;------------------------------------------------------------------------------
Func _objGrippies_mouseClickEvent($oObject = 0)
	Static $oGrippiesObject
	Local $isEvent = IsDeclared("oObject") = $DECLARED_LOCAL

	If $isEvent Then
		$oGrippiesObject = $oObject
	Else
		If IsObj($oGrippiesObject) Then
			$oGrippiesObject.mouseClick(@GUI_CtrlId)
		Else
			Return -1
		EndIf
	EndIf
EndFunc   ;==>_objGrippies_mouseClickEvent

;------------------------------------------------------------------------------
; Title...........: _objGrippies_mouseClick
; Description.....:	when a grippy is clicked, set the flag
;------------------------------------------------------------------------------
Func _objGrippies_mouseClick($oSelf, $CtrlID)
	Switch $CtrlID
		Case $oSelf.NW
			$oSelf.parent.parent.mode = $resize_nw

		Case $oSelf.N
			$oSelf.parent.parent.mode = $resize_n

		Case $oSelf.NE
			$oSelf.parent.parent.mode = $resize_ne

		Case $oSelf.East
			$oSelf.parent.parent.mode = $resize_e

		Case $oSelf.SE
			$oSelf.parent.parent.mode = $resize_se

		Case $oSelf.S
			$oSelf.parent.parent.mode = $resize_s

		Case $oSelf.SW
			$oSelf.parent.parent.mode = $resize_sw

		Case $oSelf.W
			$oSelf.parent.parent.mode = $resize_w

	EndSwitch

	$initResize = True
	_hide_selected_controls()

EndFunc   ;==>_objGrippies_mouseClick


Func _objGrippies_resizing($oSelf, $mode)
	Local $oCtrl = $oSelf.parent
	Local $left, $top, $right, $bottom

	Switch $mode
		Case $resize_nw
			$left = $oMouse.X
			$top = $oMouse.Y
			$right = ($oCtrl.Width + $oCtrl.Left) - $oMouse.X
			$bottom = ($oCtrl.Height + $oCtrl.Top) - $oMouse.Y

		Case $resize_n
			$left = $oCtrl.Left
			$top = $oMouse.Y
			$right = $oCtrl.Width
			$bottom = ($oCtrl.Top + $oCtrl.Height) - $oMouse.Y

		Case $resize_ne
			$left = $oCtrl.Left
			$top = $oMouse.Y
			$right = $oMouse.X - $oCtrl.Left
			$bottom = ($oCtrl.Top + $oCtrl.Height) - $oMouse.Y

		Case $resize_w
			$left = $oMouse.X
			$top = $oCtrl.Top
			$right = ($oCtrl.Width + $oCtrl.Left) - $oMouse.X
			$bottom = $oCtrl.Height

		Case $resize_e
			$left = $oCtrl.Left
			$top = $oCtrl.Top
			$right = $oMouse.X - $oCtrl.Left
			$bottom = $oCtrl.Height

		Case $resize_sw
			$left = $oMouse.X
			$top = $oCtrl.Top
			$right = ($oCtrl.Left + $oCtrl.Width) - $oMouse.X
			$bottom = $oMouse.Y - $oCtrl.Top

		Case $resize_s
			$left = $oCtrl.Left
			$top = $oCtrl.Top
			$right = $oCtrl.Width
			$bottom = $oMouse.Y - $oCtrl.Top

		Case $resize_se
			$left = $oCtrl.Left
			$top = $oCtrl.Top
			$right = $oMouse.X - $oCtrl.Left
			$bottom = $oMouse.Y - $oCtrl.Top

	EndSwitch


	_set_current_mouse_pos()

	Switch $oCtrl.Type
		Case "Slider"
			GUICtrlSendMsg($oCtrl.Hwnd, 27 + 0x0400, $oCtrl.Height - 20, 0) ; TBS_SETTHUMBLENGTH
	EndSwitch


	_change_ctrl_size_pos($oCtrl, $left, $top, $right, $bottom)
	$oCtrl.grippies.show()
	ToolTip($oCtrl.Name & ": X:" & $oCtrl.Left & ", Y:" & $oCtrl.Top & ", W:" & $oCtrl.Width & ", H:" & $oCtrl.Height)
EndFunc   ;==>_objGrippies_resizing


;------------------------------------------------------------------------------
; Title...........: _objGrippies_show
; Description.....:	show the grippies
;------------------------------------------------------------------------------
Func _objGrippies_show($oSelf)
;~ 	ConsoleWrite("show grippies" & @CRLF)

	;show
	GUICtrlSetState($oSelf.NW, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.N, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.NE, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.East, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.SE, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.S, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.SW, $GUI_SHOW + $GUI_ONTOP)
	GUICtrlSetState($oSelf.W, $GUI_SHOW + $GUI_ONTOP)

	;set on top
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.NW), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.N), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.NE), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.W), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.East), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.SW), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.S), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.SE), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)

	Local Const $grippy_size = $oSelf.size

	Local Const $l = $oSelf.parent.Left
	Local Const $t = $oSelf.parent.Top
	Local Const $W = $oSelf.parent.Width
	Local Const $h = $oSelf.parent.Height

	Local Const $nw_left = $l - $grippy_size
	Local Const $nw_top = $t - $grippy_size
	Local Const $n_left = $l + ($W - $grippy_size) / 2
	Local Const $n_top = $nw_top
	Local Const $ne_left = $l + $W
	Local Const $ne_top = $nw_top
	Local Const $e_left = $ne_left
	Local Const $e_top = $t + ($h - $grippy_size) / 2
	Local Const $se_left = $ne_left
	Local Const $se_top = $t + $h
	Local Const $s_left = $n_left
	Local Const $s_top = $se_top
	Local Const $sw_left = $nw_left
	Local Const $sw_top = $se_top
	Local Const $w_left = $nw_left
	Local Const $w_top = $e_top

	Switch $oSelf.parent.Type
		Case "Combo", "Checkbox", "Radio"
			GUICtrlSetPos($oSelf.East, $e_left, $e_top, Default, Default)
			GUICtrlSetPos($oSelf.W, $w_left, $w_top, Default, Default)

		Case Else
			GUICtrlSetPos($oSelf.NW, $nw_left, $nw_top, Default, Default)
			GUICtrlSetPos($oSelf.N, $n_left, $n_top, Default, Default)
			GUICtrlSetPos($oSelf.NE, $ne_left, $ne_top, Default, Default)
			GUICtrlSetPos($oSelf.East, $e_left, $e_top, Default, Default)
			GUICtrlSetPos($oSelf.SE, $se_left, $se_top, Default, Default)
			GUICtrlSetPos($oSelf.S, $s_left, $s_top, Default, Default)
			GUICtrlSetPos($oSelf.SW, $sw_left, $sw_top, Default, Default)
			GUICtrlSetPos($oSelf.W, $w_left, $w_top, Default, Default)
	EndSwitch
EndFunc   ;==>_objGrippies_show


;------------------------------------------------------------------------------
; Title...........: _objGrippies_hide
; Description.....:	hide the grippies
;------------------------------------------------------------------------------
Func _objGrippies_hide($oSelf)
;~ 	ConsoleWrite("hide grippies" & @CRLF)

	GUICtrlSetState($oSelf.NW, $GUI_HIDE)
	GUICtrlSetState($oSelf.N, $GUI_HIDE)
	GUICtrlSetState($oSelf.NE, $GUI_HIDE)
	GUICtrlSetState($oSelf.East, $GUI_HIDE)
	GUICtrlSetState($oSelf.SE, $GUI_HIDE)
	GUICtrlSetState($oSelf.S, $GUI_HIDE)
	GUICtrlSetState($oSelf.SW, $GUI_HIDE)
	GUICtrlSetState($oSelf.W, $GUI_HIDE)
EndFunc   ;==>_objGrippies_hide

Func _objGrippies_delete($oSelf)
;~ 	ConsoleWrite("delete grippies" & @CRLF)

	GUICtrlDelete($oSelf.NW)
	GUICtrlDelete($oSelf.N)
	GUICtrlDelete($oSelf.NE)
	GUICtrlDelete($oSelf.East)
	GUICtrlDelete($oSelf.SW)
	GUICtrlDelete($oSelf.S)
	GUICtrlDelete($oSelf.SE)
	GUICtrlDelete($oSelf.W)
EndFunc   ;==>_objGrippies_delete
