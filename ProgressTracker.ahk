; /// Progress Tracker ///
Codename=ProgressTracker
CurrentUser=%A_UserName% ;Placeholder for collaboration in the future
Temp_File=0 ; Check to see if the current file is a temp file
ImgSaveTrigger=0
NoLastFileTrigger = 0
SaveLocation=%A_MyDocuments%\ProgressTracker\ProgramData ; Default save location
MyDocumentsDataPath=%A_MyDocuments%\ProgressTracker
FormatTime, LocalTime,,ShortDate
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On 
#SingleInstance,Force
#Persistent
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
IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ShowAddConfirmation
IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ChromeDefault
IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, NotesAOT
IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SaveFiles
IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, MiscItemMenu
IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AutoSaveIMG
IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AskScrn
;IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, DevSettings, DarkMode
Goto ReadSettingsIni
return

ReadSettingsIni: ;Reads the settings file
IniRead, LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
IniRead, NewProjectCount, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewProjectCount
IniRead, NewTaskCount, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, NewTaskCount
IniRead, ShowAddConfirmation, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ShowAddConfirmation
IniRead, ChromeDefault, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ChromeDefault
IniRead, NotesAOT, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, NotesAOT
IniRead, SaveFiles, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SaveFiles
IniRead, SAutoSaveIMG, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AutoSaveIMG
IniRead, AskScrn, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AskScrn
IniRead, DarkModeSwitch, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, DevSettings, DarkMode
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

Menu, TagMenuBar, Add, Search by Tag, TagSearch
Menu, TagMenuBar, Add, Open Tags Menu, OpenTags

Menu, HelpMenu, Add, About, MenuAbout

Menu, MainMenuBar, Add, &File, :FileMenu
Menu, MainMenuBar, Add, &Notes, :NotesMenu
Menu, MainMenuBar, Add, &Reminders, :RemindersMenu
Menu, MainMenuBar, Add, &Misc, :OtherMenu
Menu, MainMenuBar, Add, &Tags, :TagMenuBar
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
Gui, Add, GroupBox, x685 y415 w195 h225, Misc
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
Gui, Add, ListBox, gMiscListBox vMiscListBox x695 y435 w175 r12
Gui, Add, StatusBar,,
SB_SetParts(500,400)
SB_SetText("Upcoming Reminder:", 1)
SB_SetText("Upcoming Deadline:", 2)
Gui, Tab
Gui, Show
if LastOpenProgram = ERROR
{
	NoLastFileTrigger = 1
	Goto MenuFileNew ;Goes to MenuFileNew so it creates a new file
	return
}
if LastOpenProgram =
{
	NoLastFileTrigger = 1
	Goto MenuFileNew ;Goes to MenuFileNew so it creates a new file
	return
}
else
{
	Goto LoadSaveFile ;Goes to LoadSaveFile so it has a file already open when the program starts
	return
}
return

