﻿; /// Progress Tracker ///
Codename=ProgressTracker
CurrentUser=%A_UserName% ;Placeholder for collaboration in the future
Temp_File=0 ; 
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force
#Include TrackerFunctions.ahk
#Include csv.ahk

FileCreateDir, %A_MyDocuments%\ProgressTracker
FileCreateDir, %A_MyDocuments%\ProgressTracker\DemoPrograms
FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData
FileCreateDir, %A_Temp%\ProgressTracker

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
IniWrite, %A_Temp%\ProgressTracker\New_File.ptp, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
IniWrite, 0, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewProjectCount
IniWrite, 0, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewTaskCount
Goto ReadSettingsIni
return

ReadSettingsIni: ;Reads the settings file
IniRead, LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
IniRead, NewProjectCount, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewCount
CurrentSaveFile=%LastOpenProgram% ; Set the Current Save File as the last opened one
; Creating the GUI
Gui, ProgressTracker:New,, Progress Tracker
Gui, ProgressTracker:Default
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

Gui, Add, TreeView, gMainTreeView vMainTreeView AltSubmit w240 r20
Gui, Add, Tab3, vDescriptionBox x13 w240 h200, Description|Properties
Gui, Add, Text,vMainDescriptionText w220 h125 , Click on an item to view more
Gui, Tab, 2
Gui, Add, Text,vMainPropertiesText w220 h125 , Click on an item to view more
Gui, Tab
Gui, Add, Tab3,+hide vTaskBox x265 y8 w610 h572, Info
Gui, Add, GroupBox, w580 h100, Current Progress
Gui, Add, GroupBox, w580 h258, Updates
Gui, Add, GroupBox, w580 h155, Notes and Reminders
Gui, Add, Progress, vProgressBar x300 y70 w540 h50, 1
Gui, Font, s9
Gui, Add, ListView, gUpdateListView vUpdateListView AltSubmit x290 y170 w210 h225, Title|`%|UCT|Date|File
LV_ModifyCol(1,80)
LV_ModifyCol(2,30)
LV_ModifyCol(3,0)
LV_ModifyCol(4,96)
LV_ModifyCol(5,0)
Gui, Font, s11
Gui, Add, Edit, vUpdateTitle x510 y170 w335 h20, Update Title
Gui, Add, Edit, vUpdateDescription x510 y200 w335 h160, Update Description
Gui, Add, Text,x510 y370, Progress
Gui, Add, Edit, vPercentEdit x570 y368 w50
Gui, Add, UpDown, vProgressAddPercent Range-100-100, 1 
Gui, Add, Text,x622 y370, `%
Gui, Add, Button,x700 y366 vTagsButton gTagsButton, Tags
Gui, Add, Button,x750 y366 vSaveUpdate gSaveUpdate , Save Update
Gui, Tab

Gui, Show
Goto LoadSaveFile ;Goes to LoadSaveFile so it has a file already open when the program starts
return

MenuFileNew:
GuiControl,,ProgressBar, 0
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
FileSelectFile, ProgramSave,S,%A_MyDocuments%\ProgressTracker\ProgramData,Select where to save this program, *.ptp
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
	if TV_Get(A_EventInfo, "Bold")
	{
		ProjectLoader()
	}
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
Gui, ProgressTracker:Default
Gui, Treeview, MainTreeView

return

ChangeProjectDescription:
return
ChangeProjectName:
return

DeleteProject:
Gui, ProgressTracker:Default
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
if TV_Get(TVItemID, "Bold")
{
	DeleteProject(TVItemName,CurrentSaveFile)
	Goto LoadSaveFile
}
if TVItemName = %SavedProgramName%
{
	MsgBox 16, Warning, You cannot delete a Program! 
}
else
{
	ToolTip, DeleteTask function
	TVItemParentID := TV_GetParent(TVItemID)
	TV_GetText(TVItemParentName, TVItemParentID)
	DeleteTask(TVItemParentName,TVItemName,CurrentSaveFile)
	Goto LoadSaveFile
}
return

NewProjectMenu:
Gui, ProgressTracker:Default
Gui, Treeview, MainTreeView
IniRead, NewProjectCount, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewProjectCount
IniRead, NewTaskCount, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewTaskCount
NewProjectCount+=1
NewTaskCount+=1
IniWrite, %NewProjectCount%, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewProjectCount
IniWrite, %NewTaskCount%, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewTaskCount
ProjectName=New Project %NewProjectCount%
IniRead, ProjectList, %CurrentSaveFile%, ProgramInfo, Projects
IniWrite, %ProjectList%|%ProjectName%, %CurrentSaveFile%, ProgramInfo, Projects
WriteNewProject(ProjectName,NewTaskCount,CurrentSaveFile)
Goto LoadSaveFile
return

UpdateListView:
if A_GuiEvent = Normal
{
	LV_GetText(UpdateFileName,A_EventInfo,5)
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IniRead, UpdateTitle, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%UpdateFileName%, UpdateInfo, UpdateTitle
	IniRead, UpdateDescription, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%UpdateFileName%, UpdateContent, UpdateDescription
	GuiControl,, UpdateTitle, %UpdateTitle%
	GuiControl,, UpdateDescription, %UpdateDescription%
}
return

TagsButton:
return
SaveUpdate:
return

F1::
ToolTip, DevTimeTestingArea
FormatTime, LocalTime,,M/d/yy h:mmtt
Clipboard = %A_Now%`,%LocalTime%
MsgBox, %A_Now%
ToolTip, 
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