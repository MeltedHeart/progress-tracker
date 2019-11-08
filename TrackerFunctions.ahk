; /// Tracker Library ///

DisableAllGui()
{
	WinGet, ActiveControlList, ControlList, A
	Loop, Parse, ActiveControlList, `n
	{
		GuiControl, Disable, %A_LoopField%
	}
}

EnableAllGui()
{
	WinGet, ActiveControlList, ControlList, A
	Loop, Parse, ActiveControlList, `n
	{
		GuiControl, Enable, %A_LoopField%
	}
	GuiControl, Disable, UpdateTitle
	GuiControl, Disable, UpdateDescription
	GuiControl, Disable, UpdateList
	GuiControl, Disable, TagsButton
	GuiControl, Disable, SaveUpdate
	GuiControl, Disable, PercentEdit
}

EnableUpdateGui()
{
	GuiControl, Enable, UpdateTitle
	GuiControl, Enable, UpdateDescription
	GuiControl, Enable, UpdateList
	;GuiControl, Enable, TagsButton // Placeholder until Tag feature is completed
	GuiControl, Enable, SaveUpdate
	GuiControl, Enable, PercentEdit
}

DisableAllMenus()
{
	Menu, MainMenuBar, Disable, &File
	Menu, MainMenuBar, Disable, &Notes
	Menu, MainMenuBar, Disable, &Reminders
	Menu, MainMenuBar, Disable, &Misc
	Menu, MainMenuBar, Disable, &Tags
	Menu, MainMenuBar, Disable, &Help
}

EnableAllMenus()
{
	Menu, MainMenuBar, Enable, &File
	Menu, MainMenuBar, Enable, &Notes
	Menu, MainMenuBar, Enable, &Reminders
	Menu, MainMenuBar, Enable, &Misc
	Menu, MainMenuBar, Enable, &Tags
	Menu, MainMenuBar, Enable, &Help
}

TreeViewLoader(ParentProgram,ProjectChildren,SaveFile)
{
	TV_Delete()
	P1 := TV_Add(ParentProgram)
	LastMainTaskLoop=1
	Loop, Parse, ProjectChildren, `|
	{
		P1C%A_Index% := TV_Add(A_LoopField,P1,"Bold")
		IniRead, TVLTaskList, %SaveFile%, %A_LoopField%, Tasks
		Loop, Parse, TVLTaskList, `|
		{
			P1C1C1 := TV_Add(A_LoopField,P1C%LastMainTaskLoop%)
		}
		LastMainTaskLoop+=1
		TV_Modify(P1C%A_Index%, "Expand")
	}
	TV_Modify(P1, "Expand")
}

