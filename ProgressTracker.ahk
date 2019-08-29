; /// Progress Tracker ///
Codename=ProgressTracker
CurrentUser=%A_UserName% ;Placeholder for collaboration in the future
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force
#Include TrackerFunctions.ahk

FileCreateDir, %A_MyDocuments%\ProgressTracker
FileCreateDir, %A_MyDocuments%\ProgressTracker\DemoPrograms

ifNotExist, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini ;Verifies if the settings file exists
{
	Goto CreateSettingsIni
}
else
{
	Goto ReadSettingsIni
}

CreateSettingsIni: ;Creates the settings file
IniWrite, %CurrentSaveFile%, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
Goto ReadSettingsIni
return

ReadSettingsIni: ;Reads the settings file
IniRead, LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram

CurrentSaveFile=%LastOpenProgram% ; Set the Current Save File as the last opened one

Gui, ProgressMainScreen:New, HwndProgressMainScreen,Progress Tracker
Gui, Font, s11

Menu, FileMenu, Add, &New Program`tCtrl+N, MenuFileNew
Menu, FileMenu, Add, &Open Program`tCtrl+O, MenuFileOpen
Menu, FileMenu, Add, &Save Program`tCtrl+S, MenuFileSave
Menu, FileMenu, Add, Save Program As, MenuFileSaveAs
Menu, FileMenu, Add
Menu, FileMenu, Add, Settings, MenuSettings
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, GuiClose

Menu, NotesMenu, Add, Create a note, CreateNote
Menu, NotesMenu, Add, Open a note, OpenNoteMenu

Menu, RemindersMenu, Add, Create a Reminder, CreateReminder
Menu, RemindersMenu, Add, View Reminders, OpenReminderMenu

Menu, HelpMenu, Add, About, MenuAbout

Menu, MainMenuBar, Add, &File, :FileMenu
Menu, MainMenuBar, Add, &Notes, :NotesMenu
Menu, MainMenuBar, Add, &Reminders, :RemindersMenu
Menu, MainMenuBar, Add, &Help, :HelpMenu

Gui, Menu, MainMenuBar

Gui, Add, TreeView, gMainTreeView AltSubmit w240 r16
Gui, Add, Tab3, vDescriptionBox x13 w240 h200, Description|Properties
Gui, Add, Text,vMainDescriptionText w225 h125 x22 y337, Click on an item to view more
Gui, Tab, 2
Gui, Add, Text,vMainPropertiesText w225 h125 x22 y337, Click on an item to view more
Gui, Tab
Gui, Add, Tab3,+hide vTaskBox x265 y8 w550 h500, Tasks
Gui, Tab

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
;IniRead, TaskList, %CurrentSaveFile%, %TVItemName%, Tasks
TreeViewLoader(SavedProgramName,ProjectList,CurrentSaveFile)
Sleep 10
GuiControl,,MainDescriptionText, Double Click on an item to view more
GuiControl,,MainPropertiesText, Double Click on an item to view more
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

CreateNote:
return

OpenNoteMenu:
return

CreateReminder:
return

OpenReminderMenu:
return

MenuAbout:
MsgBox, %Codename%`nhttps://github.com/MeltedHeart/progress-tracker
return

MainTreeView:
If A_GuiEvent = RightClick
{
	if A_EventInfo = 0
	{
		Menu , ContextNewMenu , Add , New Project , NewProjectMenu
		Menu , ContextNewMenu , Show
	}
	else
	{
		Menu , ContextEditMenu , Add , Change Name , ChangeProjectName
		Menu , ContextEditMenu , Add , Change Description , ChangeProjectDescription
		Menu , ContextEditMenu , Add , Delete , DeleteProject
		Menu , ContextEditMenu , Show
	}
	return
}
Gui, Submit, NoHide
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
if TVItemName=""
{
	return
}
else
{
	IniRead, SelectedProjectDescription, %CurrentSaveFile%, %TVItemName%, ProjectDescription
	IniRead, SelectedProjectTitle, %CurrentSaveFile%, %TVItemName%, ProjectTitle
	;IniRead, SelectedProjectCreator, %CurrentSaveFile%, %TVItemName%, ProjectCreator //Placeholder for collaboration in the future
	IniRead, SelectedProjectDate, %CurrentSaveFile%, %TVItemName%, Date
	IniRead, SelectedProjectLastChange, %CurrentSaveFile%, %TVItemName%, LastChange
	GuiControl,,MainDescriptionText, %SelectedProjectDescription%
	GuiControl,,MainPropertiesText, Title: %SelectedProjectTitle%`nCreator: %CurrentUser%`nDate: %SelectedProjectDate%`nLast Change: %SelectedProjectLastChange%
	IniRead, TaskList, %CurrentSaveFile%, %TVItemName%, Tasks
	;TaskLoader(TaskList,CurrentSaveFile)
}
return

ChangeProjectDescription:
return
ChangeProjectName:
return
DeleteProject:
return
NewProjectMenu:
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