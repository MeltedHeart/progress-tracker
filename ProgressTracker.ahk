﻿; /// Progress Tracker ///
Codename=ProgressTracker
CurrentUser=%A_UserName% ;Placeholder for collaboration in the future
Temp_File=0 ; Check to see if the current file is a temp file
SaveLocation=%A_MyDocuments%\ProgressTracker\ProgramData ; Default save location
MyDocumentsDataPath=%A_MyDocuments%\ProgressTracker
FormatTime, LocalTime,,ShortDate
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force
#Include TrackerFunctions.ahk
#Include csv.ahk
#Include Class_RichEdit.ahk

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
Menu, FileMenu, Add, Save Program &As, MenuFileSaveAs
Menu, FileMenu, Add
Menu, FileMenu, Add, &Settings, MenuSettings
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, GuiClose

Menu, NotesMenu, Add, &Create a Note, CreateNote
Menu, NotesMenu, Add, &View Notes, OpenNoteMenu

Menu, RemindersMenu, Add, &Create a Reminder, CreateReminder
Menu, RemindersMenu, Add, &View Reminders, OpenReminderMenu

Menu, OtherMenu, Add, Save a &Link`tCtrl+L, SaveLink
Menu, OtherMenu, Add, Attach a &File`tCtrl+F, AttachFile
Menu, OtherMenu, Add, Open Tags Menu, OpenTags
Menu, OtherMenu, Add, Save Pictures when detected, SavePictures

Menu, HelpMenu, Add, About, MenuAbout

Menu, MainMenuBar, Add, &File, :FileMenu
Menu, MainMenuBar, Add, &Notes, :NotesMenu
Menu, MainMenuBar, Add, &Reminders, :RemindersMenu
Menu, MainMenuBar, Add, &Other, :OtherMenu
Menu, MainMenuBar, Add, &Help, :HelpMenu

Gui, Menu, MainMenuBar

Gui, Add, TreeView, gMainTreeView vMainTreeView AltSubmit w240 r24
Gui, Add, Tab3, vDescriptionBox x13 w240 h200, Description|Properties
Gui, Add, Text,vMainDescriptionText w220 h125 , Click on an item to view more
Gui, Tab, 2
Gui, Add, Text,vMainPropertiesText w220 h125 , Click on an item to view more
Gui, Tab
Gui, Add, Tab3,+hide vTaskBox x265 y8 w630 h645, Info
Gui, Add, GroupBox, w600 h100, Current Progress
Gui, Add, GroupBox, w600 h258, Updates
Gui, Add, GroupBox, w195 h225, Notes
Gui, Add, GroupBox, x485 y415 w190 h225, Reminders
Gui, Add, GroupBox, x685 y415 w195 h225, Other
Gui, Add, Progress, vProgressBar x300 y70 w560 h50, 1
Gui, Font, s9
Gui, Add, ListView, gUpdateListView vUpdateListView AltSubmit x290 y170 w235 h225, Title|`%|UCT|Date|File
LV_ModifyCol(1,102)
LV_ModifyCol(2,27)
LV_ModifyCol(3,0)
LV_ModifyCol(4,102)
LV_ModifyCol(5,0)
Gui, Font, s11
Gui, Add, Edit, vUpdateTitle x535 y170 w335 h20, Update Title
Gui, Add, Edit, vUpdateDescription x535 y200 w335 h160, Update Description
Gui, Add, Text,x535 y370, Progress
Gui, Add, Edit, vPercentEdit ReadOnly x595 y368 w50
Gui, Add, UpDown, vProgressAddPercent Range-100-100, 1 
Gui, Add, Text,x647 y370, `%
;Gui, Add, Button,x725 y366 vTagsButton gTagsButton, Tags \\ Disabled until I can figure out how to do this correctly
Gui, Add, Button,x775 y366 vSaveUpdate gSaveUpdate , Save Update
Gui, Add, ListBox, gNotesListBox vNotesListBox x291 y435 w175 r12
Gui, Add, ListBox, gReminderListBox vReminderListBox x496 y435 w170 r12
Gui, Add, ListBox, gOtherListBox vOtherListBox x695 y435 w175 r12
Gui, Add, StatusBar,,
SB_SetParts(500,400)
SB_SetText("Upcoming Reminder:", 1)
SB_SetText("Upcoming Deadline:", 2)
Gui, Tab