MenuFileNew:
GuiControl,,ProgressBar, 0
IniRead,LastOpenProgram, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, FileInfo, LastOpenProgram
DisableAllGui()
DisableAllMenus()
if NoLastFileTrigger = 0
{
	MsgBox,52,Confirm,  All progress that has not been saved will be lost`nAre you sure?
}
if NoLastFileTrigger = 1
{
	MsgBox,52,Confirm,  You are about to create a new file`nAre you sure?
}
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
; // Saving the program name in a temp file for later use
FileDelete, %A_Temp%\ProgressTracker\cprogram.tmp
FileAppend, %SavedProgramName%, %A_Temp%\ProgressTracker\cprogram.tmp
; \\
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
;// Loads Save Image feature
OnClipboardChange("ChangeItUp")
ChangeItUp()
{
	Global
	IfInString, Clipboard, .jpg
	{
		SImageFormat = JPG
		MsgBox 4, Save Picture,Would you like to saved picture to the current Task/Project?
		IfMsgBox, Yes
		{
			if ImgDescriptorTrigger = 1
			{
				MsgBox 16, Warning, Image Descriptor window is already open!
				return
			}
			TempIMG = %A_Temp%/ProgressTracker/tempimg.jpg
			UrlDownloadToFile, %ImageAddress%, %TempIMG%
			ImgDescriptorTrigger = 1
			OpenImageDescriptor(TempIMG)
			return
		}
	}
	IfInString, Clipboard, .png
	{
		SImageFormat = PNG
		MsgBox 4, Save Picture,Would you like to saved picture to the current Task/Project?
		IfMsgBox, Yes
		{
			if ImgDescriptorTrigger = 1
			{
				MsgBox 16, Warning, Image Descriptor window is already open!
				return
			}
			TempIMG = %A_Temp%/ProgressTracker/tempimg.png
			UrlDownloadToFile, %ImageAddress%, %TempIMG%
			ImgDescriptorTrigger = 1
			OpenImageDescriptor(TempIMG)
			return
		}
	}
	; FileAppend, %ClipboardAll%, %A_MyDocuments%\ProgressTracker\bruh.jpg
}
;\\
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
Gui, Add, CheckBox, vWarnPopUp, Show a message box when closing data windows, confirming `ninputs and/or editing items
Gui, Add, CheckBox, vChromeDefault, Use Chrome as default browser
Gui, Add, CheckBox, vNotesAlwaysOnTop, Open notes will always be on top by default
Gui, Add, CheckBox, vSaveFileBackup, Save/Backup attached files inside Task folder
Gui, Add, CheckBox, vMiscItemMenu, Open Misc item info window first when selecting an item
Gui, Add, CheckBox, vAutoSaveIMG, Save image when copying its address?
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
;// Checking Settings
IniRead, ShowAddConfirmation, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ShowAddConfirmation
IniRead, ChromeDefault, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ChromeDefault
IniRead, NotesAOT, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, NotesAOT
IniRead, SaveFiles, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SaveFiles
IniRead, MiscItemMenu, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, MiscItemMenu
IniRead, SAutoSaveIMG, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AutoSaveIMG
IniRead, AskScrn, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AskScrn
;// Correcting Settings
if ShowAddConfirmation = Yes
{
	GuiControl,, WarnPopUp, 1
}
if ShowAddConfirmation = No
{
	GuiControl,, WarnPopUp, 0
}
if ChromeDefault = Yes
{
	GuiControl,, ChromeDefault, 1
}
if ChromeDefault = No
{
	GuiControl,, ChromeDefault, 0
}
if NotesAOT = Yes
{
	GuiControl,, NotesAlwaysOnTop, 1
}
if NotesAOT = No
{
	GuiControl,, NotesAlwaysOnTop, 0
}
if SaveFiles = Yes
{
	GuiControl,, SaveFileBackup, 1
}
if SaveFiles = No
{
	GuiControl,, SaveFileBackup, 0
}
if MiscItemMenu = Yes
{
	GuiControl,, MiscItemMenu, 1
}
if MiscItemMenu = No
{
	GuiControl,, MiscItemMenu, 0
}
if SAutoSaveIMG = Yes
{
	GuiControl,, AutoSaveIMG, 1
}
if SAutoSaveIMG = No
{
	GuiControl,, AutoSaveIMG, 0
}
if AskScrn = Yes
{
	GuiControl,, SaveScreenshotAsk, 1
}
if AskScrn = No
{
	GuiControl,, SaveScreenshotAsk, 0
}
;\\
Gui, Show
return

SaveSettings:
gui, Submit
if ShowAddConfirmation = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ShowAddConfirmation
}
if ShowAddConfirmation = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ShowAddConfirmation
}
if ChromeDefault = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ChromeDefault
}
if ChromeDefault = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, ChromeDefault
}
if NotesAOT = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, NotesAOT
}
if NotesAOT = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, NotesAOT
}
if SaveFiles = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SaveFiles
}
if SaveFiles = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SaveFiles
}
if MiscItemMenu = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, MiscItemMenu
}
if MiscItemMenu = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, MiscItemMenu
}
if SAutoSaveIMG = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SAutoSaveIMG
}
if SAutoSaveIMG = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SAutoSaveIMG
}
if AskScrn = 0
{
	IniWrite, No, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AskScrn
}
if AskScrn = 1
{
	IniWrite, Yes, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, AskScrn
}
MsgBox,,Settings, Settings have been saved! Restart to reload settings, 5
return

CreateNote:
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
If TVItemName = %SavedProgramName%
{
	MsgBox 16, Warning, You can't save notes on a Program`nPlease select a Task or a Project first!
	return
}
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
If NoteFileName = 
{
	MsgBox 16, Warning, Item Name cannot be empty!
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
NewLinkWindow()
return

SaveLinkButton:
gui, Submit
LinkName := RegExReplace(LinkName,"[^0-9xyz]","")
LinkDescriptorTrigger = 0
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
if TVItemName = %SavedProgramName%
{
	MsgBox 16, ERROR, You cannot save a misc item to a Program!`nSelect a Task/Project and try again!
	return
}
IfInString, CurrentMiscList, %LinkName%
{
	MsgBox 16, ERROR, There is already a misc item with that name!
	return
}
If LinkName = 
{
	MsgBox 16, ERROR, Item Name cannot be empty!
	return
}
if CurrentMiscList = ERROR
{
	IniWrite, LINK:%LinkName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
}
else
{
	IniWrite, LINK:%LinkName%|%CurrentMiscList%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
}
IniWrite, %SelectedLink%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TVItemName%\LINK-%LinkName%.ptd, LinkInfo, LinkAddress
IniWrite, %LinkName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TVItemName%\LINK-%LinkName%.ptd, LinkInfo, Name
StringReplace, LinkDesc, LinkDesc, `n, |, All
IniWrite, %LinkDesc%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TVItemName%\LINK-%LinkName%.ptd, LinkInfo, Description
;// Adding Tags
FullLinkName = LINK-%LinkName%
FileRead, Stags, %A_Temp%\ProgressTracker\stags.temp
IniWrite, %Stags%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TVItemName%\LINK-%LinkName%.ptd, LinkInfo, Tags
Loop, Parse, Stags, |
{
	AddToTagDir(A_LoopField,TVItemName,FullLinkName,TagFilePath,4)
}
;\\
MsgBox,,Saved, Link Saved!
return

AttachFile:
FileSelectFile, ImportedFile, S3,,Select a File
if ErrorLevel = 1
{
	return
}
NewFileWindow(ImportedFile)
return

SaveFileButton:
gui, Submit
MiscFileName := RegExReplace(MiscFileName,"[^0-9xyz]","")
FileDescriptorTrigger = 0
SelectedTVItemID := TV_GetSelection()
TV_GetText(TVItemName,SelectedTVItemID)
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
if TVItemName = %SavedProgramName%
{
	MsgBox 16, ERROR, You cannot save a misc item to a Program!`nSelect a Task/Project and try again!
	return
}
IfInString, CurrentMiscList, %MiscFileName%
{
	MsgBox 16, ERROR, There is already a misc item with that name!
	return
}
If MiscFileName = 
{
	MsgBox 16, ERROR, Item Name cannot be empty!
	return
}
if CurrentMiscList = ERROR
{
	IniWrite, FILE:%MiscFileName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
}
else
{
	IniWrite, FILE:%MiscFileName%|%CurrentMiscList%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
}
IniRead, SaveFiles, %A_MyDocuments%\ProgressTracker\ProgressTrackerSettings.ini, GeneralSettings, SaveFiles
if SaveFiles = Yes
{
	FileCopy, %ImportedFile%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%
	If ErrorLevel = 0
	{
		MsgBox 16, ERROR MISC-BF1, There has been an error trying to back up this file`nPlease try again!
		return
	}
	SplitPath, %ImportedFile%, ImportedFileNameEXT
	ImportedBackUpFile = %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\%ImportedFileNameEXT%
	if !FileExist(ImportedBackUpFile)
	{
		MsgBox 16, ERROR MISC-BF2, There has been an error trying to back up this file`nPlease try again!
		return
	}
	IniWrite, %ImportedBackUpFile%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%MiscFileName%.ptd, FileInfo, File
	IniWrite, %MiscFileName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%MiscFileName%.ptd, FileInfo, Name
	StringReplace, MiscFileDesc, MiscFileDesc, `n, |, All
	IniWrite, %LinkDesc%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%LinkName%.ptd, FileInfo, Description
}
if SaveFiles = No
{
	IniWrite, %ImportedFile%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%MiscFileName%.ptd, FileInfo, File
	IniWrite, %MiscFileName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%MiscFileName%.ptd, FileInfo, Name
	StringReplace, MiscFileDesc, MiscFileDesc, `n, |, All
	IniWrite, %LinkDesc%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%MiscFileName%.ptd, FileInfo, Description
}
;// Adding Tags
FullFileName = FILE-%MiscFileName%
FileRead, Stags, %A_Temp%\ProgressTracker\stags.temp
IniWrite, %Stags%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\FILE-%MiscFileName%.ptd, FileInfo, Tags
Loop, Parse, Stags, |
{
	AddToTagDir(A_LoopField,TVItemName,FullFileName,TagFilePath,4)
}
;\\
MsgBox,,Saved, Link Saved!
return

TagSearch:
return

OpenTags:
TagMenuTrigger = 1
Goto, TagsButton
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
gui, Add, Button, Default x35 y219 w125 vSaveSelectedTags gSaveSelectedTags, OK
if TagMenuTrigger = 1
{
	GuiControl, Disable, SaveSelectedTags
}
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

MiscListBox:
gui, Submit, NoHide
if A_GuiEvent = DoubleClick
{
	TVItemID := TV_GetSelection()
	TV_GetText(TVItemName, TVItemID)
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IfInString, MiscListBox, IMG
	{
		StringReplace, IMGPath, MiscListBox, `:,-
		Run, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\%IMGPath%
		return
	}
	IfInString, MiscListBox, LINK
	{
		StringReplace, MiscListBox, MiscListBox, `:, -
		IniRead, LinkAddress, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TVItemName%\%MiscListBox%.ptd, LinkInfo, LinkAddress
		Run, %LinkAddress%
	}
	ifInString, MiscListBox, FILE
	{
		StringReplace, MiscListBox, MiscListBox, `:, -
		IniRead, FileAddress, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TVItemName%\%MiscListBox%.ptd, FileInfo, File
		Run, %FileAddress%
	}
}
return

SaveImage:
Gui, Submit
;MsgBox, %ImgName% %SImageFormat%
ImgDescriptorTrigger = 0
TVItemID := TV_GetSelection()
TV_GetText(TVItemName, TVItemID)
IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
if TVItemName = %SavedProgramName%
{
	MsgBox 16, ERROR, You cannot save a misc item to a Program!`nSelect a Task/Project and try again!
	return
}
IfInString, CurrentMiscList, ImgName
{
	MsgBox 16, ERROR, There is already an image with that name!
	return
}
If ImgName = 
{
	MsgBox 16, Warning, Item Name cannot be empty!
	return
}
if SImageFormat = JPG
{
	UrlDownloadToFile, %Clipboard%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.jpg
	if CurrentMiscList = ERROR
	{
		IniWrite, IMG:%ImgName%.jpg, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
	}
	else
	{
		IniWrite, IMG:%ImgName%.jpg|%CurrentMiscList%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
	}
	IniWrite, %ImgName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.ptd, ImageInfo, Name
	StringReplace, ImgDesc, ImgDesc, `n, |, All
	IniWrite, %ImgDesc%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.ptd, ImageInfo, Description
	;// Adding Tags
	FullImgName = IMG-%ImgName%.jpg
	FileRead, Stags, %A_Temp%\ProgressTracker\stags.temp
	IniWrite, %Stags%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.ptd, ImageInfo, Tags
	Loop, Parse, Stags, |
	{
		AddToTagDir(A_LoopField,TVItemName,FullImgName,TagFilePath,4)
	}
	;\\
	MsgBox,,Image Saved, Image %ImgName%.jpg saved
}
If SImageFormat = PNG
{
	UrlDownloadToFile, %Clipboard%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%imgname%.png
	if CurrentMiscList = ERROR
	{
		IniWrite, IMG:%imgname%.png, %A_MyDocuments%\ProgressTracker\ProgramData\%SaveCurrentNote%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
	}
	else
	{
		IniWrite, IMG:%imgname%.png|%CurrentMiscList%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TVItemName%.ptl, MiscInfo, MiscList
	}
	IniWrite, %ImgName%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.ptd, ImageInfo, Name
	IniWrite, %ImgDesc%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.ptd, ImageInfo, Description
	;// Adding Tags
	FullImgName = IMG-%ImgName%.png
	FileRead, Stags, %A_Temp%\ProgressTracker\stags.temp
	IniWrite, %Stags%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TVItemName%\IMG-%ImgName%.ptd, ImageInfo, Tags
	Loop, Parse, Stags, |
	{
		AddToTagDir(A_LoopField,TVItemName,FullImgName,TagFilePath,4)
	}
	;\\
	MsgBox,,Image Saved, Image %imgname%.png saved!
}
return

ProgressTrackerGuiClose:
MsgBox 52, Warning, All data that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	return
}
else
{
	WinClose, %A_WorkingDir%\SavingImage.ahk ahk_class AutoHotkey
	ExitApp
}

TagSelectorGuiClose:
TagMenuTrigger = 0
Gui, Destroy
return

NotesGuiClose:
MsgBox 52, Warning, All data that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	return
}
else
{
	Gui, Destroy
	return
}

ImageDescriptorGuiClose:
{
	MsgBox 52, Warning, All data that has not been saved will be lost. `nAre you sure?
	IfMsgBox No
	{
		return
	}
	else
	{
		ImgDescriptorTrigger = 0
		Gui, Destroy
		return
	}
}

LinkDescriptorGuiClose:
{
	MsgBox 52, Warning, All data that has not been saved will be lost. `nAre you sure?
	IfMsgBox No
	{
		return
	}
	else
	{
		LinkDescriptorTrigger = 0
		Gui, Destroy
		return
	}
}

FileDescriptorGuiClose:
{
	MsgBox 52, Warning, All data that has not been saved will be lost. `nAre you sure?
	IfMsgBox No
	{
		return
	}
	else
	{
		FileDescriptorTrigger = 0
		Gui, Destroy
		return
	}
}

GuiClose:
MsgBox 52, Warning, All data that has not been saved will be lost. `nAre you sure?
IfMsgBox No
{
	return
}
else
{
	Gui, Destroy
}