; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formObjectExplorer.au3
; Description ...: Create and manage the object explorer GUI
; ===============================================================================================================================


#Region _formObjectExplorer
;------------------------------------------------------------------------------
; Title...........: _formObjectExplorer
; Description.....:	Create the GUI
;------------------------------------------------------------------------------
Func _formObjectExplorer()
	Local $w = 250
	Local $h = 500
	Local $x, $y

	Local $sPos = IniRead($sIniPath, "Settings", "posObjectExplorer", "")
	If $sPos <> "" Then
		Local $aPos = StringSplit($sPos, ",")
		$x = $aPos[1]
		$y = $aPos[2]
	Else
		Local $currentWinPos = WinGetPos($hGUI)
		$x = $currentWinPos[0] + $currentWinPos[2]
		$y = $currentWinPos[1]
	EndIf

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

	$hFormObjectExplorer = GUICreate("Object Explorer", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitObjectExplorer")
	Local $titleBarHeight = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + 3

	;background label
	GUICtrlCreateLabel("", 0, 0, $w, $h - $titleBarHeight - 25)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	;object list
	$lvObjects = GUICtrlCreateTreeView(1, 5, $w, $h - $titleBarHeight - 40, BitOR($TVS_LINESATROOT, $TVS_HASLINES, $TVS_HASBUTTONS, $TVS_FULLROWSELECT, $TVS_SHOWSELALWAYS), $WS_EX_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	;bottom section
	$labelObjectCount = GUICtrlCreateLabel("Object Count: " & $oCtrls.count, 5, $h - 18 - $titleBarHeight, $w - 20)

	_formObjectExplorer_updateList()


	;accelerators
	Local Const $accel_delete = GUICtrlCreateDummy()
	Local Const $accelerators[1][2] = _
			[ _
			["{Delete}", $accel_delete] _
			]
	GUISetAccelerators($accelerators, $hFormObjectExplorer)
	GUICtrlSetOnEvent($accel_delete, "_onLvObjectsDelete")


	GUISetState(@SW_SHOW, $hFormObjectExplorer)

	GUISwitch($hGUI)
EndFunc   ;==>_formObjectExplorer
#EndRegion _formObjectExplorer


#Region events
;------------------------------------------------------------------------------
; Title...........: _onExitGenerateCode
; Description.....: close the GUI
; Events..........: close button or menu item
;------------------------------------------------------------------------------
Func _onExitObjectExplorer()
	_saveWinPositions()

	GUIDelete($hFormObjectExplorer)
	GUICtrlSetState($menu_ObjectExplorer, $GUI_UNCHECKED)

	GUISwitch($hGUI)

	; save state to settings file
	IniWrite($sIniPath, "Settings", "ShowObjectExplorer", 0)
EndFunc   ;==>_onExitObjectExplorer


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsItem
; Description.....: make selected item the selected control (or multiple)
; Events..........: select listview item
;------------------------------------------------------------------------------
Func _onLvObjectsItem()
	$childSelected = False

	Local $count = _GUICtrlTreeView_GetCount($lvObjects)
	Local $aItems[$count]
	Local $iIndex = 0, $first = True
	Local $hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1
	Do
		If _GUICtrlTreeView_GetSelected($lvObjects, $hItem) Then
			$aItems[$iIndex] = $hItem
			$iIndex += 1

			Local $aText = _GUICtrlTreeView_GetText($lvObjects, $hItem)
			Local $aStrings = StringSplit($aText, @TAB)
			Local $textHwnd = StringTrimRight(StringTrimLeft($aStrings[2], 7), 1)
			$oCtrl = $oCtrls.get(Dec($textHwnd))

			Local $hParent = _GUICtrlTreeView_GetParentHandle($lvObjects, $hItem)
			If $hParent <> 0 Then    ;this is a child
				Local $aParentText = _GUICtrlTreeView_GetText($lvObjects, $hParent)
				Local $aParentStrings = StringSplit($aParentText, @TAB)
				Local $ParentTextHwnd = StringTrimRight(StringTrimLeft($aParentStrings[2], 7), 1)
				$oParentCtrl = $oCtrls.get(Dec($ParentTextHwnd))
				If $oParentCtrl.Type = "Tab" Then
					;get tab #
					Local $i = 0
					For $oTab In $oParentCtrl.Tabs
						If $oTab.Hwnd = Dec($textHwnd) Then
							$childSelected = True
							_GUICtrlTab_SetCurSel($oParentCtrl.Hwnd, $i)
						EndIf
						$i += 1
					Next
					_add_to_selected($oParentCtrl)
					_populate_control_properties_gui($oParentCtrl, Dec($textHwnd))
				EndIf
			Else
				If $first Then    ;select first item
					$first = False
					_add_to_selected($oCtrl)
					_populate_control_properties_gui($oCtrl)
				Else    ;add to selection
					_add_to_selected($oCtrl, False)
				EndIf
			EndIf
		EndIf
		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
	Until $hItem = 0
EndFunc   ;==>_onLvObjectsItem


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsDelete
; Description.....: Delete selected
; Events..........: Del key
;------------------------------------------------------------------------------
Func _onLvObjectsDelete()
	_delete_selected_controls()
EndFunc   ;==>_onLvObjectsDelete


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsDeleteMenu
; Description.....: Delete selected
; Events..........: right-click context menu
;------------------------------------------------------------------------------
Func _onLvObjectsDeleteMenu()
	;WM_NOTIFY is called right before this, which selects the right-clicked control
	_delete_selected_controls()
EndFunc   ;==>_onLvObjectsDeleteMenu


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsTabItemDelete
; Description.....: Show Tab Item delete menu
; Events..........: right-click context menu
;------------------------------------------------------------------------------
Func _onLvObjectsTabItemDelete()
	ShowMenu($overlay_contextmenutab, $oMouse.X, $oMouse.Y)
EndFunc
#EndRegion events


;------------------------------------------------------------------------------
; Title...........: _formObjectExplorer_updateList
; Description.....: update list of objects
;------------------------------------------------------------------------------
Func _formObjectExplorer_updateList()
	If Not IsHWnd($hFormObjectExplorer) Then Return

	Local $count = $oCtrls.count
	Local $aList[$count]

	Local $lvItem, $lvMenu, $lvMenuDelete, $childItem, $tabMenu, $tabMenuDelete, $lvMenuNewTab, $lvMenuDeleteTab, $sName
	_GUICtrlTreeView_DeleteAll($lvObjects)
	For $oCtrl In $oCtrls.ctrls
		$sName = $oCtrl.Name
		If $sName = "" Then
			$sName = $oCtrl.Type & "*"
		EndIf

		$lvItem = GUICtrlCreateTreeViewItem($sName & "       " & @TAB & "(HWND: " & Hex($oCtrl.Hwnd) & ")", $lvObjects)
		GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

		$lvMenu = GUICtrlCreateContextMenu($lvItem)
		$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
		GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")

		If $oCtrl.Type = "Tab" Then
			$lvMenuNewTab = GUICtrlCreateMenuItem("New Tab", $lvMenu)
			$lvMenuDeleteTab = GUICtrlCreateMenuItem("Delete Tab", $lvMenu)
			GUICtrlSetOnEvent($lvMenuNewTab, "_new_tab")
			GUICtrlSetOnEvent($lvMenuDeleteTab, "_delete_tab")

			For $oTab In $oCtrl.Tabs
				$childItem = GUICtrlCreateTreeViewItem($oTab.Name & "       " & @TAB & "(HWND: " & Hex($oTab.Hwnd) & ")", $lvItem)
				GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

				$tabMenu = GUICtrlCreateContextMenu($childItem)
				$tabMenuDelete = GUICtrlCreateMenuItem("Delete Tab", $tabMenu)
				GUICtrlSetOnEvent($tabMenuDelete, "_delete_tab")

				_GUICtrlTreeView_Expand($lvObjects, $lvItem)
			Next
		EndIf
	Next

	If StringStripWS($count, $STR_STRIPALL) = "" Then $count = 0
	GUICtrlSetData($labelObjectCount, "Object Count: " & $count)
EndFunc   ;==>_formObjectExplorer_updateList