TaskLoader(Selected,ParentName,TaskList,SaveFile)
{
	global
	; // Saving the program name in a temp file for later use
	FileDelete, %A_Temp%\ProgressTracker\citem.tmp
	FileAppend, %Selected%, %A_Temp%\ProgressTracker\citem.tmp
	; \\
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	Loop, Parse, TaskList, `|
	{
		if A_LoopField = %Selected%
		{
			LV_Delete()
			GuiControl,, UpdateTitle, Update Title
			GuiControl,, UpdateDescription, Update Description
			GuiControl,Enable, UpdateListView
			GuiControl,Enable, UpdateTitle
			GuiControl,Enable, UpdateDescription
			GuiControl,Enable, TagsButton
			GuiControl,Enable, SaveUpdate
			GuiControl,Enable, ProgressAddPercent
			GuiControl,Enable, PercentEdit
			IniRead, ProgressBarPercent, %SaveFile%, %ParentName%, ProgressTracker%A_Index%
			GuiControl,+Range0-100, ProgressBar
			GuiControl,,ProgressBar, %ProgressBarPercent%
			ProgressRange := 100 - ProgressBarPercent
			GuiControl,, ProgressAddPercent, 0
			GuiControl,+Range-%ProgressBarPercent%-%ProgressRange%, ProgressAddPercent
			IniRead, SelectedTaskDescription, %SaveFile%, %ParentName%, TaskDescription%A_Index%
			GuiControl,,MainDescriptionText, %SelectedTaskDescription%
			IniRead, SelectedTaskTitle, %SaveFile%, %ParentName%, Task%A_Index%
			;IniRead, SelectedProjectCreator, %CurrentSaveFile%, %TVItemName%, ProjectCreator //Placeholder for collaboration in the future
			IniRead, SelectedTaskDate, %SaveFile%, %ParentName%, Date
			IniRead, SelectedTaskLastChange, %SaveFile%, %ParentName%, LastChange
			GuiControl,,MainPropertiesText, Title: %SelectedTaskTitle%`nCreator: %CurrentUser%`nDate: %SelectedTaskDate%`nLast Change: %SelectedTaskLastChange%
			IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
			;// Loading Task Updates
			UpdateListPath=%A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%SelectedTaskTitle%.ptl
			CSV_Load(UpdateListPath,"UpdateListCSV",",")
			UpdateAmount:=CSV_TotalRows("UpdateListCSV")
			LV_Delete()
			Loop, %UpdateAmount%
			{
				RowNum=%A_Index%
				UpdateListTitle:=CSV_ReadCell("UpdateListCSV",RowNum,1)
				UpdateListPercentage:=CSV_ReadCell("UpdateListCSV",RowNum,2)
				UpdateListTime:=CSV_ReadCell("UpdateListCSV",RowNum,3)
				UpdateListConvertedTime:=CSV_ReadCell("UpdateListCSV",RowNum,4)
				UpdateListUpdateFile:=CSV_ReadCell("UpdateListCSV",RowNum,5)
				LV_Add("",UpdateListTitle,UpdateListPercentage,UpdateListTime,UpdateListConvertedTime,UpdateListUpdateFile)
				LV_ModifyCol(3, "SortDesc")
			}
			;\\
			;// Loading Task Notes
			GuiControl,,NotesListBox, |
			IniRead, NoteList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%SelectedTaskTitle%.ptl, NoteInfo, NoteList
			Loop, parse, NoteList, `|
			{
				if A_LoopField = ERROR
				{
					Break
				}
				GuiControl,,NotesListBox, %A_LoopField%
			}
			;\\
			;// Loading Task Misc
			GuiControl,, MiscListBox, |
			IniRead, MiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%SelectedTaskTitle%.ptl, MiscInfo, MiscList
			Loop, parse, MiscList, `|
			{
				if A_LoopField = ERROR
				{
					Break
				}
				GuiControl,, MiscListBox, %A_LoopField%
			}
			;\\
		}
		if Selected = %SavedProgramName%
		{
			LV_Delete()
			GuiControl,, UpdateTitle, Update Title
			GuiControl,, UpdateDescription, Update Description
			GuiControl,Disable, UpdateTitle
			GuiControl,Disable, UpdateDescription
			GuiControl,Disable, TagsButton
			GuiControl,Disable, SaveUpdate
			GuiControl,Disable, ProgressAddPercent
			GuiControl,Disable, PercentEdit
			GuiControl,,ProgressBar, 0
		}
	}
}

ProjectLoader(ProjectName,SaveFile)
{
	IniRead, SavedProgramName, %SaveFile%, ProgramInfo, ProgramName
	LV_Delete()
	GuiControl,, UpdateTitle, Update Title
	GuiControl,, UpdateDescription, Update Description
	GuiControl,Disable, UpdateListView
	GuiControl,Disable, UpdateTitle
	GuiControl,Disable, UpdateDescription
	GuiControl,Disable, TagsButton
	GuiControl,Disable, SaveUpdate
	GuiControl,Disable, ProgressAddPercent
	GuiControl,Disable, PercentEdit
	IniRead, TaskList, %SaveFile%, %ProjectName%, Tasks
	Loop, Parse, TaskList, `|
	{
		TaskAmount = %A_Index%
	}
	TaskProgressTotalRange := (TaskAmount*100)
	Loop, Parse, TaskList, `|
	{
		IniRead, TaskProgress, %SaveFile%, %ProjectName%, ProgressTracker%A_Index%
		ProgressSum += %TaskProgress%
	}
	GuiControl,+Range0-%TaskProgressTotalRange%, ProgressBar
	GuiControl,, ProgressBar, %ProgressSum%
	;// Loading Task Notes
	GuiControl,,NotesListBox, |
	IniRead, NoteList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%ProjectName%.ptl, NoteInfo, NoteList
	Loop, parse, NoteList, `|
	{
		if A_LoopField = ERROR
		{
			Break
		}
		GuiControl,,NotesListBox, %A_LoopField%
	}
	;\\
	;// Loading Task Misc
	GuiControl,,MiscListBox, |
	IniRead, MiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%SelectedTaskTitle%.ptl, MiscInfo, MiscList
	Loop, parse, MiscList, `|
	{
		if A_LoopField = ERROR
		{
			Break
		}
		GuiControl,, MiscListBox, %A_LoopField%
	}
	;\\
}

