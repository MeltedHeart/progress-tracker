; /// Progress Tracker ///
Codename=ProgressTracker
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force

FileCreateDir, %A_MyDocuments%\ProgressTracker
FileCreateDir, %A_MyDocuments%\ProgressTracker\DemoPrograms

;MsgBox, %A_MyDocuments% 

ifNotExist, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini
{
	Goto CreateSettingsIni
}
else
{
	Goto ReadSettingsIni
}

CreateSettingsIni:
MsgBox, No INI
return

ReadSettingsIni:
;MsgBox, Reading INI
IniRead, LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
IniRead, ProjectList, %LastOpenProgram%, ProgramInfo, Projects

Gui, ProgressMainScreen:New, HwndProgressMainScreen
Gui, Font, s12

Menu, FileMenu, Add, &Open Program`tCtrl+O, MenuFileOpen
Menu, FileMenu, Add, &Save Program`tCtrl+S, MenuFileSave
Menu, FileMenu, Add, Save Program As, MenuFileSaveAs
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, GuiClose

Menu, HelpMenu, Add, About, MenuAbout

Menu, MainMenuBar, Add, &File, :FileMenu
;Menu, MainMenuBar, Add, Edit 
Menu, MainMenuBar, Add, &Help, :HelpMenu

Gui, Menu, MainMenuBar

Gui, Add, ListBox, r10 vProjectSelect, %ProjectList%

Gui, Show
return

MenuFileOpen:
MsgBox 52, Warning, All progress that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	return
}
else
{
	FileSelectFile, ProgramSelect,,%A_MyDocuments%,Select a Program, *.ptp
	return
}

MenuFileSave:
Gui, Submit
return


MenuFileSaveAs:
Gui, Submit
FileSelectFile, ProgramSave,,%A_MyDocuments%,Select where to save this program, *.ptp
return

MenuAbout:
MsgBox, %Codename%
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