Gui, Show
Goto LoadSaveFile ;Goes to LoadSaveFile so it has a file already open when the program starts
return

MenuFileNew:
GuiControl,,ProgressBar, 0
IniRead,LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
DisableAllGui()
DisableAllMenus()
MsgBox,52,Confirm,  All progress that has not been saved will be lost `, Are you sure?
IfMsgBox Yes
{
	InputBox, NewFileName, New File, Choose a name for the new file,,210,125
	if ErrorLevel = 1
	{
		EnableAllGui()
		EnableAllMenus()
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
else
{
	EnableAllGui()
	EnableAllMenus()
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
TagFilePath=%A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl ; Default location of tag list file, this could be changed to a variable so the user can have multiple tag lists or load one from another user
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
FileSelectFolder, ProgramSave,S,%MyDocumentsDataPath%,Select where to save this program
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
StringReplace,ProgramFolderPath,CurrentSaveFile,\%SavedProgramName%.ptp,,All
;MsgBox,%ProgramFolderPath% ;Troubleshooting meant to be used for testing StringReplace and how it worked Spoiler: It did
FileCreateDir, %ProgramFolderPath%\%SavedProgramName%
CurrentProgramPath=%ProgramSave%\%SavedProgramName%
FileCopyDir,%ProgramFolderPath%,%CurrentProgramPath%,1
EnableAllGui()
EnableAllMenus()
return

MenuSettings:
gui, Settings:New,, Settings
gui, +ToolWindow
Gui, Add, Tab3, x12 y9 w330 h250 , General|Paths|Collaboration|Update|Developer
Gui, Tab, 1
Gui, Add, CheckBox, Checked vWarnPopUp, Show a message box when closing data windows, confirming `ninputs and/or editing items
Gui, Add, CheckBox, vChromeDefault, Use Chrome as default browser
Gui, Add, CheckBox, vNotesAlwaysOnTop, Open notes will always be on top by default
Gui, Add, CheckBox, vSaveFileBackup, Save/Backup attached files inside Task folder
Gui, Add, CheckBox, vSaveScreenshot, Save Screenshots to latest task/project
Gui, Add, CheckBox, vSaveScreenshotAsk, Ask before saving screenshot
Gui, Tab, 2
Gui, Add, Text,, Tag List Path:
Gui, Add, Edit, -Multi vTagPathCheck h20 w250, %TagFilePath%
Gui, Tab, 5
Gui, Add, Text,,Time:
FormatTime, LocalTime,,ShortDate
Gui, Add, Edit, +ReadOnly,%A_Now% - %LocalTime%
Gui, Tab
Gui, Add, Button, gSaveSettings x12 y269 w330 h30 , Save Settings
Gui, Show
return

SaveSettings:
gui, Submit
return

CreateNote:
IfWinExist, Notes
{
	MsgBox 16, Warning, Notes window is already open!
	return
}
notename := "Notes"
Gui, Notes:Default
Gui, +HWNDhWnd +Resize ;-SysMenu ;+ToolWindow +ToolWindow
Gui, Color, 1E1D1D
Gui, Font, Bold, Arial
Gui, Font, cWhite
Gui, Add, Button, y3 w20 h20 vBold gMakeNoteBold, B
Gui, Font, Norm Italic
Gui, Add, Button, x+0 yp wp hp vItalic gMakeNoteItalic, I
Gui, Font, Norm Underline
Gui, Add, Button, x+0 yp wp hp vUnderline gMakeNoteUnderline, U
Gui, Font, Norm Strike
Gui, Add, Button, x+0 yp wp hp vStrike gMakeNoteStrike, S
Gui, Font, Norm
Gui, Add, Button, x+0 yp wp hp vNormalF gMakeNoteNormal, N
Gui, Add, Button, x+0 yp wp hp vUpSize gMakeNoteUpSize, ↑
Gui, Add, Button, x+0 yp wp hp vDownSize gMakeNoteDownSize, ↓
Gui, Add, CheckBox, x+5 yp w90 hp vTransparentCheck gNoteWindowTrans, Transparent
Gui, Add, CheckBox, x+0 yp w120 hp vNoteAOTCheck gNoteAlwaysOnTop, Always On Top
Gui, +Hwnd%notename%
Note := new richedit(%notename%,"x10 w300 h190", true)
Note.SetBkgndColor(0x262626)
Font := {"Name":"Consolas","Color":0xDCDCCC,"Size":10}
Note.SetFont(Font)
Note.ShowScrollBar(0,True)
Note.AlignText("RIGHT")
;Note.ChangeFontSize(12)
Note.WordWrap("On")
Gui, Add, Button, x5 y225 vNewNoteB gNewNote w50, New
Gui, Add, Button, x+0 yp vSaveNoteB gSaveCurrentNote w255, Save
Gui, Add, Button, x+0 yp vTagsNoteB gTagsButton w50, Tags
Gui, +MinSize
NewNoteTrigger = 1
Gui, Show, h255 w345 center,%notename%
return

