; /// Tracker Library ///

BoiBox(DebugText)
{
	MsgBox, BOI`n%DebugText%
}

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
	Menu, MainMenuBar, Disable, &Help
}

EnableAllMenus()
{
	Menu, MainMenuBar, Enable, &File
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
	IniRead, SavedProgramName, %CurrentSaveFile%, ProgramInfo, ProgramName
	Loop, Parse, TaskList, `|
	{
		if A_LoopField = %Selected%
		{
			LV_Delete()
			GuiControl,, UpdateTitle, Update Title
			GuiControl,, UpdateDescription, Update Description
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
		}
		IniRead, ProjectList, %SaveFile%, ProgramInfo, Projects
		IfInString, ProjectList, %Selected%
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
	LV_Delete()
	GuiControl,, UpdateTitle, Update Title
	GuiControl,, UpdateDescription, Update Description
	;GuiControl,Disable, UpdateListView
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
	;ProgressSum = 0
	Loop, Parse, TaskList, `|
	{
		IniRead, TaskProgress, %SaveFile%, %ProjectName%, ProgressTracker%A_Index%
		ProgressSum += %TaskProgress%
	}
	GuiControl,+Range0-%TaskProgressTotalRange%, ProgressBar
	GuiControl,, ProgressBar, %ProgressSum%
}

DeleteProject(ProjectName,SaveFile)
{
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
}

DeleteTask(ProjectName,TaskName,SaveFile)
{
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
	FormatTime, LocalTime, ,ShortDate
	FileAppend ,[ProgramInfo]`nProgramName=%FileName%`nCreator=%A_UserName%`nCreatorVersion=`nProjects=`n[%FileName%]`nProjectTitle=%FileName%]`nProjectDescription=You can change this name/description by left clicking on this Program`nCreator=`nDate=%LocalTime%`nLastChange=`nProjectDescription=You can change this name/description by left clicking on this Program,%WhereToSave%\%FileName%\%FileName%.ptp
}	

WriteNewProject(ProjectName,TaskCount,SaveFile)
{
	FormatTime, LocalTime,,ShortDate
	FileAppend,`n[%ProjectName%]`nProjectTitle=%ProjectName%`nCreator=%A_User%`nDate=%LocalTime%`nLastChange=%LocalTime%`nProjectDescription=You can change this name/description by left clicking on this project and selecting Change Description/Change Name`nProjectNotes=`nProjectReminder=`nTasks= New Task %TaskCount%`nTask1=New Task %TaskCount%`nTaskDescription1=You can change this name/description by left clicking on this project and selecting Change Description/Change Name`nProgressTracker1=0,%SaveFile%
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
}

ChangeName(SelectedItem,ProjectName,SaveFile,ProjectOrTask)
{
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
		IniWrite, %TaskList%, %SaveFile%, %ProjectName%, Tasks
	}
	if ProjectOrTask = 0
	{
		IniRead, ProjectList, %SaveFile%, ProgramInfo, Projects
		StringReplace, ProjectList, ProjectList, %SelectedItem%, %NewItemName%
		IniWrite, %ProjectList%, %SaveFile%, ProgramInfo, Projects
		FileRead, SaveFileString, %SaveFile%
		StringReplace, SaveFileString, SaveFileString, %SelectedItem%, %NewItemName%
		FileDelete, %SaveFile%
		FileAppend, %SaveFileString%, %SaveFile%
		IniWrite, %NewItemName%, %SaveFile%, %NewItemName%, ProjectTitle
	}
	if ProjectOrTask = 2
	{
		IniWrite, %NewItemName%, %SaveFile%, ProgramInfo , ProgramName
		FileRead, SaveFileString, %SaveFile%
		StringReplace, SaveFileString, SaveFileString, %SelectedItem%, %NewItemName%
		IniWrite, %NewItemName%, %SaveFile%, %NewItemName%, ProjectTitle
	}
}

WriteUpdate(Title,Description,Tags,SaveFile)
{
	global
	IniWrite, %Title%, %SaveFile%, UpdateInfo, UpdateTitle
	IniWrite, %A_Now%, %SaveFile%, UpdateInfo, UpdateTime
	IniWrite, A_User, %SaveFile%, UpdateInfo, UpdateUser
	IniWrite, %Tags%, %SaveFile%, UpdateInfo, UpdateTags
	IniWrite, %Description%, %SaveFile%, UpdateContent, UpdateDescription
}

RefreshUpdateList(SavedProgramName,ParentName,SaveFile)
{
	IniRead, TaskList, %SaveFile%, %ParentName%, Tasks
	Loop, Parse, TaskList, `|
	{
		TaskAmount = %A_Index%
	}
	IniRead, SelectedTaskTitle, %SaveFile%, %ParentName%, Task%TaskAmount%
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
}