ProgramLoader()
{
	LV_Delete()
	GuiControl,, ProgressBar, 0
	GuiControl,, UpdateTitle, Update Title
	GuiControl,, UpdateDescription, Update Description
	GuiControl,Disable, UpdateListView
	GuiControl,Disable, UpdateTitle
	GuiControl,Disable, UpdateDescription
	GuiControl,Disable, TagsButton
	GuiControl,Disable, SaveUpdate
	GuiControl,Disable, ProgressAddPercent
	GuiControl,Disable, PercentEdit
	GuiControl,,NotesListBox, |
	GuiControl,,MiscListBox, |
	return
}

DeleteProject(ProjectName,SaveFile)
{
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IniRead, ProjectList, %SaveFile%, ProgramInfo, Projects
	PipeProjectName=|%ProjectName%
	StringReplace, ProjectList, ProjectList, %PipeProjectName%,, All
	if ErrorLevel = 1
	{
		ProjectNamePipe=%ProjectName%|
		StringReplace, ProjectList, ProjectList, %ProjectNamePipe%,, All
		if ErrorLevel = 1
		{
			StringReplace, ProjectList, ProjectList, %ProjectName%,, All
		}
	}
	IniWrite, %ProjectList%, %SaveFile%, ProgramInfo, Projects
	IniDelete, %SaveFile%,%ProjectName%
	FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%ProjectName%
	FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%ProjectName%
	FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%ProjectName%
	FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK%ProjectName%
}

DeleteTask(ProjectName,TaskName,SaveFile)
{
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	IniRead, TaskList, %SaveFile%, %ProjectName%, Tasks
	Loop, Parse, TaskList, `|
	{
		TaskAmount = %A_Index%
	}
	if TaskAmount = 1
	{
		MsgBox 16, Warning, You cannot delete this task!`nA Project cannot be empty, please create a new task before deleting this one
		return
	}
	else
	{
		Loop, Parse, TaskList, `|
		{
			if A_LoopField = %TaskName%
			{
				PipeTaskName=|%TaskName%
				StringReplace, TaskList, TaskList, %PipeTaskName%
				if ErrorLevel = 1
				{
					TaskNamePipe = %TaskName%|
					StringReplace, TaskList, TaskList, %TaskNamePipe%
					if ErrorLevel = 1
					{
						StringReplace, TaskList, TaskList, %TaskName%
					}
				}
				IniWrite, %TaskList%, %SaveFile%, %ProjectName%, Tasks
				TaskNum = %A_Index%
				IniDelete, %SaveFile%,%ProjectName%, Task%TaskNum%
				IniDelete, %SaveFile%,%ProjectName%, TaskDescription%TaskNum%
				IniDelete, %SaveFile%,%ProjectName%, ProgressTracker%TaskNum%
				; The following deletes all update data so it doesn't conflict with a new task of the same name
				FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TaskName%
				FileDelete, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\%TaskName%.ptl
				FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TaskName%
				FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TaskName%
				FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TaskName%
				FileRemoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TaskName%
				FileDelete, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%TaskName%.ptl
				FileDelete, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TaskName%.ptl
			}
		}
	}
}

CreateNewFile(FileName,WhereToSave)
{
	FileDelete,  %A_temp%\ProgressTracker\New_File.ptp
	FileCreateDir, %WhereToSave%\%FileName%
	FileCreateDir, %WhereToSave%\%FileName%\Notes
	FileCreateDir, %WhereToSave%\%FileName%\Reminders
	FileCreateDir, %WhereToSave%\%FileName%\Updates
	FileCreateDir, %WhereToSave%\%FileName%\Misc
	FileCreateDir, %WhereToSave%\%FileName%\Misc\IMG
	FileCreateDir, %WhereToSave%\%FileName%\Misc\LINK
	FileCreateDir, %WhereToSave%\%FileName%\Misc\FILE
	FormatTime, LocalTime, ,ShortDate
	FileAppend ,[ProgramInfo]`nProgramName=%FileName%`nCreator=%A_UserName%`nCreatorVersion=`nProjects=`n[%FileName%]`nProjectTitle=%FileName%]`nProjectDescription=You can change this name/description by left clicking on this Program`nCreator=`nDate=%LocalTime%`nLastChange=`nProjectDescription=You can change this name/description by left clicking on this Program,%WhereToSave%\%FileName%\%FileName%.ptp
}

