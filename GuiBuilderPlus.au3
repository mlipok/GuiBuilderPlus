; #HEADER# ======================================================================================================================
; Title .........: GUIBuilderPlus
; AutoIt Version : 3.3.16.0
; Description ...: Build GUI with GUI based heavily on GuiBuilderNxt
;
; Remarks .......:
;
; Author(s) .....: 	- kurtykurtyboy updates to create GUIBuilderPlus based on GUIBuilderNxt ( May 8, 2022 )
;
;
; Credit(s) .....: 	- jaberwacky: updates to create GUIBuilderNxt ( August 17, 2016 )
;					- CyberSlug, Roy, TheSaint, and many others: created/enhanced the original AutoBuilder/GUIBuilder
;
; Revisions
;  06/02/2022 ...: 	- FIXED:	Array subscript error when closing tool windows.
;					- FIXED:	Multiple selection while holding Ctrl key now works properly.
;					- FIXED:	Save/load GUI height with menus
;					- ADDED:	Show grippies on each selected control! Each control object now has a built-in crippy object
;					- ADDED:	Menu items can not be added and removed from the object explorer only
;					- REMOVED:	Prompt to save to au3 file. User can always use File menu to save/export
;					- UPDATED:	modified the About dialog text for a more detailed description and naming history
;					- MAINT:	cleaned up more global variables
;					- MAINT:	made control selection much more robust and consistent
;
;  05/23/2022 ...: 	- ADDED:	Now you can set properties for the main GUI!
;					- ADDED:	Added file menu item "Export to au3" for a more convenient and obvious way to save the generated code
;					- ADDED:	Keyboard shortcuts to save to (Ctrl+S) or load from (Ctrl+O) definition file
;					- ADDED:	Keyboard shortcut (Ctrl+A) and edit menu item to select all controls
;					- ADDED:	Save window positions
;					- ADDED:	Started implementation of main menu controls (no menu items yet)
;					- ADDED:	Setting to generate code using OnEvent mode or Msg mode
;					- ADDED:	Move control's creation order up or down the tree
;					- ADDED:	Selecting a control will also highlight it in the object explorer (single select only, for now)
;					- FIXED:	Wrong GUI width and height displayed in the titlebar at startup
;					- FIXED:	Control names not applied when loading from agd definition file
;					- FIXED:	Text looked slightly different in design vs runtime
;					- FIXED:	Property Inspector window did not minimize/restore with the main GUI
;					- FIXED:	Inconsistencies with displayed vs saved vs loaded GUI sizes
;					- FIXED:	Controls not cleared when re-loading agd file
;					- FIXED:	Sanitized some of the property inputs for invalid entry or removal (ex: -1 or "")
;					- UPDATE:	More code generation improvements
;
;  05/19/2022 ...: 	- UPDATE:	Converted maps to objects using AutoItObject UDF
;					- UPDATE:	Changed to new style of property inspector using GUIScrollBars_Ex UDF by Melba23
;					- FIXED:	Better handling in Object Explorer for controls with no name
;					- FIXED:	Delete certain tab items caused a program crash
;					- FIXED:	Pasted control was offset from mouse position
;					- FIXED:	Paste from Edit menu pasted off-screen, now pastes offset from copied control
;					- ADDED:	Added setting to apply a DPI scaling factor to the size and position properties (includes function to get DPI factor)
;					- ADDED:	Added 'New Tab' and 'Delete Tab' items in Object Explorer right-click context menu
;					- MAINT:	Cleaned up old commented-out code
;					- KNOWN ISSUE: Property tabs other than 'Main' are temporarily removed
;
;  05/13/2022 ...: 	- FIXED:	Tab control not showing when grid is on
;					- FIXED:	Tab control and tab item creation now should work properly
;					- FIXED:	Right-click menu deletes wrong item
;					- FIXED:	Right-click context menu showing wrong/duplicate items
;					- FIXED:	Fixed crash when changing properties of multiple controls at once (now works great for aligning controls!)
;					- FIXED:	Text and name properties were limited to only the characters that could fit in the box
;					- FIXED:	Spaces in Name property will now be replaced with underscores _
;					- ADDED:	New tab and delete tab context menu items
;					- ADDED:	Text color property for labels (works on multiple selection)
;					- ADDED:	Background color property for labels (works on multiple selection)
;					- ADDED:	New statusbar to show messages instead of popups and splash screens
;					- UPDATED:	Better positioning of extra tool windows
;					- UPDATED:	Arrow keys will now "nudge" the controls by 1 px, Ctrl+arrow key will move the controls by 10px
;					- UPDATED:	Copy+Paste should not change the control text
;					- UPDATED:	Changed object explorer from listview to treeview to show tab items
;					- KNOWN ISSUE:	Deleting a Tab control also deletes the property inspector!
;
;  05/11/2022 ...: 	- FIXED: object explorer and code viewer not updated after .agd load
;					- FIXED: object explorer not updated after copy/paste
;					- FIXED: properties not disabled after finish drawing (also caused property crash)
;					- FIXED: All "Main" properties now function properly - other tabs still not implemented yet (will most likely crash)
;					- FIXED: skipped mouse click after closing one of the tool windows
;					- FIXED: Drag move of selection broken after last update
;					- ADDED: Copy menu item (edit menu)
;					- ADDED: Paste menu item (edit menu)
;					- ADDED: Duplicate menu item (edit menu or Ctrl+D) <- copy+paste with offset (try it and see)
;					- ADDED: Minimize/restore the program
;					- ADDED: Increase/decrease properties with arrow keys or mouse scroll
;					- ADDED: Keyboard shortcut (F5) to run/test the form
;					- ADDED: First pass at function description template (insert comment for function title based on template file)
;					- UPDATED: Changed the look of the properties inspector (still a work in progress)
;					- UPDATED: Changed icon to be more in line with original GuiBuilder
;					- UPDATED: Modified code generation to cleaner layout (in my opinion)
;					- UPDATED: Modified test function to use _TempFile()
;					- REMOVED: Vals menu item (edit menu) - superseded by new object explorer
;
;  05/10/2022 ...: 	- ADDED: Object Explorer window to display the list of objects (view, select, and delete from list)
;					- ADDED: Last tool stays selected for multiple creation. Clicking away stops drawing.
;					- ADDED: "_" back for default control names
;					- FIXED: Issue with controls getting mixed up after deleting
;					- FIXED: More intuitive/responsive clicking on and away from controls
;					- FIXED: Graphic glitch when creating a new combobox
;					- FIXED: Graphic glitch when clearing all controls
;					- FIXED: Updown control invalid generated code
;					- FIXED: Weird selection behavior when Updown control exists
;					- FIXED: Pic control not showing the bitmap on drawing or generated GUI
;					- FIXED: View Code dialog state not saved when clicking close[X] button
;					- Other: Changed default text from Button1 to Button 1 (space)
;
;  05/08/2022 ...: 	- FIXED BUG: last control was always selected and moved after resizing or moving the GUI
;					- FIXED BUG: minor formatting issues with generated GUICtrlCreate function names
;					- FIXED BUG: crash/failure when dragging .adb definition file onto compiled exe
;					- FIXED BUG: cannot properly change text or name properties
;					- FIXED BUG(?): generated code did not match control names in the properties toolbar
;					- FIXED BUG: if ini directory did not exist, could not write to ini file
;					- ADDED: Live Generated Code dialog to view/save the generated code (View menu)
;					- ADDED: Test GUI to preview the GUI (Tools menu)
;					- ADDED: Nudge controls by 1 pixel (or nearest grid space) with arrow keys
;					- ADDED: Keyboard shortcut to turn grid on/off
;					- ADDED: Keyboard shortcut to turn grid snap on/off
;					- More efficient INI file reading
;					- New program icon
;					- Removed MouseOnEvent UDF for now, causing crashes when clicking on anything - didn't want to investigate
;					- Updated/cleaned up AutoIt3Wrapper options
;					- Fixed some Local Const declaration issues
;					- Fixed 'state' tab vertical spacing
;					- Tidy'd code
;					- Started organizing code, breaking up into manageable chunks
;					- Started reigning in the sporadic use of Global/local variables
;					- Started documenting functions
;					- Removed/updated some antiquated references and functions
;					- Updated to latest StringSize UDF
;
; Roadmap .......:	- Add option to make GUI in separate function
;					- Add options for declaring controls as global or local
;					- Support for Msg or OnEvent mode attached to controls
;					- Add IP control
;					- Add control alignment buttons (left, right, top, bottom)
;					- Finish control properties tabs
;					- creating controls on top of TAB will place them inside the tab
;					- creating controls on top of GROUP will place them inside the group
;					- Undo / Redo functionality
;					- Finish menu controls
;
; Known Issues ..:	- State, style, and ex style properties not implemented yet
;					- Menu control not implemented yet
; ===============================================================================================================================

