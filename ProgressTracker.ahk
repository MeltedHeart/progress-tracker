; /// Progress Tracker ///
Codename=ProgressTracker
CurrentUser=%A_UserName% ;Placeholder for collaboration in the future
Temp_File=0 ; Check to see if the current file is a temp file
SaveLocation=%A_MyDocuments%\ProgressTracker\ProgramData ; Default save location
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
CreateNewFile("New File",CurrentSaveFile)
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
Gui, Add, Edit, vPercentEdit ReadOnly x570 y368 w50
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
MsgBox,52,Confirm,  All progress that has not been saved will be lost `, Are you sure?
IfMsgBox Yes
{
	InputBox, NewFileName, New File, Choose a name for the new file,,210,125
	if ErrorLevel = 1
	{
		return
	}
	;CurrentSaveFile=%A_temp%\ProgressTracker\New_File.ptp
	if NewFileName =
	{
		MsgBox 16, Warning, Item Name cannot be empty!
		return
	}
	CreateNewFile(NewFileName,SaveLocation)
	CurrentSaveFile=%A_MyDocuments%\ProgressTracker\ProgramData\%NewFileName%\%NewFileName%.ptp
	Temp_File=1
	Goto LoadSaveFile
}
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
	EnableAllGui()
	EnableAllMenus()
	FileSelectFile, ProgramSave,,%A_MyDocuments%\ProgressTracker\ProgramData,Select a Program, *.ptp
	if ErrorLevel
	{
		return
	}
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
		Menu, ContextEditProjectMenu, Add, Change Name , ChangeName
		Menu, ContextEditProjectMenu, Add, Change Description , ChangeDescription
		Menu, ContextEditProjectMenu, Add, Delete , DeleteProject
		Menu, ContextEditProjectMenu ,Show
		return
	}
	else
	{
		Menu , ContextEditTaskMenu , Add , Change Name , ChangeName
		Menu , ContextEditTaskMenu , Add , Change Description , ChangeDescription
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
		ProjectLoader(TVItemName,CurrentSaveFile)
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
IniRead, NewTaskCount, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewTaskCount
NewTaskCount+=1
IniWrite, %NewTaskCount%, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewTaskCount
TaskName=New Task %NewTaskCount%
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
IniRead, TaskList, %CurrentSaveFile%, %TVItemName%, Tasks
IniWrite, %TaskList%|%TaskName%, %CurrentSaveFile%, %TVItemName%, Tasks
WriteNewTask(TaskName,TVItemName,CurrentSaveFile)
Goto LoadSaveFile
return

ChangeDescription:
Gui, ProgressTracker:Default
Gui, Treeview, MainTreeView
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
TVItemParentID := TV_GetParent(TVItemID)
TV_GetText(TVItemParentName, TVItemParentID)
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
if TV_Get(TVItemID, "Bold")
{
	IniRead, CurrentProjectDescription, %CurrentSaveFile%, %TVItemName%, ProjectDescription
	Gui, ChangeProjectDescription:New, ToolWindow, Change Description
	Gui, Add, Edit,vProjectDescriptionText h120 w250, %CurrentProjectDescription%
	Gui, Add, Button,gSaveProjectDescription w250,Save Description
	Gui, Show
	return
}
if SavedProgramName = %TVItemName%
{
	IniRead, CurrentProgramDescription, %CurrentSaveFile%, %TVItemName%, ProjectDescription
	Gui, ChangeProgramDescription:New, ToolWindow, Change Description
	Gui, Add, Edit,vProgramDescriptionText h120 w250, %CurrentProgramDescription%
	Gui, Add, Button,gSaveProgramDescription w250,Save Description
	Gui, Show
	return
}
else
{
	IniRead, TaskList, %CurrentSaveFile%, %TVItemParentName%, Tasks
	Loop, Parse, TaskList, `|
	{
		if A_LoopField = %TVItemName%
		{
			TaskNumber = %A_Index%
		}
	}
	IniRead, CurrentTaskDescription, %CurrentSaveFile%, %TVItemParentName%, TaskDescription%TaskNumber%
	Gui, ChangeTaskDescription:New, ToolWindow, Change Description
	Gui, Add, Edit,vTaskDescriptionText h120 w250, %CurrentTaskDescription%
	Gui, Add, Button,gSaveTaskDescription w250,Save Description
	Gui, Show
	return
}
return