WriteNewProject(ProjectName,TaskCount,SaveFile)
{
	IniRead, SavedProgramName, %SaveFile%, ProgramInfo, ProgramName
	FormatTime, LocalTime,,ShortDate
	FileAppend,`n[%ProjectName%]`nProjectTitle=%ProjectName%`nCreator=%A_User%`nDate=%LocalTime%`nLastChange=%LocalTime%`nProjectDescription=You can change this name/description by left clicking on this project and selecting Change Description/Change Name`nProjectNotes=`nProjectReminder=`nTasks= New Task %TaskCount%`nTask1=New Task %TaskCount%`nTaskDescription1=You can change this name/description by left clicking on this project and selecting Change Description/Change Name`nProgressTracker1=0,%SaveFile%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%ProjectName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%ProjectName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%ProjectName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK%ProjectName%
}

WriteNewTask(TaskName,ProjectName,SaveFile) 
{
	IniRead, TaskList, %SaveFile%, %ProjectName%, Tasks
	Loop, Parse, TaskList, `|
	{
		TaskAmount = %A_Index%
	}
	;TaskAmount +=1
	IniWrite, %TaskName%, %SaveFile%, %ProjectName%, Task%TaskAmount%
	IniWrite, You can change this name/description by left clicking on this task, %SaveFile%, %ProjectName%, TaskDescription%TaskAmount%
	IniWrite, 0, %SaveFile%, %ProjectName%, ProgressTracker%TaskAmount%
	IniRead, SavedProgramName, %SaveFile%, ProgramInfo, ProgramName
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%TaskName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%TaskName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%TaskName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%TaskName%
	FileCreateDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%TaskName%
}

ChangeName(SelectedItem,ProjectName,SaveFile,ProjectOrTask)
{
	FormatTime, LocalTime,,ShortDate
	InputBox, NewItemName, Change Name, Choose a new name for this item,,250,125
	if ErrorLevel = 1
	{
		return
	}
	if NewItemName =
	{
		MsgBox 16, Warning, Item Name cannot be empty!
		return
	}
	if ProjectOrTask = 1
	{
		IniRead, TaskList, %SaveFile%, %ProjectName%, Tasks
		Loop, Parse, TaskList, `|
		{
			if A_LoopField = %SelectedItem%
			{
				TaskNumber = %A_Index%
				IniWrite, %NewItemName%, %SaveFile%, %ProjectName%, Task%TaskNumber%
			}
		}
		StringReplace, TaskList, TaskList, %SelectedItem%, %NewItemName%
		;// Changing task name inside Tag File
		FileRead, TempTagFile, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl
		StringReplace, TempTagFile, TempTagFile, %SelectedItem%, %NewItemName%, All
		FileDelete, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl
		FileAppend, %TempTagFile%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl
		;\\
		IniWrite, %TaskList%, %SaveFile%, %ProjectName%, Tasks
		IniRead, SavedProgramName, %SaveFile%, ProgramInfo, ProgramName
		FileMove, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%SelectedItem%.ptl, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%NewItemName%.ptl, 1
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%NewItemName%, R
		FileMove, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%SelectedItem%.ptl, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%NewItemName%.ptl, R
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%NewItemName%, R
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%NewItemName%, R
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%NewItemName%, R
		IniWrite, %LocalTime%, %SaveFile%, %ProjectName%, LastChange
	}
	if ProjectOrTask = 0
	{
		IniRead, ProjectList, %SaveFile%, ProgramInfo, Projects
		StringReplace, ProjectList, ProjectList, %SelectedItem%, %NewItemName%
		;// Changing task name inside Tag File
		FileRead, TempTagFile, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl
		StringReplace, TempTagFile, TempTagFile, %SelectedItem%, %NewItemName%, All
		FileDelete, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl
		FileAppend, %TempTagFile%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Tags.ptl
		;\\
		IniWrite, %ProjectList%, %SaveFile%, ProgramInfo, Projects
		FileRead, SaveFileString, %SaveFile%
		StringReplace, SaveFileString, SaveFileString, %SelectedItem%, %NewItemName%
		FileDelete, %SaveFile%
		FileAppend, %SaveFileString%, %SaveFile%
		IniWrite, %NewItemName%, %SaveFile%, %NewItemName%, ProjectTitle
		IniWrite, %LocalTime%, %SaveFile%, %NewItemName%, LastChange
		FileMove, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%SelectedItem%.ptl, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%NewItemName%.ptl, 1
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%NewItemName%, R
		FileMove, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%SelectedItem%.ptl, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\%NewItemName%.ptl, R
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\IMG\%NewItemName%, R
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\FILE\%NewItemName%, R
		FileMoveDir, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%SelectedItem%, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Misc\LINK\%NewItemName%, R
	}
	if ProjectOrTask = 2
	{
		IniWrite, %NewItemName%, %SaveFile%, ProgramInfo , ProgramName
		FileRead, SaveFileString, %SaveFile%
		StringReplace, SaveFileString, SaveFileString, %SelectedItem%, %NewItemName%
		IniWrite, %NewItemName%, %SaveFile%, %NewItemName%, ProjectTitle
		IniWrite, %LocalTime%, %SaveFile%, %NewItemName%, LastChange
	}
}