#Region project-settings
#AutoIt3Wrapper_Res_HiDpi=y
#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Icon=resources\icons\icon.ico
#AutoIt3Wrapper_OutFile=GUIBuilderPlus v0.25.exe
#AutoIt3Wrapper_Res_Fileversion=0.25.0.0
#AutoIt3Wrapper_Res_Description=GUI Builder Plus

Opt("WinTitleMatchMode", 4) ; advanced
Opt("MouseCoordMode", 2)
Opt("GUIOnEventMode", 1)
Opt("GuiEventOptions", 1)
#EndRegion project-settings

Global $grippy_size = 5
#Region ; globals
;GUI components
Global $hGUI, $hToolbar, $hFormGenerateCode, $hFormObjectExplorer, $hStatusbar, $hAbout
Global $iGuiFrameH, $iGuiFrameW, $defaultGuiBkColor = 0xF0F0F0
Global $menu_wipe
;Settings menu
Global $menu_show_grid, $menu_grid_snap, $menu_paste_pos, $menu_show_ctrl, $menu_show_hidden, $menu_dpi_scaling, $menu_gui_function, $menu_onEvent_mode
;View menu
Global $menu_generateCode, $menu_ObjectExplorer
;Background
Global $background, $background_contextmenu, $background_contextmenu_paste
Global $overlay, $overlay_contextmenu, $overlay_contextmenutab
;grippys
;~ Global $NorthWest_Grippy, $North_Grippy, $NorthEast_Grippy, $West_Grippy, $East_Grippy, $SouthWest_Grippy, $South_Grippy, $SouthEast_Grippy
;code generation popup
Global $editCodeGeneration
;object explorer popup
Global $lvObjects, $labelObjectCount, $childSelected

