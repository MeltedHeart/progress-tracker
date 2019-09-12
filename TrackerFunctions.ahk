; /// Tracker Library ///

BoiBox()
{
	MsgBox, BOI
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
	Loop, Parse, TaskList, `|
	{
		if A_LoopField = %Selected%
		{
			IniRead, ProgressBarPercent, %SaveFile%, %ParentName%, ProgressTracker%A_Index%
			GuiControl,,ProgressBar, %ProgressBarPercent%
			IniRead, SelectedTaskDescription, %SaveFile%, %ParentName%, TaskDescription%A_Index%
			GuiControl,,MainDescriptionText, %SelectedTaskDescription%
			IniRead, SelectedTaskTitle, %SaveFile%, %ParentName%, Task%A_Index%
			;IniRead, SelectedProjectCreator, %CurrentSaveFile%, %TVItemName%, ProjectCreator //Placeholder for collaboration in the future
			IniRead, SelectedTaskDate, %SaveFile%, %ParentName%, Date
			IniRead, SelectedTaskLastChange, %SaveFile%, %ParentName%, LastChange
			GuiControl,,MainPropertiesText, Title: %SelectedTaskTitle%`nCreator: %CurrentUser%`nDate: %SelectedTaskDate%`nLast Change: %SelectedTaskLastChange%
		}
	}
}

CreateTempFile(WhereToSave)
{
	FileDelete,  %A_temp%\ProgressTracker\New_File.ptp
	FormatTime, Localtiem, ,ShortDate
	FileAppend ,[ProgramInfo]`nProgramName=New Program`nCreator=`nCreatorVersion=`nProjects=`n[Program1]`nCreator=`nDate=%Localtiem%`nLastChange=`nProjectDescription=,%A_temp%\ProgressTracker\New_File.ptp
}	

WriteNewProject(ProjectName,Count,SaveFile)
{
	FormatTime, LocalTime,,ShortDate
	FileAppend,`n[%ProjectName%]`nProjectTitle=%ProjectName%`nCreator=%A_User%`nDate=%LocalTime%`nLastChange=%LocalTime%`nProjectDescription=You can change this name/description by left clicking on this project and selecting Change Description/Change Name`nProjectNotes=`nProjectReminder=`nTasks= New Task %Count%`nTask%Count%=New Task %Count%`nTaskDescription1=You can change this name/description by left clicking on this project and selecting Change Description/Change Name`nProgressTracker1=0,%SaveFile%
}