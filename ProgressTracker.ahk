; /// Progress Tracker ///
Codename=ProgressTracker
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force
#Include TrackerFunctions.ahk

FileCreateDir, %A_MyDocuments%\ProgressTracker
FileCreateDir, %A_MyDocuments%\ProgressTracker\DemoPrograms

ifNotExist, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini
{
	Goto CreateSettingsIni
}
else
{
	Goto ReadSettingsIni
}

CreateSettingsIni:
IniWrite, %CurrentSaveFile%, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
Goto ReadSettingsIni
return

ReadSettingsIni:
;MsgBox, Reading INI
IniRead, LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram

CurrentSaveFile=%LastOpenProgram%

Gui, ProgressMainScreen:New, HwndProgressMainScreen
Gui, Font, s11

Menu, FileMenu, Add, &New Program`tCtrl+N, MenuFileNew
Menu, FileMenu, Add, &Open Program`tCtrl+O, MenuFileOpen
Menu, FileMenu, Add, &Save Program`tCtrl+S, MenuFileSave
Menu, FileMenu, Add, Save Program As, MenuFileSaveAs
Menu, FileMenu, Add
Menu, FileMenu, Add, Settings, MenuSettings
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, GuiClose

Menu, HelpMenu, Add, About, MenuAbout

Menu, MainMenuBar, Add, &File, :FileMenu
;Menu, MainMenuBar, Add, Edit 
Menu, MainMenuBar, Add, &Help, :HelpMenu

Gui, Menu, MainMenuBar

Gui, Add, TreeView, gMainTreeView w230 r16
Gui, Add, GroupBox, w230 h150, Item Description
Gui, Add, Text,vMainDescriptionText w220 h125 x22 y330, Click on an item to view more
;Gui, Add, ListBox, r10 vProjectSelect, %ProjectList%
;Gui, Add, Button, Default, BOI

Gui, Show
Goto LoadSaveFile
return

MenuFileNew:
return

MenuFileOpen:
DisableAllGui()
DisableAllMenus()
MsgBox 52, Warning, All progress that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	EnableAllGui()
	EnableAllMenus()
	return
}
else
{
	DisableAllGui()
	DisableAllMenus()
	FileSelectFile, ProgramSave,,%A_MyDocuments%,Select a Program, *.ptp
	CurrentSaveFile=%ProgramSave%	
	Goto LoadSaveFile
	return
}

LoadSaveFile:
TV_Delete()
IniWrite, %CurrentSaveFile%, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
IniRead, ProgramDescription, %CurrentSaveFile%, ProgramInfo, ProgramDescription
IniRead, ProjectList, %CurrentSaveFile%, ProgramInfo, Projects
TreeViewLoader(SavedProgramName,ProjectList)
EnableAllGui()
EnableAllMenus()
return

MenuFileSave:
Gui, Submit, NoHide
return

MenuFileSaveAs:
DisableAllGui()
DisableAllMenus()
Gui, Submit, NoHide
FileSelectFile, ProgramSave,,%A_MyDocuments%,Select where to save this program, *.ptp
EnableAllGui()
EnableAllMenus()
return

MenuSettings:
return

MenuAbout:
MsgBox, %Codename%
return

MainTreeView:
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
IniRead, SelectedProjectDescription, %CurrentSaveFile%, %TVItemName%, ProjectDescription
GuiControl,,MainDescriptionText, %SelectedProjectDescription%
return

GuiClose:
MsgBox 52, Warning, All progress that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	return
}
else
{
	ExitApp
}