;Property Inspector
Global $oProperties_Main, $oProperties_Ctrls

;GUI Constants
Global Const $grid_ticks = 10
Global Const $iconset = @ScriptDir & "\resources\Icons\" ; Added by: TheSaint
Global Enum $mode_default, $mode_draw, $mode_init_move, $mode_init_selection, _
		$resize_nw, $resize_n, $resize_ne, $resize_e, $resize_se, $resize_s, $resize_sw, $resize_w
Global Enum $props_Main, $props_Ctrls
; Cursor Consts - added by: Jaberwacky
Global Const $ARROW = 2, $CROSS = 3, $SIZE_ALL = 9, $SIZENESW = 10, $SIZENS = 11, $SIZENWSE = 12, $SIZEWS = 13


;other variables
Global $bStatusNewMessage
Global $right_click = False
Global $left_click = False
Global $bResizedFlag
Global $testFileName, $TestFilePID = 0, $bReTest = 0, $aTestGuiPos, $hTestGui
Global $au3InstallPath = @ProgramFilesDir & "\AutoIt3\AutoIt3.exe"
Global $initDraw, $initResize

;Control Objects
Global $oMain, $oCtrls, $oSelected, $oClipboard, $oMouse

; added by: TheSaint (most are my own, others just not declared)
Global $AgdOutFile, $lfld, $mygui
Global $setting_snap_grid, $setting_paste_pos, $setting_show_control, $setting_show_hidden, $setting_dpi_scaling, $setting_gui_function, $setting_onEvent_mode

Global $sampleavi = @ScriptDir & "\resources\sampleAVI.avi"
Global $samplebmp = @ScriptDir & "\resources\SampleImage.bmp"
Global $sIniPath = @ScriptDir & "\storage\GUIBuilderPlus.ini"
#EndRegion ; globals

#Region ; includes
#include "UDFs\AutoItObject.au3"
#include "UDFs\oLinkedList.au3"
_AutoItObject_StartUp()

#include <Array.au3>
#include <AVIConstants.au3>
#include <ButtonConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <FontConstants.au3>
#include <GuiConstantsEx.au3>
#include <GuiTab.au3>
#include <GuiListView.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <StaticConstants.au3>
#include <ListViewConstants.au3>
#include <TreeViewConstants.au3>
#include <UpDownConstants.au3>
#include <File.au3>
#include <WinAPI.au3>
#include <WinAPIMisc.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <WinAPIvkeysConstants.au3>
#include <GuiMenu.au3>
#include <GuiEdit.au3>
#include <GuiTreeView.au3>
#include "UDFS\GUIScrollbars_Ex.au3"
#include "UDFs\StringSize.au3"
#include "GuiBuilderPlus_objCtrl.au3"
#include "GuiBuilderPlus_objProperties.au3"
#include "GuiBuilderPlus_CtrlMgmt.au3"
#include "GuiBuilderPlus_definitionMgmt.au3"
#include "GuiBuilderPlus_codeGeneration.au3"
#include "GuiBuilderPlus_formMain.au3"
#include "GuiBuilderPlus_formPropertyInspector.au3"
#include "GuiBuilderPlus_formGenerateCode.au3"
#include "GuiBuilderPlus_formObjectExplorer.au3"
#EndRegion ; includes