WriteUpdate(Title,Description,Tags,SaveFile)
{
	;global
	IniWrite, %Title%, %SaveFile%, UpdateInfo, UpdateTitle
	IniWrite, %A_Now%, %SaveFile%, UpdateInfo, UpdateTime
	IniWrite, A_User, %SaveFile%, UpdateInfo, UpdateUser
	;IniWrite, %Tags%, %SaveFile%, UpdateInfo, UpdateTags
	StringReplace, Description, Description, `n, |, All
	IniWrite, %Description%, %SaveFile%, UpdateContent, UpdateDescription
}

RefreshUpdateList(SelectedItem,SavedProgramName,ParentName,SaveFile)
{
	IniRead, TaskList, %SaveFile%, %ParentName%, Tasks
	Loop, Parse, TaskList, `|
	{
		TaskAmount = %A_Index%
	}
	IniRead, SelectedTaskTitle, %SaveFile%, %ParentName%, Task%TaskAmount%
	UpdateListPath=%A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Updates\%SelectedItem%.ptl
	CSV_Load(UpdateListPath,"UpdateListCSV",",")
	UpdateAmount:=CSV_TotalRows("UpdateListCSV")
	LV_Delete()
	Loop, %UpdateAmount%
	{
		RowNum=%A_Index%
		UpdateListTitle:=CSV_ReadCell("UpdateListCSV",RowNum,1)
		UpdateListPercentage:=CSV_ReadCell("UpdateListCSV",RowNum,2)
		UpdateListTime:=CSV_ReadCell("UpdateListCSV",RowNum,3)
		UpdateListConvertedTime:=CSV_ReadCell("UpdateListCSV",RowNum,4)
		UpdateListUpdateFile:=CSV_ReadCell("UpdateListCSV",RowNum,5)
		LV_Add("",UpdateListTitle,UpdateListPercentage,UpdateListTime,UpdateListConvertedTime,UpdateListUpdateFile)
		LV_ModifyCol(3, "SortDesc")
	}
}