MakeNoteBold:
Note.ToggleFontStyle("B")
return

MakeNoteItalic:
Note.ToggleFontStyle("I")
return

MakeNoteUnderline:
Note.ToggleFontStyle("U")
return

MakeNoteStrike:
Note.ToggleFontStyle("S")
return

MakeNoteNormal:
Note.ToggleFontStyle("N")
return

MakeNoteUpSize:
Note.ChangeFontSize(+1)
return

MakeNoteDownSize:
Note.ChangeFontSize(-1)
return

NoteWindowTrans:
gui, Submit, NoHide
if TransparentCheck = 1
{
	WinSet, Transparent, 175
}
if TransparentCheck = 0
{
	WinSet, TransColor, Off
}
return

NoteAlwaysOnTop:
gui, Submit, NoHide
if NoteAOTCheck = 1
{
	Gui, +AlwaysOnTop
}
if NoteAOTCheck = 0
{
	Gui, -AlwaysOnTop
}
return

NotesGuiSize:
Critical
NoteW := (A_GuiWidth - 10)
NoteH := (A_GuiHeight - 66)
ButtonH := (A_GuiHeight - 30)
ButtonW := (A_GuiWidth - 110)
ButtonX := (A_GuiWidth - 55)
GuiControl, Move, % Note.HWND, x5 w%NoteW% h%NoteH%
GuiControl, Move, NewNoteB, y%ButtonH% 
GuiControl, Move, SaveNoteB, y%ButtonH% w%ButtonW%
GuiControl, Move, TagsNoteB, x%ButtonX% y%ButtonH% 
return

NewNote:
Note.SelAll()
Note.Clear()
Note.SetFont(Font)
NewNoteTrigger = 1
return

SaveCurrentNote:
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
;MsgBox, %NewNoteTrigger%
if NewNoteTrigger = 0
{
	NoteSaveLocation = %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TVItemName%\%CurrentNoteName%.rtf
	Note.SaveFile(NoteSaveLocation)
	MsgBox,,Saved, Note Saved!, 2
	RefreshNoteList(TVItemName)
	return
}
InputBox, NoteFileName, Name, Choose a name for this note,,195,125
if ErrorLevel = 1
{
	return
}
IniRead, CurrentNoteList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TVItemName%.ptl, NoteInfo, NoteList
IfInString, CurrentNoteList, NoteFileName
{
	MsgBox 16, Name Error, There's already a note with that name!
	return
}
IniWrite, %NoteFileName%|%CurrentNoteList%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TVItemName%.ptl, NoteInfo, NoteList
FileRead, Stags, %A_Temp%\ProgressTracker\stags.temp
Loop, Parse, Stags, |
{
	AddToTagDir(A_LoopField,TVItemName,NoteFileName,TagFilePath,2)
}
IniWrite, %Stags%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TVItemName%.ptl, %NoteFileName%, Tags
NoteSaveLocation = %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TVItemName%\%NoteFileName%.rtf
Note.SaveFile(NoteSaveLocation)
MsgBox,,Saved, Note Saved!, 3
RefreshNoteList(TVItemName)
NewNoteTrigger = 0
return

OpenNoteMenu:
return
CreateReminder:
return
OpenReminderMenu:
return
SaveLink:
return
AttachFile:
return
OpenTags:
return