;run the main loop
_main()


;------------------------------------------------------------------------------
; Title...........: _main
; Description.....: Create the main GUI and run the main program loop.
;------------------------------------------------------------------------------
Func _main()
	;create the main program data objects
	$oMouse = _objCreateMouse()
	$oCtrls = _objCtrls()
	$oCtrls.mode = $mode_default
	$oSelected = _objCtrls(True)
	$oClipboard = _objCtrls()
	$oMain = _objMain()
	$oMain.AppName = "GuiBuilderPlus"
	$oMain.AppVersion = "0.25"
	$oMain.Title = StringTrimRight(StringTrimLeft(_get_script_title(), 1), 1)
	$oMain.Name = "hGUI"
	$oMain.Width = 400
	$oMain.Height = 350
	$oMain.Left = -1
	$oMain.Top = -1
	$oMain.Background = ""

	;create properties objects
	$oProperties_Main = _objProperties()
	$oProperties_Ctrls = _objProperties()

	;make the main program GUI
	_formMain()

	;make the toolbar/properties GUI
	_formToolbar()

	_set_accelerators()

	;check if ran with parameters to load definition file
	_check_command_line()

	_initialize_settings()

	GUISetState(@SW_SHOWNORMAL, $hToolbar)
	GUISetState(@SW_SHOWNORMAL, $oProperties_Main.Hwnd)
	GUISwitch($hGUI)
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	$bResizedFlag = 0

	;load the extra toolbars
	If BitAND(GUICtrlRead($menu_ObjectExplorer), $GUI_CHECKED) = $GUI_CHECKED Then
		_formObjectExplorer()
	EndIf

	If BitAND(GUICtrlRead($menu_generateCode), $GUI_CHECKED) = $GUI_CHECKED Then
		_formGenerateCode()
	EndIf


	Local $statusDelay = 3000
	Static $startTimer = False
	Do
		If $bStatusNewMessage Then
			$tStatusbarTimer = TimerInit()
			$bStatusNewMessage = False
			$startTimer = True
		EndIf
		If $startTimer = True And TimerDiff($tStatusbarTimer) > $statusDelay Then
			_GUICtrlStatusBar_SetText($hStatusbar, "")
			$startTimer = False
		EndIf
		If $TestFilePID <> 0 Then
			If Not ProcessExists($TestFilePID) Then
				$TestFilePID = 0
				If $bReTest Then
					$bReTest = 0
					_onTestGUI()
				Else
					FileDelete($testFileName)
				EndIf
;~ 			Else
;~ 				$aTestGuiPos = WinGetPos(_WinGetByPID($TestFilePID))
			EndIf
		EndIf

		_GUIScrollbars_EventMonitor()

		Sleep(100)
	Until False
EndFunc   ;==>_main


#Region functions
;------------------------------------------------------------------------------
; Title...........: _check_command_line
; Description.....: Load .agd file from cmdLine parameters (or drag onto exe)
; Author..........:	TheSaint
;------------------------------------------------------------------------------
Func _check_command_line()
	If $CmdLine[0] > 0 Then
		If StringRight($CmdLine[1], 4) = ".agd" Then
			Local $AgdInfile = FileGetLongName($CmdLine[1])
			_load_gui_definition($AgdInfile)
		EndIf
	EndIf
EndFunc   ;==>_check_command_line


