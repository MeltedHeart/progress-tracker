; /// Progress Tracker ///
Codename=ProgressTracker
CurrentUser=%A_UserName% ;Placeholder for collaboration in the future
Temp_File=0 ; 
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force
#Include TrackerFunctions.ahk

FileCreateDir, %A_MyDocuments%\ProgressTracker
FileCreateDir, %A_MyDocuments%\ProgressTracker\DemoPrograms
FileCreateDir, %A_temp%\ProgressTracker

ifNotExist, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini ;Verifies if the settings file exists
{
	Goto CreateSettingsIni
}
else
{
	Goto ReadSettingsIni
}

CreateSettingsIni: ;Creates the settings file
CurrentSaveFile=%A_temp%\ProgressTracker\New_File.ptp
CreateTempFile(CurrentSaveFile)
IniWrite, %A_temp%\ProgressTracker\New_File.ptp, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
Goto ReadSettingsIni
return

ReadSettingsIni: ;Reads the settings file
IniRead, LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
CurrentSaveFile=%LastOpenProgram% ; Set the Current Save File as the last opened one
; Creating the GUI
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

Gui, Add, TreeView, gMainTreeView AltSubmit w240 r20
Gui, Add, Tab3, vDescriptionBox x13 w240 h200, Description|Properties
Gui, Add, Text,vMainDescriptionText w220 h125 , Click on an item to view more
Gui, Tab, 2
Gui, Add, Text,vMainPropertiesText w220 h125 , Click on an item to view more
Gui, Tab
Gui, Add, Tab3,+hide vTaskBox x265 y8 w600 h572, Info
Gui, Add, GroupBox, w570 h100, Current Progress
Gui, Add, GroupBox, w570 h258, Updates
Gui, Add, GroupBox, w570 h155, Notes and Reminders
Gui, Add, Progress, vProgressBar x300 y70 w530 h50, 1
Gui, Add, ListView, vUpdateList x290 y170 w195 h225, Title|`%|Date
Gui, Add, Edit, vUpdateTitle x500 y170 w335 h20, Update Title
Gui, Add, Edit, vUpdateDescription x500 y200 w335 h160, Update Description
Gui, Add, Text,x500 y370, Progress
Gui, Add, Edit, vPercentEdit x560 y368 w50
Gui, Add, UpDown, vProgressAddPercent Range1-100, 1 
Gui, Add, Text,x612 y370, `%
Gui, Add, Button,x690 y366 vTagsButton gTagsButton, Tags
Gui, Add, Button,x740 y366 vSaveUpdate gSaveUpdate , Save Update
Gui, Tab

Gui, Show
Goto LoadSaveFile ;Goes to LoadSaveFile so it has a file already open when the program starts
return

MenuFileNew:
IniRead,LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram

;If ! CurrentSaveFile="" 
;{
	MsgBox,52,Confirm,  Your previous changes won�t be saved `, Are you sure?
	IfMsgBox Yes
	{
		CurrentSaveFile=%A_temp%\ProgressTracker\New_File.ptp
		CreateTempFile(CurrentSaveFile)
		Temp_File=1
		Goto LoadSaveFile
	}
	return
;}
;else
;{
;	CurrentSaveFile=%A_temp%\ProgressTracker\New_File.ptp
;	CreateTempFile(CurrentSaveFile)
;	Temp_File=1
;	Goto LoadSaveFile
;}

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
	EnableAllGui()
	EnableAllMenus()
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
Sleep 50
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
		Menu , ContextNewProjectMenu , Add , New Project , NewProjectMenu
		Menu , ContextNewProjectMenu , Show
		return
	}
	if TV_Get(A_EventInfo, "Bold")
	{
		Menu, ContextEditProjectMenu, Add, New Task, NewTaskMenu
		Menu, ContextEditProjectMenu, Add, Change Name , ChangeProjectName
		Menu, ContextEditProjectMenu, Add, Change Description , ChangeProjectDescription
		Menu, ContextEditProjectMenu, Add, Delete , DeleteProject
		Menu, ContextEditProjectMenu ,Show
		return
	}
	else
	{
		Menu , ContextEditTaskMenu , Add , Change Name , ChangeProjectName
		Menu , ContextEditTaskMenu , Add , Change Description , ChangeProjectDescription
		Menu , ContextEditTaskMenu , Add , Delete , DeleteProject
		Menu , ContextEditTaskMenu , Show
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
	if ! TV_Get(A_EventInfo, "Bold")
	{
		TVItemID := TV_GetSelection()
		TaskParent := TV_GetParent(TVItemID)
		TV_GetText(TVItemTaskName,TaskParent)
		IniRead, TaskList, %CurrentSaveFile%, %TVItemTaskName%, Tasks
		TaskLoader(TVItemName,TVItemTaskName,TaskList,CurrentSaveFile)
	}
	;if TV_Get(A_EventInfo, "Bold")
	;{
	;	Placeholder to fix reading overall progress from projects
	;}
	if SelectedProjectDescription=ERROR
	{
		return
	}
	else
	GuiControl,,MainDescriptionText, %SelectedProjectDescription%
	GuiControl,,MainPropertiesText, Title: %SelectedProjectTitle%`nCreator: %CurrentUser%`nDate: %SelectedProjectDate%`nLast Change: %SelectedProjectLastChange%
}
return

NewTaskMenu:
return
ChangeProjectDescription:
return
ChangeProjectName:
return
DeleteProject:
return
NewProjectMenu:
return
TagsButton:
return
SaveUpdate:
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