MenuAbout:
DisableAllGui()
DisableAllMenus()
MsgBox,,About,%Codename% by Christian Barsallo`nhttps://github.com/MeltedHeart/progress-tracker`n`nCSV library by trueski, Kdoske and hosted by hi5`nhttps://github.com/hi5/CSV`n`nClass_RichEdit by just me`nhttps://github.com/AHK-just-me/Class_RichEdit`n`nThanks to BGM for the easy RichEdit example!
EnableAllGui()
EnableAllMenus()
return

MainTreeView:
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
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
	if TVItemName = %SavedProgramName%
	{
		Menu , ContextEditProgramMenu , Add , New Project , NewProjectMenu
		Menu , ContextEditProgramMenu , Add , Change Name , ChangeName
		Menu , ContextEditProgramMenu , Add , Change Description , ChangeDescription
		Menu , ContextEditProgramMenu , Add , Delete , DeleteProject
		Menu , ContextEditProgramMenu , Show
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
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IniRead, SelectedProjectDescription, %CurrentSaveFile%, %TVItemName%, ProjectDescription
	IniRead, SelectedProjectTitle, %CurrentSaveFile%, %TVItemName%, ProjectTitle
	;IniRead, SelectedProjectCreator, %CurrentSaveFile%, %TVItemName%, ProjectCreator //Placeholder for collaboration in the future
	IniRead, SelectedProjectDate, %CurrentSaveFile%, %TVItemName%, Date
	IniRead, SelectedProjectLastChange, %CurrentSaveFile%, %TVItemName%, LastChange
	if ! TV_Get(A_EventInfo, "Bold")
	{
		if TVItemName = %SavedProgramName%
		{
			ProgramLoader()
			return
		}
		else
		{
			TVItemID := TV_GetSelection()
			TaskParent := TV_GetParent(TVItemID)
			TV_GetText(TVItemTaskName,TaskParent)
			IniRead, TaskList, %CurrentSaveFile%, %TVItemTaskName%, Tasks
			TaskLoader(TVItemName,TVItemTaskName,TaskList,CurrentSaveFile)
		}
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
	{
		GuiControl,,MainDescriptionText, %SelectedProjectDescription%
		GuiControl,,MainPropertiesText, Title: %SelectedProjectTitle%`nCreator: %CurrentUser%`nDate: %SelectedProjectDate%`nLast Change: %SelectedProjectLastChange%
		;GuiControl,,NotesListBox, |
	}
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
IniWrite, %LocalTime%, %CurrentSaveFile%, %TVItemName%, LastChange
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
IniWrite, %LocalTime%, %CurrentSaveFile%, %TVItemName%, LastChange
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
IniWrite, %LocalTime%, %CurrentSaveFile%, %TVItemParentName%, LastChange
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
Gui, Treeview, MainTreeView
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
if TV_Get(TVItemID, "Bold")
{
	MsgBox 52, Warning, All data on this task will be lost. `nAre you sure?
	ifMsgBox, No
	{
		return
	}
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
	MsgBox 52, Warning, All data on this task will be lost. `nAre you sure?
	ifMsgBox, No
	{
		return
	}
	ifMsgBox, Yes
	{
		DeleteTask(TVItemParentName,TVItemName,CurrentSaveFile)
		Goto LoadSaveFile
	}
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
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
if A_GuiEvent = Normal
{
	LV_GetText(UpdateFileIni,A_EventInfo,5)
	UpdateFileName=%UpdateFileIni%
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IniRead, UpdateTitle, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TVItemName%\%UpdateFileName%, UpdateInfo, UpdateTitle
	IniRead, UpdateDescription, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TVItemName%\%UpdateFileName%, UpdateContent, UpdateDescription
	StringReplace, UpdateDescription, UpdateDescription, |, `n, All
	;MsgBox, %UpdateFileIni% %UpdateFileName% %UpdateTitle% %UpdateDescription% %SavedProgramName%
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
if NewNoteTrigger = 0
{
	MsgBox 16, Notes, Tags have been already asign to  this note!
	return
}
gui, TagSelector:New, ToolWindow, Tag Selector
gui, Add, Text,, Select the tag(s) for this update:
Gui, Font, s11
gui, Add, ListView, AltSubmit Checked w150 r8, Tag Name
Gui, Font
gui, Add, Button, w25 gAddTag, +
gui, Add, Button, Default x35 y219 w125 gSaveSelectedTags, OK
LoadTags(TagFilePath)
gui, Show
return

AddTag:
AddNewTag(TagFilePath)
LoadTags(TagFilePath)
return

SaveSelectedTags:
gui, Submit
RowAmount := LV_GetCount()
RowNumber := 0
FileDelete, %A_Temp%\ProgressTracker\stags.temp
Loop,
{
	FileRead, Stags, %A_Temp%\ProgressTracker\stags.temp
	RowNumber := LV_GetNext(RowNumber, "C")
	if ! RowNumber
	{
		break
	}
	Row := RowNumber
	;MsgBox %Row%
	LV_GetText(RowText, Row)
	;MsgBox %RowText%
	if Stags =
	{
		FileAppend, %RowText%, %A_Temp%\ProgressTracker\stags.temp
	}
	else
	{
		FileAppend, |%RowText%, %A_Temp%\ProgressTracker\stags.temp
	}
}
return

SavePictures:
Menu, OtherMenu, ToggleCheck, Save Pictures when detected
return

SaveUpdate:
gui, Submit, NoHide
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
IniRead, TaskList, %CurrentSaveFile%, %TVItemParentName%, Tasks
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
BonelessItemName := StrReplace(TVItemName,"","",0)
CurrentUpdateCount := LV_GetCount()
CurrentUpdateCount += 1
UpdateFile = up%CurrentUpdateCount%.ptu
FullUpdateFile=%A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TVItemName%\up%CurrentUpdateCount%.ptu
FileAppend, %UpdateTitle%`, %ProgressAddPercent%`, %A_Now%`, %LocalTime%`, %UpdateFile%`n, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TVItemName%.ptl
IniRead, TaskList, %CurrentSaveFile%, %TVItemParentName%, Tasks
Loop, Parse, TaskList, `|
{
	if A_LoopField = %TVItemName%
	{
		TaskNumber = %A_Index%
	}
}
IniRead, CurrentProgress, %CurrentSaveFile%, %TVItemParentName%, ProgressTracker%TaskNumber%
TotalProgress := CurrentProgress + ProgressAddPercent
IniWrite, %TotalProgress%, %CurrentSaveFile%, %TVItemParentName%, ProgressTracker%TaskNumber%
FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TVItemName%
;FileRead, UpdateTags, %A_Temp%\ProgressTracker\stags.temp
;Loop, Parse, UpdateTags, |
;{
;	AddToTagDir(A_LoopField,TVItemName,UpdateTitle,TagFilePath,1)
;}
WriteUpdate(UpdateTitle,UpdateDescription,UpdateTags,FullUpdateFile)
Sleep 250
RefreshUpdateList(TVItemName,SavedProgramName,TVItemParentName,CurrentSaveFile)
IniWrite, %LocalTime%, %CurrentSaveFile%, %TVItemParentName%, LastChange
TV_Modify(TVItemID, Select)
GuiControl,,ProgressBar, %TotalProgress%
FileDelete, %RowText%, %A_Temp%\ProgressTracker\stags.temp
return

NotesListBox:
gui, Submit, NoHide
if A_GuiEvent = DoubleClick
{
	TVItemID := TV_GetSelection()
	TV_GetText(TVItemName, TVItemID)
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IfWinExist, Notes
	{
		NewNoteTrigger = 0
		CurrentNoteName = %NotesListBox%
		NotePath = %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TVItemName%\%CurrentNoteName%.rtf
		;MsgBox, %ListBoxItems% %ListBoxText% %NotePath%
		Note.LoadFile(NotePath)
		return
	}
	else
	{
		GoSub, CreateNote
		Goto NotesListBox
	}
}
return

ReminderListBox:
return
OtherListBox:
return

ProgressTrackerGuiClose:
MsgBox 52, Warning, All progress that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	return
}
else
{
	ExitApp
}

NotesGuiClose:
Gui, -AlwaysOnTop
MsgBox 52, Warning, All progress that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	Gui, +AlwaysOnTop
	return
}
else
{
	Gui, Destroy
	return
}

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