;------------------------------------------------------------------------------
; Title...........: _get_script_title
; Description.....: Get/create the script title
;------------------------------------------------------------------------------
Func _get_script_title()
	Local $AgdInfile = ""
	If $CmdLine[0] > 0 Then
		If StringRight($CmdLine[1], 4) = ".agd" Then
			$AgdInfile = FileGetLongName($CmdLine[1])
		EndIf
	EndIf

	Local $gdtitle
	If $AgdOutFile <> "" Then
		$gdtitle = $AgdOutFile
	ElseIf $AgdInfile = "" Then
		$gdtitle = $AgdInfile
	Else
		$gdtitle = WinGetTitle("classname=SciTEWindow", "")
	EndIf

	If $gdtitle <> "" Then
		Local $gdvar = StringSplit($gdtitle, "\")

		$lfld = StringLeft($gdtitle, StringInStr($gdtitle, $gdvar[$gdvar[0]]) - 2)

		$gdtitle = $gdvar[$gdvar[0]]

		If $AgdInfile = "" Then
			$gdvar = StringInStr($gdtitle, ".au3")
		Else
			$gdvar = StringInStr($gdtitle, ".agd")
		EndIf

		$gdtitle = StringLeft($gdtitle, $gdvar - 1)
	Else
		$gdtitle = "MyGUI"
	EndIf

	$mygui = $gdtitle & ".au3"

	$gdtitle = '"' & $gdtitle & '"'
	Return $gdtitle
EndFunc   ;==>_get_script_title


;------------------------------------------------------------------------------
; Title...........: _initialize_settings
; Description.....: Read and initialize INI file settings
;------------------------------------------------------------------------------
Func _initialize_settings()
;~ 	_disable_control_properties_gui()

	Local $bShowGrid = True
	Local $bPastePos = True
	Local $bGridSnap = True
	Local $bShowControl = True
	Local $bShowHidden = False
	Local $bShowCode = False
	Local $bShowObjectExplorer = False
	Local $bDpiScaling = False
	Local $bGuiFunction = False
	Local $bOnEventMode = False

	Local $aSettings = IniReadSection($sIniPath, "Settings")
	If Not @error Then
		For $i = 1 To $aSettings[0][0]
			Switch $aSettings[$i][0]
				Case "ShowGrid"
					$bShowGrid = ($aSettings[$i][1] = 1) ? True : False
				Case "PastePos"
					$bPastePos = ($aSettings[$i][1] = 1) ? True : False
				Case "GridSnap"
					$bGridSnap = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowControl"
					$bShowControl = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowHidden"
					$bShowHidden = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowCode"
					$bShowCode = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowObjectExplorer"
					$bShowObjectExplorer = ($aSettings[$i][1] = 1) ? True : False
				Case "DpiScaling"
					$bDpiScaling = ($aSettings[$i][1] = 1) ? True : False
				Case "GuiInFunction"
					$bGuiFunction = ($aSettings[$i][1] = 1) ? True : False
				Case "OnEventMode"
					$bOnEventMode = ($aSettings[$i][1] = 1) ? True : False
			EndSwitch
		Next
	EndIf

	If $bShowGrid Then
		_show_grid($background, $oMain.Width, $oMain.Height)
	Else
		_hide_grid($background)
	EndIf
	_setting_show_grid(True, $bShowGrid)

	_setCheckedState($menu_show_grid, $bShowGrid)
	_setCheckedState($menu_paste_pos, $bPastePos)
	_setCheckedState($menu_grid_snap, $bGridSnap)
	_setCheckedState($menu_show_ctrl, $bShowControl)
	_setCheckedState($menu_show_hidden, $bShowHidden)
	_setCheckedState($menu_generateCode, $bShowCode)
	_setCheckedState($menu_ObjectExplorer, $bShowObjectExplorer)
	_setCheckedState($menu_dpi_scaling, $bDpiScaling)
	_setCheckedState($menu_onEvent_mode, $bOnEventMode)
;~ 	_setCheckedState($menu_gui_function, $bGuiFunction)

	$setting_paste_pos = $bPastePos
	$setting_snap_grid = $bGridSnap
	$setting_show_control = $bShowControl
	$setting_show_hidden = $bShowHidden
	$setting_dpi_scaling = $bDpiScaling
	$setting_onEvent_mode = $bOnEventMode
	$setting_gui_function = $bGuiFunction

	If Not FileExists("storage") Then
		DirCreate("storage")
	EndIf
EndFunc   ;==>_initialize_settings


;------------------------------------------------------------------------------
; Title...........: _setCheckedState
; Description.....: Set control checked state from BOOL/INT
;------------------------------------------------------------------------------
Func _setCheckedState($ctrlID, $bState)
	If $bState Then
		GUICtrlSetState($ctrlID, $GUI_CHECKED)
	Else
		GUICtrlSetState($ctrlID, $GUI_UNCHECKED)
	EndIf
EndFunc   ;==>_setCheckedState
#EndRegion functions


Func _objCreateMouse()
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "X", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Y", $ELSCOPE_PUBLIC, 0)

	Return $oSelf
EndFunc   ;==>_objCreateMouse