SaveProjectDescription:
Gui, Submit
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
TVItemParentID := TV_GetParent(TVItemID)
TV_GetText(TVItemParentName, TVItemParentID)
IniWrite, %ProjectDescriptionText%, %CurrentSaveFile%, %TVItemName%, ProjectDescription
Sleep 100
TV_Modify(TVItemID, Select)
return

SaveProgramDescription:
Gui, Submit
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
TVItemParentID := TV_GetParent(TVItemID)
TV_GetText(TVItemParentName, TVItemParentID)
IniWrite, %ProgramDescriptionText%, %CurrentSaveFile%, %TVItemName%, ProjectDescription
Sleep 100
TV_Modify(TVItemID, Select)
return

SaveTaskDescription:
Gui, Submit
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
TVItemParentID := TV_GetParent(TVItemID)
TV_GetText(TVItemParentName, TVItemParentID)
IniWrite, %TaskDescriptionText%, %CurrentSaveFile%, %TVItemParentName%, TaskDescription%TaskNumber%
Sleep 100
TV_Modify(TVItemID, Select)
return

ChangeName:
Gui, ProgressTracker:Default
Gui, Treeview, MainTreeView
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
TVItemParentID := TV_GetParent(TVItemID)
TV_GetText(TVItemParentName, TVItemParentID)
if TV_Get(TVItemID, "Bold")
{
	ChangeName(TVItemName,TVItemParentName,CurrentSaveFile,0)
	Goto LoadSaveFile
}
if TVItemName = %SavedProgramName% 
{
	ChangeName(TVItemName,TVItemParentName,CurrentSaveFile,2)
	Goto LoadSaveFile 
}
else
{
	ChangeName(TVItemName,TVItemParentName,CurrentSaveFile,1)
	Goto LoadSaveFile
}
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
if TV_GetCount() = 1
{
	IniWrite, %ProjectName%, %CurrentSaveFile%, ProgramInfo, Projects
}
else
{
	IniWrite, %ProjectList%|%ProjectName%, %CurrentSaveFile%, ProgramInfo, Projects
}
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
	if UpdateTitle = ERROR
	{
		GuiControl,, UpdateTitle, Update Title
		GuiControl,, UpdateDescription, Update Description
	}
	else
	{
		GuiControl,, UpdateTitle, %UpdateTitle%
		GuiControl,, UpdateDescription, %UpdateDescription%
	}
}
return

TagsButton:
return

SaveUpdate:
gui, Submit, NoHide
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
FormatTime, LocalTime,,M/d/yy h:mmtt
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
TVItemParentID := TV_GetParent(TVItemID)
TV_GetText(TVItemParentName, TVItemParentID)
if UpdateTitle =
{
	MsgBox 16, Warning, Update Name cannot be empty!
	return
}
if UpdateDescription =
{
	MsgBox 16, Warning, Update Description cannot be empty!
	return
}
StringLower, TVItemName, TVItemName
BonelessItemName := StrReplace(TVItemName,"",,0)
CurrentUpdateCount := LV_GetCount()
CurrentUpdateCount += 1
UpdateFile = %BonelessItemName%-up%CurrentUpdateCount%.ptu
FullUpdateFile=%MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%BonelessItemName%-up%CurrentUpdateCount%.ptu
FileAppend, %UpdateTitle%`, %ProgressAddPercent%`, %A_Now%`, %LocalTime%`, %UpdateFile%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TVItemName%.ptl
IniRead, TaskList, %CurrentSaveFile%, %TVItemParentName%, Tasks
Loop, Parse, TaskList, `|
{
	if A_LoopField = %TVItemName%
	{
		TaskNumber = %A_Index%
	}
}
IniWrite, %ProgressAddPercent%, %CurrentSaveFile%, %TVItemParentName%, ProgressTracker%TaskNumber%
WriteUpdate(UpdateTitle,UpdateDescription,UpdateTags,FullUpdateFile)
;RefreshUpdateList()
return

F1::
Gui, ProgressTracker:Default
Gui, Treeview, MainTreeView
TreeViewItemCount := TV_GetCount()
MsgBox, %TreeViewItemCount%
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