RefreshNoteList(SelectedItem)
{
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	GuiControl,,NotesListBox, |
	IniRead, NoteList, %A_MyDocuments%\ProgressTracker\ProgramData\%SavedProgramName%\Notes\%SelectedItem%.ptl, NoteInfo, NoteList
	Loop, parse, NoteList, `|
	{
		if A_LoopField = ERROR
		{
			Break
		}
		GuiControl,,NotesListBox, %A_LoopField%
	}
	return
}

RefreshMiscList()
{
	
}

LoadTags(TagFile)
{
	LV_Delete()
	IniRead, TagList, %TagFile%, TagInfo, Tags
	Loop, Parse, TagList, `|
	{
		TaskAmount = %A_Index%
		LV_Add("-Check",A_LoopField)
	}
}

AddNewTag(TagFile)
{
	InputBox, NewTagName, Add a new tag, Choose a name for the new tag`nAvoid using any special character(s),,240,140
	if ErrorLevel = 1
	{
		return
	}
	if NewTagName =
	{
		MsgBox 16, Warning, Item Name cannot be empty!
		return
	}
	StringReplace, NewTagName, NewTagName,`n,-
	IniRead, CurrentTags, %TagFile%, TagInfo, Tags
	IniWrite, %CurrentTags%|%NewTagName%, %TagFile%, TagInfo, Tags
}

AddToTagDir(TagToAdd,ParentName,DataName,TagFile,TagHolder)
{
	IniRead, TagList, %TagFile%, TagInfo, Tags
	Loop, Parse, TagList, |
	{
		if A_LoopField = %TagToAdd%
		{
			TagNum = %A_Index%
		}
	}
	if TagHolder = 1
	{
		IniRead, TagTaskList, %TagFile%, Tag%TagNum%, tasks
		if (TagTaskList ="")
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, tasks
		}
		else
		{
			IniWrite, %TagTaskList%|%DataName%`@%ParentName%, %TagFile%, Tag%TagNum%, tasks
		}
	}
	if TagHolder = 2
	{
		IniRead, TagNoteList, %TagFile%, Tag%TagNum%, notes
		if (TagNoteList = )
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, notes
		}
		if (TagNoteList ="ERROR")
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, notes
		}
		if (TagNoteList ="")
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, notes
		}
		else
		{
			IniWrite, %TagNoteList%|%ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, notes
		}
	}
	if TagHolder = 3
	{
		IniRead, TagReminderList, %TagFile%, Tag%TagNum%, reminders
		if (TagReminderList ="")
		{
			IniWrite, %ItemName%, %TagFile%, Tag%TagNum%, reminders
		}
		else
		{
			IniWrite, |%ItemName%, %TagFile%, Tag%TagNum%, reminders
		}	
	}
	if TagHolder = 4
	{
		IniRead, TagMiscList, %TagFile%, Tag%TagNum%, misc
		if (TagNoteList = )
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, misc
		}
		if (TagNoteList ="ERROR")
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, misc
		}
		if (TagOtherList ="")
		{
			IniWrite, %ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, misc
		}
		else
		{
			IniWrite, %TagMiscList%|%ItemName%`@%DataName%, %TagFile%, Tag%TagNum%, misc
		}	
	}
}

OpenImageDescriptor(ImageAddress)
{
	Global
	gui, ImageDescriptor:New,, Image Descriptor
	gui, +ToolWindow ; +AlwaysOnTop +Resize
	;gui, Add, GroupBox,w290 h290,Image
	;gui, Add, Picture,x15 y25 w280 h-1,%ImageAddress% 
	gui, Add, GroupBox, y6 w305 h290,Info
	gui, Font, s10
	gui, Add, Text, x20 y25, Name:
	gui, Add, Edit, yp-2 xp+42 w243 vImgName
	gui, Add, Text, x20 yp+30 , Description:
	gui, Add, Edit, w285 h180 yp+20 vImgDesc
	gui, Add, Button, w220 gSaveImage,Save Image
	gui, Add, Button, xp+220 yp w66 gTagsButton,Tags
	gui, Show, w325 h300, Image Descriptor
}